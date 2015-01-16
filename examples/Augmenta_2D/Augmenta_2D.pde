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
import g4p_controls.*;
import codeanticode.syphon.*;

// Declare the Augmenta receiver
AugmentaP5 auReceiver;
// Declare the inital OSC port
int oscPort = 12000;
// Declare the syphon server
SyphonServer server;
// Declare the UI
boolean guiIsVisible=true;
GTextField portInput;
GButton portInputButton;
GCheckbox autoSceneSize;
GLabel sceneSizeInfo;
GTextField sceneX;
GTextField sceneY;
GButton manualSceneButton;
// Declare a debug mode bool
boolean debug=false;

void setup() {

  // Set the initial frame size
  size(640, 480, P2D);

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
  autoSceneSize = new GCheckbox(this, 10, 10, 110, 20, "Auto scene size");
  autoSceneSize.setOpaque(true);
  sceneSizeInfo = new GLabel(this, 125, 10, 70, 20);
  sceneSizeInfo.setOpaque(true);
  sceneSizeInfo.setVisible(false);
  sceneX = new GTextField(this, 125, 10, 35, 20);
  sceneX.setText(""+width);
  sceneY = new GTextField(this, 161, 10, 35, 20);
  sceneY.setText(""+height);
  manualSceneButton = new GButton(this, 197, 10, 50, 20, "Change");
  portInput = new GTextField(this, 10, 40, 100, 20);
  portInputButton = new GButton(this, 110, 40, 50, 20, "Change");
  portInput.setText(""+oscPort);
  G4P.registerSketch(this);
}

void draw() {

  background(0);

  // Adjust the scene size
  int[] sceneSize = auReceiver.getSceneSize();
  if ( (width!=sceneSize[0] || height!=sceneSize[1]) && autoSceneSize.isSelected() && sceneSize[0]>100 && sceneSize[1]>100) {
    frame.setSize(sceneSize[0]+frame.getInsets().left+frame.getInsets().right, sceneSize[1]+frame.getInsets().top+frame.getInsets().bottom);
  }
  // Update the UI
  sceneSizeInfo.setText(sceneSize[0]+"x"+sceneSize[1], GAlign.MIDDLE, GAlign.MIDDLE);

  // Get the person data
  AugmentaPerson[] people = auReceiver.getPeopleArray();

  // For each person...
  for (int i=0; i<people.length; i++) {
    PVector pos = people[i].centroid; 

    // Draw a circle
    fill(0, 128, 255); // Filled in blue
    noStroke(); // Without stroke
    ellipse(pos.x*width, pos.y*height, 30, 30); // 30 pixels in diameter

    if (debug) {
      // Draw a point
      fill(255);
      noStroke();
      ellipse(pos.x*width, pos.y*height, 8, 8);
      // Add debug info
      text("pid : "+people[i].id+"\n"+"oid : "+people[i].oid+"\n"+"age : "+people[i].age, pos.x*width+10, pos.y*height);
      // Draw the bounding rectangle
      augmentaP5.Rectangle bounds = people[i].boundingRect;
      noFill();
      stroke(150);
      rect(width*bounds.x, height*bounds.y, bounds.width*width, bounds.height*height);
    }
  }
  // Syphon output
  if (platform == MACOSX) {
    server.sendScreen();
  }
}

void personEntered (AugmentaPerson p) {
  //println("Person entered : "+ p.id + "at ("+p.centroid.x+","+p.centroid.y+")");
}

void personUpdated (AugmentaPerson p) {
  //println("Person updated : "+ p.id + " at ("+p.centroid.x+","+p.centroid.y+")");
}

void personLeft (AugmentaPerson p) {
  //println("Person left : "+ p.id + " at ("+p.centroid.x+","+p.centroid.y+")");
}

void keyPressed() {

  // Show/Hide Gui
  if (key == 'h') {
    if (guiIsVisible) {
      guiIsVisible = false;
    } else {
      guiIsVisible = true;
    }
    showGUI(guiIsVisible);
  } else if (key == 'd') {
    // Show/hide the debug info
    if (debug) {
      debug = false;
    } else {
      debug = true;
    }
  }
}

public void handleButtonEvents(GButton button, GEvent event) { 
  if (button == portInputButton) {
    handlePortInputButton();
  } else if (button == manualSceneButton) {
    handleManualSceneButton();
  }
}
public void handleToggleControlEvents(GToggleControl box, GEvent event) {
  if (box == autoSceneSize) {
    handleAutoSceneSizeCheckbox();
  }
} 

public void handleAutoSceneSizeCheckbox() {  
  if (autoSceneSize.isSelected()) {
    sceneSizeInfo.setVisible(true);
    sceneX.setVisible(false);
    sceneY.setVisible(false);
    manualSceneButton.setVisible(false);
  } else {
    sceneSizeInfo.setVisible(false);
    sceneX.setVisible(true);
    sceneY.setVisible(true);
    sceneX.setText(""+width);
    sceneY.setText(""+height);
    manualSceneButton.setVisible(true);
  }
}

public void handlePortInputButton() {

  if (Integer.parseInt(portInput.stext.getPlainText()) != oscPort) {
    println("input :"+portInput.stext.getPlainText());
    oscPort = Integer.parseInt(portInput.stext.getPlainText());
    auReceiver.unbind();
    auReceiver=null;
    auReceiver= new AugmentaP5(this, oscPort);
  }
}
public void handleManualSceneButton() {
  try {
    String xs = sceneX.stext.getPlainText();
    String ys = sceneY.stext.getPlainText();
    xs.trim();
    ys.trim();
    int x = Integer.parseInt(xs);
    int y = Integer.parseInt(ys);
    if (width!=x || height!=y && !autoSceneSize.isSelected()) {
      frame.setSize(x+frame.getInsets().left+frame.getInsets().right, y+frame.getInsets().top+frame.getInsets().bottom);
    }
  }
  catch(NumberFormatException e) {
    println("The values entered for the screen size are not ints ! "+e);
  }
}

void showGUI(boolean val) {
  // Show or hide the GUI after the Syphon output
  portInput.setVisible(val); 
  portInputButton.setVisible(val);

  autoSceneSize.setVisible(val);
  if (autoSceneSize.isSelected()) {
    sceneSizeInfo.setVisible(val);
  } else {
    sceneX.setVisible(val);
    sceneY.setVisible(val);
    manualSceneButton.setVisible(val);
  }
}

