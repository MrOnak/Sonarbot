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
        
      case SerialResponseBattery.COMMAND_CHAR:
        retval = new SerialResponseBattery(params.get(0));
        break;
        
      case SerialResponseSonarping.COMMAND_CHAR:
        retval = new SerialResponseSonarping(params.get(0), params.get(1));
        break;      
        
      default:
        println("unknown command for SerialCommandFactory");
    }
    
    return retval;
  }
  
 /**
  * factory method
  *
  * @param char cmd
  * @return SerialCommand
  */
  SerialCommand makeCommand(char cmd) {
    SerialCommand retval = null;
    
    switch (cmd) {
      case SerialResponseComplete.COMMAND_CHAR:
        retval = new SerialResponseComplete();
        break;
        
      case SerialRequestBattery.COMMAND_CHAR:
        retval = new SerialRequestBattery();
        break;
        
      case SerialRequestLcdclear.COMMAND_CHAR:
        retval = new SerialRequestLcdclear();
        break;
        
      default:
        println("unknown command for SerialCommandFactory");
    }
    
    return retval;
  }
  
  
 /**
  * factory method
  *
  * @param char cmd
  * @param Object... params
  * @return SerialCommand
  */
  SerialCommand makeCommand(char cmd, Object... params) {
    SerialCommand retval = null;
    Float f0, f1;
    Integer i0, i1, i2;
    String s0;
    
    switch (cmd) {
      case SerialRequestFlexiblemovement.COMMAND_CHAR:
        f0 = (Float) params[0];
        f1 = (Float) params[1];
        i0 = (Integer) params[2];
        retval = new SerialRequestFlexiblemovement(f0.floatValue(), f1.floatValue(), i0.intValue());
        break;
      
      case SerialRequestTurnleft.COMMAND_CHAR:
        i0 = (Integer) params[0];
        retval = new SerialRequestTurnleft(i0.intValue());
        break;
        
      case SerialRequestTurnright.COMMAND_CHAR:
        i0 = (Integer) params[0];
        retval = new SerialRequestTurnright(i0.intValue());
        break;
        
      case SerialRequestMoveforward.COMMAND_CHAR:
        i0 = (Integer) params[0];
        retval = new SerialRequestMoveforward(i0.intValue());
        break;
        
      case SerialRequestMovebackward.COMMAND_CHAR:
        i0 = (Integer) params[0];
        retval = new SerialRequestMovebackward(i0.intValue());
        break;
        
      case SerialRequestLcdwrite.COMMAND_CHAR:
        i0 = (Integer) params[0];
        i1 = (Integer) params[1];
        s0 = (String)  params[2];
        retval = new SerialRequestLcdwrite(i0.intValue(), i1.intValue(), s0);
        break;
        
      case SerialRequestSonarping.COMMAND_CHAR:
        i0 = (Integer) params[0];
        retval = new SerialRequestSonarping(i0.intValue());
        break;
        
      case SerialRequestSonarsweep.COMMAND_CHAR:
        i0 = (Integer) params[0];
        i1 = (Integer) params[1];
        i2 = (Integer) params[2];
        retval = new SerialRequestSonarsweep(i0.intValue(), i1.intValue(), i2.intValue());
        break;
        
      default:
        println("unknown command for SerialCommandFactory");
    }
    
    return retval;
  }
}