/**
 *
 *    Augmenta Triggers example
 *
 *    This scene shows you various examples of what kind of things you can do in processing with Augmenta :
 *    - [Triggers] Sends a message when a person enters/leaves the trigger area and allows to get a list of the people inside it at any time (shapes available : circles, rectangles, complex polygons)
 *
 *    Authors : David-Alexandre Chanel
 *              Tom Duchêne
 *
 *    Website : http://www.theoriz.com
 *
 */
 
import augmentaP5.*;
import TUIO.*;
import oscP5.*;

boolean mode3D = false;

// [Triggers]
CircleTrigger ct;
RectangleTrigger rt;
PolygonTrigger pt;

void setup() {

  setupAugmenta();
  setupSyphonSpout();
  setupGUI();
  
  // [Triggers]
  ct = new CircleTrigger(width/2, height/2, 50, this);
  
  rt = new RectangleTrigger(width/2, height/4, width, 0.75f*height, this);
  
  PVector[] points = new PVector[8];
  points[0]= new PVector(0,0);
  points[1]= new PVector(300,0);
  points[2]= new PVector(320,150);
  points[3]= new PVector(140,160);
  points[4]= new PVector(200,40);
  points[5]= new PVector(100,40);
  points[6]= new PVector(120,150);
  points[7]= new PVector(0,140);
  pt = new PolygonTrigger(points, this);

}

void draw() {

  adjustSceneSize();
  background(0);
  
  // All visuals to send must be drawn in this canvas
  // Prefix your drawing functions with "canvas." as below
  canvas.beginDraw();
  canvas.background(0);
  
  // Draw a blue disk for every persons
  AugmentaPerson[] people = auReceiver.getPeopleArray();

  for (int i=0; i<people.length; i++) {
    
    PVector pos = people[i].centroid; // Storing coordinates
    
    // Draw disk
    canvas.fill(0, 128, 255); // Blue disk
    canvas.noStroke(); // Without stroke
    canvas.ellipse(pos.x*canvas.width, pos.y*canvas.height, 15, 15); // 15 pixels diameter
  
  }

  // [Triggers]
  ct.update(people);
  rt.update(people);
  pt.update(people);
  if (drawDebugData){
    ct.draw(); 
    rt.draw();
    pt.draw();
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

// DO NOT REMOVE unless you remove the trigger classes
void personEnteredTrigger(int id, Trigger t){
  println("The person with id '"+id+"' entered a trigger"); 
  // How to test which object has been triggered :
  if (t == ct){
    println("It's the circle trigger");
  }
}

// DO NOT REMOVE unless you remove the trigger classes
void personLeftTrigger(int id, Trigger t){
  println("The person with id '"+id+"' left a trigger");
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