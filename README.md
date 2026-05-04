# MIDI Footswitch Pedal für Raspberry Pi

Ein GPIO-basiertes MIDI-Footswitch-Pedal für Raspberry Pi mit Unterstützung für USB und WiFi MIDI. Perfekt für Gitarristen und Musiker, die ihre Effektgeräte oder DAWs per Fußschalter steuern möchten.

## Features

- 🎸 **GPIO-Footswitches** - Bis zu 8 (erweiterbar auf 19) physische Fußschalter
- 🔌 **USB MIDI** - Direkte Verbindung zu DAWs und Effektgeräten
- 📡 **WiFi MIDI** - Drahtlose MIDI-Übertragung (RTP-MIDI über UDP)
- 🌐 **Web-Interface** - Konfiguration über Browser
- ⚙️ **Frei konfigurierbar** - Jeder Footswitch individuell einstellbar
- 📝 **Note & CC Messages** - Volle MIDI-Unterstützung
- 🚀 **Auto-Start** - Systemd Service Integration
- 🔧 **GPIO-Pin-Mapping** - Flexible Pin-Zuweisung im Web-Interface

## Hardware

### Benötigte Komponenten

- **Raspberry Pi** (3/4/5 oder Zero W/2)
- **Footswitches** (Momentary, NO - Normally Open)
  - Empfohlen: Boss FS-5U, Behringer FS112 oder vergleichbar
  - 8 Stück (Standard-Konfiguration)
- **Kabel** für Verkabelung (Cat5/Cat6 Ethernet-Kabel funktioniert gut)
- **Optional**: Gehäuse für das Pedal
- **Optional**: 100nF Kondensatoren (Entstörung)

### Standard GPIO-Pins

| Footswitch | GPIO Pin | Physischer Pin |
|------------|----------|----------------|
| 1          | GPIO 17  | Pin 11         |
| 2          | GPIO 27  | Pin 13         |
| 3          | GPIO 22  | Pin 15         |
| 4          | GPIO 23  | Pin 16         |
| 5          | GPIO 24  | Pin 18         |
| 6          | GPIO 25  | Pin 22         |
| 7          | GPIO 5   | Pin 29         |
| 8          | GPIO 6   | Pin 31         |

**Gemeinsamer Ground (GND)**: Pin 6, 9, 14, 20, 25, 30, 34 oder 39

> 📖 **Detaillierte Verkabelungsanleitung**: Siehe [GPIO_WIRING.md](GPIO_WIRING.md)

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
- Python 3 und benötigte Packages (Flask, mido, gpiozero)
- ALSA MIDI Tools
- GPIO-Bibliotheken (pigpio)
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

Das Web-Interface bietet 5 Tabs:

#### 🎹 Controller
- Virtuelle Buttons zum Testen der MIDI-Verbindung
- Simuliert Footswitch-Drücke (nützlich ohne Hardware)

#### ⚙️ Konfiguration
1. **MIDI Grundeinstellungen**:
   - Kanal (1-16)
   - Velocity (0-127)
2. **GPIO Einstellungen**:
   - GPIO aktiviert: ✓
   - Pull-Up Widerstand: ✓ (Taster gegen GND)
   - Bounce Time: 0.05s (bei Prellen erhöhen)
3. **Footswitch Belegung** anpassen:
   - Name ändern (z.B. "Distortion", "Delay")
   - GPIO Pin zuweisen (0-27)
   - MIDI Note/CC Nummer einstellen (0-127)
   - Typ wählen (Note oder Control Change)
   - Farbe anpassen (nur Web-Interface)
   - Footswitch aktivieren/deaktivieren
4. **Speichern** klicken → Service startet neu

#### 🧪 GPIO Test
- **Live-Monitoring**: Zeigt in Echtzeit, welche Footswitches gedrückt werden
- **Event-Log**: Detaillierte Zeitstempel für jeden Button-Press/Release
- **Pin-Status**: Übersicht aller konfigurierten GPIO-Pins
- **Verwendung**:
  1. "Test starten" klicken
  2. Footswitches drücken
  3. Events werden live im Log angezeigt
  4. Perfekt zum Testen der Verkabelung!

#### 🔌 Verbindungen
- USB MIDI, WiFi MIDI und Bluetooth Einstellungen
- Port automatisch oder manuell auswählen

#### ℹ️ Info
- Versionsinformationen und Features

### Verbindungseinstellungen

Im Tab **"Verbindungen"** können Sie konfigurieren:

#### USB MIDI
- Port automatisch oder manuell auswählen
- An/Aus schalten
- Virtueller MIDI-Port wird automatisch erstellt

#### WiFi MIDI (RTP-MIDI)
- Host: `0.0.0.0` (alle Interfaces)
- Port: `5004` (Standard RTP-MIDI)
- Broadcasts MIDI-Messages über UDP

## Hardware-Verkabelung

### Einfache Verkabelung (Pull-Up aktiviert)

Jeder Footswitch wird zwischen GPIO-Pin und GND geschaltet:

```
GPIO Pin ----[Footswitch]---- GND
```

### Beispiel: 4 Footswitches

```
Raspberry Pi                  Footswitch-Pedal
┌─────────────┐              ┌──────────────┐
│  GPIO 17 ───┼──────────────┼─── Switch 1  │
│  GPIO 27 ───┼──────────────┼─── Switch 2  │
│  GPIO 22 ───┼──────────────┼─── Switch 3  │
│  GPIO 23 ───┼──────────────┼─── Switch 4  │
│  GND     ───┼──────────────┼─── Common    │
└─────────────┘              └──────────────┘
```

> 📖 **Vollständige Verkabelungsanleitung**: [GPIO_WIRING.md](GPIO_WIRING.md)

## Verwendung

### Als Gitarren-Effekt-Controller

**Beispiel-Konfiguration:**
- Footswitch 1 → CC 20 → Distortion On/Off
- Footswitch 2 → CC 21 → Delay On/Off
- Footswitch 3 → CC 22 → Reverb On/Off
- Footswitch 4 → PC 1-4 → Preset-Wechsel

### Als DAW-Controller (Ableton, Logic, etc.)

**Beispiel-Konfiguration:**
- Footswitch 1 → Note C → Clip Trigger
- Footswitch 2 → Note D → Loop Record
- Footswitch 3 → CC 64 → Sustain
- Footswitch 4 → Note E → Transport Stop/Start

### Test der Footswitches

```bash
# Logs live ansehen
sudo journalctl -u midi-controller -f

# Footswitch drücken → "🔘 Footswitch 1 gedrückt (GPIO 17)" erscheint
```

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