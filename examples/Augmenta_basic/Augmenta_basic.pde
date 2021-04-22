import augmentaP5.*;
import oscP5.*;

AugmentaP5 auReceiver;
int oscPort = 12000; // OSC reception port
boolean drawDebugData = false;

void setup() {

  size(640, 480, P2D);

  // Create the Augmenta receiver
  auReceiver = new AugmentaP5(this, oscPort);
}

void draw() {

  background(0);
    
  // Get the array of persons in the scene
  AugmentaPerson[] people = auReceiver.getPeopleArray();

  // For each person...
  for (int i=0; i<people.length; i++) {
    
    // ... get its position
    PVector pos = people[i].centroid;
    
    // ... and draw a disk
    fill(0, 128, 255); // Filled in blue
    noStroke(); // Without stroke
    ellipse(pos.x*width, pos.y*height, 16, 16); // 16 pixels diameter

    // Display a text to tell the world that they can press [d] ...
    fill(255); // white text
    textSize(12);
    text("Press [d] to draw data", 10, 22);
    
    // ... to draw each person data
    if (drawDebugData) {
      people[i].draw();
    }
  }
}

// Press 'd' to show/hide data drawing
void keyPressed() {
  if (key == 'd' || key == 'D') {
    drawDebugData = !drawDebugData;
  }
}
