"""Read the microphone stream of the rabbit and write it to standard output.

The satellite starts this script as its microphone command.
Usage: mic_relay.py HOST PORT
"""
import socket
import sys

host, port = sys.argv[1], int(sys.argv[2])
sock = socket.create_connection((host, port), timeout=10)
sock.settimeout(None)
out = sys.stdout.buffer
while True:
    data = sock.recv(4096)
    if not data:
        break
    out.write(data)
    out.flush()
