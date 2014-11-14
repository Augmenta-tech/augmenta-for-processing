/**
*
*    * Augmenta 2D example
*    Receiving and drawing basic data from Augmenta
*
*    Author : David-Alexandre Chanel
*             Tom Duchêne
*
*    Website : http://www.theoriz.com
*
*/

import oscP5.*;
import netP5.*;
import augmentaP5.*;
import peasy.test.*;
import peasy.org.apache.commons.math.*;
import peasy.*;
import peasy.org.apache.commons.math.geometry.*;
import g4p_controls.*;
import codeanticode.syphon.*;

// Declare the Augmenta receiver
AugmentaP5 auReceiver;
// Declare the inital OSC port
int oscPort = 12000;
// Declare the syphon server
SyphonServer server;
// UI
boolean guiIsVisible=true;
GLabel title;
GLabel sceneSizeInfo;
GLabel inputPort;

void setup() {

  // Set the initial frame size
  size(640,480, P2D);

  // Allow the frame to be resized
  if (frame != null) {
    frame.setResizable(true);
  }
  
  // Create the Augmenta receiver
  auReceiver= new AugmentaP5(this, oscPort);
  
  // Create a syphon server to send frames out.
  if (platform == MACOSX) {
    server = new SyphonServer(this, "Processing Syphon");
  }
  
  // Set the UI
  title = new GLabel(this, 10, 10, 200, 20);
  title.setOpaque(true);
  title.setTextBold();
  sceneSizeInfo = new GLabel(this, 10, 40, 200, 20);
  sceneSizeInfo.setOpaque(true);
  inputPort = new GLabel(this, 10, 70, 200, 20);
  inputPort.setOpaque(true);
  //portInput = new GTextField(this,10,70,100,20);
  //portInputButton = new GButton(this,110,70,50,20, "Change");
  //portInput.setText("12000");
  G4P.registerSketch(this);
}

void draw() {
  
  background(0);

  // Adapt the window to the scene size if needed
  int[] sceneSize = auReceiver.getSceneSize();
  if (width!=sceneSize[0] || height!=sceneSize[1])
  {
     //frame.setSize(sceneSize[0]+frame.getInsets().left+frame.getInsets().right, sceneSize[1]+frame.getInsets().top+frame.getInsets().bottom);
  }
    
  // Get the person data
  AugmentaPerson[] people = auReceiver.getPeopleArray();
   
  // For each person...
  for (int i=0; i<people.length; i++){
    
    // Draw the centroid
    PVector pos = people[i].centroid;
    noStroke();
    fill(255);
    ellipse(pos.x*width, pos.y*height, 10, 10);
    text("pid : "+people[i].id+"\n"+"oid : "+people[i].oid+"\n"+"age : "+people[i].age, pos.x*width+10, pos.y*height);
    
    // Draw the bounding box
    augmentaP5.Rectangle bounds = people[i].boundingRect;
    stroke(150);
    noFill();
    rect(width*bounds.x, height*bounds.y, bounds.width*width,bounds.height*height);
  }
    // Syphon output
  if (platform == MACOSX) {
    server.sendScreen();
  }

  // Update the UI
  title.setText("Current scene : 2D example", GAlign.LEFT, GAlign.MIDDLE);
  sceneSizeInfo.setText("Scene size : "+ sceneSize[0]+"x"+sceneSize[1], GAlign.LEFT, GAlign.MIDDLE);
  inputPort.setText("Osc port : " + oscPort, GAlign.LEFT, GAlign.MIDDLE);
}

void personEntered (AugmentaPerson p){
  println("Person entered : "+ p.id + "at ("+p.centroid.x+","+p.centroid.y+")"); 
}

void personUpdated (AugmentaPerson p){
  println("Person updated : "+ p.id + " at ("+p.centroid.x+","+p.centroid.y+")");  
}

void personLeft (AugmentaPerson p){
  println("Person left : "+ p.id + " at ("+p.centroid.x+","+p.centroid.y+")"); 
}

void keyPressed() {

  // Show/Hide Gui
  if (key == 'h' || key== 'H') {
    if (guiIsVisible) {
      guiIsVisible = false;
    } else {
      guiIsVisible = true;
    }
    showGUI(guiIsVisible);
  }
}

void showGUI(boolean val) {
  //portInput.setVisible(val); 
  //portInputButton.setVisible(val);
  inputPort.setVisible(val);
  title.setVisible(val);
  sceneSizeInfo.setVisible(val);
}


