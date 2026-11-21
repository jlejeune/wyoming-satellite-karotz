#!/bin/sh
# Run on the rabbit. Send the microphone as raw audio (16 kHz, 16 bit, mono) to standard output.
# Start it with: nc -ll -p 10001 -e /path/to/mic.sh
# The first line must stay "#!/bin/sh". Without it, nc -e cannot start the script.
exec ffmpeg -f oss -ac 1 -ar 16000 -i /dev/dsp -f s16le - 2>/dev/null
