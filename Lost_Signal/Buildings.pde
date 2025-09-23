PImage factory;
void collectImages() {
  factory = loadImage("assets/buildings/factory.png"); 
}

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
    //case relay: return new RelayBuilding(pos);
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
  float interfereance = spread + random(-spread, spread)/2;
  float variation = random(-interfereance, interfereance);
  return aim.copy().rotate(variation).normalize();
}

public interface Building{ 
  void tick();    // per frame method
  void consume(Signal receivedSignal); // take in signal
  void produce(); // do something with that signal
  void emit(int count);   // send out signals
  void render(); //draws the building
  
  String getBuildingId();
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
    collider = gameWorld.createCollider(cornerOffset(pos, xySize, true), cornerOffset(pos, xySize, false), false, this, defaultBuildingType);
    
    println("placed " + buildingId);
  }
  
  // tick update
  float lastPulse = 0;
  float pulseRate = 100;
  void tick() {
    render();
    if ((millis() - lastPulse) >= pulseRate) {
      lastPulse = millis();
      emit(15);
    }
  }
  
  // receive, process, send
  void consume(Signal receivedSignal) {} //does not consume
  void produce() { }
  void emit(int count) {
    for (int i = 0; i < count; i++) {
      activeSignals.add(new Signal(position.copy(), randomAim(target, spread), this, defaultBuildingType, ""));
    }
  }
  
  // rendering
  void render() {
    imageMode(CENTER);
    image(factory, (int)(position.x - xySize.x), (int)(position.y - xySize.y), (int)xySize.x*2, (int)xySize.y*2);
  }
  
  //getters
  String getBuildingId() {return buildingId;};
}

/**
int relayBuildings = 0;
public class RelayBuilding implements Building {
  // Buliding data
  PVector position; // space in 2d
  PVector xySize = new PVector(25, 25); // x size, y size
  
  float spread = PI/128;   // the rad of spread
  PVector target = new PVector(1, 0).normalize(); // target direction - normalized
  
  // Building
  String buildingId;
  ArrayList<Resource> storedResources = new ArrayList<>();
  
  Collider collider;
  
  //Constructor
  RelayBuilding(PVector pos) {
    buildingId = ("Relay " + relayBuildings);
    relayBuildings++;
    // General
    position = pos;
    collider = gameWorld.createCollider(cornerOffset(pos, xySize, true), cornerOffset(pos, xySize, false), false, defaultLayers);
  }
  float lastPulse = 0;
  float pulseRate = 100;
  void tick() {
    render();
  }
  void consume(Signal receivedSignal) {
    target = position.copy().sub(receivedSignal.position.copy()).normalize();
    emit(1);
  }
  
  void produce() { }
  void emit(int count) {
    for (int i = 0; i < count; i++) {
      activeSignals.add(new Signal(position.copy(), randomAim(target, spread)));
    }
  }
  
  void render() {
    imageMode(CENTER);
    image(factory, (int)(position.x - xySize.x), (int)(position.y - xySize.y), (int)xySize.x*2, (int)xySize.y*2);
  }
}
*/
