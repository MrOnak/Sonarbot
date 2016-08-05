/**
 * test script that is designed to test all serial commands to the m3pi
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
  guiRefresh();
  commandHandler.processQueues();
}