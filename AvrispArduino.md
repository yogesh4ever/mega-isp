# AVRISP\_ARD #

This sketch allows you to use your Arduino with avrdude.


# Details #

To use first download the sketch to your Arduino. Connect the SPI lines to the target. Add LED's with current limiting resistors to lines 7-9 on the arduino. Then run avrdude as follows:

`avrdude -p t2313 -P com5 -c avrisp -b 19200`

The sketch is set to run at 19200 bps. It worked up to 57600 but failed at 115200. If you know how to get it working faster, or how to change the bitrate for AVRStudio please let me know.