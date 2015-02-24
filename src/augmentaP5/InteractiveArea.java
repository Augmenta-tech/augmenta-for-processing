package augmentaP5;

import processing.core.PApplet;
import processing.core.PVector;
import processing.core.PGraphics;

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
		PGraphics g = AugmentaP5.canvas;
		
		g.pushStyle();
			g.noFill();
			g.stroke(255, 0, 0, 100);
			g.strokeWeight(2);
			g.rectMode(g.CORNER);
			g.textAlign(g.CORNER);
			g.rect(area.x*g.width, area.y*g.height, area.width*g.width, area.height*g.height);	
		g.popStyle();
	}
};