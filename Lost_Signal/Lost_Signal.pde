import java.util.HashSet;
import java.util.LinkedList;
import java.util.Map.*;
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
public static ArrayList<InfoPanel> buildingUI = new ArrayList<>();

public static BuildingType buildMode = BuildingType.none; // current build target

public static boolean isGameOn = false;
public static boolean isGamePaused = false;
static boolean firstPauseFrame = true;
public static int stageNumber = 1;

/// Interference
public static float globalInterference = 0;
public static float globalMoney = 125;
public static float earnedAmount = 0;
public static float spentAmount = 0;

// Called every frame
float lastUpdate = 0;
UIPanel pauseMainMenu;
UIPanel tutorial;
int tutPage = 0;

void draw() {
  //Resets scene
  background(0);
  
  if (isGameOn) {
    if (!firstPauseFrame) firstPauseFrame = true;
    
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
        if (stageNumber == 2) {alertStack.add(new GlobalAlert("Target reached\nNew buildings unlocked", 4)); globalMoney+=50;}
        else if (stageNumber == 5) alertStack.add(new GlobalAlert("Quota complete\nyou win!", 4));
        else {alertStack.add(new GlobalAlert("Target reached\nnew target " + targets.get(stageNumber), 4)); globalMoney+=(200*stageNumber);}
      }
    }
    
    updateMouse();
    renderBuildingUI();
    renderGameUI();
    renderAlerts(true);
  }
  else if (tutorial == null) { // game paused
    PVector buttonSize = new PVector(width/8, height/10);
    PVector buttonTL = new PVector(width/2 - buttonSize.x, height * (5f/10));
    PVector buttonBR = new PVector(width/2 + buttonSize.x, buttonTL.copy().y+buttonSize.y);
    
    if (isGamePaused) {
      if (firstPauseFrame) {pauseMainMenu = new UIPanel(3); firstPauseFrame = false;}
      // render paused game
      image(gameWorld.getGroundMap(), 0, 0);
            
      gameWorld.render();
      renderBuildings();
      renderSignals();
      
      
      renderGameUI();
      renderAlerts(false);
      
      // blackout mask
      fill(0, 0, 0, 100); rectMode(CORNERS); rect(0, 0, width, height);
      
      // render continue buttons
      rectMode(CORNERS); fill(100); textAlign(CENTER); 
      rect(buttonTL.x, buttonTL.y+=(buttonSize.y+10), buttonBR.x, buttonBR.y+=(buttonSize.y+10));
      fill(0); textSize(70);
      text("CONTINUE", width/2, buttonBR.y-25);
      
    }
    if (firstPauseFrame) {pauseMainMenu = new UIPanel(2); firstPauseFrame = false;}
    pauseMainMenu.render();
    fill(200); textSize(200); textAlign(CENTER);
    text("LOST SIGNAL", width/2, 300);
    
    // menu
    rectMode(CORNERS); textAlign(CENTER);
    fill(100); textSize(70);
    rect(buttonTL.x, buttonTL.y+=(buttonSize.y+10), buttonBR.x, buttonBR.y+=(buttonSize.y+10));
    fill(0);
    text("NEW GAME", width/2, buttonBR.y-25);
    fill(100);
    rect(buttonTL.x, buttonTL.y+=(buttonSize.y+10), buttonBR.x, buttonBR.y+=(buttonSize.y+10));
    fill(0);
    text("EXIT", width/2, buttonBR.y-25);
  }
  else { // tutorial    
  
    if (tutPage == 0)
      image(tutorialIntro, 0, 0, width, height);
    else if (tutPage == 1)
      image(tutorialBuildings, 0, 0, width, height);
    else if (tutPage == 2)
      image(tutorialCrafting, 0, 0, width, height);
    else if (tutPage == 3) {
      toggleTutorial(false);
      return;  
    }
    tutorial.render();
  }
}

// Called once at the start of the game
void setup() {
  // Processing setup
  //fullScreen();
  size(1980, 1080);
  //size(1980/2, 1080/2);
  frameRate(60);
  background(255);
  resetCosts();

  // 0 frame
  collectImages();
  
  // Game setup
  newGame();
}

// Clears old game data and makes a new game
void newGame() {
  gameWorld = new World();

  resetCosts(); 
  activeSignals.clear();
  worldBuildings.clear();
  alertStack.clear();
  isGameOn = false;
  isGamePaused = false;
  firstPauseFrame = true;
  stageNumber = 1;
  globalInterference = 0;
  globalMoney = 125;
  earnedAmount = 0;
  spentAmount = 0;
  
  initializeGround();
  text("Generating Map", 0, 0, width, height);  
  
  float x = random((width/2)-500, (width/2)+500);
  float y = height-50;
  theBank = addBuilding(new PVector(x, y), BuildingType.bank);
  
  alertStack.add(new GlobalAlert("New Game Started", 4));
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
// renders the buildingUI
void renderBuildingUI() {
  for (InfoPanel p : buildingUI){
    p.render();
  }
}
// renders buildings wihtout updating
void renderBuildings() {
  for (ArrayList<Building> bList : worldBuildings.values()){
    for (Building b : bList)
        b.render();
  }
}
// renders signals without updating
void renderSignals() {
  for (Signal s : activeSignals)
      s.render();
}
