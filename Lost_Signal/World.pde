class World { // The main class that acts as the game world - contains global variables and methods
  // Cells
  public int cellDimension = 20;
  PVector cellStep;
  
  // Stored Maps
  /// Map with the cell pos as a string and the index - used for reducing calculations
  public HashMap<String, Integer> cellIndices = new HashMap<>(); //Store position vectors as a string to allow direct comparison
  /// Map storing every collider in the world mapped to their index number for easy getting
  public HashMap<Integer, ArrayList<Collider>> worldColliders = new HashMap<>();
  
  // Ground data
  PImage groundMap;
  
  // World settings
  boolean worldBoarderColliders = true;
  int worldBoarderWidth = 10;

  // Debugging
  boolean doDebugRendering = true;
  boolean doRenderCells = true;
  boolean doColliderRendering = true;


  // Main working methods
  /// Constructor, acting as the setup method
  public World() {
    gameWorld = this;
    setupCells(); 
    if (worldBoarderColliders) setupBoarders();
  }

  /// Calls renderers based on settings
  void render() {
    if (doRenderCells) renderCells();
    if (doColliderRendering) renderColliders();
  }


  // Cell methods
  public PVector getCellStep() {
    return cellStep;
  }
  
  ///Gets an index that the current posVector is in
  public int findCellIndex(PVector pos) {
    //Converts pVector into position data - int cast gets rounds down
    int col = (int)(pos.x / cellStep.x);
    int row = (int)(pos.y / cellStep.y);
    String cellPos = row + "," + col;

    Integer index = cellIndices.get(cellPos);
    if (index == null) return -1; // Safe fallback
    return index;
  }
  
  // Collision Methods
  boolean offScreen(PVector pos) {
    return (pos.x < 0 || pos.x > width || pos.y < 0 || pos.y > height);
  }
  
  /// Finds if inputed pos overlaps with a collider and they share a layer
  public ArrayList<CollisionData> checkCollision(PVector pos, float radius, Building origin, ArrayList<BuildingType> targetBuildings) {
    ArrayList<CollisionData> collisionResults = new ArrayList<>();
    int cellIndex = findCellIndex(pos);
    if (cellIndex == -1) {
      collisionResults.add(new CollisionData(true));
      return collisionResults;
    }   
    
    // Only checks colliders inside the cell of the object - saves performance from checking every collider
    if (worldColliders.keySet().contains(cellIndex)) {
      for (Collider c : worldColliders.get(cellIndex)) { 
        CollisionData cData = c.isColliding(pos, radius, origin, targetBuildings);
        collisionResults.add(cData);
      }
    }
    return collisionResults;
  }
  
  /// creates a collider object and sorts and stores it
  Collider createCollider(PVector topLeft, PVector botRight, boolean isPhysicalCollider, Building building, ArrayList<BuildingType> buildingTypes) {
    // create collider object
    Collider newCollider = new Collider(topLeft, botRight, isPhysicalCollider, building, buildingTypes);
    
    // gets the indecies and stores the collider in every needed index 
    ArrayList<Integer> index = newCollider.getColliderIndecies();
    for (int i : index) {
      // creates a new entry(index, collider list) if one doesn't exist
      if (!worldColliders.keySet().contains(i)) 
        worldColliders.put(i, new ArrayList<Collider>());
      
      worldColliders.get(i).add(newCollider);
    }
    
    return newCollider;
  }
  /// creates a 11collider object and sorts and stores it
  Collider createCollider(PVector topLeft, PVector botRight, boolean isPhysicalCollider) {
    // create collider object
    Collider newCollider = new Collider(topLeft, botRight, isPhysicalCollider);
    
    // gets the indecies and stores the collider in every needed index 
    ArrayList<Integer> index = newCollider.getColliderIndecies();
    for (int i : index) {
      // creates a new entry(index, collider list) if one doesn't exist
      if (!worldColliders.keySet().contains(i)) 
        worldColliders.put(i, new ArrayList<Collider>());
      
      worldColliders.get(i).add(newCollider);
    }
    
    return newCollider;
  }

  
  // Rendering Methods
  /// debug render method for drawing world colliders
  void renderColliders() {
    for (int i : worldColliders.keySet()) {
      for (Collider c : worldColliders.get(i)) { 
        c.render();
      }
    }
  }
  
  /// debug render method for drawing cell grid
  void renderCells() {
    strokeWeight(1);
    stroke(0, 255, 0);

    for (int i = (int)cellStep.x; i <= width; i += cellStep.x) {
      line(i, 0, i, height);
    }
    for (int j = (int)cellStep.y; j <= height; j += cellStep.y) {
      line(0, j, width, j);
    }
  }
  
  
  // Setup Methods
  /// Break the screen into cells defined by settings
  void setupCells() {
    //Initialize the cell step with x and y variance based on screen dimentions
    cellStep = new PVector((float)width / cellDimension, (float)height / cellDimension); 
    
    // Break the screen into the different cells and assign a index
    for (int row = 0; row < cellDimension; row++) {
      for (int col = 0; col < cellDimension; col++) {
        String pos = row + "," + col;
        int index = row * cellDimension + col;
        cellIndices.put(pos, index);
      }
    }
  }

  /// Defines the world boundary colliders
  void setupBoarders() {
    // top
    PVector tl = new PVector(0, bAdj(0, true));
    PVector tr = new PVector(width, bAdj(0, false));
    createCollider(tl, tr, true);
    // bottom
    PVector bl = new PVector(0, bAdj(height, true));
    PVector br = new PVector(width, bAdj(height, false));
    createCollider(bl, br, true);
    // left
    PVector lt = new PVector(bAdj(0, true), 0);
    PVector lb = new PVector(bAdj(0, false), height);
    createCollider(lt, lb, true);
    // right
    PVector rt = new PVector(bAdj(width, true), 0);
    PVector rb = new PVector(bAdj(width, false), height);
    createCollider(rt, rb, true);
  }
  
  int bAdj(float o, boolean add) {
    if (add)
      return (int)(o + worldBoarderWidth/2);
    return (int)(o - worldBoarderWidth/2);
  }
  
  PImage getGroundMap() {return groundMap.copy();}
  void setGroundMap(PImage newGroundMap) {groundMap = newGroundMap.copy();}
  float getGroundMapValueAt(PVector pos) {return noise(pos.x, pos.y);}
  int getGroundZoneAt(PVector pos) {
    int pixel = (int)(pos.x + (pos.y * width));
    color c = groundMap.copy().pixels[pixel];
    
    return -1;
  }
}
