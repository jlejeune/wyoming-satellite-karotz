#!/bin/sh
# Run on the rabbit. Play raw audio (16 kHz, 16 bit, mono) from standard input on the speaker.
# Start it with: nc -ll -p 10002 -e /path/to/spk.sh
# The first line must stay "#!/bin/sh". Without it, nc -e cannot start the script.
exec ffmpeg -f s16le -ar 16000 -ac 1 -i - -f oss /dev/dsp 2>/dev/null
