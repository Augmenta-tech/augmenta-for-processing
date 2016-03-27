import codeanticode.syphon.*; // Syphon (osx)
import spout.*; // Spout (win)
import java.util.List; // Needed for controlP5
import controlP5.*; // GUI

SyphonServer syphon_server;
Spout spout_server;
PGraphics canvas; // Syphon/Spout texture output

// GUI
boolean guiIsVisible = true;
boolean uiIsLoaded = false;
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

// Manual scene size info
int manualSceneX;
int manualSceneY;
int minSize = 300;

// Used to set the interactive area
// click and drag to set a custom area, right click to set it to default (full scene)
float originX;
float originY;

AugmentaP5 auReceiver;
int oscPort = 12000;  // OSC default reception port
boolean tuio = false; // TUIO default mode
boolean drawDebugData = false;

void settings(){
  if(mode3D) {
    size(640, 480, P3D);
  } else {
    size(640, 480, P2D);
  }
  
  manualSceneX = width;
  manualSceneY = height;
  PJOGL.profile=1; // Force OpenGL2 mode for Syphon compatibility
}

void setupAugmenta() {
  
  // Create the Augmenta receiver
  auReceiver= new AugmentaP5(this, oscPort, tuio);
  auReceiver.setTimeOut(30); // TODO : comment needed here !
  auReceiver.setGraphicsTarget(canvas);
  // You can set the interactive area (can be set with the mouse in this example)
  //auReceiver.interactiveArea.set(0.25f, 0.25f, 0.5f, 0.5f);
}

void setupSyphonSpout() {

  // Create the canvas that will be sent by Syphon/Spout
  if(mode3D) {
    canvas = createGraphics(width, height, P3D);
  } else {
    canvas = createGraphics(width, height, P2D);
  }

  // Create a Syphon server to send frames out
  if (platform == MACOSX) {
    syphon_server = new SyphonServer(this, "Processing Syphon");
  } else if (platform == WINDOWS){
    spout_server = new Spout(this);
    spout_server.createSender("Processing Spout", width, height);
  }
}

void setupGUI() {

  // Create GUI
  cp5 = new ControlP5(this);
  setUI();
  
  // Load the settings
  loadSettings("settings");
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

boolean adjustSceneSize() {
  
  boolean hasChanged = false;
  
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
  if ( (canvas.width!=sw || canvas.height!=sh) && sw>=minSize && sh>=minSize && sw<=16000 && sh <=16000 ) {
    // Create the output canvas with the correct size
    if(mode3D) {
      canvas = createGraphics(sw, sh, P3D);
    } else {
      canvas = createGraphics(sw, sh, P2D);
    }
  
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
    
    hasChanged = true;

  } else if (sw <minSize || sh <minSize || sw > 16000 || sh > 16000) {
     println("ERROR : cannot set a window size smaller than minSize or greater than 16000"); 
  }
  // Update the UI text field
  sceneSizeInfo.setText(canvas.width+" x "+canvas.height);
  
  return hasChanged;
}

// --------------------------------------
// Set the GUI
// --------------------------------------
void setUI() {
  
  //Auto scene size + manual scene sihhze
  autoSceneSize = cp5.addToggle("changeAutoSceneSize")
     .setPosition(14, 35)
     .setSize(15, 15)
     .setLabel("")
     .setValue(false)
     ;
  autoSizeLabel = cp5.addTextlabel("labelAutoSceneSize")
      .setText("Auto size")
      .setPosition(30, 41)
      ;
  sceneX = cp5.addTextfield("changeSceneWidth")
     .setPosition(100,35)
     .setSize(30,20)
     .setAutoClear(false)
     .setCaptionLabel("")
     .setInputFilter(ControlP5.INTEGER);
     ;
     
  sceneX.setText(""+width);
  sceneY = cp5.addTextfield("changeSceneHeight")
     .setPosition(130,35)
     .setSize(30,20)
     .setAutoClear(false)
     .setCaptionLabel("")
     .setInputFilter(ControlP5.INTEGER);
     ;
  sceneY.setText(""+height);
  sceneSizeInfo = cp5.addTextlabel ("label")
                    .setText("500 x 500")
                    .setPosition(96,41)
                    ;
  sceneSizeInfo.setVisible(false);
  
  // Port input OSC
  portInput = cp5.addTextfield("changeInputPort")
     .setPosition(100,10)
     .setSize(40,20)
     .setAutoClear(false)
     .setCaptionLabel("")
     .setInputFilter(ControlP5.INTEGER);
     ;
  portInput.setText(""+oscPort);
  portInputLabel = cp5.addTextlabel("labeloscport")
      .setText("OSC input port")
      .setPosition(10, 16)
      ;
      
  // TUIO toggle
  tuioToggle = cp5.addToggle("changeTuio")
     .setPosition(14, 60)
     .setSize(15, 15)
     .setLabel("")
     .setValue(false)
     ;
  tuioLabel = cp5.addTextlabel("labelTuioToggle")
      .setText("TUIO mode")
      .setPosition(34, 63)
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

void drawAugmenta() {
    
  // Draw debug data on top with [d] key
  if (drawDebugData) {
    AugmentaPerson[] people = auReceiver.getPeopleArray();
    for (int i=0; i<people.length; i++) {
      people[i].draw();
    }
  }

  // Draw interactive area
  // TMP COMMENT BECAUSE CRASH ON SOME CONDITIONS
  /*if (drawDebugData) {
    auReceiver.interactiveArea.draw();
  } */ 
}

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

void sendFrames() { 
  if (platform == MACOSX) {
    syphon_server.sendImage(canvas);
  } else if (platform == WINDOWS){
    spout_server.sendTexture(canvas); 
  }
}