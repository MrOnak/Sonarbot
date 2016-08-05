import processing.serial.*;

class SerialConnection {
  Serial port;
  String inputBuffer;
  
  private final char SRLCMD_CHAR_START = '#';
  private final char SRLCMD_CHAR_CMDSEP = ':';
  private final char SRLCMD_CHAR_PAYLOADSEP = ',';
  private final char SRLCMD_CHAR_END = '\n';
  
  private final byte SRLCMD_STATE_IDLE = 0;                 // ready to receive new command
  private final byte SRLCMD_STATE_WAITINGFORCMDBYTE = 1;    // reveived the '#' start char, waiting for command byte
  private final byte SRLCMD_STATE_CMDBYTERECEIVED = 2;      // received command char (is expecting a ':' separator char now)
  private final byte SRLCMD_STATE_WAITINGFORPAYLOAD = 3;    // received separator ':' char, expects payload or terminator now
  private final byte SRLCMD_STATE_CMDAVAILABLE = 4;         // received '\n' terminator char (possibly preceeded by payload chars)
  private final byte SRLCMD_STATE_PROCESSED = 5;            // post processing payload is finished and command can now be executed
  private final byte SRLCMD_STATE_FINISHED = 6;             // execution is done, clean up is required
  private final byte SRLCMD_STATE_ERR = 10;                 // unexpected char over Serial. this error is irrecoverable at the moment
  
  private byte cmdState;
  
  /**
   * constructor.
   *
   * @param PApplet o
   * @param int baudrate
   */
  SerialConnection(PApplet o, int baudrate) {
    this.inputBuffer = "";
    this.cmdState    = this.SRLCMD_STATE_IDLE;
    
    if (Serial.list().length > 0) {
      String portName = Serial.list()[0]; //change the 0 to a 1 or 2 etc. to match your port
      this.port = new Serial(o, portName, baudrate);
      
      this.port.write(0x81);
    }
  }
  
  /**
   * processes the input buffer
   *
   * call this in draw() or periodically from somewhere else
   *
   * @param String
   */
  String processData() {
    String val      = "";     // Data received from the serial port
    boolean success = false;
    char tmp;
  
    if (this.port != null && this.port.available() > 0) {
      tmp = this.port.readChar();
      if (tmp == '#' && this.port.available() > 0) {
        val += '#';
        tmp = this.port.readChar();
        
        switch(tmp) {
          case 'K':
            // general confirmation
            val += 'K';
            
            // wait till whole payload has arrived
            while (this.port.available() < 1) {}
            
            // read the remaining newline
            if (this.port.available() > 0) {
              tmp = this.port.readChar();
              if (tmp == '\n') {
                success = true;
              }
            }
            break;
            
          case 'B':
            // battery value, single int
            val += 'B';
            
            // wait till whole payload has arrived
            while (this.port.available() < 6) {}
            
            if (this.port.available() >= 6) {
              for (int i = 0; i < 5; i++) {
                val += this.port.readChar();
              }
              // read the remaining newline
              tmp = this.port.readChar();
              if (tmp == '\n') {
                success = true;
              }
            } else {
              println("not enough payload for 'B', 6 expected, " + this.port.available() + " actual");
            }
            break;
            
          case 'P':
            // sonar ping data, two ints, separated by comma
            val += 'P';
            
            // wait till whole payload has arrived
            while (this.port.available() < 11) {}
            
            if (this.port.available() >= 11) {
              for (int i = 0; i < 10; i++) {
                val += this.port.readChar();
              }
              // read the remaining newline
              tmp = this.port.readChar();
              if (tmp == '\n') {
                success = true;
              }
            } else {
              println("not enough payload for 'P', 11 expected, " + this.port.available() + " actual");
            }
            break;
            
          default:
            this.port.clear();
            println("unknown response command '" + tmp + "' in serial connection, 'B', 'K' and 'P' are valid");
        }
        
        if (!success) {
          println("error reading payload");
        }
        
      } else {
        this.port.clear();
        println("incorrect start character '" + tmp + "', '#' expected");
      }
    }
    
    if (!success) {
      val = "";
    } else {
      println("response: " + val);
    }
    
    return val;
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