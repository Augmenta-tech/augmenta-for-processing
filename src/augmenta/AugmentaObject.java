package augmenta;

import processing.core.PApplet;
import processing.core.PVector;
import processing.core.PGraphics;

//import augmenta.Rectangle;
import java.util.ArrayList;
import java.util.Collections;

/**
 * Augmenta Object class, containing properties unique to a specific tracked object
 */
public class AugmentaObject
{
	
	//private final PApplet app;
	
	/** How long an object has been around in frames */
	public long frame = 0;
	/** Unique ID, different for each Object as long as Augmenta is running */
	public int pid = 0;
	/** Ordered ID (not usually used), ID ranging from 0-Total Number of objects */ 
	public int oid = 0; 
	/** How long an object has been around (in seconds) */
	public double age = 0; 
//	/** Normalized (0.0-1.0) distance from camera. For Kinect camera, highest value (1) is approx. 10 meters*/
//	public float depth;
//	private float lastDepth;
	/** Center of mass of object */
	public PVector centroid;
	private PVector lastCentroid;  
	/** Speed since last update */
	public PVector velocity;
	/** Computed virtual 'forward' direction for the object. Note, it is a COMPUTED value that uses the velocity to set a relative forward direction, and then when not moving this direction is kept to simulate a 'forward' direction */
	public float orientation = 0; 
	/** Oriented bounding rectangle */
	public RectangleF boundingRect;	
	/** Closest point to the camera (with Kinect). If using non-depth camera, represents brightest point on object. */
	public PVector highest;
	private PVector lastHighest;
	/** Distance between the sensor and ground plane. */
	public float depth = 0;
	private float lastDepth;
	/** Reflectivity value for lidar sensors */
	public float reflectivity = 0;
	
	/** Average motion within a object's area */
	public PVector opticalFlow; 
	/** Bounding rectangle that surrounds object's shape*/
	private RectangleF lastBoundingRect;
	/** Rectangle representing a detected HAAR feature (if there is one) */
	public RectangleF haarRect;
	/** Defines the rough outline of an object*/
	public ArrayList<PVector> contours;
	/** (deprecated) */
	public int lastUpdated;
	/** (deprecated) */
	public boolean dead;
	
	/**
	 * Create a Augmenta Person object
	 * @param PApplet	Pass in app to enable debug drawing of Augmenta Person object
	 */
	public AugmentaObject(){
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
		
		lastBoundingRect 	= new RectangleF();
		lastCentroid 		= new PVector();
		lastHighest			= new PVector();
	}
	public AugmentaObject(long _frame, int _pid, int _oid, int _age, PVector _centroid, PVector _velocity, float _orientation, RectangleF _boundingRect, float _highestX, float _highestY, float _highestZ, float _depth, float _reflectivity){
		frame = _frame;
		pid = _pid;
		oid = _oid;
		age = _age;
		centroid = _centroid;
		velocity = _velocity;
		orientation = _orientation;
		boundingRect = _boundingRect;
		highest = new PVector(_highestX, _highestY, _highestZ);
		depth = _depth;
		reflectivity = _reflectivity;

		//default :
		opticalFlow = new PVector();
		dead = false;
		contours = new ArrayList<PVector>();
		lastUpdated	= 0;
	}
	public AugmentaObject(int _pid, PVector _centroid, RectangleF _boundingRect){
		this((long)0,_pid, 0, 0, _centroid, new PVector(0,0), 0,_boundingRect, 0, 0, 1, 10, 0);
	}
	public AugmentaObject(PVector _centroid, RectangleF _boundingRect){
		this((int)(Math.random() * 100000), _centroid, _boundingRect);
	}
	public AugmentaObject(PVector _centroid){
		this(_centroid, new RectangleF(_centroid.x-0.1f, _centroid.y-0.1f, 0.2f, 0.2f,0.0f));
	}

	public void copy( AugmentaObject p){
		frame			= p.frame;
		pid 			= p.pid;
		oid 			= p.oid; 
		age 			= p.age; 
		centroid 		= p.centroid;
		velocity 		= p.velocity;
		orientation		= p.orientation;
		boundingRect	= p.boundingRect;
		highest  		= p.highest;
		depth 			= p.depth;
		reflectivity	= p.reflectivity;
		opticalFlow 	= p.opticalFlow;
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
		dead = p.dead;
	}

	/**
	 * Draw an debug view
	 */
	public void draw(){
		
		// draw rect based on object's detected size
    	// dimensions from Augmenta are 0-1, so we multiply by window width and height
		PApplet app = Augmenta.parent;
      	PGraphics g = Augmenta.canvas;
		
		if(g != null)
		{
			g.pushStyle();

			// Compute a color for the points
			int rc,gc,bc;
			if (pid%5 == 0){
				rc = 255;
				gc = 255;
				bc = 0;
			} else if (pid%5 == 1){
				rc = 255;
				gc = 0;
				bc = 255;
			} else if (pid%5 == 2){
				rc = 0;
				gc = 255;
				bc = 255;
			} else if (pid%5 == 3){
				rc = 0;
				gc = 255;
				bc = 50;
			} else {
				rc = 50;
				gc = 255;
				bc = 0;
			}
			
			// Bounding rect
			g.noFill();
			g.stroke(rc,gc,bc,255);
			g.strokeWeight(2);
			
			g.pushMatrix();
			g.rectMode(g.CENTER);
			g.textAlign(g.CENTER);
			g.translate(boundingRect.x*g.width, boundingRect.y*g.height);
			g.rotate(-PApplet.radians(boundingRect.rotation));
			g.rect(0, 0, boundingRect.width*g.width, boundingRect.height*g.height);	
			g.popMatrix();
			
			// draw circle based on object's centroid (also from 0-1)
			g.fill(rc,gc,bc);
			g.stroke(255);
			g.ellipse(centroid.x*g.width, centroid.y*g.height, 10, 10);
			
			// Draw the highest point
			g.noFill();
			g.stroke(rc,gc,bc);
			int crossSize=10;
			// Horizontal line
			g.line(centroid.x*g.width + highest.x*g.width-crossSize, centroid.y*g.height + highest.y*g.height, centroid.x*g.width + highest.x*g.width+crossSize, centroid.y*g.height + highest.y*g.height);
			// Vertical line
			g.line(centroid.x*g.width + highest.x*g.width, centroid.y*g.height + highest.y*g.height-crossSize, centroid.x*g.width + highest.x*g.width, centroid.y*g.height + highest.y*g.height+crossSize);
			
			// Draw the velocity vector
			int factor = 2;
			g.stroke(255);
			g.line(centroid.x*g.width, centroid.y*g.height, (centroid.x+velocity.x*factor)*g.width, (centroid.y+velocity.y*factor)*g.height);
			
//			// draw contours
//			//g.noFill();
//			g.stroke(255,100);
//			g.beginShape();
//			for (int i=0; i<contours.size(); i++){
//				PVector pt = (PVector) contours.get(i);
//				g.vertex(pt.x*g.width, pt.y*g.height);
//			}
//			g.endShape(PApplet.CLOSE);
			
			// text shows more info available
			g.textSize(10);
			g.fill(255);
			g.text("pid: "+pid+" age: "+age, centroid.x*g.width+12, centroid.y*g.height - 10);

			g.popStyle();
		}
	}
	
	/**
	 * Exponential smooth people's data
	 */
	public void smooth(float amount){		
		// Check if "last" values have been initialized
		if(lastDepth != 0 && lastCentroid != null && lastHighest != null && lastBoundingRect != null){
		
			// Apply smooth
			depth = depth*(1-amount) + lastDepth * amount;
			centroid.x = centroid.x*(1-amount) + lastCentroid.x * amount;
			centroid.y = centroid.y*(1-amount) + lastCentroid.y * amount;
			highest.x = highest.x*(1-amount) + lastHighest.x * amount;
			highest.y = highest.y*(1-amount) + lastHighest.y * amount;
			boundingRect.x = boundingRect.x*(1-amount) + lastBoundingRect.x * amount;
			boundingRect.y = boundingRect.y*(1-amount) + lastBoundingRect.y * amount;
			boundingRect.width = boundingRect.width*(1-amount) + lastBoundingRect.width * amount;
			boundingRect.height = boundingRect.height*(1-amount) + lastBoundingRect.height * amount;
			
			// Recalculate smoothed velocity
			velocity.x = centroid.x - lastCentroid.x;
			velocity.y = centroid.y - lastCentroid.y;

		}
		
		// Save current values as last values for next frame
		lastDepth = depth;
		lastCentroid.x = centroid.x;
		lastCentroid.y = centroid.y;
		lastHighest.x = highest.x;
		lastHighest.y = highest.y;
		lastBoundingRect.x = boundingRect.x;
		lastBoundingRect.y = boundingRect.y;
		lastBoundingRect.width = boundingRect.width;
		lastBoundingRect.height = boundingRect.height;
		
	}
};