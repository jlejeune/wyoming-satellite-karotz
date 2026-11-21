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

The files in the `rabbit` directory are for the rabbit. The directory `/usr` of the rabbit is flash memory and keeps its files after a reboot. When a client connects, the `inetd` program of the rabbit starts the two services.

1. Copy `karotz-mic.sh`, `karotz-spk.sh` and `set_mic_gain.py` to `/usr/scripts` on the rabbit, with FTP or telnet.
2. Run `chmod 755 /usr/scripts/karotz-mic.sh /usr/scripts/karotz-spk.sh /usr/scripts/set_mic_gain.py` on the rabbit.
3. Make a backup: `cp -p /usr/etc/inetd.conf /usr/etc/inetd.conf.bak`
4. Add these two lines at the end of `/usr/etc/inetd.conf`:

```
10001 stream tcp nowait root /usr/scripts/karotz-mic.sh karotz-mic.sh
10002 stream tcp nowait root /usr/scripts/karotz-spk.sh karotz-spk.sh
```

5. Tell `inetd` to read the file again: `kill -HUP $(pidof inetd)`
6. Make sure that the ports 23, 80, 10001 and 10002 of the rabbit accept connections.

A mistake in `inetd.conf` can stop telnet, the web interface and FTP at the same time. Keep a second telnet session open until step 6 succeeds. To undo the change, copy `inetd.conf.bak` over `inetd.conf` and run `kill -HUP $(pidof inetd)` again.

The microphone service sets the gain of the microphone at each connection. At gain 0 the microphone records only noise. The setting of the chip is lost at each reboot, so no other step is needed after a reboot. The services were tested after a reboot of the rabbit.

The services have no password. If a computer on your network connects to port 10001, it can listen to the microphone. Do not open these ports to the internet.

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
- If the rabbit restarts, the microphone connection stays open on the side of the container but receives no audio. The microphone relay stops after 10 seconds without audio, and the satellite connects again. Set `KAROTZ_IDLE_SECONDS` to change the 10 seconds.
- The upstream project wyoming-satellite is archived. This image does not receive upstream updates.

## License

MIT. See the file `LICENSE`.
