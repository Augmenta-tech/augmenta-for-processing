/**
*
*    * Augmenta basic example
*    Receiving and drawing basic data from Augmenta
*
*    Author : David-Alexandre Chanel
*             Tom Duchêne
*
*    Website : http://www.theoriz.com
*
*/

import augmentaP5.*;
import oscP5.*;
import netP5.*;

// Declare the Augmenta receiver
AugmentaP5 auReceiver;
// Declare the inital OSC port
int oscPort = 12000;

void setup() {

  // Set the initial frame size
  size(640,480, P2D);

  // Allow the frame to be resized
  if (frame != null) {
    frame.setResizable(true);
  }
  
  // Create the Augmenta receiver
  auReceiver= new AugmentaP5(this, oscPort);
}

void draw() {
  
  background(0);

  // Adapt the window to the scene size if needed
  int[] sceneSize = auReceiver.getSceneSize();
  if (width!=sceneSize[0] || height!=sceneSize[1]){
     frame.setSize(sceneSize[0]+frame.getInsets().left+frame.getInsets().right, sceneSize[1]+frame.getInsets().top+frame.getInsets().bottom);
  }
    
  // Get the person data
  AugmentaPerson[] people = auReceiver.getPeopleArray();
   
  // For each person...
  for (int i=0; i<people.length; i++){
    
    // Draw the centroid
    PVector pos = people[i].centroid;
    noStroke();
    fill(255);
    ellipse(pos.x*width, pos.y*height, 10, 10);
    text("pid : "+people[i].id+"\n"+"oid : "+people[i].oid+"\n"+"age : "+people[i].age, pos.x*width+10, pos.y*height);
    
    // Draw the bounding box
    augmentaP5.Rectangle bounds = people[i].boundingRect;
    stroke(150);
    noFill();
    rect(width*bounds.x, height*bounds.y, bounds.width*width,bounds.height*height);
  }
  
  // Display info
  text("Listening Port : " + str(oscPort),10,20);
  text("Scene size : " + str(sceneSize[0]) + "x" + str(sceneSize[1]),10,35);
}

void personEntered (AugmentaPerson p){
  println("Person entered : "+ p.id + "at ("+p.centroid.x+","+p.centroid.y+")"); 
}

void personUpdated (AugmentaPerson p){
  println("Person updated : "+ p.id + " at ("+p.centroid.x+","+p.centroid.y+")");  
}

void personLeft (AugmentaPerson p){
  println("Person left : "+ p.id + " at ("+p.centroid.x+","+p.centroid.y+")"); 
}


