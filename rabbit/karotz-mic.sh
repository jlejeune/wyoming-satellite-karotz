#!/bin/sh
# Run on the rabbit. inetd starts this script for each connection on port 10001.
# The standard output of the script is the network connection.
# The first line must stay "#!/bin/sh". Without it, inetd and nc -e cannot start the script.
#
# Set the microphone gain, then send the microphone as raw audio (16 kHz, 16 bit, mono).
python /usr/scripts/set_mic_gain.py >/dev/null 2>&1
exec ffmpeg -f oss -ac 1 -ar 16000 -i /dev/dsp -f s16le - 2>/dev/null
