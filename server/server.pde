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

void setup() {
  size(1000, 1000);
  
  conn           = new SerialConnection(this, 115200);
  commandHandler = new CommandQueue(conn);
  bot            = new SonarBot(0, 0, 0.0, 5.0);
  grid           = new Landscape(1001, 1001);
   
  guiInit();
}

void draw() {
  conn.processSerial();
  commandHandler.processQueues();
  guiRefresh();
}

void serialEvent (Serial port) {
  conn.appendBuffer(port.readString());
}