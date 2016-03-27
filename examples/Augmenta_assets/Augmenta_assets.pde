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
 
import augmentaP5.*;
import TUIO.*;
import oscP5.*;
// [Sound] and [Audioreaction]
import ddf.minim.*;
// [Video]
import processing.video.*;

boolean mode3D = false;

// [Audioreaction]
Slider gainSlider;
float gainSliderValue;
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

void setup() {

  setupAugmenta();
  setupSyphonSpout();
  setupGUI();
  
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
}

void draw() {

  adjustSceneSize();
  background(0);
  
  // All visuals to send must be drawn in this canvas
  // Prefix your drawing functions with "canvas." as below
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
  }

  drawAugmenta();

  canvas.endDraw();
  
  // Draw canvas in the window
  image(canvas, 0, 0, width, height);

  // Display instructions
  if(drawDebugData) {
    textSize(10);
    fill(255);
    text("Drag mouse to set the interactive area. Right click to reset.",10,height - 10);
  }
  
  // Syphon/Spout output
  sendFrames();
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