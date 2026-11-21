#!/bin/sh
# Start the Wyoming satellite for a Karotz rabbit.
# The settings come from environment variables, so the image holds no network data.
#
#   KAROTZ_HOST       Address of the rabbit. Required.
#   KAROTZ_MIC_PORT   Port of the microphone service on the rabbit. Default 10001.
#   KAROTZ_SND_PORT   Port of the speaker service on the rabbit. Default 10002.
#   SATELLITE_NAME    Name that Home Assistant shows. Default karotz.
#   WAKE_URI          Address of a Wyoming wake word service. For example tcp://openwakeword:10400.
#                     If it is not set, the server detects the wake word.
#   WAKE_WORD         Name of the wake word. Default ok_nabu.
#
# Extra arguments after the image name go to the satellite.
set -eu

: "${KAROTZ_HOST:?Set KAROTZ_HOST to the address of the rabbit}"
mic_port="${KAROTZ_MIC_PORT:-10001}"
snd_port="${KAROTZ_SND_PORT:-10002}"
name="${SATELLITE_NAME:-karotz}"
wake_word="${WAKE_WORD:-ok_nabu}"

set -- \
    --name "$name" \
    --uri tcp://0.0.0.0:10700 \
    --no-zeroconf \
    --mic-command "python /opt/relay/mic_relay.py $KAROTZ_HOST $mic_port" \
    --mic-command-rate 16000 --mic-command-width 2 --mic-command-channels 1 \
    --snd-command "python /opt/relay/snd_relay.py $KAROTZ_HOST $snd_port" \
    --snd-command-rate 16000 --snd-command-width 2 --snd-command-channels 1 \
    --mic-auto-gain 5 \
    --mic-noise-suppression 2 \
    "$@"

if [ -n "${WAKE_URI:-}" ]; then
    set -- --wake-uri "$WAKE_URI" --wake-word-name "$wake_word" "$@"
fi

exec python -m wyoming_satellite "$@"
