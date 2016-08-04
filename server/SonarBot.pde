/**
 * test script that is designed to test all serial commands to the m3pi
 */
import processing.serial.*;
import java.nio.ByteBuffer;

Serial m3piPort;                               // Serial connection to the bot

int buttonStartX = 10;
int buttonLength = 200;
int buttonHeight = 40;

int batteryButtonStartY = 10;
int turnLeftButtonStartY = 60;
int turnRightButtonStartY = 110;
int moveFwdButtonStartY = 160;
int moveBackButtonStartY = 210;
int lcdClearButtonStartY = 260;
int lcdWriteButtonStartY = 310;
int sonarPingButtonStartY = 360;
int sonarSweepButtonStartY = 410;

final char CMD_NOOP = ' ';
final char CMD_BATTERY = 'b';
final char CMD_TURNLEFT = 'l';
final char CMD_TURNRIGHT = 'r';
final char CMD_MOVESTRAIGHT = 'm';
final char CMD_MOVEFORWARD = 'f';
final char CMD_MOVEBACKWARD = 'e';
final char CMD_LCDCLEAR = 'c';
final char CMD_LCDWRITE = 'w';
final char CMD_SONARPING = 'p';
final char CMD_SONARSWEEP = 's';

char command;

void setup() {
  size(500, 500);
  
  if (Serial.list().length > 0) {
    String portName = Serial.list()[0]; //change the 0 to a 1 or 2 etc. to match your port
    m3piPort = new Serial(this, portName, 115200);
    
    m3piPort.write(0x81);
  }
  
  command = CMD_NOOP;
  
  initGui();
}

void draw() {
  getSerialData();
}



/**
 * retrieves sonar data and updates the latest dataset
 */
void getSerialData() {
  String val;     // Data received from the serial port
  String[] list;

  if (m3piPort != null && m3piPort.available() > 0) {  
    val = m3piPort.readStringUntil('\n');         // read it and store it in val
    
    if (val != null) {
      list = splitTokens(val, ":,\n");
      println("serial input: " + val);
      println("last command: " + command);
      
      switch (command) {
        case CMD_BATTERY:
          processCmdBatteryResponse(list);
          break;
        case CMD_TURNLEFT:
        case CMD_TURNRIGHT:
        case CMD_MOVESTRAIGHT:
        case CMD_MOVEBACKWARD:
        case CMD_LCDCLEAR:
        case CMD_LCDWRITE:
          break;
        case CMD_SONARPING:
        case CMD_SONARSWEEP:
          processCmdSonarPingResponse(list);
          break;          
      }
      
      processCmdCompletion(list);
      processReset(list);
    }
  } 
}