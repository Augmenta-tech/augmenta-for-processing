/**
 *
 *    * Augmenta 2D example
 *    Receiving and drawing data from Augmenta
 *    Including all tools for real life use
 *
 *    Author : David-Alexandre Chanel
 *             Tom Duchêne
 *
 *    Website : http://www.theoriz.com
 *
 */
 
import augmenta.*;
import oscP5.*;

boolean mode3D = false;

void setup() {

  // /!\ Keep this setup order !
  setupSyphonSpout();
  setupAugmenta();
  setupGUI();
  setupPong(canvas);
  // enable the resizable window
  surface.setResizable(true);

  // Add your code here
}

void draw() {

  if(adjustSceneSize())
  {
    setupPong(canvas);
  }
  
  background(0);
  
  // All visuals to send must be drawn in this canvas
  // Prefix your drawing functions with "canvas." as below
  canvas.beginDraw();
  canvas.background(0);

  drawPong();
  drawAugmenta();

  canvas.endDraw();
  
  // Draw canvas in the window
  image(canvas, 0, 0, width, height);

  // Display instructions
  if(drawDebugData) {
    textSize(10);
    fill(255);
    text("Drag mouse to set the interactive area. Right click to reset.",10,height - 10);
  }
  
  // Syphon/Spout output
  sendFrames();
}

// You can also use these events functions which are triggered automatically

void objectEntered (AugmentaObject o) {
  //println("Person entered : "+ p.pid + " at ("+p.centroid.x+","+p.centroid.y+")");
}

void objectUpdated (AugmentaObject o) {
  //println("Person updated : "+ p.pid + " at ("+p.centroid.x+","+p.centroid.y+")");
}

void objectWillLeave (AugmentaObject o) {
  //println("Person will leave : "+ p.pid + " at ("+p.centroid.x+","+p.centroid.y+")");
}
