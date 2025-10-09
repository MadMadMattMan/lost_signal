/**                                                                  factory building                                                 */
int factoryBuildings = 0;
public class FactoryBuilding implements Building {
  // Buliding data
  /// positional
  PVector position; // space in 2d
  PVector xySize = new PVector(25, 25); // x size, y size
  
  // Building
  String buildingId;
  BuildingType type = BuildingType.factory;
  Collider collider;
  float newResources = 0;
  ArrayList<Signal> toSend = new ArrayList<>();
  float sellPrice = 50;
  
  /// targeting
  float spread = PI/256;   // the degree of spread
  PVector target = new PVector(1, 0); // aim direction
  
  // Info Rendering
  InfoPanel infoPanel;
  boolean renderInfo = false;

  // Factory
  float fuel = 0f;
  ResourceType input1 = ResourceType.coal;
  float input1Count = 0; float input1Cost;
  ResourceType input2 = ResourceType.iron;
  float input2Count = 0; float input2Cost;
  ResourceType output = craftResult(input1, input2);
  
  // Rendering
  int renderX, renderY, dSize;
  
  FactoryBuilding(PVector pos) {
    position = pos;
    factoryBuildings++;
    buildingId = (type.toString() + ":" + factoryBuildings);
    collider = gameWorld.createCollider(cornerOffset(pos, xySize, 0), cornerOffset(pos, xySize, 3), true, this, factoryBuilding);
    setResource(input1, input2);
    
    // render
    renderX = (int)(position.x - xySize.x);
    renderY = (int)(position.y - xySize.y);
    dSize = (int)(xySize.x * 2);
  }
  
  void tickFrame() { // per frame method
    render();
    
    for (Signal s : toSend) {
      emit(s);
    }  
    toSend.clear();
  }      
  void tickSecond() {produce();}
  void consume(Signal receivedSignal) {  // take in signal
    Resource intake = receivedSignal.contents;
    if (intake != null) {
      ResourceType incomingType = intake.getType();
      float amount = intake.getAmount();
      if (incomingType == input1){
        input1Count += amount;
        receivedSignal.destroy = true;
      }
      else if (incomingType == input2) {
        input2Count += amount;
        receivedSignal.destroy = true;
      }
      if (fuelResources.contains(incomingType)) {
        fuel += amount;
        
        receivedSignal.destroy = true;
      }
      if (infoPanel!=null) infoPanel.updateInfo(fuel, input1Count, input2Count);
    }
    
  }
  void produce() {
    if (input1 != null && input2 != null) {
      while(input1Count >= input1Cost && input2Count >= input2Cost && fuel >= 15) {
         input1Count-=input1Cost;
         input2Count-=input2Cost;
         fuel-=20;
         newResources += 5;
      }
      int sendableResources = floor(newResources/5)*5;
      if (sendableResources >= 5) {
        newResources-=sendableResources;
        int waves = ceil(sendableResources/5);
        float perSignal = sendableResources/waves;
        for (int i = 0; i < waves * 5; i++) {
          toSend.add(new Signal(position.copy(), randomAim(target, spread), this, defaultBuildingType, new Resource(output, perSignal/5)));   
        }
      }
    }
  }
  
  void emit(Signal s) {activeSignals.add(s.copy());}
  void render() {image(factoryIcon, renderX, renderY, dSize, dSize);} //draws the building
  
  //getters
  String getBuildingId() {return buildingId;};
  PVector getBuildingPosition() {return position.copy();}
  BuildingData getBuildingData() {
   return new BuildingData(this, type, position, xySize, sellPrice, fuel, input1, input1Count, input2, input1Count);
  }
  Collider getCollider() {return collider;}
  float getBuildingPrice() {return sellPrice;}
  
  //setter
  void setAim(PVector newAim) {target = newAim;}
  void toggleInfo() {
    renderInfo = !renderInfo; // toggle bool

    if (renderInfo) { // takes a new snapshot of data
      buildingUI.remove(infoPanel);
      infoPanel = new InfoPanel(getBuildingData());
      buildingUI.add(infoPanel);
    }
    else {buildingUI.remove(infoPanel);}
    infoPanel.initialize(renderInfo);
  }
  void toggleMode() {}
  void setResource(ResourceType input1, ResourceType input2) {
    this.input1 = input1;
    this.input2 = input2;
    
    Float[] newCosts = getCraftCost(input1, input2);
    input1Cost = newCosts[0];
    input2Cost = newCosts[1];
    output = craftResult(input1, input2);
  }
}
