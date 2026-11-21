"""Read the microphone stream of the rabbit and write it to standard output.

The satellite starts this script as its microphone command.
Usage: mic_relay.py HOST PORT

The rabbit sends audio without a pause. If no audio arrives for IDLE_SECONDS,
the connection is dead, for example because the rabbit restarted. The script
then stops with an error, and the satellite starts it again.
"""
import os
import socket
import sys

IDLE_SECONDS = float(os.environ.get("KAROTZ_IDLE_SECONDS", "10"))

host, port = sys.argv[1], int(sys.argv[2])
sock = socket.create_connection((host, port), timeout=10)
sock.settimeout(IDLE_SECONDS)
out = sys.stdout.buffer
try:
    while True:
        data = sock.recv(4096)
        if not data:
            break
        out.write(data)
        out.flush()
except socket.timeout:
    sys.stderr.write("mic_relay: no audio for %s seconds, stop\n" % IDLE_SECONDS)
    sys.exit(1)
