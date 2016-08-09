/** 
 * grouping up all SerialCommand implementations that are sent from the server to the robot
 * in a single file to keep working with the Processing GUI easy
 */
 
/**
 * Serial Command class for the battery voltage request to the robot
 */
class SerialRequestBattery extends SerialCommand {
  final static char COMMAND_CHAR = 'b';
  
 /** 
  * constructor
  */
  SerialRequestBattery() {
    super(COMMAND_CHAR, 0);
  }
}

/**
 * Serial Command class for the flexible movement request to the robot
 */
class SerialRequestFlexiblemovement extends SerialCommand {
  final static char COMMAND_CHAR = 'f';
  
 /**
  * constructor
  *
  * @param float turnrateLeft [-1.0, 1.0]
  * @param float turnrateRight [-1.0, 1.0]
  * @param int duration in ms
  */
  SerialRequestFlexiblemovement(float turnrateLeft, float turnrateRight, int duration) {
    super(COMMAND_CHAR, 3);
    
    this.setParamFromFloat(0, turnrateLeft);
    this.setParamFromFloat(1, turnrateRight);
    this.setParamFromInt(2, duration);
  }
}

/**
 * Serial Command class for the left turn request to the robot
 */
class SerialRequestTurnleft extends SerialCommand {
  final static char COMMAND_CHAR = 'l';
  
 /**
  * constructor
  *
  * @param int angle
  */
  SerialRequestTurnleft(int angle) {
    super(COMMAND_CHAR, 1);
    
    this.setParamFromInt(0, angle); 
  }
}
 
/**
 * Serial Command class for the right turn request to the robot
 */
class SerialRequestTurnright extends SerialCommand {
  final static char COMMAND_CHAR = 'r';
  
 /**
  * constructor
  *
  * @param int angle
  */
  SerialRequestTurnright(int angle) {
    super(COMMAND_CHAR, 1);
    
    this.setParamFromInt(0, angle); 
  }
}
 
/**
 * Serial Command class for the forward movement request to the robot
 */
class SerialRequestMoveforward extends SerialCommand {
  final static char COMMAND_CHAR = 'm';
  
 /**
  * constructor
  *
  * @param int distance
  */
  SerialRequestMoveforward(int distance) {
    super(COMMAND_CHAR, 1);
    
    this.setParamFromInt(0, distance); 
  }
}
 
/**
 * Serial Command class for the backward movement request to the robot
 */
class SerialRequestMovebackward extends SerialCommand {
  final static char COMMAND_CHAR = 'e';
  
 /**
  * constructor
  *
  * @param int distance
  */
  SerialRequestMovebackward(int distance) {
    super(COMMAND_CHAR, 1);
    
    this.setParamFromInt(0, distance); 
  }
}
  
/**
 * Serial Command class for the LCD clear request to the robot
 */
class SerialRequestLcdclear extends SerialCommand {
  final static char COMMAND_CHAR = 'c';
  
 /** 
  * constructor
  */
  SerialRequestLcdclear() {
    super(COMMAND_CHAR, 0);
  }
}

/**
 * Serial Command class for the LCD write request to the robot
 */
class SerialRequestLcdwrite extends SerialCommand {
  final static char COMMAND_CHAR = 'w';
  
  SerialRequestLcdwrite(int x, int y, String text) {
    super(COMMAND_CHAR, 3);
    
    this.setParamFromInt(0, x);
    this.setParamFromInt(1, y);
    this.setParamFromString(2, text);
  }
}

/**
 * Serial Command class for the sonar ping request to the robot
 */
class SerialRequestSonarping extends SerialCommand {
  final static char COMMAND_CHAR = 'p';
  
  /**
   * constructor
   *
   * @param int angle
   */
  SerialRequestSonarping(int angle) {
    super(COMMAND_CHAR, 1);
    
    this.setParamFromInt(0, angle);
  }
}

/**
 * Serial Command class for the sonar sweep request to the robot
 */
class SerialRequestSonarsweep extends SerialCommand {
  final static char COMMAND_CHAR = 's';
  
 /**
  * constructor
  * 
  * @param int startAngle
  * @param int endAngle
  * @param int stepSize
  */
  SerialRequestSonarsweep(int startAngle, int endAngle, int stepSize) {
    super(COMMAND_CHAR, 3);
    
    this.setParamFromInt(0, startAngle);
    this.setParamFromInt(1, endAngle);
    this.setParamFromByte(2, byte(stepSize));
  }
}