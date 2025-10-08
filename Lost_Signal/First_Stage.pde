int mineBuildings = 0;
int lumberBuildings = 0;
int relayBuidlings = 0;
int storageBuildings = 0;
/**                                                                  gatherer building                                                 */
public class GathererBuilding implements Building {
  // Buliding data
  /// positional
  PVector position; // space in 2d
  PVector xySize = new PVector(25, 25); // x size, y size
  
  /// targeting
  float spread = PI/256;   // the degree of spread
  PVector target = new PVector(1, 0).normalize(); // target direction - normalized
  
  // Building
  String buildingId;
  BuildingType type;
  ArrayList<Signal> toSend = new ArrayList<>();
  PImage icon;
  float sellPrice = 0;
  
  // Info Rendering
  InfoPanel infoPanel;
  boolean renderInfo = false;
  
  // Miner
  ArrayList<ResourceType> availableResources = new ArrayList<>();
  ResourceType selectedResource;
  Resource storedResources;
  int resourceIndex = 0;
  
  float productionLimit = 10; // resources per second - number is max speed
  float productionRate;
  float placementPenalty = 0.2; // how much of a decline the wrong biome will cause per step (percent)
  float productionPercent = 0;
  
  Collider collider;
  
  // Rendering
  int renderX, renderY, dSize;
  
  GathererBuilding(PVector pos, BuildingType type) {
    position = pos;
    this.type = type;
    
    
    if (type == BuildingType.mine) {
      mineBuildings++;
      icon = mineIcon;
      buildingId = (type.toString() + ":" + mineBuildings);
      collider = gameWorld.createCollider(cornerOffset(pos, xySize, 0), cornerOffset(pos, xySize, 3), true, this, mineBuilding);
      availableResources.add(ResourceType.coal); availableResources.add(ResourceType.iron); availableResources.add(ResourceType.copper);
      float penalty = getBiomePenalty(getNoiseAt(position), "rich ore");
      productionLimit *= 1 - (placementPenalty * penalty); 
    }
    if (type == BuildingType.lumber) {
      lumberBuildings++;
      icon = lumberIcon;
      buildingId = (type.toString() + ":" + lumberBuildings);
      collider = gameWorld.createCollider(cornerOffset(pos, xySize, 0), cornerOffset(pos, xySize, 3), true, this, lumberBuilding);
      availableResources.add(ResourceType.wood); availableResources.add(ResourceType.leaves); availableResources.add(ResourceType.sap);
      float penalty = getBiomePenalty(getNoiseAt(position), "rich forest");
      productionLimit *= 1 - (placementPenalty * penalty); 
    }
    
    sellPrice = buildingCosts.get(type)/2;
    selectedResource = availableResources.get(0);
    storedResources = new Resource(selectedResource, 0); // initialize storage
    
    productionRate = productionLimit * resourceSpeed.get(selectedResource);
    
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
    
    int sendableResources = floor(storedResources.getAmount()/5)*5;
    if (sendableResources >= 5) {
      storedResources.increase(-sendableResources);
      int waves = ceil(sendableResources/5);
      float perSignal = sendableResources/waves;
      for (int i = 0; i < waves * 5; i++) {
        toSend.add(new Signal(position.copy(), randomAim(target, spread), this, defaultBuildingType, new Resource(selectedResource, perSignal/5)));   
      }
    }
  }
  
  void emit(Signal s) {  
    activeSignals.add(s.copy());
    
  }   // send out signals
  void render() {image(icon, renderX, renderY, dSize, dSize);} //draws the building
  
  //getters
  String getBuildingId() {return buildingId;};
  PVector getBuildingPosition() {return position.copy();}
  BuildingData getBuildingData() {
     return new BuildingData(this, type, position.copy(), xySize.copy(), sellPrice, productionRate, selectedResource);
  }
  Collider getCollider() {return collider;}
  float getBuildingPrice() {return sellPrice;}
  
  //setter
  void setAim(PVector newAim) {target = newAim;}
  void toggleInfo() {
    renderInfo = !renderInfo; // toggle bool
    
    if (renderInfo) // takes a new snapshot of data
      infoPanel = new InfoPanel(getBuildingData());
      
    infoPanel.initialize(renderInfo);
  }
  void toggleMode() {
    if ((resourceIndex+=1) == (availableResources.size())) resourceIndex = 0;
    selectedResource = availableResources.get(resourceIndex);
    productionRate = productionLimit * resourceSpeed.get(selectedResource);
    infoPanel.updateInfo(selectedResource, productionRate);
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
  PVector pastTarget = new PVector(1, 0);
  
  // Building
  String buildingId;
  BuildingType type = BuildingType.relay;
  ArrayList<Resource> storedResources = new ArrayList<>();
  ArrayList<Signal> toSend = new ArrayList<>();
  float sellPrice = 0;
  
  
  // Info Rendering
  InfoPanel infoPanel;
  boolean renderInfo = false;
  
  Collider collider;
  
  //Constructor
  RelayBuilding(PVector pos) {
    buildingId = ("Relay " + relayBuildings);
    relayBuildings++;
    // General
    sellPrice = buildingCosts.get(type)/2;
    position = pos;
    collider = gameWorld.createCollider(cornerOffset(pos, xySize, 0), cornerOffset(pos, xySize, 3), false, this, relayBuilding);
  }
  
  void tickFrame() {
    render();
    if (renderInfo) infoPanel.render();
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
     return new BuildingData(this, type, position.copy(), xySize.copy(), sellPrice, (target!=null));
  }
  Collider getCollider() {return collider;}
  float getBuildingPrice() {return sellPrice;}
  
  //setter
  void setAim(PVector newAim) {target = newAim; if (infoPanel!=null) infoPanel.updateInfo(target!=null);}
  void toggleInfo() {
    renderInfo = !renderInfo; // toggle bool
    
    if (renderInfo) // takes a new snapshot of data
      infoPanel = new InfoPanel(getBuildingData());
      
    infoPanel.initialize(renderInfo);
  }
  void toggleMode() {
    if (target != null) {
      pastTarget = target;
      target = null;
    }
    else 
      target = pastTarget;
      
    infoPanel.updateInfo(target!=null);
  } // no building mode to toggle
}

/**                                                                  storage building                                                 */
public class StorageBuilding implements Building {
  // Buliding data
  /// positional
  PVector position; // space in 2d
  PVector xySize = new PVector(25, 25); // x size, y size
  
  /// targeting
  float spread = PI/512;   // the degree of spread
  PVector target = new PVector(1, 0).normalize(); // target direction - normalized
  
  // Building
  String buildingId;
  BuildingType type = BuildingType.storage;
  ArrayList<Signal> toSend = new ArrayList<>();
  float sellPrice = 0;
  
  // Info Rendering
  InfoPanel infoPanel;
  boolean renderInfo = false;

  // Storage
  HashMap<ResourceType, Float> storage = new HashMap<>(); 
  
  Collider collider;
  
  // Rendering
  int renderX, renderY, dSize;
  
  StorageBuilding(PVector pos) {
    position = pos;
    storageBuildings++;
    buildingId = (type.toString() + ":" + storageBuildings);
    collider = gameWorld.createCollider(cornerOffset(pos, xySize, 0), cornerOffset(pos, xySize, 3), true, this, storageBuilding);
    sellPrice = buildingCosts.get(type)/2;
    
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
  void tickSecond() {}
  void consume(Signal receivedSignal) {  // take in signal
    Resource intake = receivedSignal.contents;
    if (intake != null) {
      ResourceType type = intake.getType();
      float pastAmount = 0;
       if (storage.keySet().contains(type)) {
          pastAmount = storage.get(type);
         storage.remove(type);
       }
         
       storage.put(type, (pastAmount + intake.getAmount()));
    }
    receivedSignal.destroy = true;
  }
  void produce(Signal processingSignal) {} // nothing to produce
  
  void emit(Signal s) {  
    activeSignals.add(s.copy());
    
  }   // send out signals
  void render() {image(storageIcon, renderX, renderY, dSize, dSize);} //draws the building
  
  //getters
  String getBuildingId() {return buildingId;};
  PVector getBuildingPosition() {return position.copy();}
  BuildingData getBuildingData() {
     return new BuildingData(this, type, position.copy(), xySize.copy(), sellPrice, storage);
  }
  Collider getCollider() {return collider;}
  float getBuildingPrice() {return sellPrice;}
  
  //setter
  void setAim(PVector newAim) {target = newAim;}
  void toggleInfo() {
    renderInfo = !renderInfo; // toggle bool
    
    if (renderInfo) // takes a new snapshot of data
      infoPanel = new InfoPanel(getBuildingData());
      
    infoPanel.initialize(renderInfo);
  }
  void toggleMode() {
    for (ResourceType rType : storage.keySet()) {
      int newResources = floor(storage.get(rType));
      
      int sendableResources = floor(newResources/5)*5;
      int leftoverResources = newResources-sendableResources;
      int waves = ceil(sendableResources/5);
      
      for (int i = 0; i < waves * 5; i++)
        toSend.add(new Signal(position.copy(), randomAim(target, spread), this, defaultBuildingType, new Resource(rType, 1)));   
      for (int i = 0; i < leftoverResources; i++)
        toSend.add(new Signal(position.copy(), randomAim(target, spread), this, defaultBuildingType, new Resource(rType, 1)));   
    }
    storage.clear();
  }
}
