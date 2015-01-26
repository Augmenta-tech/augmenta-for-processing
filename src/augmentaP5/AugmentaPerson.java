package augmentaP5;

import processing.core.PApplet;
import processing.core.PVector;

//import augmentaP5.Rectangle;
import java.util.ArrayList;
import java.util.Collections;

/**
 * Augmenta Person object, containing properties unique to a specific tracked person
 */
public class AugmentaPerson
{
	
	//private final PApplet app;

	/** Unique ID, different for each Person as long as Augmenta is running */
	public int id;
	/** Ordered ID (not usually used), ID ranging from 0-Total Number of people */ 
	public int oid; 
	/** How long a person has been around (in seconds) */
	public int age; 
	/** Normalized (0.0-1.0) distance from camera. For Kinect camera, highest value (1) is approx. 10 meters*/
	public float depth; 
	/** Center of mass of person */
	public PVector centroid;  
	/** Speed since last update */
	public PVector velocity;
	/** Closest point to the camera (with Kinect). If using non-depth camera, represents brightest point on person. */
	public PVector highest; 
	/** Average motion within a Person's area */
	public PVector opticalFlow; 
	/** Bounding rectangle that surrounds Person's shape*/
	public RectangleF boundingRect;
	/** Rectangle representing a detected HAAR feature (if there is one) */
	public RectangleF haarRect;
	/** Defines the rough outline of a Person*/
	public ArrayList<PVector> contours;
	/** (deprecated) */
	public int lastUpdated;
	/** (deprecated) */
	public boolean dead;
	
	/**
	 * Create a Augmenta Person object
	 * @param PApplet	Pass in app to enable debug drawing of Augmenta Person object
	 */
	public AugmentaPerson(){
		//app 			= _app;
		boundingRect 	= new RectangleF();
		haarRect 		= new RectangleF();
		centroid 		= new PVector();
		velocity 		= new PVector();
		opticalFlow 	= new PVector();
		highest			= new PVector();
		dead 			= false;
		contours 		= new ArrayList<PVector>();
		lastUpdated		= 0;
	}
	public AugmentaPerson(int _id, int _oid, int _age, float _depth, PVector _centroid, PVector _velocity, RectangleF _boundingRect, float _highestX, float _highestY, float _highestZ){
		id = _id;
		oid = _oid;
		age = _age;
		depth = _depth;
		centroid = _centroid;
		velocity = _velocity;
		boundingRect = _boundingRect;
		highest = new PVector(_highestX, _highestY);
		//default :
		opticalFlow = new PVector();
		dead = false;
		contours = new ArrayList<PVector>();
		lastUpdated	= 0;
	}
	public AugmentaPerson(int _id, PVector _centroid, RectangleF _boundingRect){
		this(_id, 0, 0, 0, _centroid, new PVector(0,0), _boundingRect, 0, 0, 0);
	}
	public AugmentaPerson(PVector _centroid, RectangleF _boundingRect){
		this((int)(Math.random() * 100000), _centroid, _boundingRect);
	}
	public AugmentaPerson(PVector _centroid){
		this(_centroid, new RectangleF(_centroid.x-0.1f, _centroid.y-0.1f, 0.2f, 0.2f));
	}

	public void copy( AugmentaPerson p){
		id 				= p.id;
		oid 			= p.oid; 
		age 			= p.age; 
		depth 			= p.depth;
		centroid 		= p.centroid;
		velocity 		= p.velocity;
		highest  		= p.highest;
		opticalFlow 	= p.opticalFlow;
		boundingRect	= p.boundingRect;
		haarRect 		= p.haarRect;
		lastUpdated		= p.lastUpdated;

		contours.clear();
		for (int i=0; i<p.contours.size(); i++){
			PVector pt = (PVector) p.contours.get(i);
			// why is this happening??
			if ( pt != null ){
				PVector co = new PVector(pt.x, pt.y);
				contours.add(co);
			}
		}
		dead 			= p.dead;
	}

	/**
	 * Draw an debug view
	 */
	public void draw(){
		// draw rect based on person's detected size
    	// dimensions from Augmenta are 0-1, so we multiply by window width and height
		PApplet app = AugmentaP5.parent;
      	app.noFill();
		app.stroke(255,100);
      	app.rect(boundingRect.x*app.width, boundingRect.y*app.height, boundingRect.width*app.width, boundingRect.height*app.height);		
      
    	// draw circle based on person's centroid (also from 0-1)
    	app.fill(255,255,255);
    	app.ellipse(centroid.x*app.width, centroid.y*app.height, 10, 10);
    	
    	// draw contours
    	app.noFill();
		app.stroke(255,100);
		app.beginShape();
		for (int i=0; i<contours.size(); i++){
			PVector pt = (PVector) contours.get(i);
			app.vertex(pt.x*app.width, pt.y*app.height);
		}
		app.endShape(PApplet.CLOSE);

    	// text shows more info available
    	app.text("id: "+id+" age: "+age, boundingRect.x*app.width, (boundingRect.y*app.height + boundingRect.height*app.height) + 2);
	}
};