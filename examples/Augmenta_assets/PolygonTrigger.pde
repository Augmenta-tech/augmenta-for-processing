import augmentaP5.*;

public class PolygonTrigger extends Trigger{
  
  // Points
  PVector[] points;
  
  public PolygonTrigger(PVector[] _points, Augmenta_assets _app){
    super(_app);
    points = _points;
  }
  
  public void setPolygon(PVector[] _points){
    points = _points;
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
    beginShape();
    for (int i=0; i<points.length; i++){
      vertex(points[i].x,points[i].y);
    }
    endShape();
  }
  
  @Override
  public Boolean pointIsInside(PVector p){
    int i;
    int j;
    boolean result = false;
    for (i = 0, j = points.length - 1; i < points.length; j = i++) {
      if ((points[i].y > p.y*height) != (points[j].y > p.y*height) &&
          (p.x*width < (points[j].x - points[i].x) * (p.y*height - points[i].y) / (points[j].y-points[i].y) + points[i].x)) {
        result = !result;
       }
    }
    return result;
  }
}
