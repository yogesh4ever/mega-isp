// rsbohn 25 July 2007
// adapted/extended from the avr910 assembler code
// this is so I can use avrdude to program chips
// I would use a different syntax otherwise...

#define LED 9
#define SCK 13
#define MISO 12
#define MOSI 11
#define RESET 10

#define SWVER "23"
#define HWVER "10"
#define PACE 50

char *DeviceList = "\x01\x56\x76\x5e";
byte device=1; // device type, get from avrdude
int here = 0; // current memory location
int last = -1;
byte cmdlog[16];
byte logcount = 0;
byte DEBUG = 0;

void spiInit();


void setup() {
  Serial.begin(19200);
  pinMode(LED, OUTPUT);
  digitalWrite(LED, HIGH);
  delay(100);
  //spiInit();
  digitalWrite(LED, LOW);
}

byte ReadChar() {
  do {} while (!Serial.available());
  return Serial.read();
}
void loop() {
  char ch;
  ch = ReadChar();
  //Serial.print(ch);
  //Serial.print(' ');
  cmdlog[logcount++ & 0x0F] = ch;
  Dispatch(ch);
}

void bprint(byte b) {
  if (b < 0x10) Serial.print('0');
  Serial.print(b, HEX);
}

/// SPI Routines 
////////////////////////////////////////////////////////////
void spiInit() {
  byte x;
  SPCR = 0x53;
  x=SPSR; x=SPDR; // read to clear them
  //digitalWrite(SCK, LOW);
}
void spiBusyWait() {
  do {} while (!(SPSR & (1 << SPIF)));
  //delay(PACE);
}

byte spiXfer(byte b) {
  byte reply;
  if (DEBUG) {
    bprint(b);
    bprint(SPSR);
  }
  //spiBusyWait();
  //delay(PACE);
  // writing SPDR starts transfer
  SPDR=b;
  spiBusyWait();
  // get reply from SPDR
  reply = SPDR;
  if (DEBUG) {
    Serial.print("::");
    bprint(reply);
    Serial.println();
  }
  return SPDR;
}
byte spiTransaction(byte a, byte b, byte c, byte d) {
  spiXfer(a);
  spiXfer(b);
  spiXfer(c);
  return spiXfer(d);
}


void SelectDevice(byte b) {
  device=b;
}
void EnableProgramMode() {
  //Serial.println("Enable Program Mode");
  pinMode(MISO, INPUT);
  pinMode(MOSI, OUTPUT);
  pinMode(SCK, OUTPUT);
  pinMode(RESET, OUTPUT);
  spiInit();
  digitalWrite(RESET, HIGH);
  digitalWrite(SCK, LOW);
  delay(50);
  digitalWrite(RESET, LOW);
  spiTransaction(0xAC, 0x53, 0x00, 0x00);
  digitalWrite(LED, HIGH);
}
void LeaveProgramMode() {
  pinMode(MISO, INPUT);
  pinMode(MOSI, INPUT);
  pinMode(SCK, INPUT);
  pinMode(RESET, INPUT);
  digitalWrite(LED, LOW);
}

void ListSupportedDevices() {
  Serial.print(DeviceList);
  Serial.print(0, BYTE);
}

void WriteProgH(byte b) {
  spiTransaction(0x48, 
    (here >> 8) & 0xFF,
    here & 0xFF,
    b);
    // delay?
  here++;
}
void WriteProgL(byte b) {
  spiTransaction(0x40, 
    (here >> 8) & 0xFF,
    here & 0xFF,
    b);
    // delay?
  //here++;
}

void ReadProg() {
  byte d = spiTransaction(0x28, 
    (here >> 8) & 0xFF,
    here & 0xFF,
    0);
  Serial.print(d, BYTE);
  d = spiTransaction(0x20,
    (here >> 8) & 0xFF,
    here & 0xFF,
    0);
  Serial.print(d, BYTE);
  here++;
}

//void LoadAddress(byte ah, byte al) {
//whatever:
void LoadAddress(byte al, byte ah) {
  here = ah;
  here = here * 256;
  here = here | al;
  last = here;
}

// write EEPROM
void WriteData(byte b) {
  spiTransaction(0xC0,
    (here >> 8) & 0xFF,
    here & 0xFF,
    b);
    here++;
}
void ReadData() {
  byte b = spiTransaction(0xA0,
    (here >> 8) & 0xFF,
    here & 0xFF,
    0);
  Serial.print(b, BYTE);
  here++;
}
void ChipErase() {
  spiTransaction(0xac, 0x80, 0x04, 0x00);
}

void ReadSignature() {
  byte b;
  b = spiTransaction(0x30, 0x00, 0x02, 0x00);
  Serial.print(b, BYTE);
  b = spiTransaction(0x30, 0x00, 0x01, 0x00);
  Serial.print(b, BYTE);
  b = spiTransaction(0x30, 0x00, 0x00, 0x00);
  Serial.print(b, BYTE);
}

void WriteProgramPage() {
  spiTransaction(0x4C,
    (here >> 8) & 0xFF,
    here & 0xFF,
    0);
}

void Universal(byte a, byte b, byte c, byte d) {
  byte reply;
  reply = spiTransaction(a, b, c,d);
  Serial.print(reply, BYTE);
}

void todo(char *feature) {
  Serial.print("Not Implemented ");
  Serial.println(feature);
}

void SelfTest() {
  Serial.println("AVR910");
  Serial.print(logcount, HEX);
  Serial.println(" commands received:");
  for (byte lx = 0; lx < 16; lx++) {
    if (cmdlog[lx]) Serial.print(cmdlog[lx], BYTE);
    else Serial.print('~');
  }
  Serial.println();
  Serial.print("Device is ");
  Serial.print(device, HEX);
  Serial.print(", DDRB is ");
  bprint(DDRB);
  Serial.println();
  Serial.print("SPCR is ");
  bprint(SPCR);
  Serial.println();
  Serial.print(last, HEX);
  Serial.print(' ');
  Serial.println(here, HEX);
  DEBUG = 1;
  //Dispatch('s');
  //DEBUG = 0;
}
/// Dispatch
/// -------- /////////////////////////////////////////////// +++++
void Dispatch(char ch) {
  if (ch == 'T') SelectDevice(ReadChar());
  if (ch == 'S') // show_id
    {Serial.print("AVR ISP"); return;}
  if (ch == 'V') //todo("Software Version");
    {Serial.print(SWVER); return;}
  if (ch == 'v') //todo("Hardware Version");
    {Serial.print(HWVER); return;}
  if (ch == 't') {
    ListSupportedDevices();
    return;
  }
  if (ch == 'p') {
    Serial.print('S'); // Serial type programmer.
    return;
  }
  if (ch == 'a') {
    Serial.print('Y'); // we support autoincrement
    return;
  }
  if (ch == 'x') digitalWrite(LED, HIGH); // x,y ignored in AVR910
  if (ch == 'y') digitalWrite(LED, LOW);  // but not here!
  //if (device == 0) // need a device from here on out...
  //  {Serial.print('?'); return;}
  if (ch == 'P') EnableProgramMode();
  if (ch == 'C') WriteProgH(ReadChar());
  if (ch == 'c') WriteProgL(ReadChar());
  if (ch == 'R') 
    {ReadProg(); return;}
  if (ch == 'A') LoadAddress(ReadChar(), ReadChar());
  if (ch == 'D') WriteData(ReadChar());
  if (ch == 'd') 
    {ReadData(); return;}
  if (ch == 'L') LeaveProgramMode();
  if (ch == 'e') ChipErase();
  if (ch == 'l') todo("Write Lock Bits");
  if (ch == 's') 
    {ReadSignature(); return;}
  // seems to read them 02 01 00 for some reason.
  // see what avrdude wants!
  if (ch == 'm') WriteProgramPage();
  if (ch == ':') 
    Universal(ReadChar(),ReadChar(),ReadChar(),0);
  if (ch == '.') 
    Universal(ReadChar(),ReadChar(),ReadChar(),ReadChar());
  if (ch == '$') SelfTest();
  if (ch == '0') LoadAddress(0,0);
  // put_ret ;send CR
  Serial.print(0x0D, BYTE);
}
