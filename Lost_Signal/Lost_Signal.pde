//Global Var
public static World gameWorld; // stores and deals with the environment data
                 /// colliders -
public static final float fixedDeltaTime = 1/10;
public static final ArrayList<Integer> defaultLayers = new ArrayList<>() {{add(0);}};
public static BuildingType buildMode = BuildingType.none;


//Global Tracking
/// List storing every signal
public static ArrayList<Signal> activeSignals = new ArrayList<>();

/// Map storing every building mapped to to their type
public static HashMap<BuildingType, ArrayList<Building>> worldBuildings = new HashMap<>();


// Called every frame
void draw() {
  //Resets scene
  background(255);
  
  //updates - in order of rendering layer;
  gameWorld.render();
  
  updateBuildings();
  updateSignals();
}

// Called once at the start of the game
void setup() {
  // Processing setup
  size(1980, 1080);
  frameRate(60);
  
  // 0 frame
  collectImages();
  
  // Game setup
  newGame();
}

// Clears old game data and makes a new game
void newGame() {
  gameWorld = new World();
  
  // Testing setup
  for (int i = 0; i < 500; i++) {
    activeSignals.add(new Signal(new PVector(250, 100), new PVector(random(-1f, 1f), random(-1f, 1f))));
  }
  
  
}
// Updates and culls signals that are lost
void updateSignals() {
  ArrayList<Signal> inactiveSignals = new ArrayList<>();
  for (Signal s : activeSignals) {
    if (!s.update()) // Update the signal - then if the signal is inactive, prepare it for cull
      inactiveSignals.add(s);
  }
  activeSignals.removeAll(inactiveSignals); // cull
}
// Updates the bulding ticks
void updateBuildings() {
  for (ArrayList<Building> bList : worldBuildings.values()){
    for (Building b : bList){
      b.tick();
    }
  }
}
