import processing.serial.*;

class SerialConnection {
  Serial port;
  
  /**
   * constructor.
   *
   * @param PApplet o
   * @param int baudrate
   */
  SerialConnection(PApplet o, int baudrate) {
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
    String val = "";     // Data received from the serial port
  
    if (this.port != null && this.port.available() > 0) {  
      val = this.port.readStringUntil('\n');         // read it and store it in val
      
      if (val == null) {
        val = "";
      } else {
        println("response: " + val);
      }
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