import processing.serial.*;

Serial port;
//char[] packet = new char[14];
char[] packet = {'1',
  '1', '5', '5', 
  '0', '1', '5', 
  '0', '1', '0'};
char[] data = {
  0, 0, 0,
  0, 0, 0,
  0, 0, 0
}
int serialCount = 0;
int aligned = 0;
int interval = 0;

float vely = 10;
int posy = 50;
void setup() {
	size(512, 512);
        fill(0, 0, 0);
	println(Serial.list()); // meh
	String portName = Serial.list()[0]; // find out which serial port we're using//String portName = "COM4";
	port = new Serial(this, portName, 9600);
	port.write('r'); // initialize the communication by sending a single character
        
}

void draw() {
	if (millis() - interval > 1000) {
		// resend single character to trigger DMP init/start
		// in case the MPU is halted/reset while applet is running
		port.write('r');
		interval = millis();
	}
	background(255);
        text("Acc: {" 
          + str(packet[1]) + ", "
          + str(packet[2]) + ", "
          + str(packet[3]) + "}"
          , 0, 15
        );
        text("Gyr: {" 
          + str(packet[4]) + ", "
          + str(packet[5]) + ", "
          + str(packet[6]) + "}"
          , 0, 30
        );
        text("Mag: {" 
          + str(packet[7]) + ", "
          + str(packet[8]) + ", "
          + str(packet[9]) + "}"
          , 0, 45
        );
}

void serialEvent(Serial port) {
	interval = millis();
	while (port.available() > 0) {
		int ch = port.read();
		print((char)ch);
		if (aligned < 4) {
			// make sure we are properly aligned on a 14-byte packet
			if (serialCount == 0) {
				if (ch == '$') aligned++; else aligned = 0;
			} else if (serialCount == 1) {
				if (ch == 2) aligned++; else aligned = 0;
			}
			println(ch + " " + aligned + " " + serialCount);
			serialCount++;
			if (serialCount == 14) serialCount = 0;
		} else {
			if (serialCount > 0 || ch == '$') {
				teapotPacket[serialCount++] = (char)ch;
				if (serialCount == 14) {
					serialCount = 0; // restart packet byte position
					for (int i = 0; i < 4; i++)
						if (q[i] >= 2)
							q[i] = -4 + q[i];
				}
			}
		}
	}
} */
