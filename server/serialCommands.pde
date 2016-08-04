
/**
 * sends the request for battery voltage to the m3pi
 */
void sendCmdBattery() {
  println("battery");
  
  if (m3piPort != null) {
    println("sending...");
    command = CMD_BATTERY;
    
    writeToSerial(m3piPort, "#b:\n");
  }
}

/**
 * sends the request to turn left by a number of degrees
 *
 * @param int angle
 */
void sendCmdTurnLeft(int angle) {
  println("turn left by " + angle + " degrees");
  if (m3piPort != null) {
    println("sending...");
    command = CMD_TURNLEFT;

    writeToSerial(m3piPort, "#l:", angle, "\n");
  }
}

/**
 * sends the request to turn right by a number of degrees
 *
 * @param int angle
 */
void sendCmdTurnRight(int angle) {
  println("turn right by " + angle + " degrees");
  
  if (m3piPort != null) {
    println("sending...");
    command = CMD_TURNRIGHT;
    
    writeToSerial(m3piPort, "#r:", angle, "\n");
  }
}

/**
 * sends the request to move forward by a number of millimeters
 *
 * @param int distance
 */
void sendCmdMoveForward(int distance) {
  println("move forward " + distance + "mm");
  
  if (m3piPort != null) {
    println("sending...");
    command = CMD_MOVEFORWARD;
    
    writeToSerial(m3piPort, "#m:", distance, "\n");
  }
}

/**
 * sends the request to move backward by a number of millimeters
 *
 * @param int distance
 */
void sendCmdMoveBackward(int distance) {
  println("move back " + (-1 * distance) + "mm");
  
  if (m3piPort != null) {
    println("sending...");
    command = CMD_MOVEBACKWARD;
    
    writeToSerial(m3piPort, "#e:", distance, "\n");
  }
}

/**
 * sends the request to clear the LCD screen on the m3pi
 */
void sendCmdLcdClear() {
  println("LCD clear");
  
  if (m3piPort != null) {
    println("sending...");
    command = CMD_LCDCLEAR;
    
    writeToSerial(m3piPort, "#c:\n");
  }
}

/**
 * sends the request to write the given text on the x/y position provided
 * onto the LCD of the m3pi
 *
 * @param int x
 * @param int y
 * @param String text
 */
void sendCmdLcdWrite(int x, int y, String text) {
  println("LCD write to position " + binary(X) + "/" + binary(Y));
  
  if (m3piPort != null) {
    println("sending...");
    command = CMD_LCDWRITE;
    
    writeToSerial(m3piPort, "#w:", x, ",", y, ",", text, "\n");
  }
}


/**
 * sends the request to perform a ranging 'ping' into the given
 * direction
 *
 * @param int angle
 */
void sendCmdSonarPing(int angle) {  
  println("sonar ping at angle " + angle + " degrees");
  
  if (m3piPort != null) {
    println("sending...");
    command = CMD_SONARPING;
    
    writeToSerial(m3piPort, "#p:", angle, "\n");
  }
}

/**
 * sends the request to perform a series of sonar ranging 'pings' from
 * startAngle to endAngle with stepSize angles intervals
 *
 * @param int startAngle
 * @param int endAngle
 * @param int stepSize
 */
void sendCmdSonarSweep(int startAngle, int endAngle, int stepSize) {
  byte s = (byte) stepSize;
  
  //println("startAngle(short): " + binary(startAngle));
  println("sonar sweep from angles " + startAngle + " to " + endAngle + " in " + s + " degree intervals");
  
  if (m3piPort != null) {
    println("sending...");
    command = CMD_SONARSWEEP;
    
    writeToSerial(m3piPort, "#s:", startAngle, ",", endAngle, ",", byte(stepSize), "\n");
  }
}