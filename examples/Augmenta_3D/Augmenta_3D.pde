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

import oscP5.*;
import netP5.*;
import augmentaP5.*;
import peasy.test.*;
import peasy.org.apache.commons.math.*;
import peasy.*;
import peasy.org.apache.commons.math.geometry.*;
import g4p_controls.*;
import codeanticode.syphon.*;

// Declare the Augmenta Receiver
AugmentaP5 auReceiver;
// Declare the camera
PeasyCam cam;
// Declare the syphon server
SyphonServer server;
// Declare the inital OSC port
int oscPort = 12000;

// Declare the UI
boolean guiIsVisible=true;
//GTextField portInput;
//GButton portInputButton;
GLabel title;
GLabel sceneSizeInfo;
GLabel inputPort;

// Global vars
int heightFactor=5;

void setup() {
  // Initial frame size
  size(640, 480, P3D);

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

  // 3D camera
  lights();
  cam = new PeasyCam(this, 1000);
  cam.setMinimumDistance(1);
  cam.setMaximumDistance(800);

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

  // Graphic settings
  stroke(255);
  smooth(4);
}

void draw() {

  // Global scene code

  // Adjust the scene size
  int[] sceneSize = auReceiver.getSceneSize();
  if (width!=sceneSize[0] || height!=sceneSize[1]) {
    //frame.setSize(sceneSize[0]+frame.getInsets().left+frame.getInsets().right, sceneSize[1]+frame.getInsets().top+frame.getInsets().bottom);
  }

  // Get the person array
  AugmentaPerson[] people = auReceiver.getPeopleArray();

  // Draw a background
  background(0);

  // Draw the interactive surface
  pushMatrix();
  translate(0, 0, -1);
  rectMode(CENTER);
  fill(70);
  rect(0, 0, width, height);
  popMatrix();
  // Draw a circle for each blob
  for (int i=0; i<people.length; i++) {
    PVector pos = people[i].centroid;
    augmentaP5.Rectangle rect = people[i].boundingRect;
    float rectHeight = 200;
    if (people[i].highest.z != 0 ) {
      rectHeight = people[i].highest.z;
    }

    // Centroids
    pushMatrix();
    translate(width*(pos.x-0.5), height*(pos.y-0.5), 3); 
    fill(255);
    ellipseMode(CENTER);
    ellipse(0, 0, 5, 5);
    //box(30);
    println("People size : "+rect.x+" "+rect.y+" "+rectHeight);
    pushMatrix();
    translate(15, 0, 0);
    text("pid : "+people[i].id+"\n"+"oid : "+people[i].oid+"\n"+"age : "+people[i].age, 0, 0);
    popMatrix();
    popMatrix();

    // Bounding boxes
    pushMatrix();
    translate(width*(rect.x-0.5+rect.width/2), height*(rect.y-0.5+rect.height/2), rectHeight/2); 
    fill(255, 255, 255, 30);
    stroke(255);
    box(rect.width*width, rect.height*height, rectHeight);
    //box(30);
    println("People size : "+rect.x+" "+rect.y+" "+rect.width+" "+rect.height);
    popMatrix();
  }

  // Syphon output
  if (platform == MACOSX) {
    server.sendScreen();
  }
  
  // Update the UI
  title.setText("Current scene : 3D example", GAlign.LEFT, GAlign.MIDDLE);
  sceneSizeInfo.setText("Scene size : "+ sceneSize[0]+"x"+sceneSize[1], GAlign.LEFT, GAlign.MIDDLE);
  inputPort.setText("Osc port : " + oscPort, GAlign.LEFT, GAlign.MIDDLE);
}

public void handleButtonEvents(GButton button, GEvent event) { 
  //if (button == portInputButton)
  //  handlePortInputButton();
}

/*public void handlePortInputButton(){  
 if (Integer.parseInt(portInput.stext.getPlainText()) != oscPort){
 oscPort = Integer.parseInt(portInput.stext.getPlainText());
 tspsReceiver=null;
 tspsReceiver= new TSPS(this, oscPort);
 }
 }*/

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

