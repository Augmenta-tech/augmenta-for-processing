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

import oscP5.*; // needed for augmenta
import TUIO.*; // Needed for augmenta
import augmentaP5.*; // Augmenta
import codeanticode.syphon.*; // Syphon
import java.util.List; // Needed for the GUI implementation
import controlP5.*; // GUI
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
// Declare the boolean defining if we're in TUIO mode
boolean tuio = false;

// Graphics that will hold the syphon/spout texture to send
PGraphics canvas;

// Declare the UI
boolean guiIsVisible=true;
boolean uiIsLoaded=false;
// ControlP5
ControlP5 cp5;
Toggle autoSceneSize;
Textlabel autoSizeLabel;
Textfield sceneX;
Textfield sceneY;
Textlabel sceneSizeInfo;
Textfield portInput;
Textlabel portInputLabel;
Toggle tuioToggle;
Textlabel tuioLabel;
// [Audioreaction]
Slider gainSlider;
float gainSliderValue;

// Save manual scene size info
int manualSceneX;
int manualSceneY;

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
// KNOWN ISSUE : Sound not working on OSX 10.11 : deactivate sound on this version
boolean activateSound = true;

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
  
  manualSceneX = width;
  manualSceneY = height;

  // Create the Augmenta receiver
  auReceiver= new AugmentaP5(this, oscPort);
  auReceiver.setTimeOut(30);
  auReceiver.setGraphicsTarget(canvas);
  // You can hardcode the interactive area if you need to
  //auReceiver.interactiveArea.set(0.25f, 0.25f, 0.5f, 0.5f);

  // Create a syphon server to send frames out.
  if (platform == MACOSX) {
    server = new SyphonServer(this, "Processing Syphon");
  }
  
  // New GUI instance
  cp5 = new ControlP5(this);
  
  // Set the UI
  setUI();
  
  // Load the settings
  loadSettings("settings");
  
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
  adjustSceneSize();
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
    gain = gainSliderValue;
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
      int xp = 30;
      int yp = 150;
      int sliderWidth = 150;
      if (volume > 1){
        fill(255,0,0);
        rect(xp, yp, sliderWidth, 5);
      } else if (volume > 0.8){
        fill(255,128,0); 
        rect(xp, yp, sliderWidth*volume, 5);
      } else {
        fill(0,255,0); 
        rect(xp, yp, sliderWidth*volume, 5);
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

// [Video]
// Called every time a new frame is available to read
void movieEvent(Movie m) {
  m.read();
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

void keyPressed(){
  if (key == 'h') {
    // Show/Hide Gui
    guiIsVisible=!guiIsVisible;
    showGUI(guiIsVisible);
  } else if (key == 'd') {
    // Show/hide the debug info
    debug=!debug;
    println("debug : "+debug);
  } else if (keyCode == TAB){
    // Go to next textfield when typing in sceneX
    if (sceneX.isFocus()){
       sceneX.setFocus(false);
       sceneY.setFocus(true);
    }
  } else if(key == 's'){
   saveSettings("settings"); 
  } else if(key == 'l'){
   loadSettings("settings"); 
  } else if (key == 'i'){
   changeTuio(false); 
  }
}

void showGUI(boolean val) {
  // Show or hide the GUI (always after the Syphon output)
  autoSceneSize.setVisible(val);
  autoSizeLabel.setVisible(val);
  if (autoSceneSize.getBooleanValue()) {
    sceneSizeInfo.setVisible(val);
  } else {
    sceneX.setVisible(val);
    sceneY.setVisible(val);
  }
  
  portInput.setVisible(val);
  portInputLabel.setVisible(val);
  
  tuioToggle.setVisible(val);
  tuioLabel.setVisible(val);
}

void adjustSceneSize() {
  // Called each frame, adjust the scene size depending on various parameters
  int sh = 0;
  int sw = 0;
  if (autoSceneSize.getBooleanValue()) {
    int[] sceneSize = auReceiver.getSceneSize();
    sw = sceneSize[0];
    sh = sceneSize[1];
  } else {
      sw = manualSceneX;
      sh = manualSceneY;
  }
  if ( (canvas.width!=sw || canvas.height!=sh) && sw>=100 && sh>=100 && sw<=16000 && sh <=16000 ) {
    // Create the output canvas with the correct size
    canvas = createGraphics(sw, sh, P2D);
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
    surface.setSize(sw, sh);
    auReceiver.setGraphicsTarget(canvas);
  } else if (sw <100 || sh <100 || sw > 16000 || sh > 16000) {
     println("ERROR : cannot set a window size smaller than 100 or greater than 16000"); 
  }
  // Update the UI text field
  sceneSizeInfo.setText(canvas.width+"x"+canvas.height);
}

// --------------------------------------
// Set the GUI
// --------------------------------------
void setUI() {
  
  //Auto scene size + manual scene size
  autoSceneSize = cp5.addToggle("changeAutoSceneSize")
     .setPosition(10, 10)
     .setSize(20, 20)
     .setLabel("")
     .setValue(false)
     ;
  autoSizeLabel = cp5.addTextlabel("labelAutoSceneSize")
      .setText("Auto scene size")
      .setPosition(30, 16)
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
  portInputLabel = cp5.addTextlabel("labeloscport")
      .setText("OSC input port")
      .setPosition(55, 46)
      ;
      
  // TUIO toggle
  tuioToggle = cp5.addToggle("changeTuio")
     .setPosition(10, 70)
     .setSize(20, 20)
     .setLabel("")
     .setValue(false)
     ;
  tuioLabel = cp5.addTextlabel("labelTuioToggle")
      .setText("TUIO mode")
      .setPosition(30, 76)
      ;
      
  // Gain slider for [AudioReaction]
  cp5.addSlider("gainSLider")
     .setPosition(10,100)
     .setSize(150, 15)
     .setLabel("")
     .setRange(0,1)
     ;
}
// --------------------------------------


// --------------------------------------
// GUI change handlers
// --------------------------------------
void changeSceneWidth(String s){
  updateManualSize();
}
void changeSceneHeight(String s){
  updateManualSize(); 
}
void updateManualSize(){
  try{
   manualSceneX = Integer.parseInt(sceneX.getText());
   manualSceneY = Integer.parseInt(sceneY.getText()); 
  } catch(Exception e){
    return;
  }
}
void changeAutoSceneSize(boolean b) {
  if(sceneSizeInfo != null && sceneX != null && sceneY != null){
    if (b) {
      sceneSizeInfo.setVisible(true);
      sceneX.setVisible(false);
      sceneY.setVisible(false);
    } else {
      sceneSizeInfo.setVisible(false);
      sceneX.setVisible(true);
      sceneY.setVisible(true);
    }
  }
}
public void changeInputPort(String s) {
  try{
    oscPort = Integer.parseInt(s);
  } catch(Exception e){
    return;
  }
  reconnectReceiver();
}
public void changeTuio(boolean b) {
  tuio = b;
  reconnectReceiver();
}
public void reconnectReceiver(){
  if(tuioToggle != null && portInput != null && auReceiver != null){ // Sanity check
    auReceiver.reconnect(oscPort, tuio);
  }
}
// --------------------------------------


// --------------------------------------
// Save / Load
// --------------------------------------
void saveSettings(String file){
  println("Saving to : "+file);
  cp5.saveProperties(file);
}

void loadSettings(String file){
  println("Loading from : "+file);
  cp5.loadProperties(file);
  // After load force the textfields callbacks
  List<Textfield> list = cp5.getAll(Textfield.class);
  for(Textfield b:list) {
    b.submit();
  }
}
// --------------------------------------


// --------------------------------------
// Exit function (This way of handling the exit of the app works everywhere except in the editor)
// --------------------------------------
void exit(){
  // Save the settings on exit
  saveSettings("settings");
  
  // Add custom code here
  // ...
  
  // Finish by forwarding the exit call
  super.exit();
}
// ---------------------