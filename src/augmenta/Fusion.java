package augmenta;

import processing.core.PVector;

public class Fusion {

	/** Offset from scene top left in meters */
	public PVector videoOutOffset;
	/** Size of the video frame in meters */
	public PVector videoOutSize;
	/** Size of the video frame in pixels */
	public PVector videoOutResolution;
	
	public Fusion() {
		videoOutOffset = new PVector();
		videoOutSize = new PVector();
		videoOutResolution = new PVector();
	}
}
