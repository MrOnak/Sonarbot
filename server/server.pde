/**
 * "Server" side of a solution that drives a m3pi robot with a sonar sensor attached
 * to a servo on top of it.
 *
 * The idea is to map the environment with the sonar sensor and navigate unknown terrain.
 */
SerialConnection conn;
CommandQueue     commandHandler;
SonarBot         bot;
Landscape        grid;
int              batteryCheckTimer;

void setup() {
  size(1000, 1000);
  
  conn              = new SerialConnection(this, 115200);
  commandHandler    = new CommandQueue(conn);
  bot               = new SonarBot(0, 0, 0.0, 5.0);
  grid              = new Landscape(1001, 1001);           // 10x10 m³
  batteryCheckTimer = 0;
   
  guiInit();
}

void draw() {
  conn.processSerial();
  commandHandler.processQueues();
  guiRefresh();
  
  if (batteryCheckTimer > 3600 * 5) {
    commandHandler.addCommand(CommandQueue.CMD_BATTERY);
    batteryCheckTimer = 0;
  }
  
  batteryCheckTimer++;
}

/**
 * is being called when data is available over the serial port from the robot
 *
 *  this function then pipes that data into a queue in SerialConnection to free up
 * the buffer on the mbed microcontroller ASAP
 */
void serialEvent (Serial port) {
  conn.appendBuffer(port.readString());
}