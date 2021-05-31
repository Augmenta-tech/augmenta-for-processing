PVector ballPos, p1Pos, p2Pos, initDir, dir;
int pWidth, pHeight;
int offset = 10;
int ballDiam; 

void setupPong(PGraphics canvas) {

  offset = (int)width/10;
  ballPos = new PVector(canvas.width/2, canvas.height/2);
  ballDiam = floor(offset/3);
  initDir = new PVector(7,4);
  dir = initDir;
  p1Pos = new PVector(floor(offset/2), 5*offset);
  p2Pos = new PVector(canvas.width-offset, 5*offset);
  pWidth = floor(offset/2);
  pHeight = 2*offset;
}

void drawPong() {
 
  AugmentaObject[] people = auReceiver.getObjectsArray();
  for (int i=0; i<people.length; i++) {

    PVector pos = people[i].centroid;
    
    if (pos.x < 0.3f){
      p1Pos.y = pos.y*height;
    }
    if (pos.x > 0.7f){
      p2Pos.y = pos.y*height; 
    }
    if (drawDebugData) {
      // Draw blue disks
      canvas.fill(0, 128, 255); // Filled in blue
      canvas.noStroke(); // Without stroke
      canvas.ellipse(pos.x*canvas.width, pos.y*canvas.height, 15, 15); // 15 pixels in diameter
      //people[i].draw();
    }
  }
  
  // Draw platforms
  canvas.fill(255);
  canvas.rect(p1Pos.x, p1Pos.y, pWidth, pHeight);
  canvas.rect(p2Pos.x, p2Pos.y, pWidth, pHeight);

  // Ball
  ballPos = new PVector(ballPos.x + dir.x, ballPos.y + dir.y);
  // Test collisions
  if(ballPos.y > height || ballPos.y < 0){
    dir.y *=-1;
    ballPos = new PVector(ballPos.x + dir.x, ballPos.y + dir.y);
  }
  // P2
  if(ballPos.x >= p2Pos.x && (ballPos.y >= p2Pos.y && ballPos.y <= p2Pos.y + pHeight)){
   dir.x *=-1;
    ballPos = new PVector(ballPos.x + dir.x, ballPos.y + dir.y);
  }
  // P1
  if(ballPos.x <= p1Pos.x + pWidth && (ballPos.y >= p1Pos.y && ballPos.y <= p1Pos.y + pHeight)){
   dir.x *=-1;
    ballPos = new PVector(ballPos.x + dir.x, ballPos.y + dir.y);
  }
  // OUT
  if(ballPos.x > p2Pos.x + pWidth || ballPos.x < p1Pos.x || ballPos.y > height || ballPos.y < 0){
    ballPos = new PVector(width/2, height/2);
    dir = initDir;
  }

  // Draw Ball
  canvas.fill(255);
  canvas.ellipse(ballPos.x, ballPos.y, 10, 10);

}
