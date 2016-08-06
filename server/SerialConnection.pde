import processing.serial.*;

class SerialConnection {
  Serial port;

 /**
  * this is the somewhat 'public' buffer of commands
  *
  * each entry in the array is a complete command.
  * while commands are still in transmission they are not in this array
  */
  ArrayList<String> inputBuffer;
  
 /** 
  * byte-stream from the robot. 
  *
  * this variable is being filled from the serialEvent() callback in the main applet
  */
  String currentBuffer;
  
 /**
  * buffer-in-progress. This is continuously being worked on as SerialConnection.processSerial() is called
  */
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
  
  private static final char SRLRSP_CHAR_COMPLETE  = 'K';
  private static final char SRLRSP_CHAR_BATTERY   = 'B';
  private static final char SRLRSP_CHAR_SONARPING = 'P';
  
  private static final int SRLRSP_PAYLOAD_COMPLETE  = 0;
  private static final int SRLRSP_PARAMS_COMPLETE   = 0;
  private static final int SRLRSP_PAYLOAD_BATTERY   = 4;
  private static final int SRLRSP_PARAMS_BATTERY    = 1;
  private static final int SRLRSP_PAYLOAD_SONARPING = 9;
  private static final int SRLRSP_PARAMS_SONARPING  = 2;
  
 /**
  * internal state of the state machine
  */
  private byte cmdState;
  
  /**
   * command pointer for internal processing
   */
  private char command;
  
  /**
   * counter for the length of the payload as currently processed from input stream
   */
  private int payloadLength;
  
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
    this.command           = '\0';
    this.payloadLength     = 0;
    
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
  * state machine that processes the data stream from the robot and provides a new
  * command as soon as it is fully transmitted
  *
  * call this in draw() or frequently from somewhere else
  */
  void processSerial() {
    char inChar;
    
    // only read Serial data when there is some
    if (this.currentBuffer.length() > 0) {
          
      // read left-most char from buffer
      inChar = this.currentBuffer.charAt(0);
      this.currentBuffer = this.currentBuffer.substring(1);
      
      // run the state machine
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
          this.command = inChar;
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
            // since the CHAR_END is a valid response byte in the payload we verify against expected payload length before publishing the response
            if ((this.command == SerialConnection.SRLRSP_CHAR_COMPLETE     && this.payloadLength == SerialConnection.SRLRSP_PAYLOAD_COMPLETE)
                || (this.command == SerialConnection.SRLRSP_CHAR_BATTERY   && this.payloadLength == SerialConnection.SRLRSP_PAYLOAD_BATTERY)
                || (this.command == SerialConnection.SRLRSP_CHAR_SONARPING && this.payloadLength == SerialConnection.SRLRSP_PAYLOAD_SONARPING)) {

              // payload end has been reached, move current buffer to queue and reset
              this.inputBuffer.add(this.processingBuffer);
              this.processingBuffer = "";
              this.payloadLength    = 0;
              this.cmdState = SerialConnection.SRLCMD_STATE_IDLE;
              
            } else {
              // add inChar to payload for later processing
              this.processingBuffer += inChar;
              this.payloadLength++;
            }
                
          } else {
            // add inChar to payload for later processing
            this.processingBuffer += inChar;
            this.payloadLength++;
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