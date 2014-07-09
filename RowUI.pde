import processing.serial.*;

Serial port;                         // The serial port
char[] teapotPacket = new char[14];  // InvenSense Teapot packet
int serialCount = 0;                 // current packet byte position
int aligned = 0;
int interval = 0;

void setup() {
	size(512, 512);
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
	
	background(0);
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
			} else if (serialCount == 12) {
				if (ch == '\r') aligned++; else aligned = 0;
			} else if (serialCount == 13) {
				if (ch == '\n') aligned++; else aligned = 0;
			}
			//println(ch + " " + aligned + " " + serialCount);
			serialCount++;
			if (serialCount == 14) serialCount = 0;
		} else {
			if (serialCount > 0 || ch == '$') {
				teapotPacket[serialCount++] = (char)ch;
				if (serialCount == 14) {
					serialCount = 0; // restart packet byte position
					
					// get quaternion from data packet
					q[0] = ((teapotPacket[2] << 8) | teapotPacket[3]) / 16384.0f;
					q[1] = ((teapotPacket[4] << 8) | teapotPacket[5]) / 16384.0f;
					q[2] = ((teapotPacket[6] << 8) | teapotPacket[7]) / 16384.0f;
					q[3] = ((teapotPacket[8] << 8) | teapotPacket[9]) / 16384.0f;
					for (int i = 0; i < 4; i++) if (q[i] >= 2) q[i] = -4 + q[i];

					/*
					random shiz
					
					// calculate gravity vector
					gravity[0] = 2 * (q[1]*q[3] - q[0]*q[2]);
					gravity[1] = 2 * (q[0]*q[1] + q[2]*q[3]);
					gravity[2] = q[0]*q[0] - q[1]*q[1] - q[2]*q[2] + q[3]*q[3];
		
					// calculate Euler angles
					euler[0] = atan2(2*q[1]*q[2] - 2*q[0]*q[3], 2*q[0]*q[0] + 2*q[1]*q[1] - 1);
					euler[1] = -asin(2*q[1]*q[3] + 2*q[0]*q[2]);
					euler[2] = atan2(2*q[2]*q[3] - 2*q[0]*q[1], 2*q[0]*q[0] + 2*q[3]*q[3] - 1);
		
					// calculate yaw/pitch/roll angles
					ypr[0] = atan2(2*q[1]*q[2] - 2*q[0]*q[3], 2*q[0]*q[0] + 2*q[1]*q[1] - 1);
					ypr[1] = atan(gravity[0] / sqrt(gravity[1]*gravity[1] + gravity[2]*gravity[2]));
					ypr[2] = atan(gravity[1] / sqrt(gravity[0]*gravity[0] + gravity[2]*gravity[2]));
		
					// output various components for debugging
					//println("q:\t" + round(q[0]*100.0f)/100.0f + "\t" + round(q[1]*100.0f)/100.0f + "\t" + round(q[2]*100.0f)/100.0f + "\t" + round(q[3]*100.0f)/100.0f);
					//println("euler:\t" + euler[0]*180.0f/PI + "\t" + euler[1]*180.0f/PI + "\t" + euler[2]*180.0f/PI);
					//println("ypr:\t" + ypr[0]*180.0f/PI + "\t" + ypr[1]*180.0f/PI + "\t" + ypr[2]*180.0f/PI);
					*/
				}
			}
		}
	}
}
