# MIDI Controller für Raspberry Pi

Ein vollständiger MIDI-Controller für Raspberry Pi mit Unterstützung für USB, WiFi und Bluetooth MIDI.

## Features

- ✅ **USB MIDI** - Direkte Verbindung zu DAWs
- ✅ **WiFi MIDI** - RTP-MIDI über UDP (Port 5004)
- ✅ **Bluetooth MIDI** - Drahtlose Verbindung
- ✅ **Web-Interface** - Konfiguration über Browser
- ✅ **16 Buttons** - Frei konfigurierbar
- ✅ **Note & CC Messages** - Volle MIDI-Unterstützung
- ✅ **Auto-Start** - Systemd Service Integration

## Installation

### Voraussetzungen
- Raspberry Pi (3/4/5 oder Zero W)
- Raspberry Pi OS (Bookworm oder neuer)
- Internet-Verbindung

### Schnell-Installation

```bash
# Repository klonen
git clone https://github.com/JannWdl/MIDI-Controller-PI.git
cd MIDI-Controller-PI

# Installation ausführen (als root)
sudo chmod +x install.sh
sudo ./install.sh

# System neu starten
sudo reboot
```

Das Installations-Skript installiert automatisch:
- Python 3 und benötigte Packages
- ALSA MIDI Tools
- Bluetooth Tools
- Flask Web-Server
- Systemd Service
- mDNS (Avahi) für .local Zugriff

## Verwendung

### Web-Interface aufrufen

Nach der Installation ist das Web-Interface erreichbar über:

- **http://[PI-IP-Adresse]:5000**
- **http://[hostname].local:5000** (z.B. `http://raspberrypi.local:5000`)

### Service-Befehle

```bash
# Service starten
sudo systemctl start midi-controller

# Service stoppen
sudo systemctl stop midi-controller

# Service Status
sudo systemctl status midi-controller

# Logs anzeigen
sudo journalctl -u midi-controller -f

# Service neu starten
sudo systemctl restart midi-controller
```

## Konfiguration

### Über Web-Interface

1. Web-Interface im Browser öffnen
2. Tab **"Konfiguration"** auswählen
3. Buttons anpassen:
   - Name ändern
   - MIDI Note/CC Nummer einstellen
   - Typ wählen (Note oder Control Change)
   - Farbe anpassen
4. **Speichern** klicken

### Verbindungseinstellungen

Im Tab **"Verbindungen"** können Sie konfigurieren:

#### USB MIDI
- Port automatisch oder manuell auswählen
- An/Aus schalten

#### WiFi MIDI (RTP-MIDI)
- Host: `0.0.0.0` (alle Interfaces)
- Port: `5004` (Standard RTP-MIDI)
- Broadcasts an UDP

#### Bluetooth MIDI
- Gerätename konfigurieren
- An/Aus schalten

### Manuelle Konfiguration

Die Konfiguration wird gespeichert in:
```
/opt/midi-controller/config/config.json
```

## MIDI Verbindung herstellen

### USB MIDI

**In DAW:**
- MIDI-Eingang aktivieren
- "MIDI Controller" oder virtuellen Port auswählen

### WiFi MIDI

**Auf dem Computer:**

1. **rtpMIDI (Windows)**: 
   - rtpMIDI installieren
   - Session erstellen
   - Raspberry Pi IP eingeben, Port 5004

2. **Linux (QmidiNet):**
   ```bash
   sudo apt install qmidinet
   qmidinet
   ```

3. **macOS (Audio MIDI Setup):**
   - Audio MIDI Setup öffnen
   - MIDI Network Setup
   - Raspberry Pi hinzufügen

## Troubleshooting

### Service startet nicht

```bash
# Logs prüfen
sudo journalctl -u midi-controller -n 50

# Manuell testen
cd /opt/midi-controller
sudo -u pi venv/bin/python3 main.py
```

### Web-Interface nicht erreichbar

```bash
# Firewall prüfen
sudo ufw allow 5000/tcp

# Service-Status prüfen
sudo systemctl status midi-controller
```

## API Dokumentation

### REST API Endpoints

- `GET /api/config` - Konfiguration abrufen
- `POST /api/config` - Konfiguration speichern
- `GET /api/status` - Status abrufen
- `POST /api/button/press` - Button drücken
- `POST /api/button/release` - Button loslassen
- `POST /api/restart` - Controller neu starten

## Lizenz

MIT License