public static final ArrayList<BuildingType> testBuilding = new ArrayList<>() {{add(BuildingType.test);}};
public static final ArrayList<BuildingType> mineBuilding = new ArrayList<>() {{add(BuildingType.mine);}};
public static final ArrayList<BuildingType> relayBuilding = new ArrayList<>() {{add(BuildingType.relay);}};

// Building Methods
Building addBuilding(PVector position, BuildingType type) {
  Building newBuilding = newBuilding(position, type);
  if (newBuilding != null){
    if (!worldBuildings.keySet().contains(type))  // if not there, add it
      worldBuildings.put(type, new ArrayList<Building>());
    worldBuildings.get(type).add(newBuilding);
    return newBuilding;
  }
  return null;
}

// General constructor
Building newBuilding(PVector pos, BuildingType type) {
  // Type specific
  switch (type) {
    case test: return new TestBuilding(pos);
    case mine: return new MineBuilding(pos);
    case relay: return new RelayBuilding(pos);
    // case export:
    default: return null;
  }
}

// General methods
public PVector cornerOffset(PVector position, PVector xySize, int corner) {
  PVector result = new PVector(0, 0);
  stroke(0); fill(0);
  switch (corner) {
    case 0: result = new PVector(position.x - xySize.x, position.y - xySize.y); break;
    case 1: result = new PVector(position.x + xySize.x, position.y - xySize.y); break;
    case 2: result = new PVector(position.x - xySize.x, position.y + xySize.y); break;
    case 3: result = new PVector(position.x + xySize.x, position.y + xySize.y); break;
    default: println("invalid corner called for cornerOffset");
   }
  
  circle(result.x, result.y, 5);
   
  return result;
}
public PVector randomAim(PVector aim, float spread) {
  float interfereanceRatio = spread*globalInterference;
  float interfereance = spread + random(-interfereanceRatio, interfereanceRatio)/2;
  float variation = random(-interfereance, interfereance);
  return aim.copy().rotate(variation).normalize();
}

public interface Building{ 
  void tickFrame();    // per frame method
  void tickSecond();  // per second method
  
  void consume(Signal receivedSignal); // take in signal
  void produce(Signal processingSignal); // do something with that signal
  void emit(Signal s);   // send out signals
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

    collider = gameWorld.createCollider(cornerOffset(pos, xySize, 0), cornerOffset(pos, xySize, 3), true, this, testBuilding);
    
    println("placed " + buildingId);
  }
  
  // tick update
  float lastPulse = 0;
  float pulseRate = 100;
  void tickFrame() {render();}
  void tickSecond() {emit(null);}
  // receive, process, send
  void consume(Signal receivedSignal) {} // does not consume
  void produce(Signal processingSignal) {} // does not produce
  void emit(Signal s) {
    Signal newSignal = new Signal(position.copy(), randomAim(target, spread), this, defaultBuildingType, null);
    activeSignals.add(newSignal.copy());
  }
  
  // rendering
  void render() {
    image(factory, (int)(position.x - xySize.x), (int)(position.y - xySize.y), (int)xySize.x*2, (int)xySize.y*2);
    stroke(0); fill(0); circle(position.x, position.y, 5);
  }
  
  //getters
  String getBuildingId() {return buildingId;};
  PVector getBuildingPosition() {return position.copy();}
  
  //setters
  void setAim(PVector newAim) {target = newAim;}
}
