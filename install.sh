#!/bin/bash
# MIDI Controller Installation Script für Raspberry Pi
# Dieses Skript installiert alle benötigten Dependencies und richtet den Service ein

set -e

echo "================================"
echo "MIDI Controller Installation"
echo "================================"
echo ""

# Prüfen ob als Root ausgeführt
if [ "$EUID" -ne 0 ]; then 
	echo "Bitte als root ausführen (sudo ./install.sh)"
	exit 1
fi

# System aktualisieren
echo "System wird aktualisiert..."
apt-get update
apt-get upgrade -y

# Python und Dependencies installieren
echo "Python Dependencies werden installiert..."
apt-get install -y python3 python3-pip python3-venv
apt-get install -y libasound2-dev libjack-dev

# MIDI Tools installieren
echo "MIDI Tools werden installiert..."
apt-get install -y alsa-utils

# Bluetooth Dependencies
echo "Bluetooth Dependencies werden installiert..."
apt-get install -y bluez bluez-tools libbluetooth-dev

# Network Tools
echo "Network Tools werden installiert..."
apt-get install -y avahi-daemon avahi-utils

# Virtual Environment erstellen
echo "Python Virtual Environment wird erstellt..."
python3 -m venv /opt/midi-controller/venv

# Python Packages installieren
echo "Python Packages werden installiert..."
/opt/midi-controller/venv/bin/pip install --upgrade pip
/opt/midi-controller/venv/bin/pip install flask flask-cors mido python-rtmidi pybluez pyserial

# Verzeichnisstruktur erstellen
echo "Verzeichnisse werden erstellt..."
mkdir -p /opt/midi-controller
mkdir -p /opt/midi-controller/config
mkdir -p /opt/midi-controller/logs
mkdir -p /var/www/midi-controller

# Dateien kopieren
echo "Dateien werden kopiert..."
cp -r ./backend/* /opt/midi-controller/ 2>/dev/null || true
cp -r ./web/* /var/www/midi-controller/ 2>/dev/null || true
cp ./config/default_config.json /opt/midi-controller/config/ 2>/dev/null || true

# Berechtigungen setzen
echo "Berechtigungen werden gesetzt..."
chown -R pi:pi /opt/midi-controller
chown -R pi:pi /var/www/midi-controller
chmod +x /opt/midi-controller/main.py

# Benutzer zu Audio-Gruppe hinzufügen
echo "Benutzer wird zu Gruppen hinzugefügt..."
usermod -a -G audio pi
usermod -a -G bluetooth pi
usermod -a -G dialout pi

# Systemd Service erstellen
echo "Systemd Service wird erstellt..."
cat > /etc/systemd/system/midi-controller.service << 'EOF'
[Unit]
Description=MIDI Controller Service
After=network.target sound.target bluetooth.target

[Service]
Type=simple
User=pi
WorkingDirectory=/opt/midi-controller
ExecStart=/opt/midi-controller/venv/bin/python3 /opt/midi-controller/main.py
Restart=always
RestartSec=10
StandardOutput=append:/opt/midi-controller/logs/output.log
StandardError=append:/opt/midi-controller/logs/error.log

[Install]
WantedBy=multi-user.target
EOF

# Service aktivieren
echo "Service wird aktiviert..."
systemctl daemon-reload
systemctl enable midi-controller.service

# MIDI Konfiguration
echo "MIDI wird konfiguriert..."
cat > /etc/modules-load.d/midi.conf << 'EOF'
snd-seq
snd-seq-midi
EOF

modprobe snd-seq
modprobe snd-seq-midi

# Bluetooth MIDI Service
echo "Bluetooth MIDI Service wird konfiguriert..."
cat > /etc/systemd/system/bt-midi.service << 'EOF'
[Unit]
Description=Bluetooth MIDI Service
After=bluetooth.target

[Service]
Type=simple
User=pi
ExecStart=/usr/bin/bluealsa
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl enable bt-midi.service

# Firewall Regeln (falls ufw installiert)
if command -v ufw &> /dev/null; then
	echo "Firewall wird konfiguriert..."
	ufw allow 5000/tcp
	ufw allow 5004/udp
fi

# Avahi Service für mDNS (midi-controller.local)
cat > /etc/avahi/services/midi-controller.service << 'EOF'
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
EOF

systemctl restart avahi-daemon

echo ""
echo "================================"
echo "Installation abgeschlossen!"
echo "================================"
echo ""
echo "Der MIDI Controller Service wurde installiert."
echo ""
echo "Befehle:"
echo "  Service starten:    sudo systemctl start midi-controller"
echo "  Service stoppen:    sudo systemctl stop midi-controller"
echo "  Service Status:     sudo systemctl status midi-controller"
echo "  Logs anzeigen:      sudo journalctl -u midi-controller -f"
echo ""
echo "Web-Interface erreichbar unter:"
echo "  http://$(hostname -I | awk '{print $1}'):5000"
echo "  http://$(hostname).local:5000"
echo ""
echo "Bitte System neu starten für vollständige Aktivierung:"
echo "  sudo reboot"
echo ""
