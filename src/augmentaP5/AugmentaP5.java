package augmentaP5;

import netP5.*;
import oscP5.*;
import processing.core.PApplet;
import processing.core.PVector;

import java.util.*;
import java.lang.reflect.Method;
import java.lang.Integer;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

/**
 * Augmenta Connection: Connects to Augmenta app and provides your applet with
 * Augmenta People objects as they arrive. This library is based on the TSPS
 * library for processing. More details at http://www.tsps.cc/
 */

public class AugmentaP5 {

	public static PApplet parent;
	private OscP5 receiver;

	/**
	 * Hashtable of current People objects. Accessibly by unique id, e.g.
	 * people.get( 0 )
	 */
	public Hashtable<Integer, AugmentaPerson> people;

	/**
	 * Current active list of People, copied to public list before every call to
	 * draw()
	 */
	private Hashtable<Integer, AugmentaPerson> _currentPeople;

	private Method personEntered;
	private Method personUpdated;
	private Method personLeft;
	private Method customEvent;

	private int defaultPort = 12000;
	private int width = 0;
	private int height = 0;

	private static int timeOut = 120; // After this number of frames, a point
										// that hasn't been updated is
										// destroyed. Do not set under 0.

	private static final Lock lock = new ReentrantLock();

	/**
	 * Starts up Augmenta with the default port (12000). Will also attempt to
	 * set up default Augmenta events, so will look for three methods
	 * implemented in your app: void personEntered( AugmentaPerson p); void
	 * personUpdated( AugmentaPerson p); void personLeft( AugmentaPerson p);
	 * 
	 * @param PApplet
	 *            _parent Your app (pass in as "this")
	 */
	public AugmentaP5(PApplet _parent) {
		System.out
				.println("[AugmentaP5] Starting the receiver with default port ("
						+ defaultPort + ")");
		parent = _parent;
		receiver = new OscP5(this, defaultPort);
		people = new Hashtable<Integer, AugmentaPerson>();
		_currentPeople = new Hashtable<Integer, AugmentaPerson>();
		registerEvents();

		parent.registerPre(this);
	}

	/**
	 * Starts up Augmenta with a specific port. The port must match what is
	 * specified in the Augmenta GUI. Will also attempt to set up default
	 * Augmenta events, so will look for three methods implemented in your app:
	 * void personEntered( AugmentaPerson p); void personUpdated( AugmentaPerson
	 * p); void personLeft( AugmentaPerson p);
	 * 
	 * @param PApplet
	 *            _parent Your app (pass in as "this")
	 * @param int Port set in Augmenta app
	 */
	public AugmentaP5(PApplet _parent, int port) {
		System.out
				.println("[AugmentaP5] Starting the receiver with custom port ("
						+ port + ")");
		parent = _parent;
		receiver = new OscP5(this, port);
		people = new Hashtable<Integer, AugmentaPerson>();
		_currentPeople = new Hashtable<Integer, AugmentaPerson>();
		registerEvents();
		parent.registerPre(this);
	}

	public void send(AugmentaPerson p, NetAddress address) {
		// Create the message
		OscMessage person = new OscMessage("/au/personUpdated");
		person.add(p.id); // pid
		person.add(p.oid); // oid
		person.add(p.age); // age
		person.add(p.centroid.x); // centroid.x
		person.add(p.centroid.y); // centroid.y
		person.add(p.velocity.x); // velocity.x
		person.add(p.velocity.y); // velocity.y
		person.add(p.depth); // depth
		person.add(p.boundingRect.x); // boundingRect.x
		person.add(p.boundingRect.y); // boudingRect.y
		person.add(p.boundingRect.width); // boundingRect.width
		person.add(p.boundingRect.height); // boundingRect.height
		person.add(p.highest.x); // highest.x
		person.add(p.highest.y); // highest.y
		person.add(p.highest.z); // highest.z
		// Send the packet
		receiver.send(person, address);
	}
	public void sendScene(int width, int height, int age, int numPeople, NetAddress address) {
		// Create the message
		OscMessage msg = new OscMessage("/au/scene");
		msg.add(age); // age
		msg.add(0); // percentage covered
		msg.add(numPeople); // number of people
		msg.add(0); // average motion X
		msg.add(0); // average motion Y
		msg.add(width); // width in pixels
		msg.add(height); // height in pixels
		
		// Send the packet
		receiver.send(msg, address);
	}
	public void sendScene(int width, int height, NetAddress address) {
		sendScene(width, height, 0, 0, address);
	}

	public void unbind() {
		System.out.println("[AugmentaP5] AugmentaP5 object unbinding...");
		receiver.stop();
		receiver = null;
	}

	public void finalize() {
		System.out.println("[AugmentaP5] AugmentaP5 object terminating...");
		receiver.stop();
		receiver = null;
		people = null;
		_currentPeople = null;

	}

	public void pre() {

		// get enumeration, which helps us loop through Augmenta.people
		Enumeration e = _currentPeople.keys();

		// loop through people + copy all to public hashtable
		people.clear();

		lock.lock();

		while (e.hasMoreElements()) {
			// get person
			int id = (Integer) e.nextElement();
			AugmentaPerson person = (AugmentaPerson) _currentPeople.get(id);

			// Adding this test to counteract nullPointerExceptions ocurring in
			// rare cases
			if (person != null) {
				person.lastUpdated--;
				// haven't gotten an update in a given number of frames
				if (person.lastUpdated < -1) {
					// System.out.println("[AugmentaP5] Person deleted because it has not been updated for 120 frames");
					callPersonLeft(person);
					_currentPeople.remove(person.id);
				} else {
					AugmentaPerson p = new AugmentaPerson();
					p.copy(person);
					people.put(p.id, p);
				}
			}
		}

		lock.unlock();
	}

	/**
	 * Access the current People objects as an array instead of a Hashmap
	 * 
	 * @return Array of AugmentaPerson objects
	 */
	public AugmentaPerson[] getPeopleArray() {
		return (AugmentaPerson[]) (people.values()
				.toArray(new AugmentaPerson[people.values().size()]));
	}

	/**
	 * @return Current number of people
	 */
	public int getNumPeople() {
		return people.size();
	}

	// Update a person
	private static void updatePerson(AugmentaPerson p, OscMessage theOscMessage) {
		lock.lock();
		try {
			p.id = theOscMessage.get(0).intValue();
		} catch (Exception e) {
			System.out
					.println("[AugmentaP5] The OSC message with address 'updatedPerson' could not be parsed : the value [0] should be an int (id)");
		}
		try {
			p.oid = theOscMessage.get(1).intValue();
		} catch (Exception e) {
			System.out
					.println("[AugmentaP5] The OSC message with address 'updatedPerson' could not be parsed : the value [1] should be an int (oid)");
		}
		try {
			p.age = theOscMessage.get(2).intValue();
		} catch (Exception e) {
			System.out
					.println("[AugmentaP5] The OSC message with address 'updatedPerson' could not be parsed : the value [2] should be an int (age)");
		}
		try {
			p.centroid.x = theOscMessage.get(3).floatValue();
		} catch (Exception e) {
			System.out
					.println("[AugmentaP5] The OSC message with address 'updatedPerson' could not be parsed : the value [3] should be a float (centroid.x)");
		}
		try {
			p.centroid.y = theOscMessage.get(4).floatValue();
		} catch (Exception e) {
			System.out
					.println("[AugmentaP5] The OSC message with address 'updatedPerson' could not be parsed : the value [4] should be a float (centroid.y)");
		}
		try {
			p.velocity.x = theOscMessage.get(5).floatValue();
		} catch (Exception e) {
			System.out
					.println("[AugmentaP5] The OSC message with address 'updatedPerson' could not be parsed : the value [5] should be a float (velocity.x)");
		}
		try {
			p.velocity.y = theOscMessage.get(6).floatValue();
		} catch (Exception e) {
			System.out
					.println("[AugmentaP5] The OSC message with address 'updatedPerson' could not be parsed : the value [6] should be a float (velocity.y)");
		}
		try {
			p.depth = theOscMessage.get(7).floatValue();
		} catch (Exception e) {
			System.out
					.println("[AugmentaP5] The OSC message with address 'updatedPerson' could not be parsed : the value [7] should be a float (depth)");
		}
		try {
			p.boundingRect.x = theOscMessage.get(8).floatValue();
		} catch (Exception e) {
			System.out
					.println("[AugmentaP5] The OSC message with address 'updatedPerson' could not be parsed : the value [8] should be a float (boundignRect.x)");
		}
		try {
			p.boundingRect.y = theOscMessage.get(9).floatValue();
		} catch (Exception e) {
			System.out
					.println("[AugmentaP5] The OSC message with address 'updatedPerson' could not be parsed : the value [9] should be a float (boundignRect.y)");
		}
		try {
			p.boundingRect.width = theOscMessage.get(10).floatValue();
		} catch (Exception e) {
			System.out
					.println("[AugmentaP5] The OSC message with address 'updatedPerson' could not be parsed : the value [10] should be a float (boundignRect.width)");
		}
		try {
			p.boundingRect.height = theOscMessage.get(11).floatValue();
		} catch (Exception e) {
			System.out
					.println("[AugmentaP5] The OSC message with address 'updatedPerson' could not be parsed : the value [11] should be a float (boundignRect.height)");
		}
		try {
			p.highest.x = theOscMessage.get(12).floatValue();
		} catch (Exception e) {
			System.out
					.println("[AugmentaP5] The OSC message with address 'updatedPerson' could not be parsed : the value [12] should be a float (highest.x)");
		}
		try {
			p.highest.y = theOscMessage.get(13).floatValue();
		} catch (Exception e) {
			System.out
					.println("[AugmentaP5] The OSC message with address 'updatedPerson' could not be parsed : the value [13] should be a float (highest.y)");
		}
		try {
			p.highest.z = theOscMessage.get(14).floatValue();
		} catch (Exception e) {
			System.out
					.println("[AugmentaP5] The OSC message with address 'updatedPerson' could not be parsed : the value [14] should be a float (highest.z)");
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

		p.contours.clear();
		for (int i = 20; i < theOscMessage.arguments().length; i += 2) {
			PVector point = new PVector();
			point.x = theOscMessage.get(i).floatValue();
			point.y = theOscMessage.get(i + 1).floatValue();
			p.contours.add(point);
		}
		p.lastUpdated = timeOut;
		lock.unlock();
	}

	// Set up (optional) Augmenta Events
	private void registerEvents() {
		// check to see if the host applet implements methods:
		// public void personEntered(AugmentaPerson p)
		// public void personEntered(AugmentaPerson p)
		// public void personEntered(AugmentaPerson p)
		// public void customEvent(ArrayList<String> args)
		try {
			personEntered = parent.getClass().getMethod("personEntered",
					new Class[] { AugmentaPerson.class });
			personUpdated = parent.getClass().getMethod("personUpdated",
					new Class[] { AugmentaPerson.class });
			personLeft = parent.getClass().getMethod("personLeft",
					new Class[] { AugmentaPerson.class });
			customEvent = parent.getClass().getMethod("customEvent",
					new Class[] { ArrayList.class });
		} catch (Exception e) {
			// no such method, or an error.. which is fine, just ignore
		}
	}

	// Parse incoming OSC Message
	protected void oscEvent(OscMessage theOscMessage) {
		// adding a person
		if (theOscMessage.checkAddrPattern("/au/personEntered")
				|| theOscMessage.checkAddrPattern("/au/personEntered/")) {
			AugmentaPerson p = new AugmentaPerson();
			updatePerson(p, theOscMessage);
			callPersonEntered(p);

			// updating a person (or adding them if they don't exist in the
			// system yet)
		} else if (theOscMessage.checkAddrPattern("/au/personUpdated")
				|| theOscMessage.checkAddrPattern("/au/personUpdated/")) {

			AugmentaPerson p = null;
			try {
				p = _currentPeople.get(theOscMessage.get(0).intValue());
			} catch (Exception e) {
				System.out
						.println("[AugmentaP5] The OSC message with address  'personUpdated' could not be parsed : the value [0] should be an int (id)");
			}

			boolean personExists = (p != null);
			if (!personExists) {
				p = new AugmentaPerson();
			}

			updatePerson(p, theOscMessage);
			if (!personExists) {
				callPersonEntered(p);
			} else {
				callPersonUpdated(p);
			}
		}

		// person is about to leave
		else if (theOscMessage.checkAddrPattern("/au/personWillLeave")
				|| theOscMessage.checkAddrPattern("/au/personWillLeave/")) {

			AugmentaPerson p = null;
			try {
				p = _currentPeople.get(theOscMessage.get(0).intValue());
			} catch (Exception e) {
				System.out
						.println("[AugmentaP5] The OSC message with address 'personWillLeave' could not be parsed : the value [0] should be an int (id)");
			}
			if (p == null) {
				return;
			}
			updatePerson(p, theOscMessage);

			callPersonLeft(p);
			_currentPeople.remove(p.id);
		}

		// scene
		else if (theOscMessage.checkAddrPattern("/au/scene")) {
			try {
				width = theOscMessage.get(5).intValue();
			} catch (Exception e) {
				System.out
						.println("[AugmentaP5] The OSC message with address 'scene' could not be parsed : the value [5] should be an int (width)");
			}
			try {
				height = theOscMessage.get(6).intValue();
			} catch (Exception e) {
				System.out
						.println("[AugmentaP5] The OSC message with address 'scene' could not be parsed : the value [6] should be an int (height)");
			}

			// System.out.println("[Augmenta] Received OSC OK : width "+width+" height "+height);
		}

		// custom event
		else if (theOscMessage.checkAddrPattern("/au/customEvent")
				|| theOscMessage.checkAddrPattern("/au/customEvent/")) {
			ArrayList<String> args = new ArrayList<String>();
			for (int i = 0; i < theOscMessage.arguments().length; i++) {
				args.add(theOscMessage.get(i).stringValue());
			}
			callCustomEvent(args);
		}
	}

	private void callPersonEntered(AugmentaPerson p) {
		_currentPeople.put(p.id, p);
		if (personEntered != null) {
			try {
				personEntered.invoke(parent, new Object[] { p });
			} catch (Exception e) {
				System.err
						.println("[AugmentaP5] Disabling personEntered() for Augmenta because of an error.");
				e.printStackTrace();
				personEntered = null;
			}
		}
	}

	private void callPersonUpdated(AugmentaPerson p) {
		if (personUpdated != null) {
			try {
				personUpdated.invoke(parent, new Object[] { p });
			} catch (Exception e) {
				System.err
						.println("[AugmentaP5] Disabling personUpdated() for Augmenta because of an error.");
				e.printStackTrace();
				personUpdated = null;
			}
		}
	}

	private void callPersonLeft(AugmentaPerson p) {
		if (personLeft != null) {
			try {
				personLeft.invoke(parent, new Object[] { p });
			} catch (Exception e) {
				System.err
						.println("[AugmentaP5] Disabling personLeft() for Augmenta because of an error.");
				e.printStackTrace();
				personLeft = null;
			}
		}
	}

	private void callCustomEvent(ArrayList<String> strings) {
		if (customEvent != null) {
			try {
				customEvent.invoke(parent, new Object[] { strings });
			} catch (Exception e) {
				System.err
						.println("[AugmentaP5] Disabling customEvent() for Augmenta because of an error.");
				e.printStackTrace();
				customEvent = null;
			}
		}
	}

	public int[] getSceneSize() {
		int[] res = new int[2];
		res[0] = width;
		res[1] = height;
		if (width == 0 || height == 0) {
			// System.out.println("[AugmentaP5 Warning : at least one of the dimensions is null or equal to 0");
		}
		return res;

	}

	public void setTimeOut(int n) {
		if (n >= 0) {
			timeOut = n;
		}
	}

};