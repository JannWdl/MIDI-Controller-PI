#!/usr/bin/env python3
"""
MIDI Controller - Hauptprogramm
Unterstützt MIDI über WiFi, Bluetooth und USB
"""

import json
import os
import logging
import threading
import time
from flask import Flask, render_template, jsonify, request, send_from_directory
from flask_cors import CORS
import mido
from mido import Message

# Logging konfigurieren
logging.basicConfig(
	level=logging.INFO,
	format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
	handlers=[
		logging.FileHandler('/opt/midi-controller/logs/midi-controller.log'),
		logging.StreamHandler()
	]
)
logger = logging.getLogger(__name__)

# Flask App
app = Flask(__name__, 
			static_folder='/var/www/midi-controller',
			template_folder='/var/www/midi-controller')
CORS(app)

# Globale Variablen
CONFIG_FILE = '/opt/midi-controller/config/config.json'
DEFAULT_CONFIG_FILE = '/opt/midi-controller/config/default_config.json'
midi_outputs = {}
button_config = {}
connection_status = {
	'usb': False,
	'wifi': False,
	'bluetooth': False
}


class MIDIController:
	"""Hauptklasse für MIDI Controller"""

	def __init__(self):
		self.config = self.load_config()
		self.outputs = {
			'usb': None,
			'wifi': None,
			'bluetooth': None
		}
		self.running = False
		self.lock = threading.Lock()

	def load_config(self):
		"""Konfiguration laden"""
		try:
			if os.path.exists(CONFIG_FILE):
				with open(CONFIG_FILE, 'r') as f:
					return json.load(f)
			elif os.path.exists(DEFAULT_CONFIG_FILE):
				with open(DEFAULT_CONFIG_FILE, 'r') as f:
					return json.load(f)
			else:
				return self.create_default_config()
		except Exception as e:
			logger.error(f"Fehler beim Laden der Konfiguration: {e}")
			return self.create_default_config()

	def create_default_config(self):
		"""Standard-Konfiguration erstellen"""
		config = {
			'midi': {
				'channel': 1,
				'velocity': 127
			},
			'connections': {
				'usb': {
					'enabled': True,
					'port': 'auto'
				},
				'wifi': {
					'enabled': True,
					'host': '0.0.0.0',
					'port': 5004
				},
				'bluetooth': {
					'enabled': False,
					'device_name': 'MIDI-Controller'
				}
			},
			'buttons': []
		}

		# 16 Standard-Buttons erstellen
		for i in range(16):
			config['buttons'].append({
				'id': i,
				'name': f'Button {i+1}',
				'note': 60 + i,
				'type': 'note',
				'color': '#3b82f6'
			})

		self.save_config(config)
		return config

	def save_config(self, config=None):
		"""Konfiguration speichern"""
		if config is None:
			config = self.config

		try:
			os.makedirs(os.path.dirname(CONFIG_FILE), exist_ok=True)
			with open(CONFIG_FILE, 'w') as f:
				json.dump(config, f, indent=2)
			logger.info("Konfiguration gespeichert")
			return True
		except Exception as e:
			logger.error(f"Fehler beim Speichern der Konfiguration: {e}")
			return False

	def init_usb_midi(self):
		"""USB MIDI initialisieren"""
		if not self.config['connections']['usb']['enabled']:
			return False

		try:
			available_ports = mido.get_output_names()
			logger.info(f"Verfügbare MIDI Ports: {available_ports}")

			port_name = self.config['connections']['usb']['port']

			if port_name == 'auto' and available_ports:
				port_name = available_ports[0]

			if port_name and port_name in available_ports:
				self.outputs['usb'] = mido.open_output(port_name)
				connection_status['usb'] = True
				logger.info(f"USB MIDI verbunden: {port_name}")
				return True
			else:
				# Virtuellen Port erstellen
				self.outputs['usb'] = mido.open_output('MIDI Controller', virtual=True)
				connection_status['usb'] = True
				logger.info("Virtueller USB MIDI Port erstellt")
				return True

		except Exception as e:
			logger.error(f"USB MIDI Fehler: {e}")
			connection_status['usb'] = False
			return False

	def init_wifi_midi(self):
		"""WiFi MIDI (RTP-MIDI) initialisieren"""
		if not self.config['connections']['wifi']['enabled']:
			return False

		try:
			# RTP-MIDI Server (vereinfacht über UDP)
			import socket

			host = self.config['connections']['wifi']['host']
			port = self.config['connections']['wifi']['port']

			self.outputs['wifi'] = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
			self.outputs['wifi'].bind((host, port))
			connection_status['wifi'] = True
			logger.info(f"WiFi MIDI Server gestartet auf {host}:{port}")
			return True

		except Exception as e:
			logger.error(f"WiFi MIDI Fehler: {e}")
			connection_status['wifi'] = False
			return False

	def init_bluetooth_midi(self):
		"""Bluetooth MIDI initialisieren"""
		if not self.config['connections']['bluetooth']['enabled']:
			return False

		try:
			# Bluetooth MIDI (vereinfacht)
			# In Produktion würde man hier BLE MIDI implementieren
			connection_status['bluetooth'] = True
			logger.info("Bluetooth MIDI aktiviert")
			return True

		except Exception as e:
			logger.error(f"Bluetooth MIDI Fehler: {e}")
			connection_status['bluetooth'] = False
			return False

	def send_midi_message(self, msg_type, note, velocity=None):
		"""MIDI Message senden"""
		if velocity is None:
			velocity = self.config['midi']['velocity']

		channel = self.config['midi']['channel'] - 1

		with self.lock:
			# USB MIDI
			if self.outputs['usb'] and connection_status['usb']:
				try:
					if msg_type == 'note_on':
						msg = Message('note_on', note=note, velocity=velocity, channel=channel)
					elif msg_type == 'note_off':
						msg = Message('note_off', note=note, velocity=0, channel=channel)
					elif msg_type == 'cc':
						msg = Message('control_change', control=note, value=velocity, channel=channel)
					else:
						return False

					self.outputs['usb'].send(msg)
					logger.debug(f"USB MIDI gesendet: {msg}")
				except Exception as e:
					logger.error(f"USB MIDI Sende-Fehler: {e}")

			# WiFi MIDI (UDP Broadcast)
			if self.outputs['wifi'] and connection_status['wifi']:
				try:
					# Vereinfachtes MIDI-Protokoll über UDP
					data = f"{msg_type},{note},{velocity}".encode()
					self.outputs['wifi'].sendto(data, ('<broadcast>', self.config['connections']['wifi']['port']))
					logger.debug(f"WiFi MIDI gesendet: {msg_type},{note},{velocity}")
				except Exception as e:
					logger.error(f"WiFi MIDI Sende-Fehler: {e}")

	def start(self):
		"""Controller starten"""
		self.running = True
		logger.info("MIDI Controller wird gestartet...")

		self.init_usb_midi()
		self.init_wifi_midi()
		self.init_bluetooth_midi()

		logger.info("MIDI Controller gestartet")

	def stop(self):
		"""Controller stoppen"""
		self.running = False
		logger.info("MIDI Controller wird gestoppt...")

		with self.lock:
			if self.outputs['usb']:
				self.outputs['usb'].close()
			if self.outputs['wifi']:
				self.outputs['wifi'].close()

		logger.info("MIDI Controller gestoppt")


# Globaler Controller
controller = MIDIController()


# API Endpoints

@app.route('/')
def index():
	"""Hauptseite"""
	return send_from_directory('/var/www/midi-controller', 'index.html')

@app.route('/<path:path>')
def static_files(path):
	"""Statische Dateien"""
	return send_from_directory('/var/www/midi-controller', path)

@app.route('/api/config', methods=['GET'])
def get_config():
	"""Konfiguration abrufen"""
	return jsonify(controller.config)

@app.route('/api/config', methods=['POST'])
def update_config():
	"""Konfiguration aktualisieren"""
	try:
		new_config = request.json
		controller.config = new_config
		controller.save_config()

		# Controller neu initialisieren
		controller.stop()
		time.sleep(0.5)
		controller.start()

		return jsonify({'success': True, 'message': 'Konfiguration gespeichert'})
	except Exception as e:
		logger.error(f"Fehler beim Aktualisieren der Konfiguration: {e}")
		return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/status', methods=['GET'])
def get_status():
	"""Status abrufen"""
	return jsonify({
		'running': controller.running,
		'connections': connection_status,
		'available_ports': mido.get_output_names()
	})

@app.route('/api/midi/send', methods=['POST'])
def send_midi():
	"""MIDI Message senden"""
	try:
		data = request.json
		msg_type = data.get('type', 'note_on')
		note = data.get('note', 60)
		velocity = data.get('velocity', controller.config['midi']['velocity'])

		controller.send_midi_message(msg_type, note, velocity)

		return jsonify({'success': True})
	except Exception as e:
		logger.error(f"Fehler beim Senden der MIDI Message: {e}")
		return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/button/press', methods=['POST'])
def button_press():
	"""Button gedrückt"""
	try:
		data = request.json
		button_id = data.get('button_id')

		# Button-Konfiguration finden
		button = next((b for b in controller.config['buttons'] if b['id'] == button_id), None)

		if not button:
			return jsonify({'success': False, 'message': 'Button nicht gefunden'}), 404

		# MIDI Message senden
		if button['type'] == 'note':
			controller.send_midi_message('note_on', button['note'])
		elif button['type'] == 'cc':
			controller.send_midi_message('cc', button['note'], 127)

		return jsonify({'success': True})
	except Exception as e:
		logger.error(f"Fehler beim Button-Press: {e}")
		return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/button/release', methods=['POST'])
def button_release():
	"""Button losgelassen"""
	try:
		data = request.json
		button_id = data.get('button_id')

		# Button-Konfiguration finden
		button = next((b for b in controller.config['buttons'] if b['id'] == button_id), None)

		if not button:
			return jsonify({'success': False, 'message': 'Button nicht gefunden'}), 404

		# MIDI Message senden
		if button['type'] == 'note':
			controller.send_midi_message('note_off', button['note'])
		elif button['type'] == 'cc':
			controller.send_midi_message('cc', button['note'], 0)

		return jsonify({'success': True})
	except Exception as e:
		logger.error(f"Fehler beim Button-Release: {e}")
		return jsonify({'success': False, 'message': str(e)}), 500

@app.route('/api/restart', methods=['POST'])
def restart_controller():
	"""Controller neu starten"""
	try:
		controller.stop()
		time.sleep(0.5)
		controller.start()
		return jsonify({'success': True, 'message': 'Controller neu gestartet'})
	except Exception as e:
		logger.error(f"Fehler beim Neustart: {e}")
		return jsonify({'success': False, 'message': str(e)}), 500


def main():
	"""Hauptfunktion"""
	logger.info("=" * 50)
	logger.info("MIDI Controller startet...")
	logger.info("=" * 50)

	# Controller starten
	controller.start()

	# Web-Server starten
	try:
		app.run(host='0.0.0.0', port=5000, debug=False, threaded=True)
	except KeyboardInterrupt:
		logger.info("Beende durch Benutzer...")
	finally:
		controller.stop()


if __name__ == '__main__':
	main()
