/**
 * Utility class that is able to build instances of subclasses of SerialCommand
 * based on an input stream
 */
class SerialCommandBuilder {
  SerialCommandFactory f;
  
 /**
  * constructor
  */
  SerialCommandBuilder() {
    f = new SerialCommandFactory();
  }
    

 /** 
  * returns the matching SerialCommand implementation based on a raw input string
  *
  * @param String stream
  * @return SerialCommand
  */
  SerialCommand parseFromString(String stream) {
    char cmdByte             = '\0';
    ArrayList<String> params = new ArrayList<String>();
    int paramCount = 0;
    int sepCount   = 0;
    String tmpParam;
    
    // do some basic integrity testing
    if (stream.charAt(0) == SerialConnection.SRLCMD_CHAR_START
      && stream.charAt(2) == SerialConnection.SRLCMD_CHAR_CMDSEP
      && stream.charAt(stream.length()-1) == SerialConnection.SRLCMD_CHAR_END) {
        
        // store the command byte
        cmdByte = stream.charAt(1);
        
        // determine number of parameter separators, this works since we assume all parameters are 4 byte long
          //#K:N                  length() =  4  4-4  =  0  floor(0/5)  = 0 separators   0-0 = 0    0/4 = 0
          //#B:abcdN              length() =  8  8-4  =  4  floor(4/5)  = 0 separators   4-0 = 4    4/4 = 1
          //#P:abcd,efghN         length() = 13  13-4 =  9  floor(9/5)  = 1 separators   9-1 = 8    8/4 = 2
          //#X:abcd,efgh,ijklN    length() = 18  18-4 = 14  floor(14/5) = 2 separators  14-2 = 12  12/4 = 3

        sepCount   = floor((stream.length() - 4) / 5);
        paramCount = (stream.length() - 4 - sepCount) / 4;
        
        // fetch all parameters
        for (int i = 0; i < paramCount; i++) {
          tmpParam = "";
          for (int b = 0; b < 4; b++) {
            tmpParam += stream.charAt(3 + 5 * i + b);
          }
          params.add(tmpParam);
        }        
        
    } else {
      println("SerialCommandBuider can't parse the input stream into a command, syntax error");
    }
    
    if (paramCount > 0) {
      return f.makeCommand(cmdByte, params);
    } else {
      return f.makeCommand(cmdByte);
    }
  } 
  
 /** 
  * serializes an instance of SerialCommand for transmission over Serial port
  *
  * @param SerialCommand cmd
  * @return ArrayList<Byte>
  */
  ArrayList<Byte> serialize(SerialCommand cmd) {
    ArrayList<Byte> retval = new ArrayList<Byte>();
    String responseStr     = "";
    StringBuilder sb       = new StringBuilder("");
    
    sb.append(SerialConnection.SRLCMD_CHAR_START)
      .append(cmd.getCmdChar())
      .append(SerialConnection.SRLCMD_CHAR_CMDSEP);
      
    for (int i = 0; i < cmd.getParamCount(); i++) {
      sb.append(cmd.getParamAsString(i));
      
      if (i < cmd.getParamCount() - 1) {
        sb.append(SerialConnection.SRLCMD_CHAR_PAYLOADSEP);
      }
    }
    
    sb.append(SerialConnection.SRLCMD_CHAR_END);
    
    responseStr = sb.toString();
    
    for (int i = 0; i < responseStr.length(); i++) {
      retval.add((byte) responseStr.charAt(i));
    }
    
    return retval;
  }
}