# GitHub Actions für Pelican GamePanel Images

Dieses Repository enthält automatisierte GitHub Actions Workflows zur Überprüfung und Wartung der Docker Images für das Pelican GamePanel.

## 🚀 Workflows Overview

### 1. 🔒 Security & Quality Audit (`security-audit.yml`)

**Zweck:** Umfassende Sicherheits- und Qualitätsprüfung aller Dockerfiles und Shell-Skripte

**Auslöser:**
- Push auf `main` oder `develop` Branch
- Pull Requests auf `main`
- Jeden Montag um 06:00 UTC (geplant)
- Manuell über GitHub UI

**Was wird geprüft:**
- **ShellCheck:** Syntax und Best Practices für Shell-Skripte
- **Dockerfile Lint:** Hadolint für Dockerfile-Standards
- **Vulnerability Scanning:** Trivy für bekannte Sicherheitslücken
- **Package Updates:** Erkennung veralteter Pakete
- **Pelican-spezifische Checks:** GamePanel-Kompatibilität

### 2. 🏗️ Build & Test (`build-test.yml`)

**Zweck:** Automatisches Bauen und Testen von geänderten Images

**Auslöser:**
- Änderungen an Dockerfiles oder entrypoint.sh
- Pull Requests
- Manuell

**Features:**
- **Multi-Platform Builds:** AMD64 und ARM64
- **Smoke Tests:** Grundlegende Funktionalitätstests
- **Game-spezifische Tests:** Java, Node.js, Python Umgebungen
- **Container Registry:** Automatisches Pushen nach GHCR
- **Caching:** Build-Cache für schnellere Builds

### 3. 📅 Scheduled Maintenance (`maintenance.yml`)

**Zweck:** Regelmäßige Wartung und Überwachung

**Auslöser:**
- Jeden Sonntag um 02:00 UTC
- Manuell mit Option für Force-Rebuild

**Funktionen:**
- **Base Image Updates:** Erkennung neuer Versionen
- **Security Scanning:** Wöchentliche Vulnerability-Checks
- **Dependency Updates:** Package-Versions-Überwachung
- **Maintenance Reports:** Automatische Berichte
- **Issue Creation:** Automatische Issues bei kritischen Problemen

## 🔧 Setup & Konfiguration

### Erforderliche Secrets

Keine speziellen Secrets erforderlich - die Workflows nutzen den automatischen `GITHUB_TOKEN`.

### Aktivierung

1. Workflows sind automatisch aktiv nach dem Commit
2. Berechtigung für GitHub Container Registry wird automatisch gewährt
3. Erste Ausführung kann manuell getriggert werden

## 📊 Berichte & Outputs

### Artifacts
- **Security Reports:** Detaillierte Sicherheitsberichte (30 Tage Aufbewahrung)
- **Build Reports:** Build-Status und Test-Ergebnisse (7 Tage)
- **Maintenance Reports:** Wartungsberichte (90 Tage)

### SARIF Integration
- Hadolint und Trivy Ergebnisse werden in GitHub Security Tab angezeigt
- Code-Scanning Alerts für gefundene Probleme

## 🎮 Pelican GamePanel Spezifika

### Geprüfte Aspekte
- **Container User:** Existenz und Konfiguration des `container` Users
- **Home Directory:** `/home/container` Setup
- **STARTUP Variable:** Verarbeitung von Pelican STARTUP Befehlen
- **Signal Handling:** Korrekte `exec` Verwendung
- **Environment Variables:** Pelican-spezifische Variablen

### Image-Kategorien
- **Java:** OpenJDK/Corretto/Temurin Versionen
- **Node.js/Bots:** Node.js Versionen und Bot-Frameworks
- **Python:** Python Umgebungen
- **Databases:** MySQL, PostgreSQL, MongoDB, Redis
- **Games:** Spiel-spezifische Images
- **Development:** Entwicklungsumgebungen

## 🔍 Monitoring & Alerts

### Automatische Issue Creation
Bei kritischen Sicherheitsproblemen werden automatisch GitHub Issues erstellt mit:
- Detaillierte Problembeschreibung
- Betroffene Images
- Empfohlene Lösungsschritte
- Links zu Reports

### Pull Request Comments
Automatische Kommentare in PRs mit:
- Build-Status
- Test-Ergebnisse
- Sicherheitsprüfungen

## 🛠️ Anpassung der Workflows

### Image-spezifische Tests hinzufügen

```yaml
# In build-test.yml unter "Test specific game requirements"
case "${{ matrix.image_type }}" in
  "your-new-type")
    echo "🎯 Testing your specific requirements"
    # Ihre Tests hier
    ;;
esac
```

### Zusätzliche Sicherheitschecks

```yaml
# In security-audit.yml unter "Custom Dockerfile Security Checks"
if grep -q "YOUR_PATTERN" "$DOCKERFILE"; then
  echo "⚠️ Your custom security warning"
fi
```

## 📈 Performance Optimierung

### Build Cache
- GitHub Actions Cache für Docker Layers
- Reduziert Build-Zeiten erheblich
- Automatische Cache-Invalidierung bei Änderungen

### Matrix Strategy
- Parallele Builds für verschiedene Images
- Fail-fast deaktiviert für vollständige Übersicht
- Limit auf 30 Images um Kosten zu kontrollieren

## 🚨 Troubleshooting

### Häufige Probleme

1. **Build Failures**
   - Prüfen Sie Dockerfile Syntax
   - Überprüfen Sie Base Image Verfügbarkeit
   - Logs in GitHub Actions Tab ansehen

2. **Security Scan Failures**
   - Kritische Vulnerabilities in Base Images
   - Veraltete Pakete
   - Siehe Security Tab für Details

3. **Test Failures**
   - Container startet nicht
   - Fehlende Dependencies
   - Falsche User/Permission Setup

### Debugging

```bash
# Lokale Reproduktion von Builds
docker build -f path/to/Dockerfile .

# Lokale Sicherheitsprüfung
trivy image your-image:tag

# Shell-Skript Prüfung
shellcheck path/to/entrypoint.sh
```

## 📚 Weitere Ressourcen

- [GitHub Actions Dokumentation](https://docs.github.com/actions)
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Pelican Panel Dokumentation](https://pelican.dev/)
- [Container Security](https://docs.docker.com/develop/security-best-practices/)

## 🤝 Beitragen

1. Fork das Repository
2. Erstellen Sie einen Feature Branch
3. Actions werden automatisch getriggert
4. PR erstellen mit Workflows Checks

Alle Workflows sind so konfiguriert, dass sie sowohl für Maintainer als auch für Contributors funktionieren.