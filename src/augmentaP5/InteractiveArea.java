package augmentaP5;

import processing.core.PApplet;
import processing.core.PVector;

//import augmentaP5.Rectangle;
import java.util.ArrayList;
import java.util.Collections;

/**
 * The rectangle restricting the area where people are tracked and displayed
 */
public class InteractiveArea
{
	/* Float values between 0 and 1 defining the interactive rectangle */
	public RectangleF area;

	public InteractiveArea(){
		area = new RectangleF(0f, 0f, 1f, 1f);
	}

	public void set(float x, float y, float width, float height){
		area = new RectangleF(x, y, width, height);
	}
	
	public boolean contains(PVector p){
		return (p.x > area.x && p.y > area.y && p.x < area.x+area.width && p.y < area.y+area.height);
	}

	/**
	 * Draw a debug view
	 */
	public void draw(){
		// draw rect based on person's detected size
    	// dimensions are between 0 and 1, so we multiply by window width and height
		PApplet app = AugmentaP5.parent;
      	app.noFill();
		app.stroke(255, 0, 0, 100);
		app.strokeWeight(2);
      	app.rect(area.x*app.width, area.y*app.height, area.width*app.width, area.height*app.height);		
	}
};