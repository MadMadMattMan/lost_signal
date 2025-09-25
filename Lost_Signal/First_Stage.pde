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
  ArrayList<Resource> storedResources = new ArrayList<>();
  ArrayList<Signal> toSend = new ArrayList<>();
  
  // Miner
  ResourceType selectedOre = ResourceType.coal;
  float lastProduction = 0;
  float productionSpeed;
  
  Collider collider;
  
  MineBuilding(PVector pos) {
    // Id
    buildingId = ("Mine " + relayBuildings);
    mineBuildings++;
    // General
    position = pos;
    collider = gameWorld.createCollider(cornerOffset(pos, xySize, true), cornerOffset(pos, xySize, false), true, this, mineBuilding);
    // Miner
    /////////productionSpeed = groundMap.pixels;
    
    println("placed " + buildingId);
  }
  
  void tick() { // per frame method
  render();
  produce(null);
  
  for (Signal s : toSend)
    emit(s, 1);
  toSend.clear();
  }    
  void consume(Signal receivedSignal) {} // take in signal
  void produce(Signal processingSignal) {

    
  } // do something with that signal
  void emit(Signal s, int count) {}   // send out signals
  void render() {image(mine, (int)(position.x - xySize.x), (int)(position.y - xySize.y), (int)xySize.x*2, (int)xySize.y*2);} //draws the building
  
  //getters
  String getBuildingId() {return buildingId;};
  PVector getBuildingPosition() {return position.copy();}
  
  //setter
  void setAim(PVector newAim) {target = newAim;}
}

int relayBuildings = 0;
public class RelayBuilding implements Building {
  // Buliding data
  /// positional
  PVector position; // space in 2d
  PVector xySize = new PVector(25, 25); // x size, y size
  
  /// targeting
  float spread = PI/256;   // the degree of spread
  PVector target = new PVector(1, 0).normalize(); // target direction - normalized
  
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
    collider = gameWorld.createCollider(cornerOffset(pos, xySize, true), cornerOffset(pos, xySize, false), false, this, relayBuilding);
    
    println("placed " + buildingId);
  }
  
  void tick() {
    render();
    for (Signal s : toSend)
      emit(s, 1);
    toSend.clear();
  }
  
  // receive, process, send
  void consume(Signal receivedSignal) {
    receivedSignal.destroy = true;
    toSend.add(receivedSignal.copy());
  } 
  void produce(Signal processingSignal) { }
  void emit(Signal signal, int count) {
    for (int i = 0; i < count; i++) {
      activeSignals.add(signal);
      signal.origin = null;
    }
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
