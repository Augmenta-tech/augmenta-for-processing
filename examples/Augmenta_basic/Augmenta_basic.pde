import augmentaP5.*;

// Declare the Augmenta Receiver
AugmentaP5 auReceiver;
// Declare the inital OSC port
int oscPort = 12000;
// Declare a debug mode bool
boolean debug=true;

void setup() {

  // Set the initial frame size
  size(640, 480, P2D);

  // Allow the frame to be resized
  if (frame != null) {
    frame.setResizable(true);
  }

  // Create the Augmenta receiver
  auReceiver = new AugmentaP5(this, oscPort);
  // You can hardcode the interactive area if you need to
  //auReceiver.interactiveArea.set(0.25f, 0.25f, 0.5f, 0.5f);
}

void draw() {

  // Global scene code

  // Get the array of the people in the scene
  AugmentaPerson[] people = auReceiver.getPeopleArray();

  // Draw a background
  background(0);

  // For each person...
  for (int i=0; i<people.length; i++) {
    PVector pos = people[i].centroid; 

    if (debug) {
      people[i].draw();
    }
  }
  
  if (debug){
    // Draw the interactive area
    auReceiver.interactiveArea.draw();
  }
}

void keyPressed() {
  if (key == 'd') {
    // Press 'D' to show/hide the debug info
    debug = !debug;
  }
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

void personEntered (AugmentaPerson p) {
  //println(" Person entered : "+ p.id + " / Position : "+p.centroid.x+"x"+p.centroid.y);
}

void personLeft (AugmentaPerson p) {
  //println(" Person left : "+ p.id + " / Position : "+p.centroid.x+"x"+p.centroid.y);
}

void personUpdated (AugmentaPerson p) {
  //println(" Person updated : "+ p.id + " / Position : "+p.centroid.x+"x"+p.centroid.y);
}

