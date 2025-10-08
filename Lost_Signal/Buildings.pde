public static final ArrayList<BuildingType> testBuilding = new ArrayList<>() {{add(BuildingType.test);}};
public static final ArrayList<BuildingType> mineBuilding = new ArrayList<>() {{add(BuildingType.mine);}}; //<>// //<>//
public static final ArrayList<BuildingType> lumberBuilding = new ArrayList<>() {{add(BuildingType.lumber);}};
public static final ArrayList<BuildingType> relayBuilding = new ArrayList<>() {{add(BuildingType.relay);}};
public static final ArrayList<BuildingType> storageBuilding = new ArrayList<>() {{add(BuildingType.storage);}};
public static final ArrayList<BuildingType> factoryBuilding = new ArrayList<>() {{add(BuildingType.factory);}};
public static final ArrayList<BuildingType> bankBuilding = new ArrayList<>() {{add(BuildingType.bank);}};

// Building Methods
Building addBuilding(PVector position, BuildingType type) {
  Building newBuilding = newBuilding(position, type);
  if (newBuilding != null){
    globalMoney -= buildingCosts.get(type);
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
    case mine: return new GathererBuilding(pos, type);
    case lumber: return new GathererBuilding(pos, type);
    case relay: return new RelayBuilding(pos);
    case storage: return new StorageBuilding(pos);
    case factory: return new FactoryBuilding(pos);
    case bank: return new BankBuilding(pos);
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
  // constant
  void tickFrame();    // per frame method
  void tickSecond();  // per second method
  
  // event
  void consume(Signal receivedSignal); // take in signal
  void produce(Signal processingSignal); // do something with that signal
  void emit(Signal s);   // send out signals
  void render(); //draws the building
  
  // getters
  String getBuildingId();
  PVector getBuildingPosition();
  BuildingData getBuildingData();
  Collider getCollider();
  float getBuildingPrice();
  
  // setters
  void setAim(PVector newAim);
  void toggleInfo();
  void toggleMode();
}
/**                                                                  bank building                                                 */
int bankBuildings = 0;
public class BankBuilding implements Building {
  // Buliding data
  /// positional
  PVector position; // space in 2d
  PVector xySize = new PVector(25, 25); // x size, y size
  
  // Building
  String buildingId;
  BuildingType type = BuildingType.bank;
  
  // Info Rendering
  InfoPanel infoPanel;
  boolean renderInfo = false;

  // Storage 
  Collider collider;
  
  // Rendering
  int renderX, renderY, dSize;
  
  BankBuilding(PVector pos) {
    position = pos;
    bankBuildings++;
    buildingId = (type.toString() + ":" + bankBuildings);
    collider = gameWorld.createCollider(cornerOffset(pos, xySize, 0), cornerOffset(pos, xySize, 3), true, this, bankBuilding);
    
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
      float sellGain = intake.getAmount() * (resourceValue.get(intake.getType()));
      globalMoney += sellGain;
      earnedAmount += sellGain;      
    }
    receivedSignal.destroy = true;
  }
  void produce(Signal processingSignal) {} // nothing to produce
  
  void emit(Signal s) {}   // doesn't send out signals
  void render() {image(bankIcon, renderX, renderY, dSize, dSize);} //draws the building
  
  //getters
  String getBuildingId() {return buildingId;};
  PVector getBuildingPosition() {return position.copy();}
  BuildingData getBuildingData() {
     return new BuildingData(this, type, position.copy(), xySize.copy());
  }
  Collider getCollider() {return collider;}
  float getBuildingPrice() {return -1;}
  
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
/**                                                                  testing building                                                 */
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
  BuildingType type;
  String buildingId;
  ArrayList<Integer> signalLayers = new ArrayList<>() {{add(0);}};
  ArrayList<Resource> storedResources = new ArrayList<>();
  float sellPrice = 10;
  
  // Info Rendering
  InfoPanel infoPanel;
  boolean renderInfo = false;
  
  Collider collider;
  
  //Constructor
  TestBuilding(PVector pos) {
    buildingId = ("Test " + testBuildings);
    testBuildings++;
    type = BuildingType.test;
    // General
    sellPrice = buildingCosts.get(type)/2;
    position = pos;

    collider = gameWorld.createCollider(cornerOffset(pos, xySize, 0), cornerOffset(pos, xySize, 3), true, this, testBuilding);
  }
  
  // tick update
  float lastPulse = 0;
  float pulseRate = 100;
  void tickFrame() {
    render(); 
    if (renderInfo) infoPanel.render();
  }
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
    image(factoryIcon, (int)(position.x - xySize.x), (int)(position.y - xySize.y), (int)xySize.x*2, (int)xySize.y*2);
    stroke(0); fill(0); circle(position.x, position.y, 5);
  }
  
  //getters
  String getBuildingId() {return buildingId;};
  PVector getBuildingPosition() {return position.copy();}
  BuildingData getBuildingData() {
     return new BuildingData(this, type, position.copy(), xySize.copy(), sellPrice);
  }
  Collider getCollider() {return collider;}
  float getBuildingPrice() {return sellPrice;}
  
  //setters
  void setAim(PVector newAim) {target = newAim;}
  void toggleInfo() {
    renderInfo = !renderInfo; // toggle bool
    
    if (renderInfo) // takes a new snapshot of data
      infoPanel = new InfoPanel(getBuildingData());
    infoPanel.initialize(renderInfo);
  }
  void toggleMode() {
    // emit stored signals
  }
}
