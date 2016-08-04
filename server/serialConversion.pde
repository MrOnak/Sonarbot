
/**
 * takes any number of arguments and ends them over serial
 * in the order they've been given
 *
 * SHOULD NOT BE NECESSARY TO CALL THIS FROM HI-LEVEL FUNCTIONS
 *
 * @param Serial port
 * @param Object... objects
 */
void writeToSerial(Serial port, Object... objects) {
  for (Object o : objects) {
    if (o.getClass().equals(Integer.class)) {
      //println("...integer");
      Integer i = (Integer) o;
      writeIntToSerial(port, i.intValue());
      
    } else if (o.getClass().equals(Float.class)) {
      //println("...float");
      Float f = (Float) o;
      writeFloatToSerial(port, f.floatValue());
    
    } else if (o.getClass().equals(Byte.class)) {
      byte b = (byte) o;
      port.write(b);
      
    } else if (o.getClass().equals(String.class)) {
      //println("...string");
      String s = (String) o;
      writeStringToSerial(port, s);
      
    } else {
      println("...unrecognized type");
    }
  }
}

/**
 * converts a Java int to four bytes and sends those individually, MSB first
 *
 * SHOULD NOT BE NECESSARY TO CALL THIS FROM HI-LEVEL FUNCTIONS
 *
 * @param Serial port
 * @param int number
 * @return void
 */
void writeIntToSerial(Serial port, int number) {
  port.write((number >> 24));
  port.write((number >> 16));
  port.write((number >> 8));
  port.write(number);
}

/**
 * converts a Java float to four bytes and sends those individually, MSB first
 *
 * SHOULD NOT BE NECESSARY TO CALL THIS FROM HI-LEVEL FUNCTIONS
 *
 * @param Serial port
 * @param int number
 * @return void
 */
void writeFloatToSerial(Serial port, float number) {
  byte[] f = convertFloatToBytes(number);
  
  port.write(f[0]);
  port.write(f[1]);
  port.write(f[2]);
  port.write(f[3]);
}

/**
 * converts a Java String into its byte representation and sends those individually
 *
 * SHOULD NOT BE NECESSARY TO CALL THIS FROM HI-LEVEL FUNCTIONS
 *
 * @param Serial port
 * @param String text
 * @return void
 */
void writeStringToSerial(Serial port, String text) {
  int len = text.length();
  //println("..." + text);
  
  for (int i = 0; i < len; i++) {
    port.write(byte(text.charAt(i)));
  }
}


byte[] convertToByteArray(int integer) {
  byte[] b = new byte[] {0,0,0,0};
  
  b[0] = (byte) (integer >> 24);
  b[0] = (byte) (integer >> 16);
  b[0] = (byte) (integer >> 8);
  b[0] = (byte) (integer);
  
  return b;
}

float convertStringToFloat(String text) {
  return convertBytesToFloat(convertStringToBytes(text));
}

int convertStringToInt(String text) {
  return convertBytesToInt(convertStringToBytes(text));
}

/**
 * converts a four byte representation of a integer into a int primitive
 *
 * SHOULD NOT BE NECESSARY TO CALL THIS FROM HI-LEVEL FUNCTIONS
 *
 * @param byte[] b     expects a 4 byte array
 * @return int
 */
int convertBytesToInt(byte[] b) {
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
float convertBytesToFloat(byte[] b) {
  byte[] f = new byte[]{b[0], b[1], b[2], b[3]};
  return ByteBuffer.wrap(f).getFloat();
}

/**
 * converts a Java float primitive into a byte[4] array
 *
 * @param float number
 * @return byte[]
 */
byte[] convertFloatToBytes(float number) {
  return ByteBuffer.allocate(4).putFloat(number).array();
}

byte[] convertStringToBytes(String text) {
  return text.getBytes();
}