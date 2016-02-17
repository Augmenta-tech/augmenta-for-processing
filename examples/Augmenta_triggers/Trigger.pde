import augmentaP5.*;

public class Trigger{

  AugmentaPerson[] people;
  IntList peopleInside;
  Augmenta_triggers app;
  PGraphics canvas;
  
  public Trigger(Augmenta_triggers _app){
    peopleInside = new IntList();
    app = _app;
    canvas = _app.canvas;
  }
  
  public void update(AugmentaPerson[] _people){
    
    // Update the people in the scene
    people = _people;
    
    IntList newPeopleInside = new IntList();
    for (int i=0; i<people.length; i++) {
        PVector p = people[i].centroid;
        if (pointIsInside(p)){
           if (!peopleInside.hasValue(people[i].id)){
             // Send message to the app : someone entered
             app.personEnteredTrigger(people[i].id, this);
           }
           newPeopleInside.append(people[i].id);
        }
     }
     
     // Check if people have left the trigger
     for (int i=0; i<peopleInside.size(); i++) {
         // Test if the point is not in the trigger anymore
         if (!newPeopleInside.hasValue(peopleInside.get(i))){
           app.personLeftTrigger(peopleInside.get(i), this);
         }
     }
     
     // Replace the old list by the new one
     peopleInside = newPeopleInside;
     
  }
  
  public void draw(){
    // Override in the child classes
  }
  
  public IntList getPeopleInside(){
     return peopleInside;
  }
  
  public Boolean pointIsInside(PVector p){
    // Override in the child classes
    return false;
  }
  
}