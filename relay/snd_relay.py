"""Read audio from standard input and send it to the speaker service of the rabbit.

The satellite starts this script as its speaker command.
Usage: snd_relay.py HOST PORT

If the rabbit does not accept data for SEND_SECONDS, the script stops with an error.
"""
import os
import socket
import sys

SEND_SECONDS = float(os.environ.get("KAROTZ_SEND_SECONDS", "30"))

host, port = sys.argv[1], int(sys.argv[2])
sock = socket.create_connection((host, port), timeout=10)
sock.settimeout(SEND_SECONDS)
inp = sys.stdin.buffer
try:
    while True:
        data = inp.read(4096)
        if not data:
            break
        sock.sendall(data)
except socket.timeout:
    sys.stderr.write("snd_relay: the rabbit did not accept audio for %s seconds, stop\n" % SEND_SECONDS)
    sys.exit(1)
finally:
    sock.close()
