#!/bin/bash
# Test-Skript für MIDI Controller Installation

echo "================================"
echo "MIDI Controller Test"
echo "================================"
echo ""

# Service Status
echo "1. Service Status:"
sudo systemctl status midi-controller --no-pager | head -n 10
echo ""

# MIDI Ports
echo "2. Verfügbare MIDI Ports:"
aconnect -l 2>/dev/null || echo "Keine MIDI Ports gefunden"
echo ""

# Web-Server
echo "3. Web-Server Test:"
curl -s http://localhost:5000/api/status | python3 -m json.tool 2>/dev/null || echo "Web-Server nicht erreichbar"
echo ""

# Logs
echo "4. Letzte Log-Einträge:"
sudo journalctl -u midi-controller -n 10 --no-pager
echo ""

# Netzwerk
echo "5. Netzwerk-Adresse:"
hostname -I
echo ""

echo "================================"
echo "Test abgeschlossen"
echo "================================"
