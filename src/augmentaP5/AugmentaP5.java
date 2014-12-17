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
 * Augmenta People objects as they arrive.
 */

public class AugmentaP5 {

	private final PApplet parent;
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
				.println("[Augmenta] Starting the receiver with default port (12000)");
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
				.println("[Augmenta] Starting the receiver with custom port ("
						+ port + ")");
		parent = _parent;
		receiver = new OscP5(this, port);
		people = new Hashtable<Integer, AugmentaPerson>();
		_currentPeople = new Hashtable<Integer, AugmentaPerson>();

		registerEvents();
		parent.registerPre(this);
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

			// Adding this test to counteract nullPointerExceptions ocurring in rare cases
			if (person != null){
				person.lastUpdated--;
				// haven't gotten an update in ~2 seconds
				if (person.lastUpdated < 0) {
					System.out
							.println("[Augmenta] Person deleted because it has not been updated for 120 frames");
					callPersonLeft(person);
					_currentPeople.remove(person.id);
				} else {
					AugmentaPerson p = new AugmentaPerson(parent);
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
		p.id = theOscMessage.get(0).intValue();
		p.oid = theOscMessage.get(1).intValue();
		p.age = theOscMessage.get(2).intValue();
		p.centroid.x = theOscMessage.get(3).floatValue();
		p.centroid.y = theOscMessage.get(4).floatValue();
		p.velocity.x = theOscMessage.get(5).floatValue();
		p.velocity.y = theOscMessage.get(6).floatValue();
		p.depth = theOscMessage.get(7).floatValue();
		p.boundingRect.x = theOscMessage.get(8).floatValue();
		p.boundingRect.y = theOscMessage.get(9).floatValue();
		p.boundingRect.width = theOscMessage.get(10).floatValue();
		p.boundingRect.height = theOscMessage.get(11).floatValue();
		p.highest.x = theOscMessage.get(12).floatValue();
		p.highest.y = theOscMessage.get(13).floatValue();
		p.highest.z = theOscMessage.get(14).floatValue();

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
		p.lastUpdated=120;
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
			AugmentaPerson p = new AugmentaPerson(parent);
			updatePerson(p, theOscMessage);
			callPersonEntered(p);

			// updating a person (or adding them if they don't exist in the
			// system yet)
		} else if (theOscMessage.checkAddrPattern("/au/personUpdated")
				|| theOscMessage.checkAddrPattern("/au/personUpdated/")) {

			AugmentaPerson p = _currentPeople.get(theOscMessage.get(0)
					.intValue());
			boolean personExists = (p != null);
			if (!personExists) {
				p = new AugmentaPerson(parent);
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
			AugmentaPerson p = _currentPeople.get(theOscMessage.get(0)
					.intValue());
			if (p == null) {
				return;
			}
			updatePerson(p, theOscMessage);

			callPersonLeft(p);
			_currentPeople.remove(p.id);
		}

		// scene
		else if (theOscMessage.checkAddrPattern("/au/scene")) {
			width = theOscMessage.get(5).intValue();
			height = theOscMessage.get(6).intValue();
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
						.println("Disabling personEntered() for Augmenta because of an error.");
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
						.println("Disabling personUpdated() for Augmenta because of an error.");
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
						.println("Disabling personLeft() for Augmenta because of an error.");
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
						.println("Disabling customEvent() for Augmenta because of an error.");
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
			// System.out.println("[Augmenta] Warning : at least one of the dimensions is null or equal to 0");
		}
		return res;

	}

};