package augmenta;

import netP5.*;
import oscP5.*;
import processing.core.PApplet;
import processing.core.PVector;
import processing.core.PGraphics;
import java.util.*;
import java.lang.reflect.Method;
import java.lang.Integer;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;
import java.awt.geom.Point2D;
import static java.lang.Math.toIntExact;

/**
 * Augmenta Connection: Connects to Augmenta app and provides your applet with
 * Augmenta People objects as they arrive. This library is based on the TSPS
 * library for processing. More details at http://www.tsps.cc/
 */

public class Augmenta extends PApplet {
	//
	public static PApplet parent;
	private OscP5 receiver;
	
	private static int oscPort = 12000;

	/**
	 * Hashtable of current People objects. Accessibly by unique id, e.g.
	 * people.get( 0 )
	 */
	public Hashtable<Integer, AugmentaObject> objects;

	/**
	 * Current active list of People, copied to public list before every call to
	 * draw()
	 */
	private Hashtable<Integer, AugmentaObject> _currentObjects;

	public InteractiveArea interactiveArea;

	public static PGraphics canvas;

	private Method objectEntered;
	private Method objectUpdated;
	private Method objectWillLeave;
	private Method customEvent;
	
	private AugmentaScene scene;
	
	private Fusion fusion;
	
	private float width = 0;
	private float height = 0;

	private static int timeOut = 120; // After this number of frames, a point
	// that hasn't been updated is
	// destroyed. Do not set under 0.

	// Holds a boolean to know if we're connected to an OSC port
	public static boolean isConnected = false;

	private static final Lock lock = new ReentrantLock();
	
	private static float smoothAmount = 0;

	/**
	 * Starts up Augmenta with the default port (12000). Will also attempt to
	 * set up default Augmenta events, so will look for three methods
	 * implemented in your app: void objectEntered( AugmentaObject o); void
	 * objectUpdated( AugmentaObject o); void objectWillLeave( AugmentaObject o);
	 * 
	 * @param PApplet
	 *            _parent Your app (pass in as "this")
	 */
	public Augmenta(PApplet _parent) {
		this(_parent, oscPort);
	}

	/**
	 * Starts up Augmenta with a specific port. The port must match what is
	 * specified in the Augmenta GUI. Will also attempt to set up default
	 * Augmenta events, so will look for three methods implemented in your app:
	 * void objectEntered( AugmentaObject o); void objectUpdated( AugmentaObject
	 * o); void objectWillLeave( AugmentaObject o);
	 * 
	 * @param PApplet
	 *            _parent Your app (pass in as "this")
	 * @param int Port set in Augmenta app
	 */

	public Augmenta(PApplet _parent, int port){
		// Common operations
		parent = _parent;
		interactiveArea = new InteractiveArea();
		scene = new AugmentaScene();
		fusion = new Fusion();
		objects = new Hashtable<Integer, AugmentaObject>();
		_currentObjects = new Hashtable<Integer, AugmentaObject>();
		registerEvents();
		parent. registerMethod("pre", this);
		canvas = (PGraphics)(_parent.g);
		
		if (port <= 1024 || port > 65535){
			System.out.println("ERROR : port "+port+" is not allowed, switching back to default ("+oscPort);
		} else {
			oscPort = port;
		}

		createReceiver();
	}
	
	private void createReceiver(){
		System.out.println("[Augmenta] Starting the receiver with port ("+ oscPort + ")");
		receiver = new OscP5(this, oscPort);
	}
	
	public int getPort(){
		return oscPort;
	}

	public void setGraphicsTarget(PGraphics target)
	{
		canvas = target;
	}

	public void sendSimulation(AugmentaObject o, NetAddress address, String message) {

		// Create the message
		OscMessage object = new OscMessage("/object/"+message);

		object.add(o.frame);// frame
		object.add(o.pid); // pid
		object.add(o.oid); // oid
		object.add(o.age); // age
		object.add(o.centroid.x); // centroid.x
		object.add(o.centroid.y); // centroid.y
		object.add(o.velocity.x); // velocity.x
		object.add(o.velocity.y); // velocity.y
		object.add(o.orientation); //orientation
		object.add(o.boundingRect.x); // boundingRect.x
		object.add(o.boundingRect.y); // boundingRect.y
		object.add(o.boundingRect.width); // boundingRect.width
		object.add(o.boundingRect.height); // boundingRect.height
		object.add(o.boundingRect.rotation); // boundingRect.rotation
		object.add(o.highest.z); //height of the object

		// Send the packet
		receiver.send(object, address);
	}

	public void sendSimulation(AugmentaObject o, NetAddress address) {
		// Create the message
		sendSimulation(o, address, "update");
	}


	public void sendScene(int frame, int numObjects, float width, float height, NetAddress address) {
		// Create the message
		OscMessage msg = new OscMessage("/scene");
		
		msg.add(frame); //frame
		msg.add(numObjects); // number of objects
		msg.add(width); // width in pixels
		msg.add(height); // height in pixels

		// Send the packet
		receiver.send(msg, address);
	}
	public void sendScene(int width, int height, NetAddress address) {
		Point2D.Float zero = new Point2D.Float(0f,0f);
		sendScene(0, 0, width, height, address);
	}

	public void unbind() {
		System.out.println("[Augmenta] Augmenta object unbinding...");
		if (receiver != null){
			receiver.stop();
			receiver = null;
		}
		objects.clear();
		_currentObjects.clear();
	}

	public void finalize() {
		System.out.println("[Augmenta] Augmenta object terminating...");
		unbind();
		objects = null;
		_currentObjects = null;
	}
	
	public void reconnect(int _port){
		if(_port != oscPort ){
		      unbind();
		      oscPort = _port;
		      createReceiver();
		}
	}

	public void pre() {
		
		// get enumeration, which helps us loop through Augmenta.objects
		Enumeration e = _currentObjects.keys();

		// loop through objects + copy all to public hashtable
		objects.clear();

		lock.lock();

		while (e.hasMoreElements()) {
			// get object
			int id = (Integer) e.nextElement();
			AugmentaObject object = (AugmentaObject) _currentObjects.get(id);

			// Adding this test to counteract nullPointerExceptions ocurring in
			// rare cases
			if (object != null) {
				object.lastUpdated--;
				// haven't gotten an update in a given number of frames
				if (object.lastUpdated < -1) {
					System.out.println("[Augmenta] Object deleted because it has not been updated for 120 frames");
					callObjectWillLeave(object);
					_currentObjects.remove(object.pid);
				} else {
					AugmentaObject p = new AugmentaObject();
					p.copy(object);
					objects.put(p.pid, p);
				}
			}	
		}

		lock.unlock();
		
	}

	/**
	 * Access the current People objects as an array instead of a Hashmap
	 * 
	 * @return Array of AugmentaObject objects
	 */
	public AugmentaObject[] getObjectsArray() {
		return (AugmentaObject[]) (objects.values()
				.toArray(new AugmentaObject[objects.values().size()]));
	}

	/**
	 * @return Current number of objects
	 */
	public int getNumObjects() {
		return objects.size();
	}

	// Update an object
	private static void updateObject(AugmentaObject o, OscMessage theOscMessage) {
		lock.lock();
		try {
			o.frame = (long)theOscMessage.get(0).intValue();
		} catch (Exception e) {
			System.out
			.println("[Augmenta] The OSC message with address 'object/update' could not be parserd : the value [0] should be an int (frame)");
		}
		try {
			o.pid = theOscMessage.get(1).intValue();
		} catch (Exception e) {
			System.out
			.println("[Augmenta] The OSC message with address 'object/update' could not be parsed : the value [1] should be an int (id)");
		}
		try {
			o.oid = theOscMessage.get(2).intValue();
		} catch (Exception e) {
			System.out
			.println("[Augmenta] The OSC message with address 'object/update' could not be parsed : the value [2] should be an int (oid)");
		}
		try {
			o.age = theOscMessage.get(3).floatValue();
		} catch (Exception e) {
			System.out
			.println("[Augmenta] The OSC message with address 'object/update' could not be parsed : the value [3] should be a float (age)");
		}
		try {
			o.centroid.x = theOscMessage.get(4).floatValue();
		} catch (Exception e) {
			System.out
			.println("[Augmenta] The OSC message with address 'object/update' could not be parsed : the value [4] should be a float (centroid.x)");
		}
		try {
			o.centroid.y = theOscMessage.get(5).floatValue();
		} catch (Exception e) {
			System.out
			.println("[Augmenta] The OSC message with address 'object/update' could not be parsed : the value [5] should be a float (centroid.y)");
		}
		try {
			o.velocity.x = theOscMessage.get(6).floatValue();
		} catch (Exception e) {
			System.out
			.println("[Augmenta] The OSC message with address 'object/update' could not be parsed : the value [6] should be a float (velocity.x)");
		}
		try {
			o.velocity.y = theOscMessage.get(7).floatValue();
		} catch (Exception e) {
			System.out
			.println("[Augmenta] The OSC message with address 'object/update' could not be parsed : the value [7] should be a float (velocity.y)");
		}
		try {
			o.orientation = theOscMessage.get(8).floatValue();
		} catch (Exception e) {
			System.out
			.println("[Augmenta] The OSC message with address 'object/update' could not be parsed : the value [8] should be a float (orientation)");
		}
		try {
			o.boundingRect.x = theOscMessage.get(9).floatValue();
		} catch (Exception e) {
			System.out
			.println("[Augmenta] The OSC message with address 'object/update' could not be parsed : the value [9] should be a float (boundingRect.x)");
		}
		try {
			o.boundingRect.y = theOscMessage.get(10).floatValue();
		} catch (Exception e) {
			System.out
			.println("[Augmenta] The OSC message with address 'object/update' could not be parsed : the value [10] should be a float (boundingRect.y)");
		}
		try {
			o.boundingRect.width = theOscMessage.get(11).floatValue();
		} catch (Exception e) {
			System.out
			.println("[Augmenta] The OSC message with address 'object/update' could not be parsed : the value [11] should be a float (boundingRect.width)");
		}
		try {
			o.boundingRect.height = theOscMessage.get(12).floatValue();
		} catch (Exception e) {
			System.out
			.println("[Augmenta] The OSC message with address 'object/update' could not be parsed : the value [12] should be a float (boundingRect.height)");
		}
		try {
			o.boundingRect.rotation = theOscMessage.get(13).floatValue();
		} catch (Exception e) {
			System.out
			.println("[Augmenta] The OSC message with address 'object/update' could not be parsed : the value [13] should be a float (boundingRect.rotation)");
		}
		try {
			o.highest.z = theOscMessage.get(14).floatValue();
		} catch (Exception e) {
			System.out
			.println("[Augmenta] The OSC message with address 'object/update' could not be parsed : the value [14] should be a float (highest.z)");
		}

		/*
		 * Old protocol p.haarRect.x = theOscMessage.get(14).floatValue();
		 * p.haarRect.y = theOscMessage.get(15).floatValue(); p.haarRect.width =
		 * theOscMessage.get(16).floatValue(); p.haarRect.height =
		 * theOscMessage.get(17).floatValue(); p.opticalFlow.x =
		 * theOscMessage.get(18).floatValue(); p.opticalFlow.y =
		 * theOscMessage.get(19).floatValue();
		 */

		// Values 15 to 19 are free for other data

//		o.contours.clear();
//		for (int i = 20; i < theOscMessage.arguments().length; i += 2) {
//			PVector point = new PVector();
//			point.x = theOscMessage.get(i).floatValue();
//			point.y = theOscMessage.get(i + 1).floatValue();
//			o.contours.add(point);
//		}
		
		if(smoothAmount != 0){
			o.smooth(smoothAmount);
		}
		
		o.lastUpdated = timeOut;
		lock.unlock();
	}

	// Set up (optional) Augmenta Events
	private void registerEvents() {
		// check to see if the host applet implements methods:
		// public void objectEntered(AugmentaObject o)
		// public void objectEntered(AugmentaObject o)
		// public void objectEntered(AugmentaObject o)
		// public void customEvent(ArrayList<String> args)
		try {
			objectEntered = parent.getClass().getMethod("objectEntered",
					new Class[] { AugmentaObject.class });
			objectUpdated = parent.getClass().getMethod("objectUpdated",
					new Class[] { AugmentaObject.class });
			objectWillLeave = parent.getClass().getMethod("objectWillLeave",
					new Class[] { AugmentaObject.class });
//			customEvent = parent.getClass().getMethod("customEvent",
//					new Class[] { ArrayList.class });
		} catch (Exception e) {
			// no such method, or an error.. which is fine, just ignore
		}
	}

	// Parse incoming OSC Message
	protected void oscEvent(OscMessage theOscMessage) {
		// adding an object
		if (theOscMessage.checkAddrPattern("/object/enter")
				|| theOscMessage.checkAddrPattern("/object/enter/")) {
			AugmentaObject o = new AugmentaObject();

			// Get the point's coordinates
			PVector point = new PVector(-1f, -1f);
			try {
				point.x = theOscMessage.get(4).floatValue();
			} catch (Exception e) {
				System.out
				.println("[Augmenta] The OSC message with address  '/object/enter' could not be parsed : the value [4] should be a float (centroid.x)");
			}
			try {
				point.y = theOscMessage.get(5).floatValue();
			} catch (Exception e) {
				System.out
				.println("[Augmenta] The OSC message with address  '/object/enter' could not be parsed : the value [5] should be a float (centroid.y)");
			}

			// Check if the point is inside the interactive area first
			if(interactiveArea.contains(point)){
				updateObject(o, theOscMessage);
				_currentObjects.put(o.pid, o);
				callObjectEntered(o);
			}

			// updating an object (or adding them if they don't exist in the
			// system yet)
		} else if (theOscMessage.checkAddrPattern("/object/update")
				|| theOscMessage.checkAddrPattern("/object/update/")) {

			AugmentaObject o = null;
			try {
				o = _currentObjects.get(theOscMessage.get(1).intValue());
			} catch (Exception e) {
				System.out
				.println("[Augmenta] The OSC message with address  '/object/update' could not be parsed : the value [1] should be an int (id)");
			}

			// Get the point's coordinates
			PVector point = new PVector(-1f, -1f);
			try {
				point.x = theOscMessage.get(4).floatValue();
			} catch (Exception e) {
				System.out
				.println("[Augmenta] The OSC message with address  '/object/update' could not be parsed : the value [4] should be a float (centroid.x)");
			}
			try {
				point.y = theOscMessage.get(5).floatValue();
			} catch (Exception e) {
				System.out
				.println("[Augmenta] The OSC message with address  '/object/update' could not be parsed : the value [5] should be a float (centroid.y)");
			}

			// Check if the object exists in the scene
			boolean personExists = (o != null);

			// Check if the point is inside the interactive area
			if(interactiveArea.contains(point)){
				
				if (!personExists) {
					o = new AugmentaObject();
					updateObject(o, theOscMessage);
					callObjectEntered(o);
					_currentObjects.put(o.pid, o);
				} else {
					updateObject(o, theOscMessage);
					callObjectUpdated(o);
				}
			} else {
				// Else we have to act like that the object left
				if (personExists) {
					updateObject(o, theOscMessage);
					callObjectWillLeave(o);
					_currentObjects.remove(o.pid);
				} // if the object does not exist in the scene no need to do this again
			}

		}

		// object is about to leave
		else if (theOscMessage.checkAddrPattern("/object/leave")
				|| theOscMessage.checkAddrPattern("/object/leave/")) {

			AugmentaObject o = null;
			try {
				o = _currentObjects.get(theOscMessage.get(1).intValue());
			} catch (Exception e) {
				System.out
				.println("[Augmenta] The OSC message with address '/object/leave' could not be parsed : the value [1] should be an int (id)");
			}
			if(o == null){
				System.out.println("ERROR : no object found with id "+theOscMessage.get(1).intValue());
				return;
			}
			updateObject(o, theOscMessage);

			callObjectWillLeave(o);
			_currentObjects.remove(o.pid);
		}

		// scene
		else if (theOscMessage.checkAddrPattern("/scene")) {
			try {
				scene.frame = theOscMessage.get(0).intValue();
			} catch (Exception e) {
				System.out
				.println("[Augmenta] The OSC message with address '/scene' could not be parsed : the value [0] should be an int (frame)");
			}
//			try {
//				scene.percentCovered = theOscMessage.get(1).floatValue();
//			} catch (Exception e) {
//				System.out
//				.println("[Augmenta] The OSC message with address 'scene' could not be parsed : the value [1] should be a float (percentCovered)");
//			}
			try {
				scene.objectCount = theOscMessage.get(1).intValue();
			} catch (Exception e) {
				System.out
				.println("[Augmenta] The OSC message with address '/scene' could not be parsed : the value [1] should be an int (objectCount)");
			}
//			try {
//				scene.averageMotion.x = theOscMessage.get(3).floatValue();
//			} catch (Exception e) {
//				System.out
//				.println("[Augmenta] The OSC message with address 'scene' could not be parsed : the value [3] should be a float (averageMotion.x)");
//			}
//			try {
//				scene.averageMotion.y = theOscMessage.get(4).floatValue();
//			} catch (Exception e) {
//				System.out
//				.println("[Augmenta] The OSC message with address 'scene' could not be parsed : the value [4] should be a float (averageMotion.y)");
//			}
			try {
				width = theOscMessage.get(2).floatValue();
				scene.width = theOscMessage.get(2).floatValue();
			} catch (Exception e) {
				System.out
				.println("[Augmenta] The OSC message with address '/scene' could not be parsed : the value [2] should be a float (width)");
			}
			try {
				height = theOscMessage.get(3).floatValue();
				scene.height = theOscMessage.get(3).floatValue();
			} catch (Exception e) {
				System.out
				.println("[Augmenta] The OSC message with address '/scene' could not be parsed : the value [3] should be a float (height)");
			}
			/*try {
				scene.depth = theOscMessage.get(7).intValue();
			} catch (Exception e) {
				System.out
				.println("[Augmenta] The OSC message with address 'scene' could not be parsed : the value [7] should be an int (depth)");
			}*/

			// System.out.println("[Augmenta] Received OSC OK : width "+width+" height "+height);
		} else if (theOscMessage.checkAddrPattern("/fusion")
				|| theOscMessage.checkAddrPattern("/fusion/")) {
			if(theOscMessage.arguments().length > 0) {
				try {
					fusion.videoOutOffset.x = theOscMessage.get(0).floatValue();
				} catch (Exception e) {
					System.out
					.println("[Augmenta] The OSC message with address '/fusion' could not be parsed : the value [0] should be a float (videoOutOffset x)");
				}
				try {
					fusion.videoOutOffset.y = theOscMessage.get(1).floatValue();
				} catch (Exception e) {
					System.out
					.println("[Augmenta] The OSC message with address '/fusion' could not be parsed : the value [1] should be a float (videoOutOffset y)");
				}
				try {
					fusion.videoOutSize.x = theOscMessage.get(2).floatValue();
				} catch (Exception e) {
					System.out
					.println("[Augmenta] The OSC message with address '/fusion' could not be parsed : the value [2] should be a float (videoOutSize x)");
				}
				try {
					fusion.videoOutSize.y = theOscMessage.get(3).floatValue();
				} catch (Exception e) {
					System.out
					.println("[Augmenta] The OSC message with address '/fusion' could not be parsed : the value [3] should be a float (videoOutSize y)");
				}
				try {
					fusion.videoOutResolution.x = theOscMessage.get(4).intValue();
				} catch (Exception e) {
					System.out
					.println("[Augmenta] The OSC message with address '/fusion' could not be parsed : the value [4] should be an int (videoOutResolution x)");
				}
				try {
					fusion.videoOutResolution.y = theOscMessage.get(5).intValue();
				} catch (Exception e) {
					System.out
					.println("[Augmenta] The OSC message with address '/fusion' could not be parsed : the value [5] should be an int (videoOutResolution y)");
				}
			}
		}
//		// custom event
//		else if (theOscMessage.checkAddrPattern("/au/customEvent")
//				|| theOscMessage.checkAddrPattern("/au/customEvent/")) {
//			ArrayList<String> args = new ArrayList<String>();
//			for (int i = 0; i < theOscMessage.arguments().length; i++) {
//				args.add(theOscMessage.get(i).stringValue());
//			}
//			callCustomEvent(args);
//		}
	}

	private void callObjectEntered(AugmentaObject o) {
		if (objectEntered != null) {
			try {
				objectEntered.invoke(parent, new Object[] { o });
			} catch (Exception e) {
				System.err
				.println("[Augmenta] Disabling objectEntered() for Augmenta because of an error.");
				e.printStackTrace();
				objectEntered = null;
			}
		}
	}
	
	private void callObjectUpdated(AugmentaObject o) {
		if (objectUpdated != null) {
			try {
				objectUpdated.invoke(parent, new Object[] { o });
			} catch (Exception e) {
				System.err
				.println("[Augmenta] Disabling objectUpdated() for Augmenta because of an error.");
				e.printStackTrace();
				objectUpdated = null;
			}
		}
	}
	
	private void callObjectWillLeave(AugmentaObject o) {
		if (objectWillLeave != null) {
			try {
				objectWillLeave.invoke(parent, new Object[] { o });
			} catch (Exception e) {
				System.err
				.println("[Augmenta] Disabling objectWillLeave() for Augmenta because of an error.");
				e.printStackTrace();
				objectWillLeave = null;
			}
		}
	}
	
//	private void callCustomEvent(ArrayList<String> strings) {
//		if (customEvent != null) {
//			try {
//				customEvent.invoke(parent, new Object[] { strings });
//			} catch (Exception e) {
//				System.err
//				.println("[Augmenta] Disabling customEvent() for Augmenta because of an error.");
//				e.printStackTrace();
//				customEvent = null;
//			}
//		}
//	}
	
	public float[] getSceneSize() {
		float[] res = new float[2];
		res[0] = width;
		res[1] = height;
		if (width == 0 || height == 0) {
			// System.out.println("[Augmenta Warning : at least one of the dimensions is null or equal to 0");
		}
		return res;
	
	}
	
	public int[] getResolution() {
		int[] res = new int[2];
		res[0] = (int)fusion.videoOutResolution.x;
		res[1] = (int)fusion.videoOutResolution.y;
		return res;
	}
	
	public PVector getPixelPerMeter(){
		int res[] = getResolution();
		float size[] = getSceneSize();
		
		return new PVector(res[0]/size[0],res[1]/size[1]);
	}
	
	public void setTimeOut(int n) {
		if (n >= 0) {
			timeOut = n;
		}
	}
	
	public AugmentaObject getOldestObject(){
		double bestAge = 0;
		int bestObject = -1;
		// For each object...
		for (int key : objects.keySet()) {
			PVector pos = objects.get(key).centroid;
			if (objects.get(key).age > bestAge) {
				bestAge = objects.get(key).age;
				bestObject = key;
			} 
			// If several objects have the same oldest age, take the one with smallest pid
			else if (objects.get(key).age == bestAge){
				if(objects.get(key).pid < objects.get(bestObject).pid){
					bestObject = key;
				}
			}
		}
		AugmentaObject p = null;
		if (bestObject != -1){
			p = objects.get(bestObject);
		}	
		return p;
	}
	
	public AugmentaObject getNewestObject(){
		double bestAge = Integer.MAX_VALUE;
		int bestObject = -1;
		// For each object...
		for (int key : objects.keySet()) {
			PVector pos = objects.get(key).centroid;
			if (objects.get(key).age < bestAge) {
				bestAge = objects.get(key).age;
				bestObject = key;
			}
			// If several objects have the same newest age, take the one with greatest pid
			else if (objects.get(key).age == bestAge){
				if(objects.get(key).pid > objects.get(bestObject).pid){
					bestObject = key;
				}
			}
		}
		AugmentaObject p = null;
		if (bestObject != -1){
			p = objects.get(bestObject);
		}	
		return p;
	}
	
	public void setSmooth(float amount){
		// Check amount bounds
		if(amount < 0){
			smoothAmount = 0;
		} else if(amount > 0.99){
			smoothAmount = 0.99f;
		} else {
			smoothAmount = amount;
		}
	}
	
	public AugmentaScene getScene(){
		return scene;
	}

};