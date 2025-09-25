public static final ArrayList<BuildingType> testBuilding = new ArrayList<>() {{add(BuildingType.test);}};
public static final ArrayList<BuildingType> relayBuilding = new ArrayList<>() {{add(BuildingType.relay);}};

// Building Methods
void addBuilding(PVector position, BuildingType type) {
  Building newBuilding = newBuilding(position, type);
  if (newBuilding != null){
    if (!worldBuildings.keySet().contains(type))  // if not there, add it
      worldBuildings.put(type, new ArrayList<Building>());
      
    worldBuildings.get(type).add(newBuilding);
  }
}

// General constructor
Building newBuilding(PVector pos, BuildingType type) {
  // Type specific
  switch (type) {
    case test: return new TestBuilding(pos);
    case relay: return new RelayBuilding(pos);
    // case export:
    default: return null;
  }
}

// General methods
public PVector cornerOffset(PVector position, PVector xySize, boolean top) {
  PVector result;
  if (top)
    result = new PVector(position.x - xySize.x, position.y - xySize.y);
  else
    result = new PVector(position.x + xySize.x, position.y + xySize.y);
  return result;
}
public PVector randomAim(PVector aim, float spread) {
  float interfereanceRatio = spread*globalInterference;
  float interfereance = spread + random(-interfereanceRatio, interfereanceRatio)/2;
  float variation = random(-interfereance, interfereance);
  return aim.copy().rotate(variation).normalize();
}

public interface Building{ 
  void tick();    // per frame method
  void consume(Signal receivedSignal); // take in signal
  void produce(); // do something with that signal
  void emit(Signal s, int count);   // send out signals
  void render(); //draws the building
  
  String getBuildingId();
  PVector getBuildingPosition();
  
  void setAim(PVector newAim);
}

int testBuildings = 0;
public class TestBuilding implements Building {
  // Buliding data
  /// positional
  PVector position; // space in 2d
  PVector xySize = new PVector(25, 25); // x size, y size
  
  /// targeting
  float spread = PI/128;   // the degree of spread
  PVector target = new PVector(1, 0).normalize(); // target direction - normalized
  
  // Building
  String buildingId;
  ArrayList<Integer> signalLayers = new ArrayList<>() {{add(0);}};
  ArrayList<Resource> storedResources = new ArrayList<>();
  
  Collider collider;
  
  //Constructor
  TestBuilding(PVector pos) {
    buildingId = ("Test " + testBuildings);
    testBuildings++;
    // General
    position = pos;
    collider = gameWorld.createCollider(cornerOffset(pos, xySize, true), cornerOffset(pos, xySize, false), true, this, testBuilding);
    
    println("placed " + buildingId);
  }
  
  // tick update
  float lastPulse = 0;
  float pulseRate = 100;
  void tick() {
    render();
    if ((millis() - lastPulse) >= pulseRate) {
      lastPulse = millis();
      emit(null, 15);
    }
  }
  
  // receive, process, send
  void consume(Signal receivedSignal) {} // does not consume
  void produce() { } // does not produce
  void emit(Signal s, int count) {
    for (int i = 0; i < count; i++) {
      activeSignals.add(new Signal(position.copy(), randomAim(target, spread), this, defaultBuildingType, ""));
    }
  }
  
  // rendering
  void render() {
    image(factory, (int)(position.x - xySize.x), (int)(position.y - xySize.y), (int)xySize.x*2, (int)xySize.y*2);
  }
  
  //getters
  String getBuildingId() {return buildingId;};
  PVector getBuildingPosition() {return position.copy();}
  
  //setters
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
  void produce() { }
  void emit(Signal signal, int count) {
    for (int i = 0; i < count; i++) {
      activeSignals.add(signal);
      signal.origin = null;
    }
  }
  
  // rendering
  void render() {
    image(factory, (int)(position.x - xySize.x), (int)(position.y - xySize.y), (int)xySize.x*2, (int)xySize.y*2);
  }
  
  //getters
  String getBuildingId() {return buildingId;};
  PVector getBuildingPosition() {return position.copy();}
  
  //setter
  void setAim(PVector newAim) {target = newAim;}
}
