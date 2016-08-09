int buttonStartX = 10;
int buttonLength = 200;
int buttonHeight = 40;

int batteryButtonStartY = 10;
int turnLeftButtonStartY = 60;
int turnRightButtonStartY = 110;
int moveFwdButtonStartY = 160;
int moveBackButtonStartY = 210;
int lcdClearButtonStartY = 260;
int lcdWriteButtonStartY = 310;
int sonarPingButtonStartY = 360;
int sonarSweepButtonStartY = 410;

final int HOME_RADIUS = 40;                  // in mm
final float DEG_45 = radians(45);
final float DEG_135 = radians(135);
final float DEG_225 = radians(225);
final float DEG_315 = radians(315);

float mmPerPixel = 1.0;                      // scaling
int windowWidth = 1000;                      // in px
int windowHeight = 1000;                     // in px
float renderingScale = 1.0;
float scrollX = 0.0;
float scrollY = 0.0;
float centerX = windowWidth / 2.0;
float centerY = windowHeight / 2.0;

boolean helpWindowVisibility = false;
boolean rotationCueVisibility = false;
boolean moveCueVisibility = false;

/**
 * basic setup of graphical stuff
 */
void guiInit() {
  colorMode(RGB, 255, 255, 255, 100);
  ellipseMode(RADIUS);
}

/** 
 * updates everything on the GUI
 */
void guiRefresh() {  
  background(0, 0, 0, 100);
  
  grid.draw(scrollX, scrollY);
  drawHome();
  bot.draw();
  
  drawCues();
  drawHUD();
  drawHelp();
}

/** 
 * draws the 'home plate' at the position where the robot started initially
 */
void drawHome() {
  float radius = scaleMMtoPx(HOME_RADIUS);
  
  fill(255, 255, 255, 100);
  stroke(255, 255, 255, 100);
  strokeWeight(2);
  ellipse(centerX + scrollX, centerY + scrollY, radius, radius);
  
  noFill();
  stroke(0, 200, 255);
  strokeWeight(2);
  ellipse(centerX + scrollX, centerY + scrollY, radius * 0.8, radius * 0.8);
  line(centerX + scrollX + radius * cos(DEG_45),
       centerY + scrollY + radius * sin(DEG_45),
       centerX + scrollX + radius * cos(DEG_225), 
       centerY + scrollY + radius * sin(DEG_225)
  );
  line(centerX + scrollX + radius * cos(DEG_135),
       centerY + scrollY + radius * sin(DEG_135),
       centerX + scrollX + radius * cos(DEG_315), 
       centerY + scrollY + radius * sin(DEG_315)
  );
}

/** 
 * draws some statistics in the top left
 */
void drawHUD() {
  rectMode(CORNER);
  color(0, 160, 0);
  noStroke();
  fill(0, 0, 0, 80);
  textSize(12);
  
  rect(0, 0, 130, 100, 10);
  fill(0, 160, 0, 100);
  text("battery: " + nf(bot.getVoltage(), 1, 2) + " V", 10, 20);
  text("angle: " + nf(bot.getAngle(), 1, 2) + " °", 10, 40);
  text("scale: " + nf(mmPerPixel, 1, 1), 10, 60);
  text("scroll: " + round(scrollX) + " / " + round(scrollY), 10, 80);
}

/** 
 * draws a help 'popup' after the user has pressed the 'h' key
 */
void drawHelp() {
  int width  = 300;
  int height = 170;
  int border = 10;
  int left   = width / 2 - border;
  int top    = height / 2 - border - border;
  
  
  if (helpWindowVisibility) {
    rectMode(CENTER);
    color(0, 160, 0);
    noStroke();
    fill(0, 0, 0, 80);
    textSize(12);
    
    rect(centerX, centerY, width, height, border);
    fill(0, 160, 0, 100);
    
    text("mousewheel",          centerX - left, centerY - top + 20*0); text("zoom",                    centerX, centerY - top + 20*0);
    text("right-mouse & drag",  centerX - left, centerY - top + 20*1); text("pan the view",            centerX, centerY - top + 20*1);
    text("v",                   centerX - left, centerY - top + 20*2); text("center view, reset zoom", centerX, centerY - top + 20*2);
    text("s",                   centerX - left, centerY - top + 20*3); text("sonar sweep",             centerX, centerY - top + 20*3);
    text("b",                   centerX - left, centerY - top + 20*4); text("query battery",           centerX, centerY - top + 20*4);
    text("i",                   centerX - left, centerY - top + 20*5); text("initialize robot",        centerX, centerY - top + 20*5);
    text("hold r & left-click", centerX - left, centerY - top + 20*6); text("rotate the robot",        centerX, centerY - top + 20*6);
//    text("hold m & left-click", centerX - left, centerY - top + 20*7); text("turn & move the robot",   centerX, centerY - top + 20*7);
    text("hold f & left-click", centerX - left, centerY - top + 20*7); text("calibrated turn & move",  centerX, centerY - top + 20*7);
  }
}

/** 
 * draws cues for rotation and movement if the user
 * holds down the 'r' (rotation) or 'm' (movement) keys.
 */
void drawCues() {
  int mX = mouseX;
  int mY = mouseY;
  int botX = bot.getScreenPosX();
  int botY = bot.getScreenPosY();
  float botRadius = scaleMMtoPx(bot.BOT_RADIUS);
  
  int dist  = bot.getDistanceToScreenPos(mX, mY);
  int angle = bot.getRotationToScreenPos(mX, mY);
  
  if (rotationCueVisibility) {
    rectMode(CORNER);
    stroke(0, 255, 0, 100);
    strokeWeight(1);
    line(botX, botY, botX + botRadius * cos(radians(angle + bot.getAngle())), botY + botRadius * sin(radians(angle + bot.getAngle())));

    fill(0, 0, 0, 80);
    noStroke();
    rect(mX, mY, 80,  30, 10);
    fill(0, 255, 0, 100);
    text(angle + "°", mX + 20, mY + 20);
    
  } else if (moveCueVisibility) {    
    rectMode(CORNER);
    stroke(0, 255, 0, 100);
    strokeWeight(1);
    noFill();
    
    ellipse(mX, mY, botRadius, botRadius);
    line(mX, mY, mX + botRadius * cos(radians(angle + bot.getAngle())), mY + botRadius * sin(radians(angle + bot.getAngle())));
    
    fill(0, 0, 0, 80);
    noStroke();
    rect(mX + botRadius + 10, mY, 90, 50, 10);
    fill(0, 255, 0, 100);
    text(angle + "°", mX + botRadius + 30, mY + 20);    
    text(dist + " mm", mX + botRadius + 30, mY + 40);
  }
}








/**
 * converts a physical length in mm into a per-pixel value
 *
 * @param float length in mm
 * @return scaleLength in pixel
 */
float scaleMMtoPx(float mm) {
  return mm / mmPerPixel;
}

/**
 * converts a pixel length into mm
 *
 * @param float px length in pixel
 * @return float
 */
float scalePxToMM(float px) {
  return px * mmPerPixel;
}







/**
 * event handler for key presses
 *
 * doesn't trigger commands to the robot but initiates the help popup and movement cues
 */
void keyPressed() {
  switch (key) {
    case 'v':
      // center the view
      scrollX = 0.0;
      scrollY = 0.0;
      mmPerPixel = 1.0;
      break;
    case 'h':
      helpWindowVisibility = !helpWindowVisibility;
      break;
    case 'r':
      rotationCueVisibility = true;
      break;
    case 'f':
    //case 'm':
      moveCueVisibility = true;
      break;
      
    default:
      if (key == CODED) {
        if (keyCode != SHIFT) {
          println("unknown command '" + key + "'");
        }
      }
  }
}

/**
 * triggers the sonarSweep and battery commands for the robot
 */
void keyReleased() {
  switch (key) {
    case 'r':
      rotationCueVisibility = false;
      break;
    case 'f':
    //case 'm':
      moveCueVisibility = false;
      break;
    case 's':
      println("performing sonar sweep");
      commandHandler.addCommand(SerialRequestSonarsweep.COMMAND_CHAR, -60, 60, 2);
      break;
    case 'b':
      println("querying battery voltage");
      commandHandler.addCommand(SerialRequestBattery.COMMAND_CHAR);
      break;
    case 'i':
      println("initializing robot");
      commandHandler.addCommand(SerialRequestBattery.COMMAND_CHAR);
      commandHandler.addCommand(SerialRequestSonarping.COMMAND_CHAR, 0);
    default:
  }
}


/**
 * zooming is handled via mouseWheel
 *
 * @param MouseEvent event
 */
void mouseWheel(MouseEvent event) {
  float rot = event.getCount();
  
  if (rot > 0) {
    mmPerPixel += rot / 10;
  } else if (rot < 0) {
    mmPerPixel = max(0.1, mmPerPixel+(rot / 10));
  }
}

/**
 * handles panning of the scene (left mouse button & drag)
 *
 * @param MouseEvent event
 */
void mouseDragged(MouseEvent event) {
  float xShift = mouseX - pmouseX;
  float yShift = mouseY - pmouseY;
  
  if (mousePressed && mouseButton == RIGHT) {
    scrollX += xShift;
    scrollY += yShift; 
  }
}

/** 
 * triggers the rotation and movement commands 
 *
 * @param MouseEvent event
 */
void mouseClicked(MouseEvent event) {
  int mX = mouseX;
  int mY = mouseY;
  int angle, dist;

  if (keyPressed == true) {
    switch (key) {
      case 'r':
        angle = bot.getRotationToScreenPos(mX, mY);        
        println("rotating bot by " + angle + " degrees");
        
        commandHandler.addCommand(SerialRequestFlexiblemovement.COMMAND_CHAR, angle);
        /*
        if (angle > 0) {
          commandHandler.addCommand(SerialRequestTurnright.COMMAND_CHAR, angle);
        } else {
          commandHandler.addCommand(SerialRequestTurnleft.COMMAND_CHAR, angle);
        }*/
        break;
      case 'f':
        dist  = bot.getDistanceToScreenPos(mX, mY);
        angle = bot.getRotationToScreenPos(mX, mY);        
        println("calibrated move to position for " + dist + " mm after rotating by " + angle + " degrees");
        
        commandHandler.addCommand(SerialRequestFlexiblemovement.COMMAND_CHAR, angle, dist);
        break;
        /*
      case 'm':
        dist  = bot.getDistanceToScreenPos(mX, mY);
        angle = bot.getRotationToScreenPos(mX, mY);        
        println("moving bot to position for " + dist + " mm after rotating by " + angle + " degrees");
        
        if (angle > 0) {
          commandHandler.addCommand(SerialRequestTurnright.COMMAND_CHAR, angle);
        } else {
          commandHandler.addCommand(SerialRequestTurnleft.COMMAND_CHAR, angle);
        }
        commandHandler.addCommand(SerialRequestMoveforward.COMMAND_CHAR, dist);
        break;*/
      default:
    }
  }
}