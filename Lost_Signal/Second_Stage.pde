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
  ResourceType input2 = ResourceType.iron;
  ResourceType output = craftResult(input1, input2);
  
  // Rendering
  int renderX, renderY, dSize;
  
  FactoryBuilding(PVector pos) {
    position = pos;
    factoryBuildings++;
    buildingId = (type.toString() + ":" + factoryBuildings);
    collider = gameWorld.createCollider(cornerOffset(pos, xySize, 0), cornerOffset(pos, xySize, 3), true, this, factoryBuilding);
    
    // render
    renderX = (int)(position.x - xySize.x);
    renderY = (int)(position.y - xySize.y);
    dSize = (int)(xySize.x * 2);
  }
  
  void tickFrame() { // per frame method
    render();
    if (renderInfo) infoPanel.render();
  }    
  void tickSecond() {}
  void consume(Signal receivedSignal) {  // take in signal
    Resource intake = receivedSignal.contents;
    if (intake != null) {
      ResourceType incomingType = intake.getType();
      float amount = intake.getAmount();
      if (incomingType == input1){
        
        receivedSignal.destroy = true;
      }
      else if (incomingType == input2) {
        
        receivedSignal.destroy = true;
      }
      if (fuelResources.contains(incomingType)) {
        fuel += amount;
        receivedSignal.destroy = true;
      }
    }
    
  }
  void produce(Signal processingSignal) {} // nothing to produce
  
  void emit(Signal s) {}   // doesn't send out signals
  void render() {image(factoryIcon, renderX, renderY, dSize, dSize);} //draws the building
  
  //getters
  String getBuildingId() {return buildingId;};
  PVector getBuildingPosition() {return position.copy();}
  BuildingData getBuildingData() {
     return new BuildingData(this, type, position.copy(), xySize.copy());
  }
  Collider getCollider() {return collider;}
  float getBuildingPrice() {return sellPrice;}
  
  //setter
  void setAim(PVector newAim) {}
  void toggleInfo() {
    renderInfo = !renderInfo; // toggle bool
    
    if (renderInfo) // takes a new snapshot of data
      infoPanel = new InfoPanel(getBuildingData());
      
    infoPanel.initialize(renderInfo);
  }
  void toggleMode() {}
}
