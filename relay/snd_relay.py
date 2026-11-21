"""Read audio from standard input and send it to the speaker service of the rabbit.

The satellite starts this script as its speaker command.
Usage: snd_relay.py HOST PORT
"""
import socket
import sys

host, port = sys.argv[1], int(sys.argv[2])
sock = socket.create_connection((host, port), timeout=10)
sock.settimeout(None)
inp = sys.stdin.buffer
while True:
    data = inp.read(4096)
    if not data:
        break
    sock.sendall(data)
sock.close()
