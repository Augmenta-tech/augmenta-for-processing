import augmentaP5.*;

public class Trigger{

  AugmentaPerson[] people;
  IntList peopleInside;
  Augmenta_assets app;
  
  public Trigger(Augmenta_assets _app){
    peopleInside = new IntList();
    app = _app;
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
     
     // Check if people have left the circle
     for (int i=0; i<peopleInside.size(); i++) {
       // Check if the point still exists
       if (people.length <i && people[i]!= null){
         // Test if the point is not in the trigger anymore
         if (!newPeopleInside.hasValue(people[i].id)){
           // Send message to the app : someone left
           app.personLeftTrigger(people[i].id, this);
         }
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
