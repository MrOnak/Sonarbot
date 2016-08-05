/**
 * Simple data store for the m3pi bot
 */
class SonarBot {
  int posX;
  int posY;
  float voltage;
  float angle;
  final int BOT_RADIUS = 47;                   // in mm
    
  SonarBot(int x, int y, float a, float v) {
    this.setPosX(x);
    this.setPosY(y);
    this.setAngle(a);
    this.setVoltage(v);    
  }
    
  void draw(float centerX, float centerY, float scrollX, float scrollY) {
    float angle  = radians(this.angle);
    float radius = scaleMMtoPx(this.BOT_RADIUS);
    float x      = this.getScreenPosX();
    float y      = this.getScreenPosY();
    
    stroke(255, 255, 255);
    strokeWeight(1);
    fill(0, 0, 0, 70);
    ellipse(x, 
            y, 
            radius, 
            radius);
    
    line(x, 
         y, 
         x + radius * cos(angle), 
         y + radius * sin(angle)
    );
  }  
  
  /**
   * @return x coordinate of the bot in mm 
   */
  int getPosX() {
    return this.posX;
  }
  
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