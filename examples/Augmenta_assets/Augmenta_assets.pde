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
 *
 *    Authors : David-Alexandre Chanel
 *              Tom Duchêne
 *
 *    Website : http://www.theoriz.com
 *
 */

import oscP5.*;
import netP5.*;
import augmentaP5.*;
import g4p_controls.*;
import codeanticode.syphon.*;
// [Sound]
import ddf.minim.*;
// [Video]
import processing.video.*;

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

// [Video]
Movie bgVideo;

// [Triggers]
CircleTrigger ct;
RectangleTrigger rt;
PolygonTrigger pt;

void setup() {

  // Set the initial frame size
  size(640, 480, P2D);

  // Allow the frame to be resized
  if (frame != null) {
    frame.setResizable(true);
  }

  // Create the Augmenta receiver
  auReceiver= new AugmentaP5(this, oscPort);
  auReceiver.setTimeOut(30);

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
  portInput = new GTextField(this, 10, 40, 60, 20);
  portInputButton = new GButton(this, 70, 40, 110, 20, "Change Osc Port");
  portInput.setText(""+oscPort);
  G4P.registerSketch(this);
  
  // [Sprites]
  // Load an image (.png/.jpg/.tga/.gif)
  // The file has to be in the "data" directory of your current sketch
  img = loadImage("plexus.png");
  
  // [Sound]
  minim = new Minim(this);
  // The file has to be in you sketch's "data" folder
  ding = minim.loadFile("ding.wav");
  
  // [Video]
  // The file has to be in you sketch's "data" folder. MP4 works well, MOV not so well.
  bgVideo = new Movie(this, "video.mp4");
  bgVideo.loop();
  
  // [Audioreaction]
  // UI
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
  
  // [Video]
  imageMode(CORNER);
  image(bgVideo, 0, 0, width, height);
  
  // [Audioreaction]
  // Compute the current audio volume
  gain = gainSlider.getValueF();
  volume = (mic.left.level()+mic.right.level())*gain/2;
  if (volume >1){
    cappedVolume = 1;
  } else {
    cappedVolume = volume;
  }
  // Display the VUmeter
  if (guiIsVisible){
    noStroke();
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

  // Draw a line between all the blobs
  stroke(255);
  strokeWeight(2);
  for (int k=0; k<people.length; k++) {
    PVector pos1 = people[k].centroid; 
    for (int l=k+1; l<people.length; l++) {
      PVector pos2 = people[l].centroid; 
      line(pos1.x*width, pos1.y*height, pos2.x*width, pos2.y*height);
    }
  }

  // For each person...
  for (int i=0; i<people.length; i++) {
    PVector pos = people[i].centroid; 
    
    // [Sprites]
    // Draw the sprite at the position of the person, with a small endless rotation
    pushMatrix();
    imageMode(CENTER);
    translate(pos.x*width, pos.y*height);
    rotate(radians(frameCount * 0.5f  % 360));
    image(img, 0, 0, 150, 150);
    popMatrix();
    
    // Draw a circle
    fill(255); // Filled in white
    noStroke(); // Without stroke
    // Normal version (commented)
    // ellipse(pos.x*width, pos.y*height, 20, 20); // 20 pixels in diameter
    // [Audioreaction] version
    ellipse(pos.x*width, pos.y*height, 15+cappedVolume*50, 15+cappedVolume*50);

    // Draw debug informations
    if (debug) {
      // Draw a point for the centroid
      fill(255);
      noStroke();
      ellipse(pos.x*width, pos.y*height, 8, 8);
      // Add debug info
      text("pid : "+people[i].id+"\n"+"oid : "+people[i].oid+"\n"+"age : "+people[i].age, pos.x*width+10, pos.y*height);
      // Draw the bounding rectangle
      augmentaP5.RectangleF bounds = people[i].boundingRect;
      noFill();
      stroke(150);
      rect(width*bounds.x, height*bounds.y, bounds.width*width, bounds.height*height);
    }
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
  
  // Syphon output
  if (platform == MACOSX) {
    server.sendScreen();
  }
}

void personEntered (AugmentaPerson p) {
  //println("Person entered : "+ p.id + "at ("+p.centroid.x+","+p.centroid.y+")");
  
  // [Sound]
  ding.rewind();
  ding.play();
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
  gainSlider.setVisible(val);

  autoSceneSize.setVisible(val);
  if (autoSceneSize.isSelected()) {
    sceneSizeInfo.setVisible(val);
  } else {
    sceneX.setVisible(val);
    sceneY.setVisible(val);
    manualSceneButton.setVisible(val);
  }
}

// [Video]
// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
}

