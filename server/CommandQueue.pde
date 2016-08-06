import java.nio.ByteBuffer;


class CommandQueue {
 /** 
  * reference to the Serial connection handler to the robot
  */
  private SerialConnection conn;

 /**
  * Class that abstracts the construction and parsing of Serial commands
  */
  private SerialCommandBuilder builder;
  
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
  
 /**
  * 'memory' of the last command sent over Serial
  */
  char lastCommand;
 
 /**
  * We're not sending commands over Serial until we have confirmation that
  * the robot has processed any previous command. This flag keeps track of
  * the state
  */
  private boolean cmdProcessed;
    
 /** 
  * Pointer for when no command is currently being processed
  */
  final static char CMD_NOOP = ' ';
  
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
    this.builder         = new SerialCommandBuilder();
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
    SerialCommand responseCmd;
    
    if (this.getInputQueueSize() > 0) {
      println(this.inputQueue.size() + " lines in the input queue");

      responseCmd = this.builder.parseFromString(
                      this.inputQueue.remove(0));
      
      if (responseCmd != null) {
        println("serial input: " + responseCmd);
        println("last command: " + this.lastCommand);
        
        switch (this.lastCommand) {
          case SerialRequestBattery.COMMAND_CHAR:
            processCmdBatteryResponse(responseCmd);
            break;
          case SerialRequestTurnleft.COMMAND_CHAR:
          case SerialRequestTurnright.COMMAND_CHAR:
          case SerialRequestMoveforward.COMMAND_CHAR:
          case SerialRequestMovebackward.COMMAND_CHAR:
          case SerialRequestLcdclear.COMMAND_CHAR:
          case SerialRequestLcdwrite.COMMAND_CHAR:
            break;
          case SerialRequestSonarping.COMMAND_CHAR:
          case SerialRequestSonarsweep.COMMAND_CHAR:
            processCmdSonarPingResponse(responseCmd);
            break;          
        }
        
        processCmdCompletion(responseCmd);
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
      cmd       = cmdString.get(1);
      
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
      case SerialRequestBattery.COMMAND_CHAR:
        retval = this.cmdBattery();
        break;

      case SerialRequestTurnleft.COMMAND_CHAR:
        i = (Integer) params[0];
        retval = this.cmdTurnLeft(i.intValue());
        break;
        
      case SerialRequestTurnright.COMMAND_CHAR:
        i = (Integer) params[0];
        retval = this.cmdTurnRight(i.intValue());
        break;
        
      case SerialRequestMoveforward.COMMAND_CHAR:
        i = (Integer) params[0];
        retval = this.cmdMoveForward(i.intValue());
        break;
        
      case SerialRequestMovebackward.COMMAND_CHAR:
        i = (Integer) params[0];
        retval = this.cmdMoveBackward(i.intValue());
        break;
        
      case SerialRequestLcdclear.COMMAND_CHAR:
        retval = this.cmdLcdClear(); 
        break;
        
      case SerialRequestLcdwrite.COMMAND_CHAR:
        x = (Integer) params[0];
        y = (Integer) params[1];
        t = (String)  params[2];
        retval = this.cmdLcdWrite(x.intValue(), y.intValue(), t);
        break;
        
      case SerialRequestSonarping.COMMAND_CHAR:
        i = (Integer) params[0];
        retval = this.cmdSonarPing(i.intValue());
        break;
        
      case SerialRequestSonarsweep.COMMAND_CHAR:
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
  * sends the request for battery voltage to the m3pi
  *
  * @return boolean
  */
  private boolean cmdBattery() {
    ArrayList<Integer> params = new ArrayList<Integer>();
    this.parameterBuffer.add(params);
    
    this.commandQueue.add(
      this.builder.serialize(SerialRequestBattery.COMMAND_CHAR)
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
      this.builder.serialize(SerialRequestTurnleft.COMMAND_CHAR, angle)
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
      this.builder.serialize(SerialRequestTurnright.COMMAND_CHAR, angle)
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
      this.builder.serialize(SerialRequestMoveforward.COMMAND_CHAR, distance)
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
      this.builder.serialize(SerialRequestMovebackward.COMMAND_CHAR, distance)
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
      this.builder.serialize(SerialRequestLcdclear.COMMAND_CHAR)
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
      this.builder.serialize(SerialRequestLcdwrite.COMMAND_CHAR, x, y, text)
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
      this.builder.serialize(SerialRequestSonarping.COMMAND_CHAR, angle)
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
      this.builder.serialize(SerialRequestSonarsweep.COMMAND_CHAR, startAngle, endAngle, stepSize)
    );
    
    return true;
  }  
  
  
  
  
  
  
  
  
  
 /** 
  * performs the necessary steps after the robot has confirmed command completion
  *
  * @param SerialCommand response
  */
  void processCmdCompletion(SerialCommand response) {
    ArrayList<Integer> buffer;
    
    if (response.getCmdChar() == SerialResponseComplete.COMMAND_CHAR) {
      println("processing for command " + this.lastCommand + " complete");
      buffer = this.parameterBuffer.remove(0);
      
      if (this.lastCommand == SerialRequestTurnleft.COMMAND_CHAR
          || this.lastCommand == SerialRequestTurnright.COMMAND_CHAR) {
        bot.rotate(buffer.get(0).intValue());
            
      } else if (this.lastCommand == SerialRequestMoveforward.COMMAND_CHAR) {
        bot.move(buffer.get(0).intValue());
      }
      
      this.lastCommand = CommandQueue.CMD_NOOP;
      this.cmdProcessed = true;
    }
  }
  
 /**
  * updates the battery voltage after the robot has replied
  *
  * @param SerialCommand response
  */
  void processCmdBatteryResponse(SerialCommand response) {
    if (response.getCmdChar() == SerialResponseBattery.COMMAND_CHAR) {
      float v = response.getParamAsFloat(0);
      bot.setVoltage(v);
    }
  }
  
 /**
  * updates the virtual landscape after the robot has replied with ping data
  *
  * @param SerialCommand response
  */
  void processCmdSonarPingResponse(SerialCommand response) {  
    if (response.getCmdChar() == SerialResponseSonarping.COMMAND_CHAR) {
      int angle = response.getParamAsInt(0);
      int range = response.getParamAsInt(1);
      println("angle: "+ angle + " range: " + range);
    }
  }
}