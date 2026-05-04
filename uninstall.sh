#!/bin/bash
# Deinstallations-Skript für MIDI Controller

set -e

echo "================================"
echo "MIDI Controller Deinstallation"
echo "================================"
echo ""

# Prüfen ob als Root ausgeführt
if [ "$EUID" -ne 0 ]; then 
	echo "Bitte als root ausführen (sudo ./uninstall.sh)"
	exit 1
fi

# Service stoppen und deaktivieren
echo "Services werden gestoppt..."
systemctl stop midi-controller.service 2>/dev/null || true
systemctl disable midi-controller.service 2>/dev/null || true
systemctl stop bt-midi.service 2>/dev/null || true
systemctl disable bt-midi.service 2>/dev/null || true

# Service-Dateien entfernen
echo "Service-Dateien werden entfernt..."
rm -f /etc/systemd/system/midi-controller.service
rm -f /etc/systemd/system/bt-midi.service
systemctl daemon-reload

# Verzeichnisse entfernen
echo "Programmdateien werden entfernt..."
rm -rf /opt/midi-controller
rm -rf /var/www/midi-controller

# Avahi Service entfernen
rm -f /etc/avahi/services/midi-controller.service
systemctl restart avahi-daemon 2>/dev/null || true

# MIDI Kernel-Module Konfiguration entfernen
rm -f /etc/modules-load.d/midi.conf

echo ""
echo "================================"
echo "Deinstallation abgeschlossen!"
echo "================================"
echo ""
echo "Hinweis: Installierte Pakete (Python, ALSA, etc.) wurden"
echo "nicht entfernt. Diese können manuell deinstalliert werden:"
echo ""
echo "  sudo apt remove python3-pip alsa-utils bluez"
echo ""
