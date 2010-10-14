sketch:
	-mkdir ArduinoISP
	-cp avrisp/ArduinoISP.pde ArduinoISP

clean:
	-rm -rf ArduinoISP
	-rm ArduinoISP*.zip

dist: ArduinoISP
	zip -r ArduinoISP.zip ArduinoISP

classic: avrisp/ArduinoISP.pde
	cp avrisp/ArduinoISP.pde avrisp/avrisp.pde

update.bat:
	echo "mkdir ArduinoISP" > update.bat
	echo "copy avrisp\ArduinoISP.pde ArduinoISP" >> update.bat
