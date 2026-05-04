#!/bin/bash
# MIDI Controller Installation Script für Raspberry Pi
# Dieses Skript installiert alle benötigten Dependencies und richtet den Service ein

set -e

echo "================================"
echo "🎹 MIDI Controller Installation"
echo "================================"
echo ""

# Prüfen ob als Root ausgeführt
if [ "$EUID" -ne 0 ]; then 
	echo "Bitte als root ausführen: sudo ./install.sh"
	exit 1
fi

# System aktualisieren
echo "📦 System Update..."
apt-get update

# Python und Dependencies installieren
echo "📦 Installiere Dependencies..."
apt-get install -y python3 python3-pip python3-venv
apt-get install -y libasound2-dev libjack-dev
apt-get install -y alsa-utils
apt-get install -y bluez bluez-tools
apt-get install -y avahi-daemon avahi-utils

# Verzeichnisstruktur erstellen
echo "📁 Erstelle Verzeichnisse..."
mkdir -p /opt/midi-controller/config
mkdir -p /opt/midi-controller/logs
mkdir -p /var/www/midi-controller

# Virtual Environment erstellen
echo "🐍 Erstelle Python Virtual Environment..."
python3 -m venv /opt/midi-controller/venv

# Python Packages installieren (OHNE pybluez - ist veraltet)
echo "📦 Installiere Python Packages (kann 5-10 Min dauern)..."
/opt/midi-controller/venv/bin/pip install --no-cache-dir --upgrade pip
/opt/midi-controller/venv/bin/pip install --no-cache-dir flask flask-cors mido python-rtmidi

# Dateien kopieren
echo "📝 Kopiere Dateien..."
[ -f backend/main.py ] && cp backend/main.py /opt/midi-controller/main.py || echo "⚠️  backend/main.py nicht gefunden"
[ -f web/index.html ] && cp web/index.html /var/www/midi-controller/index.html || echo "⚠️  web/index.html nicht gefunden"
[ -f config/default_config.json ] && cp config/default_config.json /opt/midi-controller/config/default_config.json || echo "⚠️  config/default_config.json nicht gefunden"

# Berechtigungen setzen
echo "🔐 Setze Berechtigungen..."
chown -R $SUDO_USER:$SUDO_USER /opt/midi-controller
chown -R $SUDO_USER:$SUDO_USER /var/www/midi-controller
[ -f /opt/midi-controller/main.py ] && chmod +x /opt/midi-controller/main.py

# Benutzer zu Audio-Gruppe hinzufügen
echo "👤 Füge Benutzer zu Gruppen hinzu..."
usermod -a -G audio $SUDO_USER
usermod -a -G dialout $SUDO_USER

# Systemd Service erstellen
echo "⚙️  Erstelle Systemd Service..."
cat > /etc/systemd/system/midi-controller.service << ENDSERVICE
[Unit]
Description=MIDI Controller Service
After=network.target sound.target

[Service]
Type=simple
User=$SUDO_USER
WorkingDirectory=/opt/midi-controller
ExecStart=/opt/midi-controller/venv/bin/python3 /opt/midi-controller/main.py
Restart=always
RestartSec=10
StandardOutput=append:/opt/midi-controller/logs/output.log
StandardError=append:/opt/midi-controller/logs/error.log

[Install]
WantedBy=multi-user.target
ENDSERVICE

# Service aktivieren
echo "🔄 Aktiviere Service..."
systemctl daemon-reload
systemctl enable midi-controller.service

# MIDI Konfiguration
echo "🎵 Konfiguriere MIDI..."
modprobe snd-seq 2>/dev/null || true
modprobe snd-seq-midi 2>/dev/null || true
grep -qxF 'snd-seq' /etc/modules 2>/dev/null || echo 'snd-seq' >> /etc/modules
grep -qxF 'snd-seq-midi' /etc/modules 2>/dev/null || echo 'snd-seq-midi' >> /etc/modules

# Avahi Service für mDNS
echo "🌐 Konfiguriere mDNS..."
cat > /etc/avahi/services/midi-controller.service << 'ENDAVAHI'
<?xml version="1.0" standalone='no'?>
<!DOCTYPE service-group SYSTEM "avahi-service.dtd">
<service-group>
  <name replace-wildcards="yes">MIDI Controller on %h</name>
  <service>
	<type>_http._tcp</type>
	<port>5000</port>
	<txt-record>path=/</txt-record>
  </service>
</service-group>
ENDAVAHI

systemctl restart avahi-daemon 2>/dev/null || true

echo ""
echo "================================"
echo "✅ Installation abgeschlossen!"
echo "================================"
echo ""
echo "Befehle:"
echo "  sudo systemctl start midi-controller    # Service starten"
echo "  sudo systemctl stop midi-controller     # Service stoppen"
echo "  sudo systemctl status midi-controller   # Status anzeigen"
echo "  sudo journalctl -u midi-controller -f   # Logs live anzeigen"
echo ""
echo "Web-Interface erreichbar unter:"
echo "  http://$(hostname -I | awk '{print $1}'):5000"
echo "  http://$(hostname).local:5000"
echo ""
echo "Empfohlen: System neu starten mit 'sudo reboot'"
echo ""
