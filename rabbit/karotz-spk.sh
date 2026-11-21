#!/bin/sh
# Run on the rabbit. inetd starts this script for each connection on port 10002.
# The standard input of the script is the network connection.
# The first line must stay "#!/bin/sh". Without it, inetd and nc -e cannot start the script.
#
# Play raw audio (16 kHz, 16 bit, mono) on the speaker.
exec ffmpeg -f s16le -ar 16000 -ac 1 -i - -f oss /dev/dsp 2>/dev/null
