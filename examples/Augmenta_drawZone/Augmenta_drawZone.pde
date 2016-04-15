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
 
import augmentaP5.*;
import TUIO.*;
import oscP5.*;

boolean mode3D = false;

void setup() {

  // /!\ Keep this setup order !
  setupSyphonSpout();
  setupAugmenta();
  setupGUI();
  
  // Add your code here
}

void draw() {

  adjustSceneSize();
  background(0);
  
  // All visuals to send must be drawn in this canvas
  // Prefix your drawing functions with "canvas." as below
  canvas.beginDraw();
  //canvas.background(0);
  
  // Draw a blue disk for every persons
  AugmentaPerson[] people = auReceiver.getPeopleArray();

  for (int i=0; i<people.length; i++) {
    
    PVector pos = people[i].centroid; // Storing coordinates
    
    // Draw white disks
    canvas.fill(255); // Filled in white
    canvas.noStroke(); // Without stroke
    canvas.ellipse(pos.x*canvas.width, pos.y*canvas.height, 50, 50); // 50 pixels in diameter  
  }

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

void personEntered (AugmentaPerson p) {
  //println("Person entered : "+ p.id + " at ("+p.centroid.x+","+p.centroid.y+")");
}

void personUpdated (AugmentaPerson p) {
  //println("Person updated : "+ p.id + " at ("+p.centroid.x+","+p.centroid.y+")");
}

void personLeft (AugmentaPerson p) {
  //println("Person left : "+ p.id + " at ("+p.centroid.x+","+p.centroid.y+")");
}