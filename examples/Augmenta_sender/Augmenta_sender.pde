/**
*
*    * Augmenta sender example
*    Send some generated Augmenta Packet
*    Use your mouse to send custom packets
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
  
OscP5 oscP5;
NetAddress myRemoteLocation;

float x = 0;
float y = 0;
float t = 0; // time
int age = 0;
int sense = 1;

void setup() {
  size(640,480);
  frameRate(30);
  
  // Osc network com
  oscP5 = new OscP5(this,13000);
  myRemoteLocation = new NetAddress("127.0.0.1",12000);
  
  y=height/2;
}

void draw() {

  background(0);
  
  text("Drag mouse to send custom data !",10,20);
  
  if(!mousePressed)
  {
    // Sin animation
    x = map(sin(t),-1,1,width/10,width*9/10);
  }
  // Draw disk
  ellipse(x,y,20,20);

  // Increment val
  t= t + sense*TWO_PI/70; // 70 inc
  t = t % TWO_PI;
  age++;

  // TMP WHILE SENDER LIBRARY IS NOT DONE !
  
  // Forging one augmenta person packet
  // TODO : replace by correct forging of packet
  OscMessage person = new OscMessage("/au/personUpdated");
  person.add(42); // pid 
  person.add(0);  // oid
  person.add(age);  // age
  person.add((float)x/width); // centroid.x
  person.add((float)y/height); // centroid.y
  person.add(0.3); // velocity.x
  person.add(0f); // velocity.y
  person.add(0.3); // depth
  person.add((float)x/width-0.1); // boundingRect.x
  person.add((float)y/height-0.2); // boudingRect.y
  person.add(0.2); // boundingRect.width
  person.add(0.4); // boundingRect.height
  person.add(0.2); // highest.x
  person.add(0.2); // highest.y
  person.add(0.2); // highest.z
  
  oscP5.send(person, myRemoteLocation);
  
  // Forging one augmenta scene packet
  OscMessage scene = new OscMessage("/au/scene");
  scene.add(age); // currenttime
  scene.add(0.2);  // percentCovered
  scene.add(1);  // numPeople
  scene.add(0.2); // averageMotion.x
  scene.add(0f); // averageMotion.y
  scene.add(width); // width
  scene.add(height); //height
  
  oscP5.send(scene, myRemoteLocation);
}

void mouseDragged() {
 
 // Update coords
 x = mouseX;
 y = mouseY;
 
 // The following code is here just for pure fun and aesthetic !
 // It enables the point to go on in its sinus road where
 // you left it !
 
 // Clamping
 if(x>width*9/10)
 {
   x=width*9/10;
 }
 if(x<width/10)
 {
   x=width/10;
 }
 // Reverse
 t = asin(map(x,width/10,width*9/10,-1,1));
 // Don't do it visually
 x = mouseX;
 // Change sense by calculating speed vector
 if(mouseX - pmouseX < 0)
 {
   sense = -1;
 } else {
   sense = 1;
 }
}

