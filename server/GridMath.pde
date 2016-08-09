class GridMath {
  Landscape grid;
  
  GridMath(Landscape g) {
    this.grid = g;
  }
  
  ArrayList<GridCoordinate> bresenhamLine(GridCoordinate source, GridCoordinate dest) {
    ArrayList<GridCoordinate> returnValue      = new ArrayList<GridCoordinate>();
    GridCoordinate pos        = source.clone();
    GridCoordinate delta      = pos.getAbsDisplacementTo(dest);
    float ratio     = 0;
    int distance    = 1 + source.getManhattanDistanceTo(dest);
    int direction   = source.getDirectionTo(dest);

    if (this.grid.coordsAreInBounds(source)
      && this.grid.coordsAreInBounds(dest)) {

      // find ratio
      if (abs(direction) == 3
        || abs(direction) == 1) {
        // purely vertical or horizontal
        ratio = delta.x;

      } else {
        // any diagonal angle
        ratio = delta.x / float (delta.x + delta.y);
      }

      // start drawing the line
      for (int i = 0; i < distance; i++) {
        // draw symbol on current position
        returnValue.add(pos.clone());

        // now shift position according to ratio
        if (round(i * ratio) > round((i - 1) * ratio)) {
          pos.moveHorizontal(direction);

        } else {
          pos.moveVertical(direction);
        }
      }

    } else {
      println("coordinates out of bounds");
    }

    return returnValue;
  }
}