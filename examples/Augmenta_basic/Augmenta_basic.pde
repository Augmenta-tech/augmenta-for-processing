import augmenta.*;
import oscP5.*;

Augmenta auReceiver;
int oscPort = 12000; // OSC reception port
boolean drawDebugData = false;

void setup() {

  size(640, 480, P2D);

  // Create the Augmenta receiver
  auReceiver = new Augmenta(this, oscPort);
  // enable the resizable window
  surface.setResizable(true);
}

void draw() {

  // get the resolution value from Augmenta Fusion
  int[] res = auReceiver.getResolution();
  if(res[0] > 0 && res[1] > 0){
    surface.setSize(res[0],res[1]);
  }

  background(0);
    
  // Get the array of objects in the scene
  AugmentaObject[] objects = auReceiver.getObjectsArray();

  // For each object...
  for (int i=0; i<objects.length; i++) {
    
    // ... get its position
    PVector pos = objects[i].centroid;
    
    // ... and draw a disk
    fill(0, 128, 255); // Filled in blue
    noStroke(); // Without stroke
    ellipse(pos.x*width, pos.y*height, 16, 16); // 16 pixels diameter

    // Display a text to tell the world that they can press [d] ...
    fill(255); // white text
    textSize(12);
    text("Press [d] to draw infos", 10, 22);
    
    // ... to draw each object info
    if (drawDebugData) {
      objects[i].draw();
    }
  }
}

// Press 'd' to show/hide data drawing
void keyPressed() {
  if (key == 'd' || key == 'D') {
    drawDebugData = !drawDebugData;
  }
}
