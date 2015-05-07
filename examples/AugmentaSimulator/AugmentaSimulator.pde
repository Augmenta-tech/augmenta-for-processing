/**
*
*    * Augmenta simulator
*    Send some generated Augmenta Packet
*    Use your mouse to send custom packets
*
*    Author : David-Alexandre Chanel
*             Tom Duchêne
*
*    Website : http://www.theoriz.com
*
*/

import netP5.*;
import java.awt.geom.Point2D;
import g4p_controls.*;
import augmentaP5.*;


AugmentaP5 augmenta;
NetAddress sendingAddress;
AugmentaPerson testPerson;
GTextField portInput;
GButton portInputButton;

float x = 0;
float y = 0;
float t = 0; // time
int age = 0;
int sceneAge = 0;
int direction = 1;
int pid = int(random(1000));
//int pid = 43;
int oscPort = 12000;

Boolean send = true;
Boolean moving = false;
Boolean grid = false;

// Array of TestPerson points
int unit = 65;
int count;
TestPerson[] persons;

void setup() {
  size(640,480);
  frameRate(30);
  
  // Setup the array of TestPerson
  int wideCount = width / unit;
  int highCount = height / unit;
  count = wideCount * highCount;
  persons = new TestPerson[count];
  
  int index = 0;
  for (int y = 0; y < highCount; y++) {
    for (int x = 0; x < wideCount; x++) {
      persons[index++] = new TestPerson(x*unit, y*unit, unit/2, unit/2, random(0.05, 0.8), unit);
    }
  }
  
  // Osc network com
  augmenta = new AugmentaP5(this, 50000);
  sendingAddress = new NetAddress("127.0.0.1",oscPort);
  RectangleF rect = new RectangleF(0.4f,0.4f,0.2f,0.2f);
  PVector pos = new PVector(0.5f, 0.5f);
  testPerson = new AugmentaPerson(pid, pos, rect);
  
  // Set the UI
  portInput = new GTextField(this, 10, 70, 60, 20);
  portInputButton = new GButton(this, 70, 70, 110, 20, "Change Osc Port");
  portInput.setText(""+oscPort);
  G4P.registerSketch(this);

  // Init
  y=height/2;
  x=width/2;
}

void draw() {

  background(0);
  textSize(14);
  text("Drag mouse to send custom data to 127.0.0.1:"+oscPort,10,20);
  text("Press [s] to toggle data sending",10,35);
  text("Press [m] to toggle automatic movement",10,50);
  text("Press [g] to toggle a grid of random persons",10,65);
  
  if (grid){
    // Update and draw the TestPersons
    for(int i = 0; i < persons.length ; i++){
      persons[i].update();
      //persons[i].send(augmenta, sendingAddress);
      if(send){
        fill(255);
      }
      else{
        fill(128);
      }
      persons[i].draw();
    }
  }
  
  if(!mousePressed)
  {
    // Sin animation
    if (moving){
      x = map(sin(t),-1,1,width/10,width*9/10);
    }
  }
  // Draw disk
  if (send){
    fill(255);
  }else{
    fill(128);
  }
  ellipse(x,y,20,20);
  //rect(
  textSize(16);
  text(""+pid, x+20,y-10, 50, 20);

  // Increment val
  t= t + direction*TWO_PI/70; // 70 inc
  t = t % TWO_PI;
  age++;

  // Update point
  testPerson.centroid.x = (float)x/width;
  testPerson.centroid.y = (float)y/height;
  testPerson.boundingRect.x = (float)x/width-0.1;
  testPerson.boundingRect.y = (float)y/height-0.1;
  // Other values 
  testPerson.age = age;
  
  // Send point
  if (send){
    augmenta.sendSimulation(testPerson, sendingAddress);
    if (grid){
      for(int i = 0; i < persons.length ; i++){
        persons[i].send(augmenta, sendingAddress);
      }
    }
  }
  // Send scene
  sceneAge++;
  float percentCovered = random(0.1)+0.2f;
  Point2D.Float p = new Point2D.Float(2f+random(0.1),-2f+random(0.1));
  augmenta.sendScene(width, height, 100, sceneAge, percentCovered, persons.length, p, sendingAddress);

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
 // Change direction by calculating speed vector
 if(mouseX - pmouseX < 0)
 {
   direction = -1;
 } else {
   direction = 1;
 }
}

void keyPressed() {

  // Stop/Start the movement of the point
  if (key == 'm' || key == 'M') {
    moving=!moving;
  } else if (key == 's' || key == 'S'){
    send=!send;
    if (send){
      augmenta.sendSimulation(testPerson, sendingAddress, "personEntered");
    } else {
      augmenta.sendSimulation(testPerson, sendingAddress, "personWillLeave");
    }
    pid = int(random(1000));
    age = 0;
  } else if (key == ENTER || key == RETURN){
    if(portInput.hasFocus() == true) {
      handlePortInputButton();
    }
  } else if (key == 'g' || key == 'G'){
    grid=!grid;
  }
}

public void handleButtonEvents(GButton button, GEvent event) { 
  if (button == portInputButton) {
    handlePortInputButton();
  }
}

public void handlePortInputButton() {

  if (Integer.parseInt(portInput.getText()) != oscPort) {
    println("input :"+portInput.getText());
    oscPort = Integer.parseInt(portInput.getText());
    augmenta.unbind();
    augmenta=null;
    augmenta= new AugmentaP5(this, 50000);
    sendingAddress = new NetAddress("127.0.0.1",oscPort);
  }
}

