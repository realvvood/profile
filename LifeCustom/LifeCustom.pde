class Cell {

  float xPos, yPos;
  boolean state = false;
  int adjStates = 0;
  float cellSize;

  Cell(float xPos, float yPos) {
    this.xPos = xPos;
    this.yPos = yPos;
    this.cellSize = 600/board.gridSize;
  }

  void draw() {
    fill(map(adjStates, 0, 8, 255, 100));
    if (state) fill(0);

    rect(xPos, yPos, cellSize, cellSize);
  }

  //let user draw
  void mouseClicked() {
    if (mouseX <= xPos+cellSize && mouseX >= xPos && mouseY <= yPos+cellSize && mouseY >= yPos) {
      state = !state;
      if (state) liveCount++;
      else liveCount--;
    }
  }
}


class Board {
  
  int gridSize = 30;
  
  Board(int gridSize) {
    this.gridSize = gridSize;
  }

  void draw() {
    if (start && frameCount%stepLength == 0) {
      for (int row = 0; row <  cells.length; row++) { 
        for (int col = 0; col < cells[row].length; col++) { 
          int cellCheck = cellCheck(row, col);
          //1. Any live cell with two or three live neighbours survives.
          if (cells[row][col].state == true && (cellCheck == 2 || cellCheck == 3)) cells[row][col].state = true;
          //2. Any dead cell with three live neighbours becomes a live cell.
          else if (cells[row][col].state == false && (cellCheck == 3)) {
            cells[row][col].state = true;
            liveCount++;
          }
          //3. All other live cells die in the next generation. Similarly, all other dead cells stay dead.
          else {
            if (cells[row][col].state == true) liveCount--;
            cells[row][col].state = false;
          }

          cells[row][col].draw();
          cells[row][col].adjStates = cellCheck;
        }
      }
    }
    else {
      //simply draw all cells
      for (int row = 0; row <  cells.length; row++) { 
        for (int col = 0; col < cells[row].length; col++) { 
          int cellCheck = cellCheck(row, col);
          cells[row][col].draw();
          cells[row][col].adjStates = cellCheck;
        }
      }
    }
  }
  
}


Cell[][] cells;
boolean[][] cellsPast;
int[][] cellsAdj;
int gridSize = 40;
Board board;

boolean start = false;
int stepLength = 1;

int liveCount = 0;
ArrayList<Integer> liveArray = new ArrayList<Integer>();

void setup()
{
  size(800, 600);
  noStroke();

  // create cell grids
  board = new Board(gridSize);
  cells = new Cell[gridSize][gridSize];
  cellsPast = new boolean[gridSize][gridSize];
  cellsAdj = new int[gridSize][gridSize];

  for (int row = 0; row <  cells.length; row++) { 
    for (int col = 0; col < cells[row].length; col++) { 
      cells[row][col] = new Cell(row*600/gridSize, col*600/gridSize);
    }
  }
}


void draw()
{
  background(100);
  noStroke();

  //sidebar bg
  fill(255);
  rect(620, 20, 160, 320);
  rect(620, 360, 160, 160);
  rect(620, 540, 160, 40);

  //instructions
  fill(0);
  textAlign(LEFT);
  text("p - Start/Stop simulation\n\nr - Reset canvas\n\nn - Randomise canvas\n\n\nk / l - Change speed"+"\n\nCurrent: "+1.0/stepLength+"x"+"\n\n\ng / h - Change board size"+"\n\nCurrent: "+gridSize, 630, 100);
  text("Live Cell Count: "+liveCount, 630, 380);

  textAlign(CENTER);
  text("CONWAY'S GAME\nOF LIFE", 700, 45);
  if (start) text("RUNNING", 700, 565);
  else {
    fill(255, 0, 0);
    text("PAUSED", 700, 565);
  }
  
  board.draw();
  
  stroke(0);
  //draw cell live graph
  for (int i = 0; i < liveArray.size(); i++) {
    line(620+i, 520, 620+i, 520-map(liveArray.get(i), 0, gridSize*gridSize, 0, 250));
  }

  //memorise past position
  for (int row = 0; row < cells.length; row++) { 
    for (int col = 0; col < cells[row].length; col++) { 
      if (cells[row][col].state) cellsPast[row][col] = true;
      else cellsPast[row][col] = false;
    }
  }

  //update live cell count
  liveArray.add(liveCount);
  if (liveArray.size() > 160) liveArray.remove(0);
}


//checks count of living adjacent cells
int cellCheck(int row, int col) {
  int adjStates = 0;

  //iterates over adjacent tiles
  for (int i = -1; i<=1; i++) {
    for (int j = -1; j<=1; j++) {
      if (!(row+i < 0 || col+j < 0 || row+i >= gridSize || col+j >= gridSize || (i == 0 && j == 0)) && cellsPast[row+i][col+j]) adjStates++;
    }
  }

  return adjStates;
}


//change state of clicked tile
void mouseClicked() {
  for (int row = 0; row <  cells.length; row++) { 
    for (int col = 0; col < cells[row].length; col++) cells[row][col].mouseClicked();
  }
}


void keyPressed() {
  //start/stop sim
  if (key == 'p') start = !start;
  //reset sim
  if (key == 'r') {
    liveCount = 0;
    start = false;
    for (int row = 0; row <  cells.length; row++) { 
      for (int col = 0; col < cells[row].length; col++) { 
        cells[row][col].state = false;
      }
    }
  }
  //generate new pattern
  if (key == 'n') {
    liveCount = 0;
    for (int row = 0; row <  cells.length; row++) { 
      for (int col = 0; col < cells[row].length; col++) { 
        if (random(0, 1) <= 0.5) {
          cells[row][col].state = true;
          liveCount++;
        } else cells[row][col].state = false;
      }
    }
  }
  //increase/decrease sim speed
  if (key == 'k' && stepLength <= 8) stepLength = stepLength*2;
  if (key == 'l' && stepLength >= 2) stepLength = stepLength/2;
  //increase/decrease board size
  if (key == 'h' && gridSize < 300 && !start) {
    gridSize += 20;
    setup();
  }
  if (key == 'g' && gridSize > 20 && !start) {
    gridSize -= 20;
    setup();
  }
}
