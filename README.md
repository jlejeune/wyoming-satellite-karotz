# wyoming-satellite-karotz

This project turns a Karotz rabbit into a voice assistant for Home Assistant. It builds a container image that runs the Wyoming satellite and connects it to two small services on the rabbit.

The Wyoming protocol is the way that Home Assistant talks to voice devices and voice services. A satellite is the program that links a microphone and a speaker to those services.

## How it works

The rabbit runs two TCP services. The microphone service sends raw audio. The speaker service plays raw audio that it receives.

The container runs wyoming-satellite 1.4.1. It reads the microphone service, detects the wake word, and sends your question to Home Assistant. It sends the answer to the speaker service.

Home Assistant uses its own speech to text and text to speech services. The container does not hold them.

## Requirements

- A Karotz rabbit that runs Free Rabbits OS. The rabbit must have `ffmpeg` and the `nc` command of BusyBox.
- Home Assistant with the Wyoming integration.
- A Wyoming wake word service, for example wyoming-openwakeword.

## Set up the rabbit

The files in the `rabbit` directory are for the rabbit. Copy them to the rabbit with FTP or telnet.

1. Run `python set_mic_gain.py` on the rabbit. The microphone records only noise at gain 0. The setting is lost at each reboot.
2. Start the microphone service: `nohup nc -ll -p 10001 -e /path/to/mic.sh &`
3. Start the speaker service: `nohup nc -ll -p 10002 -e /path/to/spk.sh &`

The services have no password. Anyone on your network can listen to the microphone while the service runs. Do not open these ports to the internet.

The tests used `nc -ll -e` to start the services by hand. Starting them at each boot is not tested yet.

## Run the container

The image is `ghcr.io/jlejeune/wyoming-satellite-karotz`. These environment variables set it up:

| Variable | Meaning | Default |
|---|---|---|
| `KAROTZ_HOST` | Address of the rabbit | required |
| `KAROTZ_MIC_PORT` | Port of the microphone service | `10001` |
| `KAROTZ_SND_PORT` | Port of the speaker service | `10002` |
| `SATELLITE_NAME` | Name that Home Assistant shows | `karotz` |
| `WAKE_URI` | Address of the wake word service, for example `tcp://openwakeword:10400` | not set |
| `WAKE_WORD` | Name of the wake word | `ok_nabu` |

If you do not set `WAKE_URI`, the server detects the wake word. Extra arguments after the image name go to the satellite.

```
docker run -p 10700:10700 \
  -e KAROTZ_HOST=rabbit.example \
  -e WAKE_URI=tcp://openwakeword.example:10400 \
  ghcr.io/jlejeune/wyoming-satellite-karotz:latest
```

In Home Assistant, add the Wyoming integration. Enter the address of the container and port 10700. Then pick a voice assistant for the new device.

## Known limits

- The microphone of the rabbit has a high noise floor. The satellite uses noise suppression and automatic gain to work around it. Speak close to the rabbit.
- The rabbit has no echo cancellation. Its own speaker can disturb the microphone.
- The upstream project wyoming-satellite is archived. This image does not receive upstream updates.

## License

MIT. See the file `LICENSE`.
