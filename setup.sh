#!/bin/bash

# Farben definieren
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

# Funktion für animierte Ausgabe
print_animated() {
    text="$1"
    color="$2"
    for (( i=0; i<${#text}; i++ )); do
        echo -n "${color}${text:$i:1}${NC}"
        sleep 0.01
    done
    echo
}

# Funktion für Fortschrittsbalken
show_progress() {
    local duration=$1
    local steps=50
    local sleep_time=$(echo "scale=4; $duration / $steps" | bc)
    
    echo -ne "${CYAN}["
    for i in $(seq 1 $steps); do
        echo -ne "="
        sleep $sleep_time
    done
    echo -e "]${NC} ${GREEN}✓${NC}"
}

# Clear screen
clear

# ASCII Art Header
echo -e "${MAGENTA}"
cat << "EOF"
  _____ _               _                      _       
 / ____| |             | |                    | |      
| |    | |__   ___  ___| | ___ __ ___   __ _| |_ ___ 
| |    | '_ \ / _ \/ __| |/ / '_ ` _ \ / _` | __/ _ \
| |____| | | |  __/ (__|   <| | | | | | (_| | ||  __/
 \_____|_| |_|\___|\___|_|\_\_| |_| |_|\__,_|\__\___|
                                                       
        ____             _             
       |  _ \  ___   ___| | _____ _ __ 
       | | | |/ _ \ / __| |/ / _ \ '__|
       | |_| | (_) | (__|   <  __/ |   
       |____/ \___/ \___|_|\_\___|_|   
                                        
           ____       _               
          / ___|  ___| |_ _   _ _ __  
          \___ \ / __| __| | | | '_ \ 
           ___) | (__| |_| |_| | |_) |
          |____/ \___|\__|\__,_| .__/ 
                               |_|     
EOF
echo -e "${NC}"

echo -e "${CYAN}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${WHITE}     Checkmate Docker Setup mit Let's Encrypt         ${CYAN}║${NC}"
echo -e "${CYAN}║${YELLOW}                 Andreas Höfler                        ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

sleep 1

# Willkommensnachricht
print_animated "Willkommen! 👋" "$GREEN"
echo ""
print_animated "Dieses Script hilft dir bei der Einrichtung von Checkmate mit SSL." "$WHITE"
echo ""
sleep 1

# Funktion zur Docker Installation
install_docker() {
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${WHITE}🔧 Docker Installation${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # Betriebssystem erkennen
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
        VERSION=$VERSION_ID
    else
        echo -e "${RED}Kann Betriebssystem nicht erkennen!${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Erkanntes System: $OS $VERSION${NC}"
    echo ""
    
    case $OS in
        ubuntu|debian)
            echo -e "${CYAN}Installiere Docker für Ubuntu/Debian...${NC}"
            echo ""
            
            # Alte Versionen entfernen
            echo -ne "${CYAN}[1/6] Entferne alte Docker Versionen...${NC} "
            sudo apt-get remove -y docker docker-engine docker.io containerd runc &>/dev/null
            echo -e "${GREEN}✓${NC}"
            
            # System aktualisieren
            echo -ne "${CYAN}[2/6] Aktualisiere Paketlisten...${NC} "
            sudo apt-get update -qq &>/dev/null
            echo -e "${GREEN}✓${NC}"
            
            # Abhängigkeiten installieren
            echo -ne "${CYAN}[3/6] Installiere Abhängigkeiten...${NC} "
            sudo apt-get install -y -qq \
                ca-certificates \
                curl \
                gnupg \
                lsb-release &>/dev/null
            echo -e "${GREEN}✓${NC}"
            
            # Docker GPG Key hinzufügen
            echo -ne "${CYAN}[4/6] Füge Docker GPG Key hinzu...${NC} "
            sudo install -m 0755 -d /etc/apt/keyrings
            curl -fsSL https://download.docker.com/linux/$OS/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg &>/dev/null
            sudo chmod a+r /etc/apt/keyrings/docker.gpg
            echo -e "${GREEN}✓${NC}"
            
            # Docker Repository hinzufügen
            echo -ne "${CYAN}[5/6] Füge Docker Repository hinzu...${NC} "
            echo \
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/$OS \
                $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
            sudo apt-get update -qq &>/dev/null
            echo -e "${GREEN}✓${NC}"
            
            # Docker installieren
            echo -e "${CYAN}[6/6] Installiere Docker Engine...${NC}"
            sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            ;;
            
        centos|rhel|fedora)
            echo -e "${CYAN}Installiere Docker für CentOS/RHEL/Fedora...${NC}"
            echo ""
            
            # Alte Versionen entfernen
            echo -ne "${CYAN}[1/5] Entferne alte Docker Versionen...${NC} "
            sudo yum remove -y docker docker-client docker-client-latest docker-common docker-latest docker-latest-logrotate docker-logrotate docker-engine &>/dev/null
            echo -e "${GREEN}✓${NC}"
            
            # Abhängigkeiten installieren
            echo -ne "${CYAN}[2/5] Installiere Abhängigkeiten...${NC} "
            sudo yum install -y yum-utils &>/dev/null
            echo -e "${GREEN}✓${NC}"
            
            # Docker Repository hinzufügen
            echo -ne "${CYAN}[3/5] Füge Docker Repository hinzu...${NC} "
            sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo &>/dev/null
            echo -e "${GREEN}✓${NC}"
            
            # Docker installieren
            echo -e "${CYAN}[4/5] Installiere Docker Engine...${NC}"
            sudo yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
            
            # Docker starten
            echo -ne "${CYAN}[5/5] Starte Docker...${NC} "
            sudo systemctl start docker
            sudo systemctl enable docker &>/dev/null
            echo -e "${GREEN}✓${NC}"
            ;;
            
        *)
            echo -e "${RED}Nicht unterstütztes Betriebssystem: $OS${NC}"
            echo -e "${YELLOW}Bitte installiere Docker manuell: https://docs.docker.com/get-docker/${NC}"
            return 1
            ;;
    esac
    
    # Benutzer zur Docker Gruppe hinzufügen
    echo ""
    echo -ne "${CYAN}Füge Benutzer zur Docker Gruppe hinzu...${NC} "
    sudo usermod -aG docker $USER &>/dev/null
    echo -e "${GREEN}✓${NC}"
    
    echo ""
    echo -e "${GREEN}✓ Docker erfolgreich installiert!${NC}"
    echo -e "${YELLOW}⚠ Hinweis: Möglicherweise musst du dich neu anmelden, damit die Gruppenänderungen wirksam werden.${NC}"
    echo ""
    
    return 0
}

# Voraussetzungen prüfen
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}📋 Schritt 1: Voraussetzungen prüfen${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Docker Check
echo -ne "${CYAN}Prüfe Docker Installation...${NC} "
if command -v docker &> /dev/null; then
    echo -e "${GREEN}✓ Installiert${NC}"
    DOCKER_VERSION=$(docker --version | cut -d ' ' -f3 | cut -d ',' -f1)
    echo -e "  ${BLUE}→ Version: $DOCKER_VERSION${NC}"
else
    echo -e "${YELLOW}✗ Nicht gefunden${NC}"
    echo ""
    echo -e "${CYAN}Soll Docker automatisch installiert werden? (j/n):${NC}"
    read -p "Auswahl: " INSTALL_DOCKER
    
    if [[ "$INSTALL_DOCKER" =~ ^[jJ]$ ]]; then
        if install_docker; then
            echo -e "${GREEN}Docker wurde erfolgreich installiert!${NC}"
        else
            echo -e "${RED}Docker Installation fehlgeschlagen!${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}Bitte installiere Docker manuell: https://docs.docker.com/get-docker/${NC}"
        exit 1
    fi
fi

# Docker Compose Check
echo -ne "${CYAN}Prüfe Docker Compose...${NC} "
if command -v docker-compose &> /dev/null || docker compose version &> /dev/null 2>&1; then
    echo -e "${GREEN}✓ Installiert${NC}"
else
    echo -e "${YELLOW}✗ Nicht gefunden${NC}"
    echo ""
    echo -e "${CYAN}Installiere Docker Compose Plugin...${NC}"
    
    # Prüfe ob Docker Compose Plugin bereits mit Docker installiert wurde
    if docker compose version &> /dev/null 2>&1; then
        echo -e "${GREEN}✓ Docker Compose Plugin bereits vorhanden${NC}"
    else
        # Legacy docker-compose installieren
        echo -ne "${CYAN}Installiere docker-compose...${NC} "
        COMPOSE_VERSION=$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep 'tag_name' | cut -d\" -f4)
        sudo curl -L "https://github.com/docker/compose/releases/download/${COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose &>/dev/null
        sudo chmod +x /usr/local/bin/docker-compose
        echo -e "${GREEN}✓${NC}"
    fi
fi

# Docker Daemon Status prüfen
echo -ne "${CYAN}Prüfe Docker Daemon Status...${NC} "
if sudo systemctl is-active --quiet docker 2>/dev/null || pgrep dockerd > /dev/null 2>&1; then
    echo -e "${GREEN}✓ Läuft${NC}"
else
    echo -e "${YELLOW}✗ Nicht aktiv${NC}"
    echo -ne "${CYAN}Starte Docker Daemon...${NC} "
    sudo systemctl start docker 2>/dev/null || sudo service docker start 2>/dev/null
    sleep 2
    if sudo systemctl is-active --quiet docker 2>/dev/null || pgrep dockerd > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗ Fehler${NC}"
        echo -e "${YELLOW}Bitte starte Docker manuell: sudo systemctl start docker${NC}"
    fi
fi

echo ""
sleep 1

# Konfiguration sammeln
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}⚙️  Schritt 2: Konfiguration${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Domain abfragen
while true; do
    echo -e "${CYAN}Gib deine Domain ein (z.B. checkmate.example.com):${NC}"
    read -p "Domain: " DOMAIN
    if [[ -z "$DOMAIN" ]]; then
        echo -e "${RED}Domain darf nicht leer sein!${NC}"
    else
        echo -e "${GREEN}✓ Domain gesetzt: $DOMAIN${NC}"
        break
    fi
done
echo ""

# E-Mail abfragen
while true; do
    echo -e "${CYAN}Gib deine E-Mail-Adresse für Let's Encrypt ein:${NC}"
    read -p "E-Mail: " EMAIL
    if [[ -z "$EMAIL" ]] || [[ ! "$EMAIL" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
        echo -e "${RED}Bitte gib eine gültige E-Mail-Adresse ein!${NC}"
    else
        echo -e "${GREEN}✓ E-Mail gesetzt: $EMAIL${NC}"
        break
    fi
done
echo ""

# Secret Key generieren
SECRET_KEY=$(openssl rand -hex 32)
echo -e "${GREEN}✓ Secret Key generiert${NC}"
echo ""

sleep 1

# Zusammenfassung
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}📝 Schritt 3: Zusammenfassung${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BLUE}Domain:${NC}           $DOMAIN"
echo -e "${BLUE}E-Mail:${NC}           $EMAIL"
echo -e "${BLUE}Secret Key:${NC}       ${YELLOW}***********${NC}"
echo ""

echo -e "${CYAN}Möchtest du mit dieser Konfiguration fortfahren? (j/n):${NC}"
read -p "Auswahl: " CONFIRM

if [[ ! "$CONFIRM" =~ ^[jJ]$ ]]; then
    echo -e "${RED}Setup abgebrochen.${NC}"
    exit 0
fi

echo ""
sleep 1

# Dateien erstellen
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}🔧 Schritt 4: Dateien erstellen${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -ne "${CYAN}Erstelle docker-compose.yml...${NC} "
cat > docker-compose.yml << EOF
services:
  # Nginx Proxy für automatisches Reverse Proxying
  nginx-proxy:
    image: nginxproxy/nginx-proxy:latest
    container_name: nginx-proxy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/tmp/docker.sock:ro
      - nginx-certs:/etc/nginx/certs
      - nginx-vhost:/etc/nginx/vhost.d
      - nginx-html:/usr/share/nginx/html
    restart: unless-stopped
    networks:
      - proxy

  # Let's Encrypt Companion für automatische SSL-Zertifikate
  letsencrypt:
    image: nginxproxy/acme-companion:latest
    container_name: letsencrypt
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock:ro
      - nginx-certs:/etc/nginx/certs
      - nginx-vhost:/etc/nginx/vhost.d
      - nginx-html:/usr/share/nginx/html
      - acme-state:/etc/acme.sh
    environment:
      - DEFAULT_EMAIL=${EMAIL}
      - NGINX_PROXY_CONTAINER=nginx-proxy
    restart: unless-stopped
    networks:
      - proxy
    depends_on:
      - nginx-proxy

  # MongoDB Datenbank für Checkmate
  mongodb:
    image: ghcr.io/bluewave-labs/checkmate-mongo:latest
    container_name: checkmate-db
    restart: unless-stopped
    command: ["mongod", "--quiet", "--bind_ip_all"]
    volumes:
      - ./mongo/data:/data/db
    networks:
      - checkmate-internal
    healthcheck:
      test: ["CMD", "mongosh", "--eval", "db.adminCommand('ping')", "--quiet"]
      interval: 5s
      timeout: 30s
      start_period: 0s
      start_interval: 1s
      retries: 30

  # Checkmate Server
  server:
    image: ghcr.io/bluewave-labs/checkmate-backend-mono:latest
    container_name: checkmate
    pull_policy: always
    restart: unless-stopped
    environment:
      - UPTIME_APP_API_BASE_URL=https://${DOMAIN}/api/v1
      - UPTIME_APP_CLIENT_HOST=https://${DOMAIN}
      - DB_CONNECTION_STRING=mongodb://mongodb:27017/uptime_db
      - CLIENT_HOST=https://${DOMAIN}
      - JWT_SECRET=${SECRET_KEY}
      - VIRTUAL_HOST=${DOMAIN}
      - VIRTUAL_PORT=52345
      - LETSENCRYPT_HOST=${DOMAIN}
      - LETSENCRYPT_EMAIL=${EMAIL}
    networks:
      - proxy
      - checkmate-internal
    depends_on:
      mongodb:
        condition: service_healthy

networks:
  proxy:
    driver: bridge
  checkmate-internal:
    driver: bridge

volumes:
  nginx-certs:
  nginx-vhost:
  nginx-html:
  acme-state:
EOF
echo -e "${GREEN}✓${NC}"

echo -ne "${CYAN}Erstelle .env Datei...${NC} "
cat > .env << EOF
# Domain Konfiguration
DOMAIN=${DOMAIN}
EMAIL=${EMAIL}

# Checkmate Konfiguration
SECRET_KEY=${SECRET_KEY}

# Erstellt von: Andreas Höfler Setup Script
# Datum: $(date '+%Y-%m-%d %H:%M:%S')
EOF
echo -e "${GREEN}✓${NC}"

echo -ne "${CYAN}Erstelle .gitignore...${NC} "
cat > .gitignore << EOF
.env
*.log
*.swp
*~
EOF
echo -e "${GREEN}✓${NC}"

echo ""
sleep 1

# DNS Check
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}🌐 Schritt 5: DNS Überprüfung${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -ne "${CYAN}Prüfe DNS Auflösung für $DOMAIN...${NC} "

# Zuerst prüfen ob Domain in /etc/hosts ist und automatisch bereinigen
if grep -q "$DOMAIN" /etc/hosts 2>/dev/null; then
    echo -e "${YELLOW}⚠${NC}"
    echo -e "  ${YELLOW}→ Domain gefunden in /etc/hosts!${NC}"
    echo -e "  ${CYAN}→ Entferne lokalen Eintrag...${NC} "
    
    # Backup erstellen
    sudo cp /etc/hosts /etc/hosts.backup.$(date +%Y%m%d_%H%M%S)
    
    # Zeilen mit der Domain entfernen
    sudo sed -i "/$DOMAIN/d" /etc/hosts
    
    echo -e "  ${GREEN}✓ Lokaler Eintrag entfernt${NC}"
    echo -e "  ${BLUE}→ Backup erstellt: /etc/hosts.backup.*${NC}"
    echo ""
    echo -ne "${CYAN}Prüfe DNS Auflösung erneut...${NC} "
fi

# DNS Auflösung prüfen - verschiedene Tools probieren
DNS_LOOKUP=""
if command -v host &> /dev/null; then
    DNS_LOOKUP=$(host "$DOMAIN" 2>/dev/null)
elif command -v nslookup &> /dev/null; then
    DNS_LOOKUP=$(nslookup "$DOMAIN" 2>/dev/null | grep -A1 "Name:" | grep "Address:")
elif command -v dig &> /dev/null; then
    DNS_LOOKUP=$(dig +short "$DOMAIN" 2>/dev/null)
else
    echo -e "${YELLOW}⚠ Kein DNS-Tool gefunden${NC}"
    echo -e "  ${YELLOW}→ Installiere 'bind-utils' oder 'dnsutils' für DNS-Checks${NC}"
    echo ""
    sleep 1
fi

if [[ -n "$DNS_LOOKUP" ]]; then
    # IPs extrahieren je nach verwendetem Tool
    if command -v host &> /dev/null; then
        RESOLVED_IPS=$(echo "$DNS_LOOKUP" | grep "has address" | awk '{print $4}')
    elif command -v nslookup &> /dev/null; then
        RESOLVED_IPS=$(echo "$DNS_LOOKUP" | grep "Address:" | awk '{print $2}')
    else
        RESOLVED_IPS="$DNS_LOOKUP"
    fi
    
    # Loopback-Adressen (127.x.x.x und ::1) herausfiltern
    PUBLIC_IPS=$(echo "$RESOLVED_IPS" | grep -v "^127\." | grep -v "^::1" | grep -v "^$")
    
    if [[ -z "$PUBLIC_IPS" ]]; then
        echo -e "${RED}✗${NC}"
        echo -e "  ${RED}→ Domain zeigt nur auf lokale IP (127.x.x.x)${NC}"
        echo -e "  ${YELLOW}→ Dies ist ein Fehler in deiner /etc/hosts oder DNS-Konfiguration${NC}"
        echo -e "  ${YELLOW}→ Let's Encrypt wird definitiv fehlschlagen!${NC}"
        echo -e "  ${YELLOW}→ Bitte konfiguriere einen öffentlichen A-Record für $DOMAIN${NC}"
        echo ""
        echo -e "  ${CYAN}Tipps zur Fehlerbehebung:${NC}"
        echo -e "  ${WHITE}1. Prüfe /etc/hosts: ${CYAN}cat /etc/hosts | grep $DOMAIN${NC}"
        echo -e "  ${WHITE}2. Teste externe DNS: ${CYAN}nslookup $DOMAIN 8.8.8.8${NC}"
        echo -e "  ${WHITE}3. Leere DNS-Cache: ${CYAN}sudo systemd-resolve --flush-caches${NC}"
    else
        RESOLVED_IP=$(echo "$PUBLIC_IPS" | head -n1)
        echo -e "${GREEN}✓${NC}"
        echo -e "  ${BLUE}→ Aufgelöst zu: $RESOLVED_IP${NC}"
        
        # Mehrere IPs? Zeige alle an
        IP_COUNT=$(echo "$PUBLIC_IPS" | wc -l)
        if [[ $IP_COUNT -gt 1 ]]; then
            echo -e "  ${BLUE}→ Weitere IPs gefunden:${NC}"
            echo "$PUBLIC_IPS" | tail -n +2 | while read ip; do
                echo -e "    ${BLUE}• $ip${NC}"
            done
        fi
        
        # Server IP ermitteln
        echo -ne "  ${CYAN}→ Ermittle Server IP...${NC} "
        SERVER_IP=$(curl -s --max-time 5 ifconfig.me 2>/dev/null || curl -s --max-time 5 icanhazip.com 2>/dev/null || curl -s --max-time 5 api.ipify.org 2>/dev/null)
        
        if [[ -n "$SERVER_IP" && "$SERVER_IP" != "unbekannt" ]]; then
            echo -e "${GREEN}$SERVER_IP${NC}"
            
            # Prüfe ob eine der aufgelösten IPs mit der Server-IP übereinstimmt
            if echo "$PUBLIC_IPS" | grep -q "^${SERVER_IP}$"; then
                echo -e "  ${GREEN}✓ DNS korrekt konfiguriert!${NC}"
            else
                echo -e "  ${YELLOW}⚠ Warnung: DNS zeigt auf andere IP!${NC}"
                echo -e "  ${YELLOW}  Domain IP: $RESOLVED_IP${NC}"
                echo -e "  ${YELLOW}  Server IP: $SERVER_IP${NC}"
                echo -e "  ${YELLOW}  Let's Encrypt könnte fehlschlagen.${NC}"
                echo ""
                echo -e "  ${CYAN}Mögliche Ursachen:${NC}"
                echo -e "  ${WHITE}1. DNS-Änderungen noch nicht propagiert (kann 24-48h dauern)${NC}"
                echo -e "  ${WHITE}2. Domain zeigt auf falschen Server${NC}"
                echo -e "  ${WHITE}3. Server hat mehrere IP-Adressen${NC}"
                echo -e "  ${WHITE}4. Du verwendest einen Proxy/CDN (z.B. Cloudflare)${NC}"
            fi
        else
            echo -e "${YELLOW}Fehler${NC}"
            echo -e "  ${YELLOW}→ Konnte Server-IP nicht ermitteln${NC}"
            echo -e "  ${YELLOW}→ Bitte prüfe manuell, ob $RESOLVED_IP zu diesem Server gehört${NC}"
        fi
    fi
else
    echo -e "${RED}✗${NC}"
    echo -e "  ${RED}→ Domain konnte nicht aufgelöst werden${NC}"
    echo -e "  ${YELLOW}→ Stelle sicher, dass ein A-Record für $DOMAIN existiert!${NC}"
    if command -v nslookup &> /dev/null; then
        echo -e "  ${YELLOW}→ Prüfe mit: ${CYAN}nslookup $DOMAIN${NC}"
    else
        echo -e "  ${YELLOW}→ Installiere DNS-Tools: ${CYAN}apt install dnsutils${NC} oder ${CYAN}yum install bind-utils${NC}"
    fi
fi

echo ""
sleep 1

# Abschlussfrage
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}🚀 Schritt 6: Container starten${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

echo -e "${CYAN}Möchtest du die Container jetzt starten? (j/n):${NC}"
read -p "Auswahl: " START_CONTAINERS

if [[ "$START_CONTAINERS" =~ ^[jJ]$ ]]; then
    echo ""
    echo -ne "${CYAN}Starte Container...${NC} "
    echo ""
    
    # Prüfe ob docker-compose oder docker compose verwendet werden soll
    if command -v docker-compose &> /dev/null; then
        COMPOSE_CMD="docker-compose"
    else
        COMPOSE_CMD="docker compose"
    fi
    
    if $COMPOSE_CMD up -d; then
        echo ""
        echo -e "${GREEN}✓ Container erfolgreich gestartet!${NC}"
        echo ""
        
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${GREEN}🎉 Setup abgeschlossen!${NC}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        echo -e "${WHITE}Deine Checkmate-Instanz wird unter folgender URL erreichbar sein:${NC}"
        echo -e "${GREEN}→ https://$DOMAIN${NC}"
        echo ""
        echo -e "${YELLOW}Hinweis:${NC}"
        echo -e "  • SSL-Zertifikat kann bis zu 5 Minuten dauern"
        echo -e "  • Logs anzeigen: ${CYAN}$COMPOSE_CMD logs -f${NC}"
        echo -e "  • Status prüfen: ${CYAN}$COMPOSE_CMD ps${NC}"
        echo ""
        echo -e "${MAGENTA}Viel Erfolg, Andreas! 🚀${NC}"
        echo ""
    else
        echo ""
        echo -e "${RED}✗ Fehler beim Starten der Container${NC}"
        echo -e "${YELLOW}Prüfe die Logs mit: $COMPOSE_CMD logs${NC}"
    fi
else
    echo ""
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}✓ Konfiguration gespeichert!${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${WHITE}Starte die Container später mit:${NC}"
    
    # Zeige den richtigen Befehl an
    if command -v docker-compose &> /dev/null; then
        echo -e "${CYAN}→ docker-compose up -d${NC}"
    else
        echo -e "${CYAN}→ docker compose up -d${NC}"
    fi
    echo ""
    echo -e "${MAGENTA}Bis bald, Andreas! 👋${NC}"
    echo ""
fi
