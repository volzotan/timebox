#!/usr/bin/python
# -*- coding: utf-8 -*-

# Import der Module
import sys
import os

# 1-Wire Slave-Liste lesen
try:
    file = open('/sys/devices/w1_bus_master1/w1_master_slaves')
    w1_slaves = file.readlines()
    file.close()
except Exception as e:
    print("no sensor file found. exit")
    sys.exit(1)

if w1_slaves is None or len(w1_slaves) == 0 or (len(w1_slaves) == 1 and w1_slaves[1] == "not found."):
    print("no sensor found. exit")
    sys.exit(2)

# Fuer jeden 1-Wire Slave aktuelle Temperatur ausgeben
for line in w1_slaves:
  # 1-wire Slave extrahieren
  w1_slave = line.split("\n")[0]
  # 1-wire Slave Datei lesen
  file = open('/sys/bus/w1/devices/' + str(w1_slave) + '/w1_slave')
  filecontent = file.read()
  file.close()

  # Temperaturwerte auslesen und konvertieren
  stringvalue = filecontent.split("\n")[1].split(" ")[9]
  temperature = float(stringvalue[2:]) / 1000

  # Temperatur ausgeben
  print(str(w1_slave) + ': %6.2f °C' % temperature)

sys.exit(0)