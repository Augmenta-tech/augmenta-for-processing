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
 
import augmenta.*;
import oscP5.*;
import peasy.*; // Peasycam to move around the area

// Declare the camera
PeasyCam cam;
PMatrix originalMatrix; // to store initial PMatrix
PMatrix lastCamMatrix;
boolean updateOriginalMatrix = false;
boolean mode3D = true;

//zoom
float scaleValue = 2;

void setup() {

  // /!\ Keep this setup order !
  setupSyphonSpout();
  setupAugmenta();
  setupGUI();
  // enable the resizable window
  surface.setResizable(true);
  
  // Save the basic matrix of the scene before peasycam
  originalMatrix = getMatrix();
  printMatrix();
  lights();
  createEasyCam();
  stroke(255);
  smooth(4);
  
  // Add your code here
}

void draw() {
  
  if(scaleValue == 0){
    System.out.println("Cannot use a scale value of zero"); 
    return;
  }

  if (cam == null){
    updateOriginalMatrix = true;
  }
  
  // If scene has changed reset Camera
  if(adjustSceneSize()) {
      cam.setActive(false);
      cam = null;
  }
  
  background(0);
  
  // All visuals to send must be drawn in this canvas
  // Prefix your drawing functions with "canvas." as below
  canvas.beginDraw();
  
  manage3DMatrix();

  canvas.background(0);
  
  // Prepare global coordinate system
  canvas.pushMatrix();
  canvas.translate(0, 0, -1);
  canvas.scale(1/scaleValue,1/scaleValue,1/scaleValue); // this allows to "zoom" in or out, to fit everything in the screen
  
  // Draw the floor surface
  canvas.rectMode(CENTER);
  canvas.fill(70);
  float planeWidth = width;
  float planeHeight = height;  
  //System.out.println("Size: " + width + "," + height);
  
  // Draw a simple plane
  //canvas.rect(0, 0, planeWidth, planeHeight);

  //Set the current origin in the topleft corner of the plane, needed to draw objects and checkerboard
  canvas.translate(-planeWidth/2,-planeHeight/2,0);
  
  // Draw a checkerboard with 1m x 1m tiles
  drawCheckerBoard(canvas);
  
  // Draw every objects
  AugmentaObject[] objects = auReceiver.getObjectsArray();

  for (int i=0; i<objects.length; i++) {
    // Push a new matrix for each object, to keep the origin in the top left corner of the plane for the next object
    canvas.pushMatrix();
    
    PVector pos = objects[i].centroid;
    
    augmenta.RectangleF rect = objects[i].boundingRect;
    float rectHeight = 2;
    if (objects[i].highest.z != 0 ) {
      rectHeight = objects[i].highest.z*auReceiver.getPixelPerMeter().x;
    }

    // Move the origin at the centroid position
    canvas.translate(planeWidth*(pos.x), planeHeight*(pos.y), 0); 
    
    // Centroids
    canvas.fill(255);
    canvas.ellipseMode(CENTER);
    canvas.ellipse(0, 0, 5, 5);

    // Bounding boxes
    //canvas.pushMatrix();
    //canvas.translate(-(rect.width * auReceiver.getPixelPerMeter().x)/4, -(rect.height * auReceiver.getPixelPerMeter().y)/4, 0);
    //canvas.translate(width*(rect.x-0.5+rect.width/2), height*(rect.y-0.5+rect.height/2), rectHeight/2);
    canvas.pushMatrix();
    canvas.translate(0,0,rectHeight/2);
    canvas.rotate(-radians(rect.rotation));
    canvas.fill(255, 255, 255, 30);
    canvas.stroke(255);
    canvas.box(rect.width * auReceiver.getResolution()[0], rect.height*auReceiver.getResolution()[1], rectHeight);
    canvas.popMatrix();
    
    if (drawDebugData){
      //println("People size : "+rect.x+" "+rect.y+" "+rectHeight);
      canvas.pushMatrix();
      canvas.fill(255, 255, 255, 200);
      canvas.translate(30, 0, 0);
      canvas.scale(scaleValue,scaleValue,scaleValue);
      canvas.text("pid : "+objects[i].pid+"\n"+"oid : "+objects[i].oid+"\n"+"age : "+objects[i].age +"\nrot: " +rect.rotation + "\nsize: " + rect.width + "," + rect.height, 0, 0);
      canvas.popMatrix();
    }
    canvas.popMatrix();
  }
  canvas.popMatrix();
  canvas.endDraw();
  
  updateMatrix();
  
  // Draw canvas in the window
  image(canvas, 0, 0, width, height);
  
  // Syphon/Spout output
  sendFrames();
}

// You can also use these events functions which are triggered automatically

void objectEntered (AugmentaObject o) {
  //println("Person entered : "+ p.pid + " at ("+p.centroid.x+","+p.centroid.y+")");
}

void objectUpdated (AugmentaObject o) {
  //println("Person updated : "+ p.pid + " at ("+p.centroid.x+","+p.centroid.y+")");
}

void objectWillLeave (AugmentaObject o) {
  //println("Person will leave : "+ p.pid + " at ("+p.centroid.x+","+p.centroid.y+")");
}

/** Helper functions */

// Draws a checkerboard corresponding to the Augmenta zone. Note that every dimensions are halved.
void drawCheckerBoard(PGraphics canvas){
  //System.out.println(auReceiver.getSceneSize()[0] + "," + auReceiver.getSceneSize()[1]);
  //System.out.println(auReceiver.getResolution()[0] + "," + auReceiver.getResolution()[1]);
  //System.out.println(auReceiver.getPixelPerMeter().x + "," + auReceiver.getPixelPerMeter().y);
  
  canvas.pushMatrix();
  int fillColor = 200;
  canvas.rectMode(CORNER);
  for(int j = 0; j < (height/auReceiver.getPixelPerMeter().y); j++){
    canvas.pushMatrix();
    float _height;
    if(j > (height/auReceiver.getPixelPerMeter().y)-1){
      //System.out.println("Height: " + height + " - " + j*auReceiver.getPixelPerMeter().y);
      _height = (height - j*auReceiver.getPixelPerMeter().y);
    } else {
      _height = auReceiver.getPixelPerMeter().y;
    }
    for(int i = 0; i < (width/auReceiver.getPixelPerMeter().x); i++){
      //System.out.println("i; " + i + ",j: " + j);
      canvas.fill(fillColor/((i+j)%2+1));
      float _width;
      if(i > (width/auReceiver.getPixelPerMeter().x)-1){
        //System.out.println("Width: " + width + " - " + i*auReceiver.getPixelPerMeter().x);
        _width = (width - i*auReceiver.getPixelPerMeter().x);
      } else {
        _width = auReceiver.getPixelPerMeter().x;
      }
      canvas.rect(0,0,_width,_height);
      canvas.translate(auReceiver.getPixelPerMeter().x,0,0);
    }
    canvas.popMatrix();
    canvas.translate(0,auReceiver.getPixelPerMeter().y,0);
  }
  canvas.popMatrix(); 
}
