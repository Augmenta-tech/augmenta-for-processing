/**
 *
 *    * Augmenta 3D example
 *    Receiving and drawing 3D data from Augmenta
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
import peasy.*; // Peasycam to move around the area

// Declare the camera
PeasyCam cam;
PMatrix originalMatrix; // to store initial PMatrix
PMatrix lastCamMatrix;
boolean updateOriginalMatrix = false;
boolean mode3D = true;

void setup() {

  // /!\ Keep this setup order !
  setupSyphonSpout();
  setupAugmenta();
  setupGUI();
  
  // Save the basic matrix of the scene before peasycam
  originalMatrix = getMatrix();
  printMatrix();
  lights();
  createEasyCam();
  stroke(255);
  smooth(4);
  
  // Add your code here
}

void draw() {

  if (cam == null){
    updateOriginalMatrix = true;
  }
  
  // If scene has changed reset Camera
  if(adjustSceneSize()) {
      cam.setActive(false);
      cam = null;
  }
  
  background(0);
  
  // All visuals to send must be drawn in this canvas
  // Prefix your drawing functions with "canvas." as below
  canvas.beginDraw();
  
  manage3DMatrix();

  canvas.background(0);
  
  // Draw the floor surface
  canvas.pushMatrix();
  canvas.translate(0, 0, -1);
  canvas.rectMode(CENTER);
  canvas.fill(70);
  canvas.rect(0, 0, width, height);
  canvas.popMatrix();
  
  // Draw every persons
  AugmentaPerson[] people = auReceiver.getPeopleArray();

  for (int i=0; i<people.length; i++) {
    
    PVector pos = people[i].centroid;
    
    augmentaP5.RectangleF rect = people[i].boundingRect;
    float rectHeight = 200;
    if (people[i].highest.z != 0 ) {
      rectHeight = people[i].highest.z*400;
    }

    // Centroids
    canvas.pushMatrix();
    canvas.translate(width*(pos.x-0.5), height*(pos.y-0.5), 3); 
    canvas.fill(255);
    canvas.ellipseMode(CENTER);
    canvas.ellipse(0, 0, 5, 5);
    
    if (drawDebugData){
      //println("People size : "+rect.x+" "+rect.y+" "+rectHeight);
      canvas.pushMatrix();
      canvas.translate(15, 0, 0);
      canvas.text("pid : "+people[i].id+"\n"+"oid : "+people[i].oid+"\n"+"age : "+people[i].age, 0, 0);
      canvas.popMatrix();
    }

    canvas.popMatrix();

    // Bounding boxes
    canvas.pushMatrix();
    canvas.translate(width*(rect.x-0.5+rect.width/2), height*(rect.y-0.5+rect.height/2), rectHeight/2); 
    canvas.fill(255, 255, 255, 30);
    canvas.stroke(255);
    canvas.box(rect.width*width, rect.height*height, rectHeight);
    canvas.popMatrix();
  }
  
  canvas.endDraw();
  
  updateMatrix();
  
  // Draw canvas in the window
  image(canvas, 0, 0, width, height);
  
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

void personWillLeave (AugmentaPerson p) {
  //println("Person will leave : "+ p.id + " at ("+p.centroid.x+","+p.centroid.y+")");
}