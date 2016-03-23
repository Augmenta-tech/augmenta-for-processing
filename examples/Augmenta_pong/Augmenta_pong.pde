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

import oscP5.*; // needed for augmenta
import TUIO.*; // Needed for augmenta
import augmentaP5.*; // Augmenta
import codeanticode.syphon.*; // Syphon
import java.util.List; // Needed for the GUI implementation
import controlP5.*; // GUI

// Declare the Augmenta receiver
AugmentaP5 auReceiver;
// Declare the inital OSC port
int oscPort = 12000;
// Declare the boolean defining if we're in TUIO mode
boolean tuio = false;

// Declare the syphon server
SyphonServer server;
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

// Save manual scene size info
int manualSceneX;
int manualSceneY;

// Declare a debug mode bool
boolean debug=false;

// PONG
PVector ballPos, p1Pos, p2Pos, initDir, dir;
int pWidth, pHeight;

void initGame(PGraphics canvas) {

  ballPos = new PVector(canvas.width/2, canvas.height/2);
  initDir = new PVector(7,4);
  dir = initDir;
  p1Pos = new PVector(30, -100);
  p2Pos = new PVector(canvas.width-30, -100);
  pWidth = 20;
  pHeight = 100;
}

void settings() {
  // Set the initial frame size
  size(640, 400, P2D);
  PJOGL.profile=1; // Force OpenGL2 mode for Syphobn compatibility
}

void setup() {

  // Create the canvas that will be used to send the syphon output
  canvas = createGraphics(width, height, P2D);
  
  manualSceneX = width;
  manualSceneY = height;

  // Create the Augmenta receiver
  auReceiver= new AugmentaP5(this, oscPort, tuio);
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
  
  initGame(canvas);
  
}

void draw() {

  // Adjust the scene size
  adjustSceneSize();
  // Draw a background for the window
  background(0);
  // Begin drawing the canvas
  canvas.beginDraw();
  canvas.background(0);
  
  //reset paddles out
  p1Pos.y = -1000;
  p2Pos.y = -1000;
  
  // Draw a blue circle for everyone :
  // Get the person data
  AugmentaPerson[] people = auReceiver.getPeopleArray();
  // For each person we will...
  for (int i=0; i<people.length; i++) {
    //...get the position...
    PVector pos = people[i].centroid;
    
    if (pos.x < 0.3f){
      p1Pos.y = pos.y*height;
          }
    if (pos.x > 0.7f){
      p2Pos.y = pos.y*height; 
          }
    //<>//
    if (debug) {
      // Draw the debug info if necessary
      //...and draw a blue circle
      canvas.fill(0, 128, 255); // Filled in blue
      canvas.noStroke(); // Without stroke
      canvas.ellipse(pos.x*canvas.width, pos.y*canvas.height, 15, 15); // 15 pixels in diameter
      //people[i].draw();
    }
  }
  canvas.fill(255);
      canvas.rect(p1Pos.x - pWidth/2, p1Pos.y - pHeight/2, pWidth, pHeight);
canvas.rect(p2Pos.x - pWidth/2, p2Pos.y - pHeight/2, pWidth, pHeight);


  // Ball
  ballPos = new PVector(ballPos.x + dir.x, ballPos.y + dir.y);
  // Test collisions
  if(ballPos.y > height || ballPos.y < 0){
    dir.y *=-1;
    ballPos = new PVector(ballPos.x + dir.x, ballPos.y + dir.y);
  }
  // P2
  if(ballPos.x >= p2Pos.x - pWidth/2 && (ballPos.y > p2Pos.y - pHeight/2 && ballPos.y < p2Pos.y + pHeight/2)){
   dir.x *=-1;
    ballPos = new PVector(ballPos.x + dir.x, ballPos.y + dir.y);
  }
  // P1
  if(ballPos.x <= p1Pos.x + pWidth/2 && (ballPos.y > p1Pos.y - pHeight/2 && ballPos.y < p1Pos.y + pHeight/2)){
   dir.x *=-1;
    ballPos = new PVector(ballPos.x + dir.x, ballPos.y + dir.y);
  }
  // OUT
  if(ballPos.x > p2Pos.x || ballPos.x < p1Pos.x || ballPos.y > height || ballPos.y < 0){
    ballPos = new PVector(width/2, height/2);
    dir = initDir;
  }
  
  canvas.fill(255);
  canvas.ellipse(ballPos.x, ballPos.y, 10, 10);
  

  if (debug) {
    // Draw the interactive area
    auReceiver.interactiveArea.draw();
  }

  canvas.endDraw();
  
  // Draw the augmenta canvas in the window
  image(canvas, 0, 0, width, height);
  
  // Syphon output
  if (platform == MACOSX) {
    server.sendImage(canvas);
  }

}

void personEntered (AugmentaPerson p) {
  //println("Person entered : "+ p.id + " at ("+p.centroid.x+","+p.centroid.y+")");
}

void personUpdated (AugmentaPerson p) {
  //println("Person updated : "+ p.id + " at ("+p.centroid.x+","+p.centroid.y+")");
}

void personLeft (AugmentaPerson p) {
  //println("Person left : "+ p.id + " at ("+p.centroid.x+","+p.centroid.y+")");
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
    surface.setSize(sw+frame.getInsets().left+frame.getInsets().right, sh+frame.getInsets().top+frame.getInsets().bottom);
    auReceiver.setGraphicsTarget(canvas);
    
    // Adjust Pong vars
    initGame(canvas);    
    
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
// --------------------------------------