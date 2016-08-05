/**
 * test script that is designed to test all serial commands to the m3pi
 */
import processing.serial.*;
import java.nio.ByteBuffer;

Serial m3piPort;                               // Serial connection to the bot

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

SonarBot bot = new SonarBot(0, 0, 0.0, 5.0);
Landscape grid = new Landscape(1001, 1001);

void setup() {
  size(1000, 1000);
  
  if (Serial.list().length > 0) {
    String portName = Serial.list()[0]; //change the 0 to a 1 or 2 etc. to match your port
    m3piPort = new Serial(this, portName, 115200);
    
    m3piPort.write(0x81);
  }
  
  command = CMD_NOOP;
  
  guiInit();
}

void draw() {
  guiRefresh();
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