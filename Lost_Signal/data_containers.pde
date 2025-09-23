// Struct for the data in collision
public static class CollisionData{
  // public variables as class is a data container
  public boolean collisionResult = false;
  public boolean physicalCollision = false;
  public PVector collisionNormal = new PVector();
  
  public boolean consumeable;
  public Building building;
  
  
   // Constructors
   CollisionData() {} // no collision
   CollisionData(boolean physicalCollision, PVector collisionNormal) { // obstructor collision
     this.collisionResult = true;
     this.physicalCollision = physicalCollision;
     this.collisionNormal = collisionNormal;
     this.consumeable = false;
     this.building = null;
   }
   CollisionData(boolean physicalCollision, PVector collisionNormal, Boolean consumeable, Building building) { // full collision
     this.collisionResult = true;
     this.physicalCollision = physicalCollision;
     this.collisionNormal = collisionNormal;
     this.consumeable = consumeable;
     this.building = building;
   }
   
}

public class Resource { 
  
}
