//Global Var
public static World gameWorld; // stores and deals with the environment data
                 /// colliders -

//Local Var
ArrayList<Signal> activeSignals = new ArrayList<>();
ArrayList<Integer> defaultLayers = new ArrayList<>() {{add(0);}};

// Called every frame
void draw() {
  //Resets scene
  background(255);
  frameRate(60);
  updateSignals();
  
  gameWorld.render();
}

// Called when a mouse click occurs
void mouseClicked() {
  PVector clickLocation = new PVector(mouseX, mouseY);
  gameWorld.addBuilding(clickLocation, BuildingType.mine);
}

// Called once at the start of the game
void setup() {
  // Processing setup
  size(1000, 750);
  
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
