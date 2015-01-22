import augmentaP5.*;

public class CircleTrigger extends Trigger{
  
  PVector pos;
  float radius;
  
  public CircleTrigger(float _x, float _y, float _radius, Augmenta_assets _app){
    super(_app);
    pos = new PVector(_x, _y);
    radius = _radius;
  }
  
  public void setPosition(float _x, float _y){
    pos.x = _x;
    pos.y = _y; 
  }
  
  public void setRadius(float _radius){
    radius = _radius;
  }

  @Override
  public void draw(){
    strokeWeight(2); 
    stroke(255);
    if ( peopleInside.size() > 0){
      fill(255,0,0,70);
    } else {
      fill(255,255,255,70);
    }
    ellipse(pos.x, pos.y, 2*radius, 2*radius);
  }
  
  @Override
  public Boolean pointIsInside(PVector p){
    return (dist(p.x*width, p.y*height, pos.x, pos.y) < radius);
  }
}
