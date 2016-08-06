/**
 * Factory class to generate SerialCommand instances.
 *
 * Its generally not advised to use this directly, use the SerialCommandBuilder class instead
 */
class SerialCommandFactory {
 /**
  * constructor
  */
  SerialCommandFactory() {
  }
  
 /**
  * factory method
  *
  * @param char cmd
  * @param ArrayList<String> params
  * @return SerialCommand
  */
  SerialCommand makeCommand(char cmd, ArrayList<String> params) {
    SerialCommand retval = null;
    
    switch (cmd) {
      case SerialConnection.SRLRSP_CHAR_COMPLETE:
        retval = new SerialResponseComplete();
        break;
        
      case SerialConnection.SRLRSP_CHAR_BATTERY:
        retval = new SerialResponseBattery(params.get(0));
        break;
        
      case SerialConnection.SRLRSP_CHAR_SONARPING:
        retval = new SerialResponseSonarping(params.get(0), params.get(1));
        break;      
        
      default:
        println("unknown command for SerialCommandFactory");
    }
    
    return retval;
  }
}