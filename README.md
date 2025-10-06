# 🚀 Checkmate interaktives Setup Script mit Let's Encrypt 

Ein interaktives Setup-Script für Checkmate (Uptime Monitoring) mit automatischer Docker-Installation und Let's Encrypt SSL.

## ✨ Features

- 🎨 **Coole ASCII-Art** Header
- 🌈 **Bunte Farbausgaben** für bessere Lesbarkeit  
- 🔧 **Automatische Docker Installation** (Ubuntu/Debian/CentOS/RHEL/Fedora)
- 🔍 **Automatische /etc/hosts Bereinigung** für DNS-Probleme
- 📋 **Automatische Checks** für alle Voraussetzungen
- ⚙️ **Interaktive Konfiguration** mit Validierung
- 🔐 **Automatische Secret Key-Generierung**
- 🌐 **DNS-Überprüfung** vor dem Start
- 📝 **Automatische Dateierstellung** (docker-compose.yml, .env, .gitignore)
- 🚀 **Optionaler sofortiger Start** der Container

## 🎯 Voraussetzungen

- **Linux-System** (Ubuntu, Debian, CentOS, RHEL oder Fedora)
- **Root/Sudo-Zugriff** für Docker Installation
- **Domain** die auf deinen Server zeigt (A-Record)
- **Offene Ports** 80 und 443

## 📦 Was wird installiert?

### Checkmate Stack:
- **Nginx Proxy** - Automatisches Reverse Proxying
- **Let's Encrypt** - Automatische SSL-Zertifikate
- **Checkmate Backend** (`ghcr.io/bluewave-labs/checkmate-backend-mono`)
- **MongoDB** (`ghcr.io/bluewave-labs/checkmate-mongo`)

### Optional (falls nicht vorhanden):
- Docker CE (Community Edition)
- Docker CLI
- containerd.io
- Docker Buildx Plugin
- Docker Compose Plugin

## 🚀 Verwendung

### 1. Script herunterladen und ausführbar machen

```bash
chmod +x setup.sh
```

### 2. Script ausführen

```bash
./setup.sh
```

### 3. Den Anweisungen folgen

Das Script führt dich durch folgende Schritte:

1. **Voraussetzungen prüfen**
   - Docker Installation prüfen (oder installieren)
   - Docker Compose prüfen (oder installieren)
   - Docker Daemon Status prüfen

2. **Konfiguration**
   - Domain eingeben
   - E-Mail-Adresse eingeben
   - Passwort generieren oder eingeben
   - Port festlegen (Standard: 3000)

3. **Zusammenfassung & Bestätigung**

4. **Dateien erstellen**
   - docker-compose.yml
   - .env mit deinen Einstellungen
   - .gitignore

5. **DNS-Überprüfung**
   - Prüft ob deine Domain korrekt konfiguriert ist
   - Vergleicht DNS-Auflösung mit Server-IP

6. **Container starten** (optional)
   - Startet alle Container mit `docker-compose up -d`

## 🔑 Wichtige Hinweise zur Docker Installation

### Nach der Installation:

1. **Neuanmeldung erforderlich**: Nach der Docker-Installation musst du dich möglicherweise neu anmelden, damit die Gruppenberechtigungen wirksam werden:
   ```bash
   # Entweder neu anmelden oder:
   newgrp docker
   ```

2. **Teste Docker**:
   ```bash
   docker run hello-world
   ```

3. **Ohne sudo verwenden**: Nach der Neuanmeldung kannst du Docker ohne sudo nutzen

## 📝 Erstellte Dateien

Nach dem Setup findest du folgende Dateien:

- `docker-compose.yml` - Docker Compose Konfiguration
- `.env` - Umgebungsvariablen (NICHT in Git committen!)
- `.gitignore` - Git Ignore Datei

## 🛠️ Nützliche Befehle nach dem Setup

```bash
# Container Status anzeigen
docker-compose ps

# Logs anzeigen (alle Container)
docker-compose logs -f

# Logs eines bestimmten Containers
docker-compose logs -f checkmate
docker-compose logs -f nginx-proxy
docker-compose logs -f letsencrypt

# Container neustarten
docker-compose restart

# Container stoppen
docker-compose down

# Container stoppen und Volumes löschen (VORSICHT!)
docker-compose down -v

# Container aktualisieren
docker-compose pull
docker-compose up -d
```

## 🔍 Troubleshooting

### Docker Installation schlägt fehl

**Problem**: Installation bricht mit Fehler ab

**Lösung**:
1. Prüfe deine Internetverbindung
2. Stelle sicher, dass du sudo-Rechte hast
3. Prüfe `/var/log/apt/` (Ubuntu/Debian) oder `/var/log/yum.log` (CentOS/RHEL)
4. Installiere Docker manuell: https://docs.docker.com/get-docker/

### SSL-Zertifikat wird nicht erstellt

**Problem**: Kein HTTPS nach 5-10 Minuten

**Lösung**:
1. Prüfe DNS-Auflösung:
   ```bash
   nslookup deine-domain.de
   ```

2. Prüfe Firewall:
   ```bash
   sudo ufw status  # Ubuntu
   sudo firewall-cmd --list-all  # CentOS
   ```

3. Prüfe Let's Encrypt Logs:
   ```bash
   docker-compose logs letsencrypt
   ```

### Docker Daemon startet nicht

**Problem**: Docker läuft nicht

**Lösung**:
```bash
# Status prüfen
sudo systemctl status docker

# Docker starten
sudo systemctl start docker

# Docker beim Systemstart aktivieren
sudo systemctl enable docker

# Logs prüfen
sudo journalctl -u docker -f
```

### Checkmate startet nicht

**Problem**: Container beendet sich sofort

**Lösung**:
1. Prüfe Logs:
   ```bash
   docker-compose logs checkmate
   ```

2. Prüfe Datenbankverbindung:
   ```bash
   docker-compose exec checkmate-db psql -U checkmate -d checkmate
   ```

3. Prüfe Umgebungsvariablen in `.env`

### Permission Denied Fehler

**Problem**: Keine Berechtigung für Docker-Befehle

**Lösung**:
```bash
# Benutzer zur Docker-Gruppe hinzufügen
sudo usermod -aG docker $USER

# Neu anmelden oder:
newgrp docker

# Teste
docker run hello-world
```

## 🔐 Sicherheitshinweise

- ✅ Ändere **alle** Standard-Passwörter
- ✅ Verwende **starke, zufällige** Passwörter
- ✅ Halte deine **Docker-Images aktuell**
- ✅ Erstelle **regelmäßig Backups**
- ✅ Beschränke den Zugriff auf sensible Ports
- ✅ Die `.env` Datei **NIEMALS** in Git committen
- ✅ Verwende **Firewall-Regeln** (nur 80/443 öffentlich)

## 💾 Backup & Restore

### Datenbank Backup erstellen

```bash
# Backup erstellen
docker-compose exec checkmate-db pg_dump -U checkmate checkmate > backup_$(date +%Y%m%d_%H%M%S).sql

# Backup mit Kompression
docker-compose exec checkmate-db pg_dump -U checkmate checkmate | gzip > backup_$(date +%Y%m%d_%H%M%S).sql.gz
```

### Datenbank Restore

```bash
# Aus normalem Backup
docker-compose exec -T checkmate-db psql -U checkmate checkmate < backup.sql

# Aus komprimiertem Backup
gunzip < backup.sql.gz | docker-compose exec -T checkmate-db psql -U checkmate checkmate
```

### Vollständiges Backup (inkl. Volumes)

```bash
# Container stoppen
docker-compose down

# Volumes sichern
sudo tar czf checkmate_volumes_$(date +%Y%m%d).tar.gz \
    /var/lib/docker/volumes/checkmate-db-data \
    /var/lib/docker/volumes/checkmate-data

# Container wieder starten
docker-compose up -d
```

## 📊 Überwachung

### Container-Status überwachen

```bash
# Ressourcenverbrauch anzeigen
docker stats

# Nur Checkmate Container
docker stats checkmate checkmate-db

# Speicherplatz prüfen
docker system df
```

## 🔄 Updates

### Checkmate aktualisieren

```bash
# Images aktualisieren
docker-compose pull

# Container mit neuen Images neu starten
docker-compose up -d

# Alte Images aufräumen
docker image prune -a
```

## 🎓 Unterstützte Betriebssysteme

- ✅ Ubuntu 20.04, 22.04, 24.04
- ✅ Debian 10, 11, 12
- ✅ CentOS 7, 8, 9
- ✅ RHEL 7, 8, 9
- ✅ Fedora 37+


Bei Problemen:

1. Prüfe die Logs: `docker-compose logs -f`
2. Prüfe die Checkmate-Dokumentation
3. Öffne ein Issue im Checkmate Repository

## 📄 Lizenz

Dieses Setup-Script ist frei verwendbar.

---

**Erstellt von:** Andreas Höfler  
**Version:** 1.0  
**Datum:** Oktober 2025

---

## ⭐ Viel Erfolg mit deinem Checkmate Setup!
