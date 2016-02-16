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
import controlP5.*;

// Declare the Augmenta receiver
AugmentaP5 auReceiver;
// Declare the inital OSC port
int oscPort = 12000;

// Declare the syphon server
SyphonServer server;
// Graphics that will hold the syphon/spout texture to send
PGraphics canvas;

// Declare the UI
boolean guiIsVisible=true;
// ControlP5
ControlP5 cp5;
CheckBox autoSceneSize;
Textfield sceneX;
Textfield sceneY;
Textlabel sceneSizeInfo;
Textfield portInput;

// Declare a debug mode bool
boolean debug=false;

void settings(){
  // Set the initial frame size
  size(640, 480, P2D);
  PJOGL.profile=1;
}

void setup() {

  // Create the canvas that will be used to send the syphon output
  canvas = createGraphics(width, height, P2D);

  // Allow the frame to be resized
  if (surface != null) {
    surface.setResizable(true);
  }

  // Create the Augmenta receiver
  auReceiver= new AugmentaP5(this, oscPort);
  auReceiver.setTimeOut(30);
  // You can hardcode the interactive area if you need to
  //auReceiver.interactiveArea.set(0.25f, 0.25f, 0.5f, 0.5f);

  auReceiver.setGraphicsTarget(canvas);

  // Create a syphon server to send frames out.
  if (platform == MACOSX) {
    server = new SyphonServer(this, "Processing Syphon");
  }
  
  // New GUI instance
  cp5 = new ControlP5(this);
  // Set the properties format : needed to save/load correctly
  cp5.getProperties().setFormat(ControlP5.SERIALIZED);

  // Set the UI
  setUI();
  loadSettings("settings");
}

void draw() {

  // Adjust the scene size
  adjustSceneSize();
  // Draw a background for the window
  background(0);
  // Begin drawing the canvas
  canvas.beginDraw();
  canvas.background(0);

  // Get the person data
  AugmentaPerson[] people = auReceiver.getPeopleArray();

  // For each person...
  for (int i=0; i<people.length; i++) {
    PVector pos = people[i].centroid;
    PVector velocity = people[i].velocity; 

    // Draw a circle
    canvas.fill(0, 128, 255); // Filled in blue
    canvas.noStroke(); // Without stroke
    canvas.ellipse(pos.x*canvas.width, pos.y*canvas.height, 15, 15); // 30 pixels in diameter
    if (debug) {
      canvas.stroke(255);
      //canvas.line(pos.x*canvas.width, pos.y*canvas.height, (pos.x+velocity.x*2)*canvas.width, (pos.y+velocity.y*2)*canvas.height);
      people[i].draw();
    }
  }

  if (debug) {
    // Draw the interactive area
    auReceiver.interactiveArea.draw();
  }

  canvas.endDraw();
  
  //draw augmenta canvas
  image(canvas, 0, 0, width, height);
  
  // Syphon output
  if (platform == MACOSX) {
    server.sendImage(canvas);
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
  } else if (keyCode == TAB){
    if (sceneX.isFocus()){
       sceneX.setFocus(false);
       sceneY.setFocus(true);
    }
  } else if(key == 's'){
   saveSettings("settings"); 
  }
}

public void changeInputPort(String s) {

  if (Integer.parseInt(s) != oscPort) {
    println("input :"+portInput.getText());
    oscPort = Integer.parseInt(portInput.getText());
    auReceiver.unbind();
    auReceiver=null;
    auReceiver= new AugmentaP5(this, oscPort);
  }
}

void showGUI(boolean val) {
  // Show or hide the GUI after the Syphon output
  portInput.setVisible(val);

  autoSceneSize.setVisible(val);
  if (autoSceneSize.getArrayValue()[0] == 1) {
    sceneSizeInfo.setVisible(val);
  } else {
    sceneX.setVisible(val);
    sceneY.setVisible(val);
  }
}

void setUI() {
  
  //Auto scene size + manual scene size
  autoSceneSize = cp5.addCheckBox("changeAutoSceneSize")
                .setPosition(10, 10)
                .setSize(20, 20)
                .addItem("Auto Scene Size", 0)
                ;
  sceneX = cp5.addTextfield("changeSceneWidth")
     .setPosition(110,10)
     .setSize(30,20)
     .setAutoClear(false)
     .setCaptionLabel("")
     .setInputFilter(ControlP5.INTEGER);
     ;
  sceneX.setText(""+width);
  sceneY = cp5.addTextfield("changeSceneHeight")
     .setPosition(140,10)
     .setSize(30,20)
     .setAutoClear(false)
     .setCaptionLabel("")
     .setInputFilter(ControlP5.INTEGER);
     ;
  sceneY.setText(""+height);
  sceneSizeInfo = cp5.addTextlabel("label")
                    .setText("500x500")
                    .setPosition(110,16)
                    ;
  sceneSizeInfo.setVisible(false);
  
  // Port input OSC
  portInput = cp5.addTextfield("changeInputPort")
     .setPosition(10,40)
     .setSize(40,20)
     .setAutoClear(false)
     .setCaptionLabel("")
     .setInputFilter(ControlP5.INTEGER);
     ;
  portInput.setText(""+oscPort);
  // corresponding label
  cp5.addTextlabel("labeloscport")
      .setText("OSC input port")
      .setPosition(55, 46)
      ;
}

void changeAutoSceneSize(float[] a) {
  if (autoSceneSize.getArrayValue()[0] == 1) {
    sceneSizeInfo.setVisible(true);
    sceneX.setVisible(false);
    sceneY.setVisible(false);
  } else {
    sceneSizeInfo.setVisible(false);
    sceneX.setVisible(true);
    sceneY.setVisible(true);
    sceneX.setText(""+width);
    sceneY.setText(""+height);
  }
}

void adjustSceneSize() {
  int sh = 0;
  int sw = 0;
  if (autoSceneSize.getArrayValue()[0] == 1) {
    int[] sceneSize = auReceiver.getSceneSize();
    sw = sceneSize[0];
    sh = sceneSize[1];
  } else {
    try {
      sw = Integer.parseInt(sceneX.getText());
      sh = Integer.parseInt(sceneY.getText());
    }
    catch(NumberFormatException e) {
      println("The values entered for the screen size are not ints ! "+e);
    }
  }
  if ( (canvas.width!=sw || canvas.height!=sh) && sw>100 && sh>100 && sw<=16000 && sh <=16000 ) {
    // Create the output canvas with the correct size
    canvas = createGraphics(sw, sh);
    float ratio = (float)sw/(float)sh;
    if (sw >= displayWidth*0.9f || sh >= displayHeight*0.9f) {
      // Resize the window to fit in the screen with the correct ratio
      if ( ratio > displayWidth/displayHeight ) {
        sw = (int)(displayWidth*0.8f);
        sh = (int)(sw/ratio);
      } else {
        sh = (int)(displayHeight*0.8f);
        sw = (int)(sh*ratio);
      }
    }
    surface.setSize(sw+frame.getInsets().left+frame.getInsets().right, sh+frame.getInsets().top+frame.getInsets().bottom);
  }
  
  // Update the UI text field
  sceneSizeInfo.setText(canvas.width+"x"+canvas.height);
}

void saveSettings(String file){
  println("Saving to : "+file);
  cp5.saveProperties(file);
}

void loadSettings(String file){
  println("Loading from : "+file);
  cp5.loadProperties(file);
}

void stop(){
 saveSettings("settings"); 
}