# Run on the rabbit with its Python 2: python set_mic_gain.py
# Set the microphone gain and the input gain of the sound chip to 75.
# At gain 0 the microphone records only noise. The gain is a live setting of the chip.
# This script does not make it permanent, so run it again after each reboot.
import fcntl
import os
import struct

fd = os.open("/dev/mixer", os.O_RDWR)


def read_level(index):
    # The ioctl numbers are written as signed values because Python 2 on this 32-bit ARM needs it.
    request = (0x80044D00 + index) - (1 << 32)
    return struct.unpack("i", fcntl.ioctl(fd, request, struct.pack("i", 0)))[0]


def write_level(index, level):
    request = (0xC0044D00 + index) - (1 << 32)
    fcntl.ioctl(fd, request, struct.pack("i", level | (level << 8)))


for name, index in (("mic", 7), ("igain", 12)):
    write_level(index, 75)
    value = read_level(index)
    print("%s now left=%d right=%d" % (name, value & 255, (value >> 8) & 255))
