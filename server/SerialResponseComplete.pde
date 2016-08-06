/**
 * Serial Command class for the "processing complete" response 
 * from the robot
 */
class SerialResponseComplete extends SerialCommand {
  final static char COMMAND_CHAR = 'K';
  
 /** 
  * constructor
  */
  SerialResponseComplete() {
    super(COMMAND_CHAR, 0);
  }
}