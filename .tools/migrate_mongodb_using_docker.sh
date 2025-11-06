#!/usr/bin/env bash
set -euo pipefail

# migrate_mongodb_using_docker.sh
# Usage:
#   ./migrate_mongodb_using_docker.sh /absolute/path/to/mongo_data /absolute/path/to/dump [old_image_tag] [target_container]
#
# - DATA_DIR: path on the host where the existing MongoDB data directory lives (e.g. /srv/pterodactyl/bots/nodemongo/mongodb)
# - DUMP_DIR: path on the host where the mongodump output will be written
# - old_image_tag (optional): docker image tag to use for the old server (default: "mongo:7")
# - target_container (optional): name of a running target container (8.2) to restore into; if provided the script will run mongorestore inside that container

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 DATA_DIR DUMP_DIR [old_image_tag] [target_container]"
  exit 2
fi

DATA_DIR="$1"
DUMP_DIR="$2"
OLD_IMAGE="${3:-mongo:7}"
TARGET_CONTAINER="${4:-}"

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DUMP_SUBDIR="dump_${TIMESTAMP}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker CLI not found. Install Docker and ensure your user can run docker commands." >&2
  exit 3
fi

if [ ! -d "$DATA_DIR" ]; then
  echo "Data directory does not exist: $DATA_DIR" >&2
  exit 4
fi

mkdir -p "$DUMP_DIR"

echo "Starting temporary MongoDB (${OLD_IMAGE}) using host data: $DATA_DIR"

# Run a temporary container that mounts the host data dir as /data/db and exposes a dump dir
CONTAINER_NAME="mongo_migrate_temp_${TIMESTAMP}"
docker run --name "$CONTAINER_NAME" -v "$DATA_DIR":/data/db:rw -v "$DUMP_DIR":/dump:rw -d "$OLD_IMAGE" --bind_ip_all || {
  echo "Failed to start temporary MongoDB container from image $OLD_IMAGE" >&2
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
  exit 5
}

echo "Waiting for MongoDB to accept connections inside container $CONTAINER_NAME..."
for i in $(seq 1 30); do
  if docker exec "$CONTAINER_NAME" bash -lc "(mongosh --eval 'db.runCommand({ping:1})' >/dev/null 2>&1) || (mongo --eval 'db.runCommand({ping:1})' >/dev/null 2>&1)"; then
    echo "MongoDB is ready (attempt $i)"
    break
  fi
  sleep 2
  if [ "$i" -eq 30 ]; then
    echo "Timed out waiting for temporary MongoDB to become ready. Check container logs: docker logs $CONTAINER_NAME" >&2
    docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
    exit 6
  fi
done

echo "Running mongodump inside temporary container to: /dump/$DUMP_SUBDIR"
docker exec "$CONTAINER_NAME" bash -lc "mkdir -p /dump/$DUMP_SUBDIR && (mongodump --out /dump/$DUMP_SUBDIR || mongodump --archive=/dump/$DUMP_SUBDIR.archive)" || {
  echo "mongodump failed inside $CONTAINER_NAME. See logs." >&2
  docker logs "$CONTAINER_NAME" || true
  docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
  exit 7
}

echo "Dump completed. Stopping and removing temporary container $CONTAINER_NAME"
docker rm -f "$CONTAINER_NAME" >/dev/null || true

ABS_DUMP_PATH="$(cd "$DUMP_DIR" && pwd)/$DUMP_SUBDIR"
echo "Database dumped to: $ABS_DUMP_PATH"

if [ -n "$TARGET_CONTAINER" ]; then
  echo "Target container specified: $TARGET_CONTAINER - attempting restore into that running container"
  if ! docker ps --format '{{.Names}}' | grep -qx "$TARGET_CONTAINER"; then
    echo "Target container '$TARGET_CONTAINER' not found in running containers." >&2
    echo "You can restore later with: docker exec -it <target_container> mongorestore /path/to/dump" >&2
    exit 8
  fi

  # Copy dump into target container /tmp/mongo_restore_<ts>
  TMP_REMOTE_DIR="/tmp/mongo_restore_${TIMESTAMP}"
  echo "Copying dump into target container at $TMP_REMOTE_DIR"
  docker cp "$ABS_DUMP_PATH" "$TARGET_CONTAINER":"$TMP_REMOTE_DIR" || {
    echo "docker cp failed" >&2
    exit 9
  }

  echo "Running mongorestore inside $TARGET_CONTAINER"
  docker exec "$TARGET_CONTAINER" bash -lc "mongorestore --drop $TMP_REMOTE_DIR/$DUMP_SUBDIR || ( [ -f $TMP_REMOTE_DIR/*.archive ] && mongorestore --archive=$TMP_REMOTE_DIR/*.archive )" || {
    echo "mongorestore failed inside $TARGET_CONTAINER" >&2
    exit 10
  }

  echo "Restore completed inside container $TARGET_CONTAINER"
  echo "Cleaning temporary files inside target container"
  docker exec "$TARGET_CONTAINER" rm -rf "$TMP_REMOTE_DIR" || true
fi

echo "Migration script finished. Verify your application connects to the new MongoDB server and test data integrity."