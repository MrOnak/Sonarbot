



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
//byte[] convertFloatToBytes(float number) {
//  return ByteBuffer.allocate(4).putFloat(number).array();
//}

byte[] convertStringToBytes(String text) {
  return text.getBytes();
}