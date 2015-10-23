In System Programmers based on the AVR Mega8 chip, including Arduino(tm)

Avrisp protocol firmware (includes support for fuses and locks).

**November 2011** Source code is now available on
[github](https://github.com/rsbohn/arduinoisp).

**June 2011** Haven't tried it, but perhaps the fastest way to get ArduinoISP working on the UNO is to disable the bootloader. Then when the board resets it goes right into ArduinoISP. Note: you will want some way to re-enable the bootloader.

**July 2009** How about a shield for the Arduino for use with mega-isp?
[mega-isp-shield](http://drug123.org.ua/mega-isp-shield/)

Older code:
Arduino-AVR910: works with AVRDude to copy your hex file to your AVR chip. If you already have an Arduino you can use it to burn projects to other AVR chips (Mega8, Tiny2313, Tiny13, etc).
