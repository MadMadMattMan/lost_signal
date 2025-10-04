/**                                                                  mine building                                                 */
int mineBuildings = 0;
public class MineBuilding implements Building {
  // Buliding data
  /// positional
  PVector position; // space in 2d
  PVector xySize = new PVector(25, 25); // x size, y size
  
  /// targeting
  float spread = PI/256;   // the degree of spread
  PVector target = new PVector(1, 0).normalize(); // target direction - normalized
  
  // Building
  String buildingId;
  BuildingType type = BuildingType.mine;
  Resource storedResources;
  Resource overflowResources;
  ArrayList<Signal> toSend = new ArrayList<>();
  
  // Info Rendering
  InfoPanel infoPanel;
  boolean renderInfo = false;
  
  // Miner
  ArrayList<ResourceType> availableOres = new ArrayList<>();
  ResourceType selectedOre;
  int oreIndex = 0;
  
  float productionRate = 10; // resources per second - number is max speed
  float placementPenalty = 0.2; // how much of a decline the wrong biome will cause per step (percent)
  float productionPercent = 0;
  
  Collider collider;
  
  // Rendering
  int renderX, renderY, dSize;
  
  MineBuilding(PVector pos) {
    // Id
    buildingId = ("Mine " + mineBuildings);
    mineBuildings++;
    // General
    position = pos;
    collider = gameWorld.createCollider(cornerOffset(pos, xySize, 0), cornerOffset(pos, xySize, 3), true, this, mineBuilding);
    // Miner
    availableOres.add(ResourceType.coal); availableOres.add(ResourceType.iron); availableOres.add(ResourceType.copper);
    selectedOre = availableOres.get(0);
    storedResources = new Resource(selectedOre, 0); // initialize storage
    float penalty = getBiomePenalty(getNoiseAt(position), "rich ore");
    productionRate *= 1 - (placementPenalty * penalty);   
    
    // render
    renderX = (int)(position.x - xySize.x);
    renderY = (int)(position.y - xySize.y);
    dSize = (int)(xySize.x * 2);
  }
  
  void tickFrame() { // per frame method
    render();
    if (renderInfo) infoPanel.render();
    
    for (Signal s : toSend) {
      emit(s);
    }  
    toSend.clear();
  }    
  void tickSecond() {produce(null);} // produce called once per second
  void consume(Signal receivedSignal) {} // take in signal
  void produce(Signal processingSignal) {
    productionPercent += productionRate;
    
    int newResources = floor(productionPercent);
    productionPercent-=newResources;
    storedResources.increase(newResources);
    
    int sendableResources = floor(storedResources.getAmount());
    if (sendableResources >= 5) {
      storedResources.reset();      
      int waves = ceil(sendableResources/5);
      float perSignal = sendableResources/waves;
      for (int i = 0; i < waves * 5; i++) {
        toSend.add(new Signal(position.copy(), randomAim(target, spread), this, defaultBuildingType, new Resource(selectedOre, perSignal)));   
      }
    }
  }
  
  void emit(Signal s) {  
    activeSignals.add(s.copy());
    
  }   // send out signals
  void render() {image(mineIcon, renderX, renderY, dSize, dSize);} //draws the building
  
  //getters
  String getBuildingId() {return buildingId;};
  PVector getBuildingPosition() {return position.copy();}
  BuildingData getBuildingData() {
     return new BuildingData(this, type, position.copy(), xySize.copy(), buildingId, productionRate, selectedOre);
  }
  Collider getCollider() {return collider;}
  
  //setter
  void setAim(PVector newAim) {target = newAim;}
  void toggleInfo() {
    renderInfo = !renderInfo; // toggle bool
    
    if (renderInfo) // takes a new snapshot of data
      infoPanel = new InfoPanel(getBuildingData());
      
    infoPanel.initialize(renderInfo);
  }
  void toggleMode() {
    if ((oreIndex+=1) == (availableOres.size())) oreIndex = 0;
    selectedOre = availableOres.get(oreIndex);
    infoPanel.updateInfo(selectedOre);
  }
}



/**                                                                  relay building                                                 */
int relayBuildings = 0;
public class RelayBuilding implements Building {
  // Buliding data
  /// positional
  PVector position; // space in 2d
  PVector xySize = new PVector(25, 25); // x size, y size
  
  /// targeting
  float spread = PI/256;   // the degree of spread
  PVector target = null; // no target until set
  
  // Building
  String buildingId;
  BuildingType type;
  ArrayList<Resource> storedResources = new ArrayList<>();
  ArrayList<Signal> toSend = new ArrayList<>();
  
  // Info Rendering
  InfoPanel infoPanel;
  boolean renderInfo = false;
  
  Collider collider;
  
  //Constructor
  RelayBuilding(PVector pos) {
    buildingId = ("Relay " + relayBuildings);
    relayBuildings++;
    // General
    position = pos;
    collider = gameWorld.createCollider(cornerOffset(pos, xySize, 0), cornerOffset(pos, xySize, 3), false, this, relayBuilding);
  }
  
  void tickFrame() {
    render();
    for (Signal s : toSend)
      emit(s);
    toSend.clear();
  }
  void tickSecond(){}
  
  // receive, process, send
  void consume(Signal receivedSignal) {
    receivedSignal.destroy = true;
    Signal newSignal = receivedSignal.copy();
    if (target != null)
      newSignal.applyForce(target.copy().setMag(10));
    toSend.add(newSignal);
  } 
  void produce(Signal processingSignal) { }
  void emit(Signal signal) {
    activeSignals.add(signal);
    signal.origin = null;
  }
  
  // rendering
  void render() {
    image(relayIcon, (int)(position.x - xySize.x), (int)(position.y - xySize.y), (int)xySize.x*2, (int)xySize.y*2);
  }
  
  //getters
  String getBuildingId() {return buildingId;};
  PVector getBuildingPosition() {return position.copy();}
  BuildingData getBuildingData() {
     return new BuildingData(this, type, position.copy(), xySize.copy(), buildingId);
  }
  Collider getCollider() {return collider;}
  
  //setter
  void setAim(PVector newAim) {target = newAim;}
  void toggleInfo() {
    renderInfo = !renderInfo; // toggle bool
    
    if (renderInfo) // takes a new snapshot of data
      infoPanel = new InfoPanel(getBuildingData());
  }
  void toggleMode() {} // no building mode to toggle
}
