// Struct for the data in collision
public static class CollisionData{
  // public variables as class is a data container
  public boolean collisionResult = false;
  public boolean invalidCollision = false;
  public boolean physicalCollision = false;
  public PVector collisionNormal = new PVector();
  
  public boolean consumeable = false;
  public Building building = null;
  
  
   // Constructors
   CollisionData() {} // no collision
   CollisionData(boolean physicalCollision, PVector collisionNormal) { // obstructor collision
     this.collisionResult = true;
     this.physicalCollision = physicalCollision;
     this.collisionNormal = collisionNormal;
   }
   CollisionData(boolean physicalCollision, PVector collisionNormal, Building building) { // full collision
     this.collisionResult = true;
     this.physicalCollision = physicalCollision;
     this.collisionNormal = collisionNormal;
     this.consumeable = true;
     this.building = building;
   }
   CollisionData(boolean invalid) {
     collisionResult = invalid;
     invalidCollision = invalid;
   }
   
}

public class Resource { 
  public ResourceType type;
  public float amount;
  
  Resource() {} // empty resource
  Resource(ResourceType type, float amount) {
  this.type = type;
  this.amount=amount;
  }

  ResourceType getType() {return type;}
  float getAmount() {return amount;}
  
  void increase(float amount) {this.amount+=amount;}
  void reset() {this.amount = 0;}
}
