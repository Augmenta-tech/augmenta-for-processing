package augmenta;

/**
 * Simple rectangle class for Augmenta bounding boxes, etc.
 */
public class RectangleF
{
	public float x, y, width, height, rotation;
	
	public RectangleF(float _x, float _y, float _width, float _height, float _rotation){
		x = _x;
		y = _y;
		width = _width;
		height = _height;
		_rotation = 0;
	}
	public RectangleF(){
		x = 0;
		y = 0;
		width = 0;
		height = 0;
		rotation = 0;
	}
};