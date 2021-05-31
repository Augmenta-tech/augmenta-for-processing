package augmenta;

import processing.core.PVector;

/**
 * Augmenta Scene object, containing properties of the whole scene containing tracked people
 */
public class AugmentaScene {
	
	/** Time in frame number */
	public int frame = 0; //age = 0;
	/** Percent covered */ 
	public float percentCovered = 0; 
	/** Number of person */
	public int objectCount = 0;//numObjects = 0; 
	/** Average motion */
	public PVector averageMotion;
	/** Width */
	public float width = 0; 
	/** Height */
	public float height = 0;
	/** Depth */
//	public int depth = 0; 
	
	public AugmentaScene(){
		frame = 0;
		percentCovered = 0.0f;
		objectCount = 0;
		averageMotion = new PVector();
		width = 0.0f;
		height = 0.0f;
//		depth = 0;
	}
	
}
