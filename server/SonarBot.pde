/**
 * Simple data store for the m3pi bot
 */
class SonarBot {
  int posX;
  int posY;
  float voltage;
  float angle;
  float sonarAngle;
  final int BOT_RADIUS = 47;                   // in mm
  final int SONAR_RADIUS = 20;                 // in mm
  final float SONAR_HALFCURVE = radians(50);            
    
 /**
  * constructor
  *
  * @param int x
  * @param int y
  * @param float a angle
  * @param float v voltage
  * @param float s sonar angle
  */
  SonarBot(int x, int y, float a, float v, float s) {
    this.setPosX(x);
    this.setPosY(y);
    this.setAngle(a);
    this.setVoltage(v);    
    this.setSonarAngle(s);
  }
    
 /** 
  * draws the bot
  */
  void draw() {
    float angle  = radians(this.angle);
    float radius = scaleMMtoPx(this.BOT_RADIUS);
    float x      = this.getScreenPosX();
    float y      = this.getScreenPosY();
    
    float sonarX = this.getSonarScreenPosX();
    float sonarY = this.getSonarScreenPosY();
    float sonarR = scaleMMtoPx(this.SONAR_RADIUS);
    float sonarA = (float) this.angle - 180 + this.sonarAngle;
    
    // bring back to range
    if (sonarA < -180) {
      sonarA += 360;
    }
    
    float sonarStartAngle = radians(sonarA - 50);
    float sonarEndAngle   = radians(sonarA + 50);
    
    
    stroke(255, 255, 255);
    strokeWeight(1);
    fill(0, 0, 0, 70);
    ellipse(x, y, radius, radius);
    // draw the heading
    line(x, y, x + radius * cos(angle), y + radius * sin(angle));
    // draw the sonar 
    noFill();
    strokeWeight(4);
    ellipse(sonarX, sonarY, 2, 2);
    arc(sonarX, sonarY, scaleMMtoPx(10), scaleMMtoPx(10),sonarStartAngle, sonarEndAngle, CHORD);
  }  
  
 /**
  * @return x coordinate of the bot in mm 
  */
  int getPosX() {
    return this.posX;
  }
  
 /**
  * returns the x-coordinate of the bot according to the current viewport
  *
  * @return int
  */
  int getScreenPosX() {
    return int(scaleMMtoPx(this.posX) + centerX + scrollX);
  }
  
 /**
  * @param int x x-coordinate of the bot in mm
  */
  void setPosX(int x) {
    this.posX = x;
  }
  
 /**
  * @return y-coordinate of the bot in mm 
  */
  int getPosY() {
    return this.posY;
  }
    
 /**
  * returns the y-coordinate of the bot according to the current viewport
  *
  * @return int
  */
  int getScreenPosY() {
    return int(scaleMMtoPx(this.posY) + centerY + scrollY);
  }
  
 /**
  * @param int y y-coordinate of the bot in mm
  */
  void setPosY(int y) {
    this.posY = y;
  }
  
  /**
   * returns the last known angle of the sonar
   *
   * @return float
   */
  float getSonarAngle() {
    return this.sonarAngle;
  }
  
  /**
   * sets the angle of the sonar. 
   *
   * @param float angle
   */
  void setSonarAngle(float a) {
    this.sonarAngle = a;
  }
  
  /**
   * returns the x-coordinate of the current sonar position, depending on bot angle
   * and sonar angle.
   *
   * @return int
   * @todo to be implemented
   */

  int getSonarScreenPosX() {
    // sonar axle is 53mm in front of the center of the bot and 10mm to the right.
    // position of the sonar head further depends on the angle of the servo at the time,
    //   4mm to the left of the sonar axle and 12mm in front of it
    return int(scaleMMtoPx(this.posX + 54 * cos(radians(this.angle + 11))) + centerX + scrollX);
  }
  
  /**
   * returns the y-coordinate of the current sonar position, depending on bot angle
   * and sonar angle.
   *
   * @return int
   * @todo to be implemented
   */
  int getSonarScreenPosY() {
    return int(scaleMMtoPx(this.posY + 54 * sin(radians(this.angle + 11))) + centerY + scrollY);

  }
  
 /**
  * updates the bots position (posX, posY) after moving the given distance
  *
  * @param int distance
  */
  void move(int distance) {
    this.posX += int(distance * cos(radians(this.angle)));
    this.posY += int(distance * sin(radians(this.angle)));    
  }
  
 /**
  * @return rotation of the bot in degrees
  */
  float getAngle() {
    return this.angle;
  }
  
 /** 
  * @param float a rotation of the bot in degrees
  */
  void setAngle(float a) {
    this.angle = a;
  }
  
 /**
  * adds a rotation to the current angle
  *
  * @param float a
  */
  void rotate(float a) {
    this.angle += a;
  }
  
 /**
  * @return battery capacity of the bot in V
  */
  float getVoltage() {
    return this.voltage;
  }
  
 /**
  * @param float v battery capacity of the bot in V
  */
  void setVoltage(float v) {
    this.voltage = v;
  }

 /**
  * returns a distance in mm between the bot and a position on the screen
  *
  * @param int x
  * @param int y
  * @return int distance in mm
  */
  int getDistanceToScreenPos(int x, int y) {
    return round(scalePxToMM(sqrt(pow(this.getScreenPosX() - x, 2) + pow(this.getScreenPosY() - y, 2))));
  }
  
 /**
  * returns the rotation required for the bot to face a position on the screen.
  *
  * negative values indicate a rotation to the left, positive values to the right.
  *
  * @param int x
  * @param int y
  * @return rotation in degrees
  */
  int getRotationToScreenPos(int x, int y) {
    int a = round(degrees(atan2(y - this.getScreenPosY(), x - this.getScreenPosX())));
    // correct for heading
    a -= this.angle;
    // bring back to range
    if (a < -180) {
      a += 360;
    }
    
    return a;
  }
}