import java.nio.ByteBuffer;


class CommandQueue {
  private SerialConnection conn;

  private ArrayList<ArrayList<Byte>> commandQueue;
  private ArrayList<String> inputQueue;
  /** 
   * the cmd*() functions will store the raw parameters in this buffer to
   * allow access to the values again once the confirmation from the robot
   * has been received without caching and unserializing the byte stream again
   */
  private ArrayList<ArrayList<Integer>> parameterBuffer;
  char lastCommand;
  private boolean cmdProcessed;
    
  final char CMD_NOOP = ' ';
  final char CMD_BATTERY = 'b';
  final char CMD_TURNLEFT = 'l';
  final char CMD_TURNRIGHT = 'r';
  final char CMD_MOVEFORWARD = 'f';
  final char CMD_MOVEBACKWARD = 'e';
  final char CMD_LCDCLEAR = 'c';
  final char CMD_LCDWRITE = 'w';
  final char CMD_SONARPING = 'p';
  final char CMD_SONARSWEEP = 's';
  
  
  CommandQueue(SerialConnection c) {
    this.commandQueue    = new ArrayList<ArrayList<Byte>>();
    this.inputQueue      = new ArrayList<String>();
    this.parameterBuffer = new ArrayList<ArrayList<Integer>>();
    this.conn            = c;
    this.lastCommand     = this.CMD_NOOP;
    this.cmdProcessed    = true;
  }
  
  int getCommandQueueSize() {
    return this.commandQueue.size();
  }
  
  int getInputQueueSize() {
    return this.inputQueue.size();
  }
  
  /**
   * call this from draw()
   *
   * will fetch all incoming data and store it in the input queue.
   *
   * after that both the input and the command queues are processed
   */
  void processQueues() {
    this.readFromSerial();
    this.processInputQueue();
    this.processCommandQueue();
  }

  /**
   * reads the input stream from the serial connection 
   * and fills the inputQueue
   *
   * no input processing is performed
   */
  private void readFromSerial() {
    String response;
    
    do {
      response = conn.processData();
      
      if (!"".equals(response)) {
        this.inputQueue.add(response);
      }
    } while(!"".equals(response));
  }
  
  /** 
   * processes every entry in the input queue
   */
  private void processInputQueue() {
    String response;
    String[] list;
    
    if (this.getInputQueueSize() > 0) {
      println(this.inputQueue.size() + " lines in the input queue");

      response = this.inputQueue.remove(0);
      
      if (!"".equals(response)) {
        list = splitTokens(response, ":,\n");
        println("serial input: " + response);
        println("last command: " + this.lastCommand);
        
        switch (this.lastCommand) {
          case CMD_BATTERY:
            processCmdBatteryResponse(list);
            break;
          case CMD_TURNLEFT:
          case CMD_TURNRIGHT:
          case CMD_MOVEFORWARD:
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
      }
    }
  }
  
  /**
   * if the serial connection is free the oldest
   * command is sent
   */
  private void processCommandQueue() {    
    ArrayList<Byte> cmdString;
    byte cmd;
    
    if (this.commandQueue.size() > 0) {
      println(this.commandQueue.size() + " commands in the queue");
      
      for (int i = 0; i < this.commandQueue.size(); i++) {
        println(this.commandQueue.get(i));
      }
      
      println("-----------");
    }
    
    if (this.commandQueue.size() > 0 && this.cmdProcessed) {
      cmdString = this.commandQueue.remove(0);
      cmd       = (byte) cmdString.get(1);
      
      println("sending command " + (char) cmd);
      this.lastCommand = (char) cmd;
      
      if (this.lastCommand == this.CMD_TURNLEFT 
          || this.lastCommand == this.CMD_TURNRIGHT) {
            
      } else if (this.lastCommand == this.CMD_MOVEFORWARD) {
      
      }
      
      
      this.conn.write(cmdString);
      this.cmdProcessed = false;
    }
  }
  
  /**
   * adds the given command with its parameters to the queue.
   *
   * returns true if the command was valid, false otherwise
   *
   * @param char cmd
   * @param Object... params
   * @return boolean
   */
  boolean addCommand(char cmd, Object... params) {
    boolean retval = false;
    Integer i, x, y, a, b, s;
    String t;
    
    switch(cmd) {
      case 'b': //this.CMD_BATTERY
        retval = this.cmdBattery();
        break;

      case 'l': //this.CMD_TURNLEFT
        i = (Integer) params[0];
        retval = this.cmdTurnLeft(i.intValue());
        break;
        
      case 'r': //this.CMD_TURNRIGHT
        i = (Integer) params[0];
        retval = this.cmdTurnRight(i.intValue());
        break;
        
      case 'f': //this.CMD_MOVEFORWARD
        i = (Integer) params[0];
        retval = this.cmdMoveForward(i.intValue());
        break;
        
      case 'e': //this.CMD_MOVEBACKWARD
        i = (Integer) params[0];
        retval = this.cmdMoveBackward(i.intValue());
        break;
        
      case 'c': //this.CMD_LCDCLEAR
        retval = this.cmdLcdClear(); 
        break;
        
      case 'w': //this.CMD_LCDWRITE
        x = (Integer) params[0];
        y = (Integer) params[1];
        t = (String)  params[2];
        retval = this.cmdLcdWrite(x.intValue(), y.intValue(), t);
        break;
        
      case 'p': //this.CMD_SONARPING
        i = (Integer) params[0];
        retval = this.cmdSonarPing(i.intValue());
        break;
        
      case 's': //this.CMD_SONARSWEEP
        a = (Integer) params[0];
        b = (Integer) params[1];
        s = (Integer) params[2];
        retval = this.cmdSonarSweep(a.intValue(), b.intValue(), s.intValue());
        break;
        
      default:
    }
    
    return retval;
  }
  
  
  
  
  /**
   * converts each of the parameters into a representation that is transmittable over Serial
   *
   * @param Object... objects
   * @return String
   */
  private ArrayList<Byte> serialize(Object... objects) {
    ArrayList<Byte> retval = new ArrayList<Byte>();
    byte[] tmp;
    
    for (Object o : objects) {
      if (o.getClass().equals(Integer.class)) {
        //println("...integer");
        Integer i = (Integer) o;
        tmp = this.makeSerialInt(i.intValue());
        
      } else if (o.getClass().equals(Float.class)) {
        //println("...float");
        Float f = (Float) o;
        tmp = this.makeSerialFloat(f.floatValue());
      
      } else if (o.getClass().equals(Byte.class)) {
        tmp = new byte[] {(byte) o};
        
      } else if (o.getClass().equals(String.class)) {
        //println("...string");
        tmp = this.makeSerialString((String) o);
        
      } else {
        println("...unrecognized type");
        tmp = null;
      }
      
      if (tmp != null) {
        
        for (Byte b : tmp) {
          retval.add(b);
        }
      }
    }  
    
    return retval;    
  }
  

  /**
   * converts a Java int to four bytes and sends those individually, MSB first
   *
   * @param int number
   * @return byte[]
   */
  private byte[] makeSerialInt(int number) {
    byte[] i = new byte[] {0,0,0,0};
    
    i[0] = (byte) (number >> 24);
    i[1] = (byte) (number >> 16);
    i[2] = (byte) (number >> 8);
    i[3] = (byte) (number);
    
    return i;    
  }
    
  /**
   * converts a Java float to four bytes and sends those individually, MSB first
   *
   * @param int number
   * @return byte[]
   */
    private byte[] makeSerialFloat(float number) {
    return ByteBuffer.allocate(4).putFloat(number).array();
  }
  
  /**
   * converts a Java String into its byte representation and sends those individually
   *
   * @param String text
   * @return String
   */
    private byte[] makeSerialString(String text) {
    int len = text.length();
    byte[] s = new byte[len];
    
    for (int i = 0; i < len; i++) {
      s[i] = byte(text.charAt(i));
    }
    
    return s;
  }    
  
  private float convertStringToFloat(String text) {
    return this.convertBytesToFloat(this.convertStringToBytes(text));
  }
  
  private int convertStringToInt(String text) {
    return this.convertBytesToInt(this.convertStringToBytes(text));
  }
  
  private byte[] convertStringToBytes(String text) {
    return text.getBytes();
  }
  
  /**
   * converts a four byte representation of a integer into a int primitive
   *
   * SHOULD NOT BE NECESSARY TO CALL THIS FROM HI-LEVEL FUNCTIONS
   *
   * @param byte[] b     expects a 4 byte array
   * @return int
   */
  private int convertBytesToInt(byte[] b) {
    byte[] f = new byte[]{b[0], b[1], b[2], b[3]};
    return ByteBuffer.wrap(f).getInt();
  }
  
  /**
   * converts a four byte representation of a float into a float primitive
   *
   * SHOULD NOT BE NECESSARY TO CALL THIS FROM HI-LEVEL FUNCTIONS
   *
   * @param byte[] b     expects a 4 byte array
   * @return float
   */
  private float convertBytesToFloat(byte[] b) {
    byte[] f = new byte[]{b[0], b[1], b[2], b[3]};
    return ByteBuffer.wrap(f).getFloat();
  }
  
    
  
  
  
  
  
  
  
  /**
   * sends the request for battery voltage to the m3pi
   *
   * @return boolean
   */
  private boolean cmdBattery() {
    ArrayList<Integer> params = new ArrayList<Integer>();
    this.parameterBuffer.add(params);
    
    this.commandQueue.add(this.serialize("#b:\n"));
 
    return true;
  }
  
  /**
   * sends the request to turn left by a number of degrees
   *
   * @param int angle
   * @return boolean
   */
  private boolean cmdTurnLeft(int angle) {
    ArrayList<Integer> params = new ArrayList<Integer>();
    params.add(angle);
    this.parameterBuffer.add(params);
    
    this.commandQueue.add(this.serialize("#l:", angle, "\n"));
    
    return true;
  }
  
  /**
   * sends the request to turn right by a number of degrees
   *
   * @param int angle
   * @return boolean
   */
  private boolean cmdTurnRight(int angle) {
    ArrayList<Integer> params = new ArrayList<Integer>();
    params.add(angle);
    this.parameterBuffer.add(params);
    
    this.commandQueue.add(this.serialize("#r:", angle, "\n"));
    
    return true;
  }
  
  /**
   * sends the request to move forward by a number of millimeters
   *
   * @param int distance
   * @return boolean
   */
  private boolean cmdMoveForward(int distance) {
    ArrayList<Integer> params = new ArrayList<Integer>();
    params.add(distance);
    this.parameterBuffer.add(params);
    
    this.commandQueue.add(this.serialize("#m:", distance, "\n"));
    
    return true;
  }
  
  /**
   * sends the request to move backward by a number of millimeters
   *
   * @param int distance
   * @return boolean
   */
  private boolean cmdMoveBackward(int distance) {
    ArrayList<Integer> params = new ArrayList<Integer>();
    params.add(distance);
    this.parameterBuffer.add(params);
    
    this.commandQueue.add(this.serialize("#e:", distance, "\n"));
    
    return true;
  }
  
  /**
   * sends the request to clear the LCD screen on the m3pi
   *
   * @return boolean
   */
  private boolean cmdLcdClear() {
    ArrayList<Integer> params = new ArrayList<Integer>();
    this.parameterBuffer.add(params);
    
    this.commandQueue.add(this.serialize("#c:\n"));
    
    return true;
  }
  
  /**
   * sends the request to write the given text on the x/y position provided
   * onto the LCD of the m3pi
   *
   * @param int x
   * @param int y
   * @param String text
   * @return boolean
   */
  private boolean cmdLcdWrite(int x, int y, String text) {
    ArrayList<Integer> params = new ArrayList<Integer>();
    params.add(x);
    params.add(y);
    this.parameterBuffer.add(params);
    
    this.commandQueue.add(this.serialize("#w:", x, ",", y, ",", text, "\n"));
    
    return true;
  }
  
  
  /**
   * sends the request to perform a ranging 'ping' into the given
   * direction
   *
   * @param int angle
   * @return boolean
   */
  private boolean cmdSonarPing(int angle) {  
    ArrayList<Integer> params = new ArrayList<Integer>();
    params.add(angle);
    this.parameterBuffer.add(params);
    
    this.commandQueue.add(this.serialize("#p:", angle, "\n"));
    
    return true;
  }
  
  /**
   * sends the request to perform a series of sonar ranging 'pings' from
   * startAngle to endAngle with stepSize angles intervals
   *
   * @param int startAngle
   * @param int endAngle
   * @param int stepSize
   * @return boolean
   */
  private boolean cmdSonarSweep(int startAngle, int endAngle, int stepSize) {
    ArrayList<Integer> params = new ArrayList<Integer>();
    params.add(startAngle);
    params.add(endAngle);
    params.add(stepSize);
    this.parameterBuffer.add(params);
    
    this.commandQueue.add(this.serialize("#s:", startAngle, ",", endAngle, ",", byte(stepSize), "\n"));
    
    return true;
  }  
  
  
  
  
  
  
  
  
  
    
  void processCmdCompletion(String[] list) {
    ArrayList<Integer> buffer;
    
    if (list[0].charAt(1) == 'K') {
      println("processing for command " + this.lastCommand + " complete");
      buffer = this.parameterBuffer.remove(0);
      
      if (this.lastCommand == this.CMD_TURNLEFT
          || this.lastCommand == this.CMD_TURNRIGHT) {
        bot.rotate(buffer.get(0).intValue());
            
      } else if (this.lastCommand == this.CMD_MOVEFORWARD) {
        
      }
      
      this.lastCommand = this.CMD_NOOP;
      this.cmdProcessed = true;
    }
  }
  
  void processCmdBatteryResponse(String[] list) {
    if (list[0].charAt(1) == 'B') {
      float v = this.convertStringToFloat(list[1]);
      println(v);
      bot.setVoltage(v);
    }
  }
  
  void processCmdSonarPingResponse(String[] list) {  
    if (list[0].charAt(1) == 'P') {
      int angle = this.convertStringToInt(list[1]);
      int range = this.convertStringToInt(list[2]);
      println("angle: "+ angle + " range: " + range);
      
      if (this.lastCommand == this.CMD_SONARPING) {
        this.lastCommand = this.CMD_NOOP;
      }
    } else if (list[0].charAt(1) == 'K' && this.lastCommand == this.CMD_SONARSWEEP) {
      this.lastCommand = this.CMD_NOOP;
    }
  }
}