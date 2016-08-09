/**
 * generic base class for Serial commands
 */
abstract class SerialCommand {
  private char cmdChar;
  private ArrayList<String> params;
  private int paramCount;
  
 /**
  * constructor
  *
  * @param char c the command char
  * @param int p the number of parameters this command will have
  */
  SerialCommand(char c, int p) {
    this.cmdChar    = c;
    this.paramCount = p;
    this.params     = new ArrayList<String>();
    
    this.initParams();
  }
  
 /**
  * initializes all parameters with the empty string
  */
  private void initParams() {
    for (int i = 0; i < this.paramCount; i++) {
      this.params.add("");
    }
  }
  
 /**
  * returns the command char
  *
  * @return char
  */
  char getCmdChar() {
    return this.cmdChar;
  }
  
 /**
  * returns the number of parameters this command has
  *
  * @return int
  */
  int getParamCount() {
    return this.paramCount;
  }
  
 /** 
  * returns all parameters
  *
  * @return ArrayList<String>
  */
  ArrayList<String> getParams() {
    return this.params;
  }
  
 /**
  * return the parameter at the given index
  *
  * @param int index
  * @return String
  */
  String getParam(int index) {
    String retval = "";
    
    if (index < this.paramCount) {
      retval = this.params.get(index);
    }
    
    return retval;
  }   
  
 /**
  * returns the parameter at the given index converted to int
  *
  * @param int index
  * @return String
  */
  String getParamAsString(int index) {
    String retval = "";
    
    if (index < this.paramCount) {
      retval = this.params.get(index);
    }
    
    return retval;
  }
  
 /**
  * returns the parameter at the given index converted to float
  *
  * @param int index
  * @return float
  */
  float getParamAsFloat(int index) {
    float retval = 0.0;
    
    if (index < this.paramCount) {
      retval  = this.convertBytesToFloat(
                  this.convertStringToBytes(
                    this.getParamAsString(index)
                  )
                );
    }
    
    return retval;
  }
  
 /**
  * returns the parameter at the given index converted to int
  *
  * @param int index
  * @return int
  */
  int getParamAsInt(int index) {
    int retval = 0;
    
    if (index < this.paramCount) {
      retval  = this.convertBytesToInt(
                  this.convertStringToBytes(
                    this.getParamAsString(index)
                  )
                );
    }
    
    return retval;
  }
  
 /**
  * sets the value of the parameter at the given index
  *
  * @param int index
  * @param String value
  */
  protected void setParam(int index, String value) {  
    if (index < this.paramCount) {
      this.params.set(index, value);
    }
  }
  
  /**
   * sets the value of the parameter at the given index from a String value
   * 
   * @param int index
   * @param String value
   */
  protected void setParamFromString(int index, String value) {
    this.setParam(index, value);
  }
  
 /**
  * sets the value of the parameter at the given index from an integer value
  *
  * @param int index
  * @param int value
  */
  protected void setParamFromInt(int index, int value) {
    this.setParamFromString(index, new String(this.convertIntToBytes(value)));
  }
  
 /**
  * sets the value of the parameter at the given index from a byte value
  * 
  * @param int index
  * @param byte value
  */
  protected void setParamFromByte(int index, byte value) {
    this.setParamFromString(index, new String(new byte[] {value}));
  }
  
 /**
  * sets the value of the parameter at the given index from a float value
  *
  * @param int index
  * @param float value
  */
  protected void setParamFromFloat(int index, float value) {
    this.setParamFromString(index, new String(this.convertFloatToBytes(value)));
  }
  
 /**
  * generic toString()
  *
  * @return String
  */
  public String toString() {
    String retval = this.cmdChar + "['";
    
    for (int i = 0; i < this.params.size(); i++) {
      retval += this.params.get(i);
      
      if (i < this.params.size() - 1) {
        retval += "','";
      }
    }
    
    retval += "']\n";
    
    return retval;
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
  * converts a Java float to four bytes and sends those individually, MSB first
  *
  * @param int number
  * @return byte[]
  */
  private byte[] convertFloatToBytes(float number) {
    return ByteBuffer.allocate(4).putFloat(number).array();
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
  * converts a Java int to four bytes and sends those individually, MSB first
  *
  * @param int number
  * @return byte[]
  */
  private byte[] convertIntToBytes(int number) {
    byte[] i = new byte[] {0,0,0,0};
    
    i[0] = (byte) (number >> 24);
    i[1] = (byte) (number >> 16);
    i[2] = (byte) (number >> 8);
    i[3] = (byte) (number);
    
    return i;    
  }
      
    
}