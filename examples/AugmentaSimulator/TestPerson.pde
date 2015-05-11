import augmentaP5.*;

class TestPerson {
  AugmentaPerson p;
  int xOffset;
  int yOffset;
  float x, y;
  float oldX, oldY;
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
    int pid = int(random(10000000));
    RectangleF rect = new RectangleF(0.4f,0.4f,0.2f,0.2f);
    PVector pos = new PVector(0.5f, 0.5f);
    p = new AugmentaPerson(pid, pos, rect);
    
    p.highest.z = random(0.4, 0.6);
  }
  
  // Custom method for updating the variables
  void update() {
    
    // Store the oldX oldY values
   oldX = x;
   oldY = y;
    
    // Compute the new values
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
    // Compute the velocity
    p.velocity.x = (x - oldX)/width;
    p.velocity.y = (y - oldY)/height;
    // Update augmenta
    p.depth = 0.5f;
    p.centroid.x = (x+xOffset)/width;
    p.centroid.y = (y+yOffset)/height;
    p.boundingRect.x = p.centroid.x - p.boundingRect.width/2;
    p.boundingRect.y = p.centroid.y - p.boundingRect.height/2;
    p.highest.x = p.centroid.x;
    p.highest.y = p.centroid.y;
    p.age++; 
  }
  
  void send(AugmentaP5 augmenta, NetAddress a){
     augmenta.sendSimulation(p, a);
  }
  
  // Custom method for drawing the object
  void draw() {
    ellipse(xOffset + x, yOffset + y, 6, 6);
  }
}

