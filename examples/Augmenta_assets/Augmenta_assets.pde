/**
 *
 *    Augmenta Assets example
 *
 *    This scene shows you various examples of what kind of things you can do in processing with Augmenta :
 *    - Display points representing people and lines between them
 *    - [Audioreaction] Change the radius of the circle depending on a sound input
 *    - [Sprites] Add an image under people's feet
 *    - [Video] Play a video in the background
 *    - [Sound] Play a sound when a person enters the scene
 *    - [Triggers] Sends a message when a person enters/leaves the trigger area and allows to get a list of the people inside it at any time (shapes available : circles, rectangles, complex polygons)
 *
 *    Authors : David-Alexandre Chanel
 *              Tom Duchêne
 *
 *    Website : http://www.theoriz.com
 *
 */

import oscP5.*;
import augmentaP5.*;
import g4p_controls.*;
import codeanticode.syphon.*;
// [Sound] and [Audioreaction]
import ddf.minim.*;
// [Video]
import processing.video.*;

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
GTextField portInput;
GButton portInputButton;
GCheckbox autoSceneSize;
GLabel sceneSizeInfo;
GTextField sceneX;
GTextField sceneY;
// [Audioreaction]
GCustomSlider gainSlider;

// Declare a debug mode bool
boolean debug=false;

// [Sprites]
PImage img;

// [Sound]
Minim minim;
AudioPlayer ding;
// [Audioreaction]
AudioInput mic;
float volume;
float cappedVolume;
float gain;
// KNOWN ISSUE : Sound working on OSX 10.11 : deactivate sound on this version
boolean activateSound = false;

// [Video]
Movie bgVideo;

// [Triggers]
CircleTrigger ct;
RectangleTrigger rt;
PolygonTrigger pt;

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

  // Create a syphon server to send frames out.
  if (platform == MACOSX) {
    server = new SyphonServer(this, "Processing Syphon");
  }
  
  // Set the UI
  setUI();
  
  // [Sprites]
  // Load an image (.png/.jpg/.tga/.gif)
  // The file has to be in the "data" directory of your current sketch
  img = loadImage("plexus.png");
  
  // [Sound]
  if(activateSound){
    minim = new Minim(this);
    // The file has to be in you sketch's "data" folder
    ding = minim.loadFile("ding.wav");
  }
  
  // [Video]
  // The file has to be in you sketch's "data" folder. MP4 works well, MOV not so well.
  bgVideo = new Movie(this, "video.mp4");
  bgVideo.loop();
  
  // [Audioreaction]
  // UI
  if(activateSound){
    gainSlider = new GCustomSlider(this, 10, 55, 170, 50, "blue18px");
    gainSlider.setShowDecor(false, false, false, false);
    gainSlider.setNumberFormat(G4P.DECIMAL, 3);
    gainSlider.setLimits(0.5f, 0f, 100.0f);
    gainSlider.setShowValue(false); 
    // Get the microphone input
    //minim = new Minim(this); Warning ! Uncomment this line if you haven't already created an instance of Minim
    mic = minim.getLineIn(Minim.STEREO, 512);
    volume=0;
    gain=1;
    // The capped volume is the same as the volume but limited to a max value of 1
    cappedVolume=0;
  }
  
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

  // Adjust the scene size
  //adjustSceneSize();
  // Draw a background for the window
  background(0);
  // Begin drawing the canvas
  canvas.beginDraw();
  canvas.background(0);

  // Get the person data
  AugmentaPerson[] people = auReceiver.getPeopleArray();
  
  // [Video]
  // For an unknow reason trying to display the video on first frame outputs a nullpointerexception, this tests fixes it
  if (frameCount > 1){
    canvas.imageMode(CORNER);
    canvas.image(bgVideo, 0, 0, canvas.width, canvas.height);
  }
  
  // [Audioreaction]
  // Compute the current audio volume
  if(activateSound){
    gain = gainSlider.getValueF();
    volume = (mic.left.level()+mic.right.level())*gain/2;
    if (volume >1){
      cappedVolume = 1;
    } else {
      cappedVolume = volume;
    }
    // Display the VUmeter
    if (guiIsVisible){
      canvas.noStroke();
      // Draw the debug rectangle symbolizing the volume
      if (volume > 1){
        fill(255,0,0);
        rect(gainSlider.getX()+3, gainSlider.getY()+30, gainSlider.getWidth()-6, 5);
      } else if (volume > 0.8){
        fill(255,128,0); 
        rect(gainSlider.getX()+3, gainSlider.getY()+30, (gainSlider.getWidth())*volume, 5);
      } else {
        fill(0,255,0); 
        rect(gainSlider.getX()+3, gainSlider.getY()+30, (gainSlider.getWidth())*volume, 5);
      }
    }
  }

  // Draw a line between all the blobs
  canvas.stroke(255);
  canvas.strokeWeight(2);
  for (int k=0; k<people.length; k++) {
    PVector pos1 = people[k].centroid; 
    for (int l=k+1; l<people.length; l++) {
      PVector pos2 = people[l].centroid; 
      canvas.line(pos1.x*canvas.width, pos1.y*canvas.height, pos2.x*canvas.width, pos2.y*canvas.height);
    }
  }

  // For each person...
  for (int i=0; i<people.length; i++) {
    PVector pos = people[i].centroid; 
    
    // [Sprites]
    // Draw the sprite at the position of the person, with a small endless rotation
    canvas.pushMatrix();
    canvas.imageMode(CENTER);
    canvas.translate(pos.x*canvas.width, pos.y*canvas.height);
    canvas.rotate(radians(frameCount * 0.5f  % 360));
    canvas.image(img, 0, 0, 150, 150);
    canvas.popMatrix();
    
    // Draw a circle
    canvas.fill(255); // Filled in white
    canvas.noStroke(); // Without stroke
    // [Audioreaction] version
    if(activateSound){
      canvas.ellipse(pos.x*canvas.width, pos.y*canvas.height, 15+cappedVolume*50, 15+cappedVolume*50);
    }else{
      canvas.ellipse(pos.x*canvas.width, pos.y*canvas.height, 20, 20); // 20 pixels in diameter
    }

    // Draw debug informations
    if (debug) {
      people[i].draw();
    }
  }
  
  if (debug){
    // Draw the interactive area
    auReceiver.interactiveArea.draw();
  }
  
  // [Triggers]
  ct.update(people);
  rt.update(people);
  pt.update(people);
  if (debug){
    
    ct.draw(); 
    rt.draw();
    pt.draw();
  }
  
  // End the main draw loop
  canvas.endDraw();
  
  // Syphon output
  if (platform == MACOSX) {
    server.sendImage(canvas);
  }
  
  //draw augmenta canvas
  image(canvas, 0, 0, width, height);
  
}

void personEntered (AugmentaPerson p) {
  //println("Person entered : "+ p.id + "at ("+p.centroid.x+","+p.centroid.y+")");
  
  // [Sound]
    if(activateSound){
    ding.rewind();
    ding.play();
  }
}

void personUpdated (AugmentaPerson p) {
  //println("Person updated : "+ p.id + " at ("+p.centroid.x+","+p.centroid.y+")");
}

void personLeft (AugmentaPerson p) {
  //println("Person left : "+ p.id + " at ("+p.centroid.x+","+p.centroid.y+")");
}

// DO NOT REMOVE unless you remove the trigger classes
void personEnteredTrigger(int id, Trigger t){
  //println("The person with id '"+id+"' entered a trigger"); 
  // How to test which object has been triggered :
  if (t == ct){
    //println("It's the circle trigger");
  }
}

// DO NOT REMOVE unless you remove the trigger classes
void personLeftTrigger(int id, Trigger t){
  //println("The person with id '"+id+"' left a trigger");
}

void keyPressed() {

  // Show/Hide Gui
  if (key == 'h') {
    guiIsVisible = !guiIsVisible;
    showGUI(guiIsVisible);
  } else if (key == 'd') {
    // Show/hide the debug info
    debug = !debug;
  }   else if (key == ENTER || key == RETURN){
    if(portInput.hasFocus() == true) {
      handlePortInputButton();
    }
  }
}

// Used to set the interactive area
// click and drag to set a custom area, right click to set it to default (full scene)
float originX;
float originY;
void mousePressed(){
  if (debug){
    if (mouseButton == LEFT){
      originX = (float)mouseX/(float)width;
      originY = (float)mouseY/(float)height;
    } else {
      auReceiver.interactiveArea.set(0f, 0f, 1f, 1f);
    }
  }
}
void mouseDragged(){
  if (debug){
    if (mouseButton == LEFT){
      float w = (float)mouseX/(float)width-originX;
      float h = (float)mouseY/(float)height-originY;
      if (w > 0 && h > 0){
        auReceiver.interactiveArea.set(originX, originY, w, h); 
      } else if (w < 0 && h > 0){
        auReceiver.interactiveArea.set((float)mouseX/(float)width, originY, -w, h);
      } else if (h < 0 && w > 0){
        auReceiver.interactiveArea.set(originX, (float)mouseY/(float)height, w, -h);
      } else {
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
  } else {
    sceneSizeInfo.setVisible(false);
    sceneX.setVisible(true);
    sceneY.setVisible(true);
    sceneX.setText(""+width);
    sceneY.setText(""+height);
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

void showGUI(boolean val) {
  // Show or hide the GUI after the Syphon output
  portInput.setVisible(val); 
  portInputButton.setVisible(val);
  gainSlider.setVisible(val);

  autoSceneSize.setVisible(val);
  if (autoSceneSize.isSelected()) {
    sceneSizeInfo.setVisible(val);
  } else {
    sceneX.setVisible(val);
    sceneY.setVisible(val);
  }
}

// [Video]
// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}

void setUI(){
  // Set the UI
  /*
  autoSceneSize = new GCheckbox(this, 10, 10, 110, 20, "Auto scene size");
  autoSceneSize.setOpaque(true);
  sceneSizeInfo = new GLabel(this, 125, 10, 70, 20);
  sceneSizeInfo.setOpaque(true);
  sceneSizeInfo.setVisible(false);
  sceneX = new GTextField(this, 125, 10, 35, 20);
  sceneX.setText(""+width);
  sceneY = new GTextField(this, 161, 10, 35, 20);
  sceneY.setText(""+height);
  portInput = new GTextField(this, 10, 40, 60, 20);
  portInputButton = new GButton(this, 70, 40, 110, 20, "Change Osc Port");
  portInput.setText(""+oscPort);
  G4P.registerSketch(this);
  */
}
/*
void adjustSceneSize() {
  int sh = 0;
  int sw = 0;
  if (autoSceneSize.isSelected()) {
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
  if ( (canvas.width!=sw || canvas.height!=sh) && sw>100 && sh>100) {
    // Create the output canvas with the correct size
    println("adjust");
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
  sceneSizeInfo.setText(canvas.width+"x"+canvas.height, GAlign.MIDDLE, GAlign.MIDDLE);
}
*/