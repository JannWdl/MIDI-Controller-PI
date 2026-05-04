# Bluetooth MIDI Support

## Status

⚠️ **Bluetooth MIDI ist aktuell NICHT implementiert**

Die aktuelle Version des MIDI Footswitch Pedals unterstützt:
- ✅ **USB MIDI** (empfohlen, niedrigste Latenz)
- ✅ **WiFi MIDI** (UDP-basiert, siehe [WIFI_MIDI.md](WIFI_MIDI.md))
- ❌ **Bluetooth MIDI** (geplant für zukünftige Version)

---

## Warum nicht implementiert?

Bluetooth MIDI auf Linux/Raspberry Pi erfordert:
1. **BlueZ** (Bluetooth-Stack) - vorhanden
2. **bluez-alsa** oder **bluez-midi** - komplex zu konfigurieren
3. **BLE MIDI Protokoll** - spezielles GATT-Profil nötig
4. **Pairing-Management** - UI für Bluetooth-Verbindungen
5. **Latenz höher als WiFi** (~20-30ms vs. ~10ms)

**Aufwand:** Hoch  
**Nutzen:** Gering (WiFi/USB sind besser)

---

## Alternativen

### 1. USB MIDI (beste Option) 🎯

**Vorteile:**
- ✅ Niedrigste Latenz (< 2ms)
- ✅ Höchste Zuverlässigkeit
- ✅ Plug & Play
- ✅ Funktioniert mit allen DAWs

**Setup:**
```sh
# Im Web-Interface: USB MIDI aktivieren
# Raspberry Pi per USB mit Computer verbinden
# In DAW: "MIDI Controller" als Input wählen
```

---

### 2. WiFi MIDI 📡

**Vorteile:**
- ✅ Kabellos
- ✅ Bereits implementiert
- ✅ ~10ms Latenz (akzeptabel)

**Setup:**
- Siehe [WIFI_MIDI.md](WIFI_MIDI.md) für Details

---

### 3. USB-Bluetooth-Adapter (Workaround)

Falls du **unbedingt** Bluetooth brauchst:

#### Option A: USB-Bluetooth-MIDI-Adapter

**Hardware:**
- Yamaha MD-BT01 (~50€)
- Quicco Sound mi.1 (~80€)
- CME WIDI Master (~100€)

**Setup:**
1. Raspberry Pi per **USB** mit Adapter verbinden
2. USB MIDI im Web-Interface aktivieren
3. Adapter mit Computer/Tablet/iOS pairen
4. **Fertig!**

**Vorteile:**
- ✅ Funktioniert out-of-the-box
- ✅ Standard BLE MIDI
- ✅ iOS/iPadOS/macOS/Android kompatibel

**Nachteile:**
- ❌ Zusätzliche Hardware nötig
- ❌ Kosten

---

#### Option B: Computer mit Bluetooth + USB

1. Raspberry Pi per **USB** an Computer
2. Computer per **Bluetooth** an Tablet/Synth
3. DAW auf Computer routet MIDI weiter

---

## Geplante Implementation (Zukunft)

Falls es Nachfrage gibt, könnte Bluetooth MIDI implementiert werden mit:

### Technischer Ansatz:

**1. bluez-alsa Installation:**
```sh
sudo apt-get install bluez bluez-tools bluealsa
```

**2. BLE GATT MIDI Service:**
- MIDI Service UUID: `03B80E5A-EDE8-4B33-A751-6CE34EC4C700`
- MIDI Characteristic: `7772E5DB-3868-4112-A1A9-F2669D106BF3`

**3. Python BLE Library:**
```python
import bleak  # Bluetooth Low Energy Library
```

**4. Web-Interface:**
- Bluetooth-Scan-Button
- Liste verfügbarer Geräte
- Pairing-Management

### Geschätzter Aufwand:
- **Entwicklung:** 3-5 Tage
- **Testing:** 2-3 Tage
- **Dokumentation:** 1 Tag

**Total:** ~1-2 Wochen Vollzeit-Arbeit

---

## Community Contribution

Falls du Bluetooth MIDI implementieren möchtest:

**1. Fork das Repository:**
```sh
git clone https://github.com/JannWdl/MIDI-Controller-PI
cd MIDI-Controller-PI
git checkout -b feature/bluetooth-midi
```

**2. Implementiere:**
- `backend/bluetooth_midi.py` - BLE MIDI Service
- Web-Interface Bluetooth-Tab erweitern
- Tests schreiben

**3. Pull Request erstellen**

**Hilfreiche Ressourcen:**
- BLE MIDI Spec: https://www.midi.org/specifications/item/bluetooth-le-midi
- bluez-alsa: https://github.com/Arkq/bluez-alsa
- Python bleak: https://github.com/hbldh/bleak

---

## Vergleich: USB vs. WiFi vs. Bluetooth

| Feature | USB MIDI | WiFi MIDI | Bluetooth MIDI |
|---------|----------|-----------|----------------|
| **Latenz** | < 2ms ✅ | ~10ms ⚠️ | ~20-30ms ❌ |
| **Reichweite** | 5m (Kabel) | 50m+ ✅ | 10m ⚠️ |
| **Zuverlässigkeit** | 100% ✅ | 95% ⚠️ | 90% ❌ |
| **Setup** | Plug & Play ✅ | Bridge nötig ⚠️ | Pairing nötig ❌ |
| **iOS/iPad** | Adapter nötig | Mit App möglich | Nativ ✅ |
| **Batteriebetrieb** | ❌ | ❌ | ✅ (theoretisch) |
| **Implementiert** | ✅ | ✅ | ❌ |

---

## FAQ

### Warum nicht einfach PyBluez verwenden?

**PyBluez ist veraltet:**
- ❌ Python 3.13 inkompatibel
- ❌ Unterstützt kein BLE MIDI
- ❌ Nicht mehr gewartet

### Kann ich einen Bluetooth-Dongle verwenden?

Ja, aber:
- Raspberry Pi hat bereits Bluetooth (3/4/5/Zero W)
- Software-Support fehlt, nicht Hardware

### Wann kommt Bluetooth MIDI?

**Aktuell keine Pläne.**

Gründe:
- USB/WiFi decken 99% der Use Cases ab
- Bluetooth hat höhere Latenz
- Implementierung komplex
- Geringer Mehrwert

**Falls du es brauchst:**
- Verwende USB-Bluetooth-Adapter (siehe oben)
- Oder implementiere es selbst (Pull Request willkommen!)

---

## Workaround für iOS/iPad

Falls du das Footswitch-Pedal mit iOS/iPad nutzen willst:

**Option 1: USB-C zu Lightning/USB-C Adapter + USB MIDI**
- Apple USB-C zu Lightning Adapter
- Raspberry Pi per USB verbinden
- USB MIDI aktivieren
- Funktioniert mit GarageBand, Cubasis, etc.

**Option 2: WiFi + iOS-App**
- WiFi MIDI aktivieren
- iOS-App wie "MIDI Network" verwenden
- Siehe [WIFI_MIDI.md](WIFI_MIDI.md)

**Option 3: USB-Bluetooth-Adapter**
- CME WIDI Master an Raspberry Pi USB
- Mit iPad pairen
- Nativ in iOS-Apps nutzen

---

## Status Updates

Diese Datei wird aktualisiert falls:
- Bluetooth MIDI implementiert wird
- Community-Lösungen gefunden werden
- Neue Hardware-Adapter empfohlen werden

**Letzte Aktualisierung:** 2024 (Version 1.0)

**Fragen?** Öffne ein Issue auf GitHub: https://github.com/JannWdl/MIDI-Controller-PI/issues
