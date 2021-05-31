import augmenta.*;

public class CircleTrigger extends Trigger{
  
  PVector pos;
  float radius;
  
  public CircleTrigger(float _x, float _y, float _radius, Augmenta_triggers _app){
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
    canvas = app.canvas;
    canvas.strokeWeight(2); 
    canvas.stroke(255);
    if ( peopleInside.size() > 0){
      canvas.fill(255,0,0,70);
    } else {
      canvas.fill(255,255,255,70);
    }
    canvas.ellipse(pos.x, pos.y, 2*radius, 2*radius);
  }
  
  @Override
  public Boolean pointIsInside(PVector p){
    return (dist(p.x*canvas.width, p.y*canvas.height, pos.x, pos.y) < radius);
  }
}
