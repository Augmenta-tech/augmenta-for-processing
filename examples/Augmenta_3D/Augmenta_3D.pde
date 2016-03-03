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

import netP5.*; // needed for oscP5
import oscP5.*; // needed for augmenta
import TUIO.*; // Needed for augmenta
import augmentaP5.*; // Augmenta
import codeanticode.syphon.*; // Syphon
import java.util.List; // Needed for the GUI implementation
import controlP5.*; // GUI
import peasy.*; // Peasycam to move around the area

// Declare the Augmenta Receiver
AugmentaP5 auReceiver;
// Declare the inital OSC port
int oscPort = 12000;
// Declare the boolean defining if we're in TUIO mode
boolean tuio = false;

// Declare the camera
PeasyCam cam;
PMatrix originalMatrix; // to store initial PMatrix
PMatrix lastCamMatrix;
boolean updateOriginalMatrix = false;

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

// Global vars
int heightFactor=5;

void settings(){
  // Set the initial frame size
  size(500, 250, P3D);
  PJOGL.profile=1;  // Force OpenGL2 mode for Syphobn compatibility
}

void setup() {
  // Save the basic matrix of the scene before peasycam
  originalMatrix = getMatrix();
  printMatrix();
  // Create the canvas that will be used to send the syphon output
  canvas = createGraphics(width, height, P3D);
  
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
  
  // 3D camera
  lights();
  createEasyCam();
  
  // Load the settings
  loadSettings("settings");

  // Graphic settings
  stroke(255);
  smooth(4);
}

void draw() {
  
  // If the scene has been resized and the cam deleted, change a flag to put everything back up later
  if (cam == null){
    updateOriginalMatrix = true;
  }
  
  // Adjust the scene size
  adjustSceneSize();
  
  // Draw a background for the window
  background(0);
  // Begin drawing the canvas
  canvas.beginDraw();
  
  manage3DMatrix();
  
  canvas.background(0);

  // Draw the interactive surface
  canvas.pushMatrix();
  canvas.translate(0, 0, -1);
  canvas.rectMode(CENTER);
  canvas.fill(70);
  canvas.rect(0, 0, width, height);
  canvas.popMatrix();
  
  // Draw a blue circle for everyone :
  // Get the person data
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
    
    if (debug){
      println("People size : "+rect.x+" "+rect.y+" "+rectHeight);
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
  
  if(updateOriginalMatrix == true){
    // The scene has been resized, save the new original matrix and recreate the easycam
   originalMatrix = getMatrix();
   setMatrix(originalMatrix);
   createEasyCam();
   updateOriginalMatrix = false;
  } else{ 
    setMatrix(originalMatrix); // replace the PeasyCam-matrix
  }
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

void createEasyCam(){
  cam = new PeasyCam(this, 1000);
  cam.setMinimumDistance(1);
  cam.setMaximumDistance(800); 
}

void manage3DMatrix(){
 // Check if the matrix is the identity or not
  float[] m = new float[16];
  getMatrix().get(m);
  for(int i = 0; i < 4; i++){
    for(int j = 0; j < 4; j++){
      if ((i == j && m[i*4+j] == 1) || (i !=j && m[i*4+j] == 0)){
        canvas.setMatrix(lastCamMatrix);
      } else {
        lastCamMatrix = getMatrix();
        canvas.setMatrix(getMatrix()); // replace the PGraphics-matrix
      }
    }
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
    canvas = createGraphics(sw, sh, P3D);
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
    cam.setActive(false);
    cam = null;
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
  cp5.addTextlabel("labelAutoSceneSize")
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
  cp5.addTextlabel("labeloscport")
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
  cp5.addTextlabel("labelTuioToggle")
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
   manualSceneX = Integer.parseInt(sceneX.getText());
   manualSceneY = Integer.parseInt(sceneY.getText()); 
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
  oscPort = Integer.parseInt(s);
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