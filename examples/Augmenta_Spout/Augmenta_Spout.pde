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
// Declare the spout server
Spout spoutServer;
// Graphics that will hold the syphon/spout texture to send
PGraphics canvas;

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

  canvas = createGraphics(width, height, P2D);


  // Allow the frame to be resized
  if (frame != null) {
    frame.setResizable(true);
  }

  // Create the Augmenta receiver
  auReceiver= new AugmentaP5(this, oscPort);
  auReceiver.setTimeOut(5);

  //auReceiver.setGraphicsTarget(canvas);

  // You can hardcode the interactive area if you need to
  //auReceiver.interactiveArea.set(0.25f, 0.25f, 0.5f, 0.5f);

  // Create a syphon server to send frames out.
  if (platform == MACOSX) {
    server = new SyphonServer(this, "AugmentaSyphon");
  }
  else if (platform == WINDOWS)
  {
    spoutServer = new Spout();
    spoutServer.initSender("AugmentaSyphon", canvas.width, canvas.height);
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
  portInput = new GTextField(this, 10, 40, 60, 20);
  portInputButton = new GButton(this, 70, 40, 110, 20, "Change Osc Port");
  portInput.setText(""+oscPort);
  G4P.registerSketch(this);
  
}

void draw() {

  
  // Adjust the scene size
  //int[] sceneSize = auReceiver.getSceneSize();
  //if ( (width!=sceneSize[0] || height!=sceneSize[1]) && autoSceneSize.isSelected() && sceneSize[0]>100 && sceneSize[1]>100) {
   // frame.setSize(sceneSize[0]+frame.getInsets().left+frame.getInsets().right, sceneSize[1]+frame.getInsets().top+frame.getInsets().bottom);
  //}
  
  int sx = Integer.parseInt(sceneX.getText());
  int sy = Integer.parseInt(sceneY.getText());
  
  if(sx != canvas.width || sy != canvas.height)
  {
    canvas.setSize(sx,sy);
    return;
  }

  background(0);
  canvas.beginDraw();
  canvas.background(0);

  // Update the UI
  sceneSizeInfo.setText(canvas.width+"x"+canvas.height, GAlign.MIDDLE, GAlign.MIDDLE);

  // Get the person data
  AugmentaPerson[] people = auReceiver.getPeopleArray();

  // For each person...
  for (int i=0; i<people.length; i++) {
    PVector pos = people[i].centroid;
    PVector velocity = people[i].velocity; 

    // Draw a circle
    canvas.fill(0, 128, 255); // Filled in blue
    canvas.noStroke(); // Without stroke
    canvas.ellipse(pos.x*width, pos.y*height, 30, 30); // 30 pixels in diameter
    if (debug) {
      canvas.stroke(255);
      canvas.line(pos.x*width, pos.y*height, (pos.x+velocity.x*2)*width, (pos.y+velocity.y*2)*height);
      people[i].draw();
    }
  }

  if (debug) {
    // Draw the interactive area
    auReceiver.interactiveArea.draw();
  }

  // Syphon output
  if (platform == MACOSX) {
    server.sendImage(canvas);
  }
  else if (platform == WINDOWS)
  {
    spoutServer.sendImage(canvas);
  }

  //draw augmenta canvas
  image(canvas, 0, 100, canvas.width, canvas.height);

  canvas.endDraw();
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
    guiIsVisible = !guiIsVisible;
    showGUI(guiIsVisible);
  } 
  else if (key == 'd') {
    // Show/hide the debug info
    debug = !debug;
  }
}
// Used to set the interactive area
// click and drag to set a custom area, right click to set it to default (full scene)
float originX;
float originY;
void mousePressed() {
  if (debug) {
    if (mouseButton == LEFT) {
      originX = (float)mouseX/(float)width;
      originY = (float)mouseY/(float)height;
    } 
    else {
      auReceiver.interactiveArea.set(0f, 0f, 1f, 1f);
    }
  }
}
void mouseDragged() {
  if (debug) {
    if (mouseButton == LEFT) {
      float w = (float)mouseX/(float)width-originX;
      float h = (float)mouseY/(float)height-originY;
      if (w > 0 && h > 0) {
        auReceiver.interactiveArea.set(originX, originY, w, h);
      } 
      else if (w < 0 && h > 0) {
        auReceiver.interactiveArea.set((float)mouseX/(float)width, originY, -w, h);
      } 
      else if (h < 0 && w > 0) {
        auReceiver.interactiveArea.set(originX, (float)mouseY/(float)height, w, -h);
      } 
      else {
        auReceiver.interactiveArea.set((float)mouseX/(float)width, (float)mouseY/(float)height, -w, -h);
        println("Rect : "+(float)mouseX/(float)width+" "+ (float)mouseY/(float)height+" "+ -w+" "+ -h);
      }
    }
  }
}

public void handleButtonEvents(GButton button, GEvent event) { 
  if (button == portInputButton) {
    handlePortInputButton();
  } 
  else if (button == manualSceneButton) {
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
  } 
  else {
    sceneSizeInfo.setVisible(false);
    sceneX.setVisible(true);
    sceneY.setVisible(true);
    sceneX.setText(""+width);
    sceneY.setText(""+height);
    manualSceneButton.setVisible(true);
  }
}

public void handlePortInputButton() {

  if (Integer.parseInt(portInput.getText()) != oscPort) {
    println("input :"+portInput.getText());
    oscPort = Integer.parseInt(portInput.getText());
    auReceiver.unbind();
    auReceiver=null;
    auReceiver= new AugmentaP5(this, oscPort);
  }
}
public void handleManualSceneButton() {
  try {
    String xs = sceneX.getText();
    String ys = sceneY.getText();
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
  } 
  else {
    sceneX.setVisible(val);
    sceneY.setVisible(val);
    manualSceneButton.setVisible(val);
  }
}

