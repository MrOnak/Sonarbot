import java.nio.ByteBuffer;


class CommandQueue {
 /** 
  * reference to the Serial connection to the robot
  */
  private SerialConnection conn;

 /**
  * queue of commands going to the robot
  */
  private ArrayList<ArrayList<Byte>> commandQueue;
  
 /**
  * queue of responses from the robot
  */
  private ArrayList<String> inputQueue;
  
  /** 
   * the cmd*() functions will store the raw parameters in this buffer to
   * allow access to the values again once the confirmation from the robot
   * has been received without caching and unserializing the byte stream again
   */
  private ArrayList<ArrayList<Integer>> parameterBuffer;
  char lastCommand;
  private boolean cmdProcessed;
    
  final static char CMD_NOOP         = ' ';
  final static char CMD_BATTERY      = 'b';
  final static char CMD_TURNLEFT     = 'l';
  final static char CMD_TURNRIGHT    = 'r';
  final static char CMD_MOVEFORWARD  = 'm';
  final static char CMD_MOVEBACKWARD = 'e';
  final static char CMD_LCDCLEAR     = 'c';
  final static char CMD_LCDWRITE     = 'w';
  final static char CMD_SONARPING    = 'p';
  final static char CMD_SONARSWEEP   = 's';
  
 /**
  * constructor
  *
  * @param SerialConnection c
  */
  CommandQueue(SerialConnection c) {
    this.commandQueue    = new ArrayList<ArrayList<Byte>>();
    this.inputQueue      = new ArrayList<String>();
    this.parameterBuffer = new ArrayList<ArrayList<Integer>>();
    this.conn            = c;
    this.lastCommand     = CommandQueue.CMD_NOOP;
    this.cmdProcessed    = true;
  }

 /**
  * returns the number of commands queued to be sent to the robot
  *
  * @return int
  */
  int getCommandQueueSize() {
    return this.commandQueue.size();
  }
  
 /** 
  * returns the number of responses from the robot that have yet to be processed
  *
  * @return int
  */
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
      response = conn.readResponse();
      
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
        list = this.unserialize(response);

        println("serial input: " + response);
        println("last command: " + this.lastCommand);
        
        switch (this.lastCommand) {
          case CommandQueue.CMD_BATTERY:
            processCmdBatteryResponse(list);
            break;
          case CommandQueue.CMD_TURNLEFT:
          case CommandQueue.CMD_TURNRIGHT:
          case CommandQueue.CMD_MOVEFORWARD:
          case CommandQueue.CMD_MOVEBACKWARD:
          case CommandQueue.CMD_LCDCLEAR:
          case CommandQueue.CMD_LCDWRITE:
            break;
          case CommandQueue.CMD_SONARPING:
          case CommandQueue.CMD_SONARSWEEP:
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
    
    if (this.commandQueue.size() > 0 && this.cmdProcessed) {
      cmdString = this.commandQueue.remove(0);
      cmd       = (byte) cmdString.get(1);
      
      println("sending command " + (char) cmd);
      this.lastCommand = (char) cmd;
                  
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
      case CommandQueue.CMD_BATTERY:
        retval = this.cmdBattery();
        break;

      case CommandQueue.CMD_TURNLEFT:
        i = (Integer) params[0];
        retval = this.cmdTurnLeft(i.intValue());
        break;
        
      case CommandQueue.CMD_TURNRIGHT:
        i = (Integer) params[0];
        retval = this.cmdTurnRight(i.intValue());
        break;
        
      case CommandQueue.CMD_MOVEFORWARD:
        i = (Integer) params[0];
        retval = this.cmdMoveForward(i.intValue());
        break;
        
      case CommandQueue.CMD_MOVEBACKWARD:
        i = (Integer) params[0];
        retval = this.cmdMoveBackward(i.intValue());
        break;
        
      case CommandQueue.CMD_LCDCLEAR:
        retval = this.cmdLcdClear(); 
        break;
        
      case CommandQueue.CMD_LCDWRITE:
        x = (Integer) params[0];
        y = (Integer) params[1];
        t = (String)  params[2];
        retval = this.cmdLcdWrite(x.intValue(), y.intValue(), t);
        break;
        
      case CommandQueue.CMD_SONARPING:
        i = (Integer) params[0];
        retval = this.cmdSonarPing(i.intValue());
        break;
        
      case CommandQueue.CMD_SONARSWEEP:
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
  * splits the raw byte stream into the command byte and the associated parameters.
  *
  * @param String stream
  * @return String[]
  */
  private String[] unserialize(String stream) {
    String[] retval;
    int params    = 0;
    
    // determine number of parameters based on command response byte
    switch (stream.charAt(1)) {
      case SerialConnection.SRLRSP_CHAR_COMPLETE:
        params = SerialConnection.SRLRSP_PARAMS_COMPLETE;
        retval = new String[params + 1];
        retval[0] = new StringBuilder("")
                      .append(SerialConnection.SRLCMD_CHAR_START)
                      .append(SerialConnection.SRLRSP_CHAR_COMPLETE)
                      .toString();
        break;
        
      case SerialConnection.SRLRSP_CHAR_BATTERY:
        params = SerialConnection.SRLRSP_PARAMS_BATTERY;
        retval = new String[params + 1];
        retval[0] = new StringBuilder("")
                      .append(SerialConnection.SRLCMD_CHAR_START)
                      .append(SerialConnection.SRLRSP_CHAR_BATTERY)
                      .toString();
        break;
        
      case SerialConnection.SRLRSP_CHAR_SONARPING:
        params = SerialConnection.SRLRSP_PARAMS_SONARPING;
        retval = new String[params + 1];
        retval[0] = new StringBuilder("")
                      .append(SerialConnection.SRLCMD_CHAR_START)
                      .append(SerialConnection.SRLRSP_CHAR_SONARPING)
                      .toString();
        break;
        
      default:
        println("unknown response command");
        retval = null;
    }
    
    // parameters can be parsed independent of command response byte now
    for (int i = 0; i < params; i++) {
      retval[1 + i] = "";
      for (int b = 0; b < 4; b++) {
        // 0123456789abc
        // #P:abcd,efgh\n
        retval[1 + i] += stream.charAt(3 + 5 * i + b);
      }
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
        Integer i = (Integer) o;
        tmp = this.makeSerialInt(i.intValue());
        
      } else if (o.getClass().equals(Float.class)) {
        Float f = (Float) o;
        tmp = this.makeSerialFloat(f.floatValue());
      
      } else if (o.getClass().equals(Byte.class)) {
        tmp = new byte[] {(byte) o};
        
      } else if (o.getClass().equals(String.class)) {
        tmp = this.makeSerialString((String) o);
        
      } else if (o.getClass().equals(Character.class)) {
        Character c = (Character) o;
        tmp = new byte[]{(byte) c.charValue()};
        
      } else {
        println("unrecognized type for serialization");
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
  
 /**
  * converts a float encapsulated in a string back to a float primitive
  *
  * @param String text
  * @return float
  */
  private float convertStringToFloat(String text) {
    return this.convertBytesToFloat(this.convertStringToBytes(text));
  }
  
 /**
  * converts a float encapsulated in a string back to a float primitive
  *
  * @param String text
  * @return int
  */
  private int convertStringToInt(String text) {
    return this.convertBytesToInt(this.convertStringToBytes(text));
  }
 
 /**
  * converts a string to an array of byte
  *
  * @param String text
  * @return byte[]
  */
  private byte[] convertStringToBytes(String text) {
    return text.getBytes();
  }
  
 /**
  * converts a four byte representation of a integer into a int primitive
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
    
    this.commandQueue.add(
      this.serialize(
        new StringBuilder("")
          .append(SerialConnection.SRLCMD_CHAR_START)
          .append(CommandQueue.CMD_BATTERY)
          .append(SerialConnection.SRLCMD_CHAR_CMDSEP)
          .append(SerialConnection.SRLCMD_CHAR_END)
          .toString()
      )
    );
 
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
    
    this.commandQueue.add(
      this.serialize(
        new StringBuilder("")
          .append(SerialConnection.SRLCMD_CHAR_START)
          .append(CommandQueue.CMD_TURNLEFT)
          .append(SerialConnection.SRLCMD_CHAR_CMDSEP)
          .toString(),
        angle, 
        SerialConnection.SRLCMD_CHAR_END
      )
    );
    
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
    
    this.commandQueue.add(
      this.serialize(
        new StringBuilder("")
          .append(SerialConnection.SRLCMD_CHAR_START)
          .append(CommandQueue.CMD_TURNRIGHT)
          .append(SerialConnection.SRLCMD_CHAR_CMDSEP)
          .toString(), 
        angle, 
        SerialConnection.SRLCMD_CHAR_END
      )
    );
    
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
    
    this.commandQueue.add(
      this.serialize(
        new StringBuilder("")
          .append(SerialConnection.SRLCMD_CHAR_START)
          .append(CommandQueue.CMD_MOVEFORWARD)
          .append(SerialConnection.SRLCMD_CHAR_CMDSEP)
          .toString(), 
        distance, 
        SerialConnection.SRLCMD_CHAR_END
      )
    );
    
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
    
    this.commandQueue.add(
      this.serialize(
        new StringBuilder("")
          .append(SerialConnection.SRLCMD_CHAR_START)
          .append(CommandQueue.CMD_MOVEBACKWARD)
          .append(SerialConnection.SRLCMD_CHAR_CMDSEP)
          .toString(), 
        distance, 
        SerialConnection.SRLCMD_CHAR_END
      )
    );
    
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
    
    this.commandQueue.add(
      this.serialize(
        new StringBuilder("")
          .append(SerialConnection.SRLCMD_CHAR_START)
          .append(CommandQueue.CMD_LCDCLEAR)
          .append(SerialConnection.SRLCMD_CHAR_CMDSEP)
          .append(SerialConnection.SRLCMD_CHAR_END)
          .toString()        
      )
    );
    
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
    
    this.commandQueue.add(
      this.serialize(
        new StringBuilder("")
          .append(SerialConnection.SRLCMD_CHAR_START)
          .append(CommandQueue.CMD_LCDWRITE)
          .append(SerialConnection.SRLCMD_CHAR_CMDSEP)
          .toString(), 
        x, 
        SerialConnection.SRLCMD_CHAR_PAYLOADSEP, 
        y, 
        SerialConnection.SRLCMD_CHAR_PAYLOADSEP, 
        text, 
        SerialConnection.SRLCMD_CHAR_END
      )
    );
    
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
    
    this.commandQueue.add(
      this.serialize(
        new StringBuilder("")
          .append(SerialConnection.SRLCMD_CHAR_START)
          .append(CommandQueue.CMD_SONARPING)
          .append(SerialConnection.SRLCMD_CHAR_CMDSEP)
          .toString(), 
        angle, 
        SerialConnection.SRLCMD_CHAR_END
      )
    );
    
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
    
    this.commandQueue.add(
      this.serialize(
        new StringBuilder("")
          .append(SerialConnection.SRLCMD_CHAR_START)
          .append(CommandQueue.CMD_SONARSWEEP)
          .append(SerialConnection.SRLCMD_CHAR_CMDSEP)
          .toString(), 
        startAngle, 
        SerialConnection.SRLCMD_CHAR_PAYLOADSEP,
        endAngle, 
        SerialConnection.SRLCMD_CHAR_PAYLOADSEP, 
        byte(stepSize), 
        SerialConnection.SRLCMD_CHAR_END
      )
    );
    
    return true;
  }  
  
  
  
  
  
  
  
  
  
 /** 
  * performs the necessary steps after the robot has confirmed command completion
  *
  * @param String[] list response data array
  */
  void processCmdCompletion(String[] list) {
    ArrayList<Integer> buffer;
    
    if (list[0].charAt(1) == SerialConnection.SRLRSP_CHAR_COMPLETE) {
      println("processing for command " + this.lastCommand + " complete");
      buffer = this.parameterBuffer.remove(0);
      
      if (this.lastCommand == CommandQueue.CMD_TURNLEFT
          || this.lastCommand == CommandQueue.CMD_TURNRIGHT) {
        bot.rotate(buffer.get(0).intValue());
            
      } else if (this.lastCommand == CommandQueue.CMD_MOVEFORWARD) {
        bot.move(buffer.get(0).intValue());
      }
      
      this.lastCommand = CommandQueue.CMD_NOOP;
      this.cmdProcessed = true;
    }
  }
  
 /**
  * updates the battery voltage after the robot has replied
  *
  * @param String[] list response data array
  */
  void processCmdBatteryResponse(String[] list) {
    if (list[0].charAt(1) == SerialConnection.SRLRSP_CHAR_BATTERY) {
      float v = this.convertStringToFloat(list[1]);
      println(v);
      bot.setVoltage(v);
    }
  }
  
 /**
  * updates the virtual landscape after the robot has replied with ping data
  *
  * @param String[] list response data array
  */
  void processCmdSonarPingResponse(String[] list) {  
    if (list[0].charAt(1) == SerialConnection.SRLRSP_CHAR_SONARPING) {
      int angle = this.convertStringToInt(list[1]);
      int range = this.convertStringToInt(list[2]);
      println("angle: "+ angle + " range: " + range);
      
      if (this.lastCommand == CommandQueue.CMD_SONARPING) {
        this.lastCommand = CommandQueue.CMD_NOOP;
      }
    } else if (list[0].charAt(1) == 'K' && this.lastCommand == CommandQueue.CMD_SONARSWEEP) {
      this.lastCommand = CommandQueue.CMD_NOOP;
    }
  }
}