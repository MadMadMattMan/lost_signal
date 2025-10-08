import java.util.HashSet;
import java.util.LinkedList;
// global variables
/// constants
public static final float fixedDeltaTime = 0.1f;
public static final ArrayList<BuildingType> defaultBuildingType = new ArrayList<>() {{add(BuildingType.test); add(BuildingType.mine); add(BuildingType.relay); add(BuildingType.lumber); add(BuildingType.storage); add(BuildingType.factory); add(BuildingType.bank);}};
public static final ArrayList<ResourceType> fuelResources = new ArrayList<>() {{add(ResourceType.coal); add(ResourceType.wood); add(ResourceType.leaves);}};

/// tracking
public static World gameWorld; // stores and deals with the environment data
public static ArrayList<Signal> activeSignals = new ArrayList<>(); // List storing every signal
public static HashMap<BuildingType, ArrayList<Building>> worldBuildings = new HashMap<>(); // Map storing every building mapped to to their type
public static Building theBank;
public static ArrayList<InfoPanel> openPanels = new ArrayList<>(); // List with every open panel
public static LinkedList<GlobalAlert> alertStack = new LinkedList<>();

public static BuildingType buildMode = BuildingType.none; // current build target

public static boolean isGameOn = true;
public static int stageNumber = 0;

/// Interference
public static float globalInterference = 0;
public static float globalMoney = 80;
public static float earnedAmount = 0;

// Called every frame
float lastUpdate = 0;

void draw() {
  //Resets scene
  background(0);
  
  if (isGameOn) {
    //updates - in order of rendering layer;
    image(gameWorld.getGroundMap(), 0, 0);
    gameWorld.render();
    updateBuildings(true);
    updateSignals();
    
    //one second update
    if ((millis() - lastUpdate) >= 1000) {
      lastUpdate = millis();
      updateBuildings(false);
      
      globalInterference = activeSignals.size()/7.5f;
      if (targets.get(stageNumber) < earnedAmount) {
        stageNumber++;
        alertStack.add(new GlobalAlert("Target reached\nNew buildings unlocked", 10));
      }
    }
    
    updateMouse();
    renderUI();
    GlobalAlert currentAlert = alertStack.peek();
    if (currentAlert != null)
      currentAlert.render();
  } 
}

// Called once at the start of the game
void setup() {
  // Processing setup
  //fullScreen();
  size(1980, 1080);
  //size(1000, 500);
  frameRate(60);
  background(255);
  text("Generating Map", 0, 0, width, height);  
  
  // 0 frame
  collectImages();
  
  // Game setup
  newGame();
}

// Clears old game data and makes a new game
void newGame() {
  gameWorld = new World();
  activeSignals.clear();
  worldBuildings.clear();
  
  initializeGround();
  
  float x = random(50, width-50);
  float y = height-50;
  theBank = addBuilding(new PVector(x, y), BuildingType.bank);
  
  alertStack.add(new GlobalAlert("New Game Started", 6));
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
void updateBuildings(boolean tickFrame) {
  for (ArrayList<Building> bList : worldBuildings.values()){
    for (Building b : bList){
      if (tickFrame)
        b.tickFrame();
      else
        b.tickSecond();
    }
  }
}
