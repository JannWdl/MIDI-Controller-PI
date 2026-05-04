# GPIO Footswitch Verkabelung

## Standard-Pin-Belegung

Die Footswitches werden an die GPIO-Pins des Raspberry Pi angeschlossen.

### Footswitch Pins (Standard-Konfiguration)

| Footswitch | GPIO Pin | Physischer Pin | Farbe    | MIDI Note/CC |
|------------|----------|----------------|----------|--------------|
| 1          | GPIO 17  | Pin 11         | Blau     | Note 60 (C)  |
| 2          | GPIO 27  | Pin 13         | Blau     | Note 61      |
| 3          | GPIO 22  | Pin 15         | Grün     | Note 62      |
| 4          | GPIO 23  | Pin 16         | Grün     | Note 63      |
| 5          | GPIO 24  | Pin 18         | Orange   | Note 64      |
| 6          | GPIO 25  | Pin 22         | Orange   | Note 65      |
| 7          | GPIO 5   | Pin 29         | Rot      | CC 66        |
| 8          | GPIO 6   | Pin 31         | Rot      | CC 67        |

### Ground (GND) Pins

Verbinde **alle** Footswitch-GND mit einem der folgenden Pins:
- Pin 6 (GND)
- Pin 9 (GND)
- Pin 14 (GND)
- Pin 20 (GND)
- Pin 25 (GND)
- Pin 30 (GND)
- Pin 34 (GND)
- Pin 39 (GND)

## Verkabelung

### Schaltung pro Footswitch

```
GPIO Pin (z.B. GPIO 17) ----[Footswitch]---- GND
```

**Mit Pull-Up aktiviert (Standard):**
- Taster öffnet: GPIO = HIGH (3.3V)
- Taster schließt: GPIO = LOW (0V, GND)

### Beispiel-Verkabelung

```
Raspberry Pi                  Footswitch-Pedal
┌─────────────┐              ┌──────────────┐
│             │              │              │
│  GPIO 17 ───┼──────────────┼─── Switch 1  │
│  GPIO 27 ───┼──────────────┼─── Switch 2  │
│  GPIO 22 ───┼──────────────┼─── Switch 3  │
│  GPIO 23 ───┼──────────────┼─── Switch 4  │
│  GPIO 24 ───┼──────────────┼─── Switch 5  │
│  GPIO 25 ───┼──────────────┼─── Switch 6  │
│  GPIO 5  ───┼──────────────┼─── Switch 7  │
│  GPIO 6  ───┼──────────────┼─── Switch 8  │
│             │              │              │
│  GND     ───┼──────────────┼─── Common    │
│             │              │              │
└─────────────┘              └──────────────┘
```

## Hardware-Komponenten

### Footswitches
- **Empfohlen**: Momentary Footswitches (NO - Normally Open)
- **Alternative**: Latching Footswitches
- **Beispiel**: Boss FS-5U, Behringer FS112

### Kabel
- **Typ**: Mehradrige Kabel (Cat5/Cat6 Ethernet-Kabel funktioniert gut)
- **Länge**: Bis zu 3m empfohlen
- **Stecker**: 1/4" Klinkenstecker oder direkt löten

### Optional: Entstörkondensatoren
Bei langen Kabeln (>2m) kann ein 100nF Kondensator zwischen GPIO und GND helfen:
```
GPIO ----[100nF]---- GND
		[Switch]
```

## Konfiguration im Web-Interface

1. **Web-Interface öffnen**: `http://raspberrypi.local:5000`
2. **Tab "Konfiguration"** öffnen
3. **GPIO Einstellungen** anpassen:
   - **GPIO aktiviert**: ✓ (aktiviert)
   - **Pull-Up Widerstand**: ✓ (für Taster gegen GND)
   - **Bounce Time**: 0.05s (Standard, bei Prellen erhöhen)

4. **Footswitch Belegung**:
   - **Name**: Beliebig (z.B. "Distortion", "Delay", "Wah")
   - **GPIO Pin**: Pin-Nummer (0-27)
   - **Typ**: Note oder CC
   - **Note/CC Nummer**: 0-127
   - **Farbe**: Für Web-Interface-Anzeige
   - **Aktiv**: Footswitch aktivieren/deaktivieren

5. **Speichern** klicken → Service startet neu

## Verfügbare GPIO-Pins

**Verwendbar für Footswitches:**
- GPIO 2, 3, 4, 5, 6
- GPIO 12, 13, 16, 17, 18, 19, 20, 21
- GPIO 22, 23, 24, 25, 26, 27

**NICHT verwenden:**
- GPIO 0, 1 (reserviert für HAT)
- GPIO 7, 8, 9, 10, 11 (SPI)
- GPIO 14, 15 (UART)

## Test

### 🧪 GPIO-Test mit Web-Interface (empfohlen)

Das **GPIO-Test-Tool** im Web-Interface ermöglicht Live-Monitoring der Footswitches:

1. **Web-Interface öffnen**: `http://raspberrypi.local:5000`
2. Tab **"🧪 GPIO Test"** öffnen
3. **"▶️ Test starten"** klicken
4. **Footswitches drücken** - Events werden in Echtzeit angezeigt:
   ```
   [14:32:15.123] EVENT ⬇️ GEDRÜCKT - Footswitch 1 (GPIO 17) → Note 60
   [14:32:15.234] EVENT ⬆️ LOSGELASSEN - Footswitch 1 (GPIO 17) → Note 60
   ```
5. **Pin-Status** zeigt den aktuellen Zustand jedes Pins
6. **"⏹️ Test stoppen"** wenn fertig

**Vorteile:**
- ✅ Echtzeit-Feedback mit Millisekunden-Zeitstempel
- ✅ Erkennt Verkabelungsprobleme sofort
- ✅ Zeigt GPIO-Pin-Zuordnung an
- ✅ Prellen (Bounce) wird sichtbar gemacht
- ✅ Keine externe MIDI-Software nötig

### Manueller GPIO-Test (Kommandozeile)

```bash
# Pin-Status prüfen
raspi-gpio get 17

# Pin manuell testen
raspi-gpio set 17 ip pu  # Input mit Pull-Up
```

### Footswitch testen

1. Footswitch anschließen
2. Web-Interface öffnen
3. Tab "Controller" → Footswitch drücken
4. MIDI-Nachricht wird gesendet (siehe Logs)

```bash
# Logs live ansehen
sudo journalctl -u midi-controller -f
```

## Troubleshooting

### Footswitch reagiert nicht
- GPIO-Pin korrekt verkabelt? (Physischer Pin vs. GPIO-Nummer!)
- GND verbunden?
- Pull-Up aktiviert?
- Footswitch im Web-Interface auf "Aktiv"?

### Prellen (mehrfache Auslösungen)
- **Bounce Time erhöhen**: 0.1s oder mehr
- Hardware-Lösung: 100nF Kondensator parallel zum Taster

### Falsche Auslösung ohne Druck
- Kabel zu lang? → Kondensator hinzufügen
- Pull-Up deaktiviert? → Aktivieren
- Schlechter Kontakt? → Verbindungen prüfen

### GPIO-Pin-Konflikt
- Pin bereits verwendet? → Anderen Pin wählen
- `raspi-gpio get [pin]` zum Prüfen

## Sicherheit

⚠️ **WICHTIG:**
- **Nur 3.3V GPIOs verwenden** (NICHT 5V!)
- **Keine externe Spannung** an GPIO anlegen
- **Max. 16mA pro Pin** (Footswitches sind OK)
- **GND niemals mit 3.3V/5V verbinden**

## Pinout-Referenz

```
Raspberry Pi GPIO Pinout (40-Pin Header)
┌─────┬──────┬────┬────┬──────┬─────┐
│     │ 3.3V │  1 │  2 │  5V  │     │
│     │ GP2  │  3 │  4 │  5V  │     │
│     │ GP3  │  5 │  6 │ GND  │ ← GND
│     │ GP4  │  7 │  8 │ GP14 │     │
│ GND │ GND  │  9 │ 10 │ GP15 │     │
│  ✓  │ GP17 │ 11 │ 12 │ GP18 │  ✓  │ ← Footswitch Pins
│  ✓  │ GP27 │ 13 │ 14 │ GND  │ GND │
│  ✓  │ GP22 │ 15 │ 16 │ GP23 │  ✓  │
│     │ 3.3V │ 17 │ 18 │ GP24 │  ✓  │
│     │ GP10 │ 19 │ 20 │ GND  │ GND │
│     │ GP9  │ 21 │ 22 │ GP25 │  ✓  │
│     │ GP11 │ 23 │ 24 │ GP8  │     │
│ GND │ GND  │ 25 │ 26 │ GP7  │     │
│     │ GP0  │ 27 │ 28 │ GP1  │     │
│  ✓  │ GP5  │ 29 │ 30 │ GND  │ GND │
│  ✓  │ GP6  │ 31 │ 32 │ GP12 │  ✓  │
│     │ GP13 │ 33 │ 34 │ GND  │ GND │
│     │ GP19 │ 35 │ 36 │ GP16 │     │
│     │ GP26 │ 37 │ 38 │ GP20 │     │
│ GND │ GND  │ 39 │ 40 │ GP21 │     │
└─────┴──────┴────┴────┴──────┴─────┘

✓ = Standard-Pins für Footswitches
```

## Erweiterte Konfiguration

### Mehr als 8 Footswitches

Du kannst bis zu 19 Footswitches anschließen (alle verfügbaren GPIO-Pins).

Im Web-Interface:
1. Neuen Footswitch in der Konfiguration hinzufügen
2. Freien GPIO-Pin zuweisen
3. Speichern

### Externe Pull-Down-Widerstände

Falls du Pull-Down statt Pull-Up möchtest:
```python
# In config: "pull_up": false
# Taster zwischen GPIO und 3.3V
# 10kΩ Widerstand zwischen GPIO und GND
```

### MIDI-Program-Change

Aktuell: Note und CC
Zukünftig: Program Change Support geplant
