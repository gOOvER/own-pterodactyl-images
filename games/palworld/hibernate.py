import subprocess
import time
import os

SERVER_PORT = int(os.environ.get('SERVER_PORT', '27019'))
RCON_PORT = int(os.environ.get('RCON_PORT', '25575'))
ADMIN_PASSWORD = os.environ.get('ADMIN_PASSWORD', '3h29v7g7g75')
TMUX_SESSION = "palworld_server"

def check_players():
    players_output = run_command(
        f"/usr/local/bin/rcon -a 127.0.0.1:{RCON_PORT} -p {ADMIN_PASSWORD} ShowPlayers"
    )
    print(f"player: {players_output}")
    return players_output != "name,playeruid,steamid" and players_output.strip() != ""

def run_command(command):
    result = subprocess.run(
        command, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True, text=True
    )
    return result.stdout.strip()

def is_server_running():
    return "PalServer-Win64-Shipping.exe" in run_command("ps aux")

def stop_server():
    if is_server_running():
        print("Sending shutdown command to server...")
        run_command(f"/usr/local/bin/rcon -a 127.0.0.1:{RCON_PORT} -p {ADMIN_PASSWORD} shutdown 10")
        
        for i in range(20):
            if not is_server_running():
                print("Server has shut down.")
                return
            time.sleep(1)
        
        print("Server didn't shut down in time. Killing the process.")
        run_command("pkill -f PalServer-Win64-Shipping.exe")
    else:
        print("Server is not running.")

def start_server():
    if not is_server_running():
        print("Starting server...")
        startup_command = os.environ.get('MODIFIED_STARTUP', '')
        
        subprocess.Popen(startup_command, shell=True)
        
        for i in range(60):
            if is_server_running():
                print("Server has started successfully.")
                return
            time.sleep(1)
        print("Server may have failed to start. Please check logs.")
    else:
        print("Server is already running.")

def detect_connection():
    capture_command = f"netstat -tna | grep -q ':{SERVER_PORT}.*ESTABLISHED'"
    return run_command(capture_command) == ""

def main():
    start_server()
    
    while True:
        if is_server_running():
            if not check_players():
                print("No players found. Stopping the server.")
                stop_server()
                print("Waiting for players to connect")
                while not detect_connection():
                    time.sleep(1)
                print("Connection attempt detected. Starting server.")
                start_server()
            else:
                print("Players found. Server will continue running.")
                time.sleep(60)
        else:
            print("Server is not running. Starting the server.")
            start_server()
        
        time.sleep(30)

if __name__ == "__main__":
    main()