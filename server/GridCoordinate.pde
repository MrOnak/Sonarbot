class GridCoordinate {
  int x;
  int y;
  
  GridCoordinate() {
    this.x = 0;
    this.y = 0;
  }
  
  GridCoordinate(int x, int y) {
    this.x = x;
    this.y = y;
  }
    
    
  int getManhattanDistanceTo(GridCoordinate target) {
    return abs(this.x - target.x)
         + abs(this.y - target.y);
  }

  GridCoordinate getDisplacementTo(GridCoordinate target) {
    return new GridCoordinate(target.x - this.x,
                    target.y - this.y);
  }
  
  GridCoordinate getAbsDisplacementTo(GridCoordinate target) {
    GridCoordinate retval = this.getDisplacementTo(target);
    
    retval.x = abs(retval.x);
    retval.y = abs(retval.y);
    
    return retval;
  }
  
  /**
   * moves this coordinate one step into the given direction
   *
   * note that no boundary- or other checks of any kind are performed
   *
   * @param int direction
   * @return GridCoordinate
   */
  GridCoordinate move(int direction) {
    this.moveHorizontal(direction).moveVertical(direction);
    
    return this;
  } 

  /**
   * moves this coordinate one step on the horizontal axis into the given direction
   *
   * note that no boundary- or other checks of any kind are performed
   *
   * @param int direction
   * @return GridCoordinate
   */
  GridCoordinate moveHorizontal(int direction) {
    if (direction == -1
      || direction == 2
      || direction == -4) {
      // going *west
      this.x--;

    } else if (direction == 1
      || direction == -2
      || direction == 4) {
      // going *east
      this.x++;
    }
    
    return this;
  }

  /**
   * moves this coordinate one step on the vertical axis into the given direction
   *
   * note that no boundary- or other checks of any kind are performed
   *
   * @param int direction
   * @return GridCoordinate
   */
  GridCoordinate moveVertical(int direction) {
    if (direction < -1) {
      // going north*
      this.y--;

    } else if (direction > 1) {
      // going south*
      this.y++;
    }
    
    return this;
  }

  /**
   * gives an indication about a direction
   *
   * note that the indication is only precise for immediate neighbour
   * tiles. for longer distances it gives a tendency, not the exact
   * direction:
   *
   * if @ is the current position, then directions returned are as follows:
   *
   *    NW   N   NE
   *     -4 -3 -2
   *   W -1  @  1 E
   *      2  3  4
   *    SW   S   SE
   *
   * 'no direction' is returned as 0
   * As you can see the strategy is simple:
   * The x-axis has a value of 1/-1 respectively, where the y-axis has
   * values of 3/-3.
   *
   * Diagonal direction is indicated by adding the x/y values.
   *
   * @public
   * @param    GridCoordinate target
   * @returns  int direction indicator
   */
  int getDirectionTo(GridCoordinate target) {
    int returnValue = 0;

    // add x-axis indication
    if (target.x != this.x) {
      returnValue += (target.x - this.x) / Math.abs(target.x - this.x);
    } 

    // add y-axis indication
    if (target.y != this.y) {
      returnValue += 3 * ((target.y - this.y) / Math.abs(target.y - this.y));
    } 

    return returnValue;
  }
  
  GridCoordinate clone() {
    return new GridCoordinate(this.x, this.y);
  }
  
  String toString() {
    return this.x + "/" + this.y;
  } 
}