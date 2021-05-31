package augmenta;

import processing.core.PApplet;
import processing.core.PVector;
import processing.core.PGraphics;

//import augmenta.Rectangle;
import java.util.ArrayList;
import java.util.Collections;

/**
 * The rectangle restricting the area where objects are tracked and displayed
 */
public class InteractiveArea
{
	/* Float values between 0 and 1 defining the interactive rectangle */
	public RectangleF area;

	public InteractiveArea(){
		area = new RectangleF(0f, 0f, 1f, 1f,0f);
	}

	public void set(float x, float y, float width, float height){
		area = new RectangleF(x, y, width, height,0f);
	}
	
	public boolean contains(PVector o){
		return (o.x > area.x && o.y > area.y && o.x < area.x+area.width && o.y < area.y+area.height);
	}

	/**
	 * Draw a debug view
	 */
	public void draw(){
		// draw rect based on the object's detected size
    	// dimensions are between 0 and 1, so we multiply by window width and height
		PApplet app = Augmenta.parent;
		PGraphics g = Augmenta.canvas;
		
		g.pushStyle();
			g.noFill();
			g.stroke(255, 0, 0, 100);
			g.strokeWeight(2);
			g.rectMode(g.CENTER);
			g.textAlign(g.CENTER);
			g.rect(area.x*g.width, area.y*g.height, area.width*g.width, area.height*g.height);	
		g.popStyle();
	}
};