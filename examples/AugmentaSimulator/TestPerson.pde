import augmentaP5.*;

class TestPerson {
  AugmentaPerson p;
  int xOffset;
  int yOffset;
  float x, y;
  int unit;
  int xDirection = 1;
  int yDirection = 1;
  float speed; 
  
  // Contructor
  TestPerson(int xOffsetTemp, int yOffsetTemp, int xTemp, int yTemp, float speedTemp, int tempUnit) {
    xOffset = xOffsetTemp;
    yOffset = yOffsetTemp;
    x = xTemp;
    y = yTemp;
    speed = speedTemp;
    unit = tempUnit;
    
    // Setup the augmenta person
    int pid = int(random(100000));
    RectangleF rect = new RectangleF(0.4f,0.4f,0.2f,0.2f);
    PVector pos = new PVector(0.5f, 0.5f);
    p = new AugmentaPerson(pid, pos, rect);
    
  }
  
  // Custom method for updating the variables
  void update() {
    x = x + (speed * xDirection);
    if (x >= unit || x <= 0) {
      xDirection *= -1;
      x = x + (1 * xDirection);
      y = y + (1 * yDirection);
    }
    if (y >= unit || y <= 0) {
      yDirection *= -1;
      y = y + (1 * yDirection);
    }
    // Update augmenta
    p.centroid.x = (x+xOffset)/width;
    p.centroid.y = (y+yOffset)/height;
    p.boundingRect.x = p.centroid.x - p.boundingRect.width/2;
    p.boundingRect.y = p.centroid.y - p.boundingRect.height/2;
  }
  
  void send(AugmentaP5 augmenta, NetAddress a){
     augmenta.sendSimulation(p, a);
  }
  
  // Custom method for drawing the object
  void draw() {
    fill(255);
    ellipse(xOffset + x, yOffset + y, 6, 6);
  }
}
