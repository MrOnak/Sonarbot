void initGui() {
  background(0);
  color(0, 0, 0);
  fill(0, 160, 0);
  textSize(20);
  
  // buttons
  drawButton(buttonStartX, batteryButtonStartY, buttonLength, buttonHeight, "battery");
  drawButton(buttonStartX, turnLeftButtonStartY, buttonLength, buttonHeight, "turn left");
  drawButton(buttonStartX, turnRightButtonStartY, buttonLength, buttonHeight, "turn right");
  drawButton(buttonStartX, moveFwdButtonStartY, buttonLength, buttonHeight, "move fwd");
  drawButton(buttonStartX, moveBackButtonStartY, buttonLength, buttonHeight, "move back");
  drawButton(buttonStartX, lcdClearButtonStartY, buttonLength, buttonHeight, "clear LCD");
  drawButton(buttonStartX, lcdWriteButtonStartY, buttonLength, buttonHeight, "write on LCD");
  drawButton(buttonStartX, sonarPingButtonStartY, buttonLength, buttonHeight, "sonar ping");
  drawButton(buttonStartX, sonarSweepButtonStartY, buttonLength, buttonHeight, "sonar sweep");
}


void mouseClicked(MouseEvent event) {
  if (command == CMD_NOOP) {
    if (mouseX >= buttonStartX && mouseX < buttonStartX + buttonLength) {
      if (mouseY >= batteryButtonStartY && mouseY < batteryButtonStartY + buttonHeight) {
        // battery
        sendCmdBattery();
      }
      
      if (mouseY >= turnLeftButtonStartY && mouseY < turnLeftButtonStartY + buttonHeight) {
        // turn left
        sendCmdTurnLeft(90);
      }
      
      if (mouseY >= turnRightButtonStartY && mouseY < turnRightButtonStartY + buttonHeight) {
        // turn right
        sendCmdTurnRight(90);
      }
      
      if (mouseY >= moveFwdButtonStartY && mouseY < moveFwdButtonStartY + buttonHeight) {
        // move forward
        sendCmdMoveForward(100);
      }
      
      if (mouseY >= moveBackButtonStartY && mouseY < moveBackButtonStartY + buttonHeight) {
        // move backward
        sendCmdMoveBackward(100);
      }
      
      if (mouseY >= lcdClearButtonStartY && mouseY < lcdClearButtonStartY + buttonHeight) {
        // clear LCD
        sendCmdLcdClear();
      }
      
      if (mouseY >= lcdWriteButtonStartY && mouseY < lcdWriteButtonStartY + buttonHeight) {
        // write to LCD
        sendCmdLcdWrite(0, 0, "hello");
      }
      
      if (mouseY >= sonarPingButtonStartY && mouseY < sonarPingButtonStartY + buttonHeight) {
        // sonar ping
        sendCmdSonarPing(0);
      }
      
      if (mouseY >= sonarSweepButtonStartY && mouseY < sonarSweepButtonStartY + buttonHeight) {
        // sonar sweep
        sendCmdSonarSweep(-60, 60, 2);
      }
    }
  }
}


void drawButton(int startX, int startY, int length, int height, String text) {
  color(0, 0, 0);
  fill(0, 160, 0);
  textSize(20);
  
  rect(startX, startY, length, height);
  fill(0, 0, 0);
  text(text, startX + 10, startY + height - 12);
}