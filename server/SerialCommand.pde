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
  * returns the parameter at the given index converted to float
  *
  * @param int index
  * @return float
  */
  float getParamAsFloat(int index) {
    float retval = 0.0;
    
    if (index < this.paramCount) {
      retval = this.convertBytesToFloat(this.convertStringToBytes(this.params.get(index)));
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
      retval = this.convertBytesToInt(this.convertStringToBytes(this.params.get(index)));
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
  * converts a four byte representation of a integer into a int primitive
  *
  * @param byte[] b     expects a 4 byte array
  * @return int
  */
  private int convertBytesToInt(byte[] b) {
    byte[] f = new byte[]{b[0], b[1], b[2], b[3]};
    return ByteBuffer.wrap(f).getInt();
  }   
    
}