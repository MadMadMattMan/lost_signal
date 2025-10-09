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
  public ButtonAction type;
  
  public InfoPanel infoPanel;
  
  public UIPanel UIPanel;
  public boolean offGame;
  
  
  
  Button(InfoPanel panel, ButtonAction type) {
    this.infoPanel = panel;
    this.type = type;
  }
  Button(UIPanel panel, ButtonAction type, boolean offGame) {
    this.UIPanel = panel;
    this.type = type;
    this.offGame = offGame;
  }
  
  public void click() {
    if (UIPanel != null && isGameOn || offGame)
        UIPanel.clickEvent(type);
    else if (isGameOn)
      infoPanel.clickEvent(type);
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
  Resource storedResources;
  Resource overflowResources;
  float sellPrice;
  
  // General output
  ResourceType selectedOutput = ResourceType.none;
  float productionRate = 0; // resources per second - number is max speed
  float productionPercent = 0;
  
  // Relay
  boolean aimMode;
  
  // Storage
  HashMap<ResourceType, Float> storage;
  
  // Factory
  ResourceType input1;
  float input1Count;
  ResourceType input2;
  float input2Count;
  float fuelValue;
  
  // generic constructor
  BuildingData(Building building, BuildingType type, PVector pos, PVector xySize, float sellPrice) { 
    this.building = building;
    this.type = type;
    this.pos = pos;
    this.xySize = xySize;
    this.sellPrice = sellPrice;
  }
  // producer constructor
  BuildingData(Building building, BuildingType type, PVector pos, PVector xySize, float sellPrice, float prodRate, ResourceType output) { 
    this.building = building;
    this.type = type;
    this.pos = pos;
    this.xySize = xySize;
    this.sellPrice = sellPrice;
    this.productionRate = prodRate;
    this.selectedOutput = output;
  }
  // relay constructor
  BuildingData(Building building, BuildingType type, PVector pos, PVector xySize, float sellPrice, boolean aimMode ) {
    this.building = building;
    this.type = type;
    this.pos = pos;
    this.xySize = xySize;
    this.sellPrice = sellPrice;
    this.aimMode = aimMode;
  }
  // storage constructor
  BuildingData(Building building, BuildingType type, PVector pos, PVector xySize, float sellPrice, HashMap<ResourceType, Float> storage) {
    this.building = building;
    this.type = type;
    this.pos = pos;
    this.xySize = xySize;
    this.sellPrice = sellPrice;
    this.storage = storage;
  }
  // bank constructor
  BuildingData(Building building, BuildingType type, PVector pos, PVector xySize) {
    this.building = building;
    this.type = type;
    this.pos = pos;
    this.xySize = xySize;
  }
  // factory constructor
  BuildingData(Building building, BuildingType type, PVector pos, PVector xySize, float sellPrice, float fuelVal, ResourceType input1, float count1, ResourceType input2, float count2) { 
    this.building = building;
    this.type = type;
    this.pos = pos;
    this.xySize = xySize;
    this.sellPrice = sellPrice;
    this.input1 = input1;
    this.input1Count = count1;
    this.input2 = input2;
    this.input2Count = count2;
    this.fuelValue = fuelVal;
  }
}
