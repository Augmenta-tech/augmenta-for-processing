package augmentaP5;

import processing.core.PVector;

/**
 * Augmenta Scene object, containing properties of the whole scene containing tracked people
 */
public class AugmentaScene {
	
	/** Time in frame number */
	public int age = 0;
	/** Percent covered */ 
	public float percentCovered = 0; 
	/** Number of person */
	public int numPeople = 0; 
	/** Average motion */
	public PVector averageMotion;
	/** Width */
	public int width = 0; 
	/** Height */
	public int height = 0;
	/** Depth */
	public int depth = 0; 
	
	public AugmentaScene(){
		age = 0;
		percentCovered = 0.0f;
		numPeople = 0;
		averageMotion = new PVector();
		width = 0;
		height = 0;
		depth = 0;
	}
	
}
