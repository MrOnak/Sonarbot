/**
 * Serial Command class for the battery voltage response 
 * from the robot
 */
class SerialResponseBattery extends SerialCommand {
  final static char COMMAND_CHAR = 'B';
  
 /** 
  * constructor
  */
  SerialResponseBattery(String v) {
    super(COMMAND_CHAR, 1);
    
    this.setParam(0, v);
  }
}