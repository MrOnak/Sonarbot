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
  int width;
  int height;
  int[][] grid;
  int gridCenterX;
  int gridCenterY;
  final int CELL_SIZE = 10; // in mm
  
 /**
  * constructor
  *
  * @param int w
  * @param int h
  */
  Landscape(int w, int h) {
    this.width = w;
    this.height = h;
    this.grid = new int[w][h];
    
    for (int y = 0; y < this.height; y++) {
      for (int x = 0; x < this.width; x++) {
        this.grid[x][y] = 50; 
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

    float centerCellX = this.gridCenterX + (bot.getPosX() / this.CELL_SIZE) - (scalePxToMM(scrollX) / this.CELL_SIZE);
    float centerCellY = this.gridCenterY + (bot.getPosY() / this.CELL_SIZE) - (scalePxToMM(scrollY) / this.CELL_SIZE);
    
    float startCellX = centerCellX - cellsX / 2;
    float startCellY = centerCellY - cellsY / 2;
    
    float offsetX = (round(startCellX) - startCellX) * edgeLen;
    float offsetY = (round(startCellY) - startCellY) * edgeLen;
    
    int posX, posY;
    
    rectMode(CENTER);
    noStroke();
        
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
}