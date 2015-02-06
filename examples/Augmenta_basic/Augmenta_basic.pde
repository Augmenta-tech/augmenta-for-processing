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
      // Draw a point
      fill(255);
      noStroke();
      ellipse(pos.x*width, pos.y*height, 10, 10);
      // Add debug info
      text("pid : "+people[i].id+"\n"+"oid : "+people[i].oid+"\n"+"age : "+people[i].age, pos.x*width+10, pos.y*height);
      // Draw the bounding rectangle
      augmentaP5.RectangleF bounds = people[i].boundingRect;
      noFill();
      stroke(150);
      rect(width*bounds.x, height*bounds.y, bounds.width*width, bounds.height*height);
    }
  }
}

void keyPressed() {
  if (key == 'd') {
    // Press 'D' to show/hide the debug info
    if (debug) {
      debug = false;
    } else {
      debug = true;
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

