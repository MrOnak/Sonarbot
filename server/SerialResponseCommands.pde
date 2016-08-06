/** 
 * grouping up all SerialCommand implementations that are sent from the robot to the server
 * in a single file to keep working with the Processing GUI easy
 */
 
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