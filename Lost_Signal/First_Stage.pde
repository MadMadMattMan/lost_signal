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
  Resource storedResources;
  Resource overflowResources;
  ArrayList<Signal> toSend = new ArrayList<>();
  
  // Miner
  ResourceType selectedOre = ResourceType.iron;
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
    selectedOre = randomType();
    storedResources = new Resource(selectedOre, 0); // initialize storage
    float penalty = getBiomePenalty(getNoiseAt(position), "rich ore");
    productionRate *= 1 - (placementPenalty * penalty);   
    
    // render
    renderX = (int)(position.x - xySize.x);
    renderY = (int)(position.y - xySize.y);
    dSize = (int)(xySize.x * 2);
    
    println("placed " + buildingId);
  }
  
  void tickFrame() { // per frame method
    render();
    
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
  void render() {image(mine, renderX, renderY, dSize, dSize);} //draws the building
  
  //getters
  String getBuildingId() {return buildingId;};
  PVector getBuildingPosition() {return position.copy();}
  
  //setter
  void setAim(PVector newAim) {target = newAim;}
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
  ArrayList<Resource> storedResources = new ArrayList<>();
  ArrayList<Signal> toSend = new ArrayList<>();
  
  Collider collider;
  
  //Constructor
  RelayBuilding(PVector pos) {
    buildingId = ("Relay " + relayBuildings);
    relayBuildings++;
    // General
    position = pos;
    collider = gameWorld.createCollider(cornerOffset(pos, xySize, 0), cornerOffset(pos, xySize, 3), false, this, relayBuilding);
    
    println("placed " + buildingId);
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
    image(relay, (int)(position.x - xySize.x), (int)(position.y - xySize.y), (int)xySize.x*2, (int)xySize.y*2);
  }
  
  //getters
  String getBuildingId() {return buildingId;};
  PVector getBuildingPosition() {return position.copy();}
  
  //setter
  void setAim(PVector newAim) {target = newAim;}
}
