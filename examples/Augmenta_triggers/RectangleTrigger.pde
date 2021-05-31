import augmenta.*;

public class RectangleTrigger extends Trigger{
  // Top left corner
  PVector tl;
  // Bottom right corner
  PVector br;
  
  public RectangleTrigger(float _tlx, float _tly, float _brx, float _bry, Augmenta_triggers _app){
    super(_app);
    tl = new PVector(_tlx, _tly);
    br = new PVector(_brx, _bry);
  }
  
  public void setRectangle(float _tlx, float _tly, float _brx, float _bry){
    tl = new PVector(_tlx, _tly);
    br = new PVector(_brx, _bry);
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
    canvas.rect(tl.x, tl.y, br.x-tl.x, br.y-tl.y);
  }
  
  @Override
  public Boolean pointIsInside(PVector p){
    return (p.x*canvas.width < br.x && p.x*canvas.width > tl.x && p.y*canvas.height < br.y && p.y*canvas.height > tl.y);
  }
}
