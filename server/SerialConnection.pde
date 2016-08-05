import processing.serial.*;

class SerialConnection {
  Serial port;
  ArrayList<String> inputBuffer;
  String currentBuffer;
  String processingBuffer;
  
  private static final char SRLCMD_CHAR_START = '#';
  private static final char SRLCMD_CHAR_CMDSEP = ':';
  private static final char SRLCMD_CHAR_PAYLOADSEP = ',';
  private static final char SRLCMD_CHAR_END = '\n';
  
  private static final byte SRLCMD_STATE_IDLE = 0;                 // ready to receive new command
  private static final byte SRLCMD_STATE_WAITINGFORCMDBYTE = 1;    // reveived the '#' start char, waiting for command byte
  private static final byte SRLCMD_STATE_CMDBYTERECEIVED = 2;      // received command char (is expecting a ':' separator char now)
  private static final byte SRLCMD_STATE_WAITINGFORPAYLOAD = 3;    // received separator ':' char, expects payload or terminator now
  private static final byte SRLCMD_STATE_CMDAVAILABLE = 4;         // received '\n' terminator char (possibly preceeded by payload chars)
  private static final byte SRLCMD_STATE_ERR = 10;                 // unexpected char over Serial. this error is irrecoverable at the moment
  
  private byte cmdState;
  
  /**
   * constructor.
   *
   * @param PApplet o
   * @param int baudrate
   */
  SerialConnection(PApplet o, int baudrate) {
    this.currentBuffer     = "";
    this.processingBuffer  = "";
    this.inputBuffer       = new ArrayList<String>();
    this.cmdState          = SerialConnection.SRLCMD_STATE_IDLE;
    
    if (Serial.list().length > 0) {
      String portName = Serial.list()[0]; //change the 0 to a 1 or 2 etc. to match your port
      this.port = new Serial(o, portName, baudrate);
      
      this.port.write(0x81);
    }
  }
  
  /** 
   * call this from the main applet inside the serialEvent() function like follows
   * where 'conn' is your instance of this SerialConnection class.
   *
   * void serialEvent (Serial sp) {
   *   conn.appendBuffer(sp.readString());
   * }
   */
  void appendBuffer(String stream) {
    this.currentBuffer += stream;
  }
  
  /**
   * processes the input buffer
   *
   * call this in draw() or periodically from somewhere else
   */
  void processSerial() {
    char inChar;
    
    // only read Serial data when there is no current command
    if (this.currentBuffer.length() > 0) {
      println(this.currentBuffer.length() + " bytes available over Serial. current state is " + this.cmdState + ", processingBuffer is '" + this.processingBuffer + "'");
          
      inChar = this.currentBuffer.charAt(0);
      this.currentBuffer = this.currentBuffer.substring(1);
      
      switch (this.cmdState) {
        case SerialConnection.SRLCMD_STATE_IDLE:
          if (inChar == SerialConnection.SRLCMD_CHAR_START) {
            this.processingBuffer += inChar;
            this.cmdState = SerialConnection.SRLCMD_STATE_WAITINGFORCMDBYTE;
          } else {
            this.cmdState = SerialConnection.SRLCMD_STATE_ERR;
          }
          break;
          
        case SerialConnection.SRLCMD_STATE_WAITINGFORCMDBYTE:
          this.processingBuffer += inChar;
          this.cmdState = SerialConnection.SRLCMD_STATE_CMDBYTERECEIVED;
          break;
          
        case SerialConnection.SRLCMD_STATE_CMDBYTERECEIVED:
          if (inChar == SerialConnection.SRLCMD_CHAR_CMDSEP) {
            this.processingBuffer += inChar;
            this.cmdState = SerialConnection.SRLCMD_STATE_WAITINGFORPAYLOAD;
          } else {
            this.cmdState = SerialConnection.SRLCMD_STATE_ERR;
          }        
          break;
         
        case SerialConnection.SRLCMD_STATE_WAITINGFORPAYLOAD:
          if (inChar == SerialConnection.SRLCMD_CHAR_END) {
            // payload end has been reached, move current buffer to queue
            this.inputBuffer.add(this.processingBuffer);
            this.processingBuffer = "";
            this.cmdState = SerialConnection.SRLCMD_STATE_IDLE;
          } else {
            // add inChar to payload for later processing
            this.processingBuffer += inChar;
          }
          break;
          
        case SerialConnection.SRLCMD_STATE_ERR:
          println("error reading from Serial");
          break;
      }
    }
  }
  
  /**
   * returns a response from the robot if a whole response has been received, the empty string otherwise
   *
   * @return String
   */
  String readResponse() {
    String response = "";
    
    if (this.inputBuffer.size() > 0) {
      response = this.inputBuffer.remove(0);
    }
    
    return response;
  }
  
  /**
   * returns true if the serial port is open, false otherwise
   *
   * @return boolean
   */
  boolean connected() {
    return (this.port != null);
  }
  
  /**
   * writes the byte stream to the serial connection
   *
   * @param ArrayList<Byte> stream
   */
  void write(ArrayList<Byte> stream) {
    if (this.port != null) {
      print("sending: ");
      for (Byte b : stream) {
        this.port.write((byte) b);
        print((byte) b + " ");
      }
      println("");
    }
  }
  
}