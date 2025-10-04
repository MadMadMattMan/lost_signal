// Struct for the data in collision
public class CollisionData{
  // public variables as class is a data container
  public boolean collisionResult = false;
  public boolean invalidCollision = false;
  public boolean physicalCollision = false;
  public PVector collisionNormal = new PVector();
  
  public boolean consumeable = false;
  public Building building = null;
  public Button button = null;
  
  
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
   CollisionData(Button clickedButton) { // button click
     this.collisionResult = true;
     this.button = clickedButton;
   }
   CollisionData(boolean invalid) { // invalid data (off the screen)
     collisionResult = invalid;
     invalidCollision = invalid;
   }
   
   String ToString() {
     String str = "";
     str+=collisionResult;
     str+="; ";
     str+=invalidCollision;
     str+="; ";
     str+=physicalCollision;
     str+="; ";
     str+=collisionNormal;
     str+="; ";
     str+=consumeable;
     str+="; ";
     str+=building;
     str+="; ";
     str+=button;
     return str;
   }
}

public class Button {
  public InfoPanel parentPanel;
  public ButtonAction type;
  
  Button(InfoPanel panel, ButtonAction type) {
    this.parentPanel = panel;
    this.type = type;
  }
  
  public void click() {
    parentPanel.clickEvent(type); 
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

// displayable data for buildings
public class BuildingData {
  /// positional
  PVector pos; // space in 2d
  PVector xySize = new PVector(25, 25); // x size, y size

  // Building
  Building building;
  BuildingType type;
  String buildingId;
  BuildingType buildingType;
  Resource storedResources;
  Resource overflowResources;
  
  // General output
  ResourceType selectedOutput = ResourceType.none;
  float productionRate = 0; // resources per second - number is max speed
  float productionPercent = 0;
  
  BuildingData(Building building, BuildingType type, PVector pos, PVector xySize, String id) { // generic constructor
    this.building = building;
    this.type = type;
    this.pos = pos;
    this.xySize = xySize;
    this.buildingId = id;
    this.buildingType = BuildingType.none;
  }
}
