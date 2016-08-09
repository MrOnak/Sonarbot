/**
 * Represents and manages a grid of 10x10mm large squares of ground.
 *
 * Must be initiated with the width and height in cells.
 *
 * The value [0, 100] stored for each grid represents the probability of being blocked. 
 * A value of 100 is the highest probability of being blocked. 0 represents a cell that is 
 * likely to be empty.
 *
 * Initially all cells have a value of 50. 
 *
 * The bots position 0/0 refers to width/2 / height/2 on the grid stored in this array
 */
class Landscape {
  GridMath gm;
  int width;
  int height;
  int[][] grid;
  int gridCenterX;
  int gridCenterY;
  final int CELL_SIZE = 10; // in mm
  final int VISIBILITY_INCREMENT = 100;
  
 /**
  * constructor
  *
  * @param int w
  * @param int h
  */
  Landscape(int w, int h) {
    this.gm     = new GridMath(this);
    this.width = w;
    this.height = h;
    this.grid = new int[w][h];
    
    for (int y = 0; y < this.height; y++) {
      for (int x = 0; x < this.width; x++) {
        this.grid[x][y] = 0; 
      }
    }
    
    this.gridCenterX = ceil(this.width / 2);
    this.gridCenterY = ceil(this.height / 2);
    this.grid[this.gridCenterX][this.gridCenterY] = 100;  // @todo remove this
  }
  
 /**
  * draws the sonar data based on the current view
  *
  * @param float scrollX
  * @param float scrollY
  */
  void draw(float scrollX, float scrollY) {
    float edgeLen = scaleMMtoPx(this.CELL_SIZE);

    int cellsX = ceil(windowWidth / edgeLen);
    int cellsY = ceil(windowHeight / edgeLen);

    float centerCellX = this.gridCenterX - (scalePxToMM(scrollX) / this.CELL_SIZE);
    float centerCellY = this.gridCenterY - (scalePxToMM(scrollY) / this.CELL_SIZE);
    
    float startCellX = centerCellX - cellsX / 2;
    float startCellY = centerCellY - cellsY / 2;
    
    float offsetX = (round(startCellX) - startCellX) * edgeLen;
    float offsetY = (round(startCellY) - startCellY) * edgeLen;
    
    int posX, posY;
    
    rectMode(CENTER);
    stroke(0, 0, 0, 100);
    strokeWeight(1);
        
    for (int y = 0; y <= cellsY; y++) {
      for (int x = 0; x <= cellsX; x++) {
        posX = round(startCellX) + x;
        posY = round(startCellY) + y;
        
        if (posX > -1 && posX < this.width && posY > -1 && posY < this.height) {
          fill(255, 255, 255, this.grid[posX][posY]);
          
          rect(offsetX + x * edgeLen, 
               offsetY + y * edgeLen,
               edgeLen,
               edgeLen
          );
        }
      }
    }
  }
  
 /**
  * considers the triangle of cells spanned by the given three coordinates as accessible and
  * will update the grid data accordingly.
  *
  * all coordinates are expected to be in millimeters relative to the [0, 0] point of origin
  *
  * @param int x1
  * @param int y1
  * @param int x2
  * @param int y2
  * @param int x3
  * @param int y3
  */
  void addFreeSpace(int x1, int y1, int x2, int y2, int x3, int y3) {
    int gridX1 = this.convertMMToCellX(x1);
    int gridY1 = this.convertMMToCellY(y1);
    int gridX2 = this.convertMMToCellX(x2);
    int gridY2 = this.convertMMToCellY(y2);
    int gridX3 = this.convertMMToCellX(x3);
    int gridY3 = this.convertMMToCellY(y3);
    
    this.drawLine(gridX1, gridY1, gridX2, gridY2); 
    this.drawLine(gridX1, gridY1, gridX3, gridY3); 
    this.drawLine(gridX2, gridY2, gridX3, gridY3); 
    //this.grid[gridX1][gridY1] = 100;
    //this.grid[gridX2][gridY2] = 100;
    //this.grid[gridX3][gridY3] = 100;
  }
  
  void increaseCellOpenness(int x, int y) {
    this.grid[x][y] = min(100, this.grid[x][y] + this.VISIBILITY_INCREMENT);
  }
  
 /**
  * expects a horizontal distance relative from the origin as parameter and will return
  * the matching cell offset for it
  *
  * @param int dist
  * @return int
  */
  int convertMMToCellX(int dist) {
    return this.gridCenterX + round(dist / (float) this.CELL_SIZE);
  }
  
 /**
  * expects a vertical distance relative from the origin as parameter and will return
  * the matching cell offset for it
  *
  * @param int dist
  * @return int
  */
  int convertMMToCellY(int dist) {
    return this.gridCenterY + round(dist / (float) this.CELL_SIZE);
  }
  
  boolean coordsAreInBounds(GridCoordinate pos) {
    boolean retval = false;
    
    if (pos.x > -1 && pos.x < this.width
        && pos.y > -1 && pos.y < height) {
          
      retval = true;
    }
    
    return retval;
  }
  
  void drawLine(int x0, int y0, int x1, int y1) {
    GridCoordinate start = new GridCoordinate(x0, y0);
    GridCoordinate dest  = new GridCoordinate(x1, y1);
    
    ArrayList<GridCoordinate> cells = this.gm.bresenhamLine(start, dest);
    //println(cells);
    
    for (GridCoordinate c : cells) {
      this.increaseCellOpenness(c.x, c.y);
    }
    
  }
}