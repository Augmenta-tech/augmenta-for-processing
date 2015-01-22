import augmentaP5.*;

public class RectangleTrigger extends Trigger{
  // Top left corner
  PVector tl;
  // Bottom right corner
  PVector br;
  
  public RectangleTrigger(float _tlx, float _tly, float _brx, float _bry, Augmenta_assets _app){
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
    strokeWeight(2); 
    stroke(255);
    if ( peopleInside.size() > 0){
      fill(255,0,0,70);
    } else {
      fill(255,255,255,70);
    }
    rect(tl.x, tl.y, br.x-tl.x, br.y-tl.y);
  }
  
  @Override
  public Boolean pointIsInside(PVector p){
    return (p.x*width < br.x && p.x*width > tl.x && p.y*height < br.y && p.y*height > tl.y);
  }
}
