/**
 * Serial Command class for the sonar ping response 
 * from the robot
 */
class SerialResponseSonarping extends SerialCommand {
  final static char COMMAND_CHAR = 'P';
  
 /**
  * constructor
  */
  SerialResponseSonarping(String angle, String range) {
    super(COMMAND_CHAR, 2);
    
    this.setParam(0, angle);
    this.setParam(1, range);
  }
}