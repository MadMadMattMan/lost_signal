// Image gathering
PImage mineIcon, relayIcon, factoryIcon;
PImage xIcon, toggleIcon;
void collectImages() {
  mineIcon = loadImage("assets/buildings/mine.png"); 
  relayIcon = loadImage("assets/buildings/relay.png"); 
  factoryIcon = loadImage("assets/buildings/factory.png"); 
  
  xIcon = loadImage("assets/ui/x.png");
  toggleIcon = loadImage("assets/ui/toggle.png");
}

// Building info screen
class InfoPanel {
  HashMap<ButtonAction, Button> buttons = new HashMap<>();
  ArrayList<Collider> colliders = new ArrayList<>();
  
  PVector destroyButtonPos, destroyButtonAlt;
  int destroyButtonSize = 20;
  PVector toggleButtonPos, toggleButtonAlt;
  int toggleButtonSize = 20;
  
  Building building;
  BuildingType type;
  boolean gatherer = false, relay = false;
  ResourceType resource;
  float prodRate;
  
  PVector topLeft = new PVector();
  PVector bottomRight;
  PVector xySize = new PVector(60, 100);
  int offset = 5;
  
  
  float textXOffset;
  
  InfoPanel(BuildingData bData) {
    this.building = bData.building;
    this.type = bData.type;
    
    PVector buildingPos = bData.pos;
    PVector buildingSize = bData.xySize;
    
    this.resource = bData.selectedOutput;
    this.prodRate = bData.productionRate;
    
    topLeft.x = buildingPos.x - buildingSize.x - xySize.x - offset;
    topLeft.y = buildingPos.y + buildingSize.y - xySize.y;
    bottomRight = new PVector(topLeft.x + xySize.x, topLeft.y + xySize.y);
    
    buttons.put(ButtonAction.destroy, new Button(this, ButtonAction.destroy));
    buttons.put(ButtonAction.toggle, new Button(this, ButtonAction.toggle));
    
    destroyButtonPos = new PVector(bottomRight.x - destroyButtonSize, bottomRight.y - destroyButtonSize);
    destroyButtonAlt = bottomRight.copy();
    toggleButtonPos = new PVector(topLeft.x, bottomRight.y - toggleButtonSize);
    toggleButtonAlt = new PVector(topLeft.x + toggleButtonSize, bottomRight.y);
    
    textXOffset = topLeft.x + 2;
  }
  /**
  void relayPanel(BuildingData bData) {
    this.resource = bData.selectedOutput;
  } */
  void gathererPanel(BuildingData bData) {
    this.resource = bData.selectedOutput;
    this.prodRate = bData.productionRate;
  }
  
  public void clickEvent(ButtonAction action) {
    switch (action) {
      case destroy: initialize(false); gameWorld.removeBuilding(type, building); break;
      case toggle: building.toggleMode(); break;
      default: println("unknown InfoPanel button press");
    }
  }
  
  void initialize(boolean state) {
    if (state) { // setup
      colliders.add(gameWorld.createCollider(destroyButtonPos.copy(), destroyButtonAlt.copy(), buttons.get(ButtonAction.destroy))); 
      colliders.add(gameWorld.createCollider(toggleButtonPos.copy(), toggleButtonAlt.copy(), buttons.get(ButtonAction.toggle))); 
    }
    else { // destroy
      for (Collider c : colliders) {
        gameWorld.removeCollider(c);
      }
      colliders.clear();
    }
  }
  
  public void render() {
    // Panel render
    stroke(0);
    strokeWeight(1);
    fill(200);
    rectMode(CORNER);
    rect(topLeft.x, topLeft.y, xySize.x, xySize.y);
    
    // Destroy render
    fill(200, 50, 50);
    rect(destroyButtonPos.x, destroyButtonPos.y, destroyButtonSize, destroyButtonSize);
    image(xIcon, (int)(destroyButtonPos.x), (int)(destroyButtonPos.y), (int)destroyButtonSize, (int)destroyButtonSize);
    rect(toggleButtonPos.x, toggleButtonPos.y, toggleButtonSize, toggleButtonSize);
    image(toggleIcon, (int)(toggleButtonPos.x), (int)(toggleButtonPos.y), (int)destroyButtonSize, (int)toggleButtonSize);
    
    //Text render
    ////textFont();
    fill(0);
    float yOffset = 0;
    textSize(yOffset+=15);
    text(type.toString(), textXOffset, topLeft.y + yOffset);
    textSize(12);
    if (type!=BuildingType.relay) text(resource.toString(), textXOffset, topLeft.y + (yOffset+=20));
    
    text(prodRate, textXOffset, topLeft.y + (yOffset+=14));
  }
}



// Ground map settings
int algorithmType = 0;
int resolution = 1;
int seed = -1;
int grid;

void initializeGround() {
  if (seed >= 0) // if there is a set seed
    noiseSeed(seed);
  
  // set up the biome map
  biomeColMap.put("rich forest", new PVector(29, 73, 23));
  biomeIndexMap.put("rich forest", 0);
  
  biomeColMap.put("forest", new PVector(49, 93, 43));
  biomeIndexMap.put("forest", 1);

  biomeColMap.put("dirt", new PVector(64,41,5));
  biomeIndexMap.put("dirt", 2);
  
  biomeColMap.put("ore", new PVector(78, 79, 85));
  biomeIndexMap.put("ore", 3);
  
  biomeColMap.put("rich ore", new PVector(88, 89, 115));
  biomeIndexMap.put("rich ore", 4);
    
  dim = gameWorld.cellDimension;
  w = width/dim;
  h = height/dim;
  
    
  noiseDetail(resolution);
  grid = gameWorld.cellDimension;
  if (algorithmType == 0) {
    gameWorld.setGroundMap(generatePerlinGround());
  }
  else {
    gameWorld.setGroundMap(generateGridGround());
  }
    
  println("\n\nGenerated map using " + algorithmType + " with the seed " + noise(0));
}

HashMap<String, PVector> biomeColMap = new HashMap<>();
HashMap<String, Integer> biomeIndexMap = new HashMap<>();

float bias = 0;
float noiseVal;
float noiseScale = 0.01;

int dim;
int w;
int h;

PImage generatePerlinGround() {
  PImage map = createImage(width, height, RGB);
  map.loadPixels();
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      noiseVal = noise(x * noiseScale, y * noiseScale)*2;
      color col = getColor(noiseVal, x, y);
      map.pixels[x + (y * width)] = col;
    }
  }
  map.updatePixels();
  return map;
}

PImage generateGridGround() {
  PImage map = createImage(width, height, RGB);
  map.loadPixels();
  
  
  
  for (int gx = 0; gx < dim; gx++){
    for (int gy = 0; gy < dim; gy++){
    noiseVal = noise(gx*w * noiseScale, gy*h * noiseScale);
      for (int y = gy*h; y < (gy+1)*h; y++) {
        for (int x = gx*w; x < (gx+1)*w; x++) {
          color col = getColor(noiseVal, gx, gy);
          map.pixels[x + (y * width)] = col;
        }
      }
    }
  }
  map.updatePixels();
  return map;
}

float getNoiseAt(PVector pos) {
  return noise(pos.x * noiseScale, pos.y * noiseScale) * 2;
}

color getColor(float value, int x, int y) {
  String biome = getBiome(value);
  PVector colorVal = biomeColMap.get(biome);
  float variance = value * random(8, 15);
  float shadow = map(x + y, 0, width + height, 0.9, 1.5);
  
  return color(
    constrain((colorVal.x + variance) * shadow, 0, 255),
    constrain((colorVal.y + variance) * shadow, 0, 255),
    constrain((colorVal.z + variance) * shadow, 0, 255));
}

String getBiome(float value){
  if (value < 0.1f)      return "rich forest";
  else if (value < 0.3f) return "forest";
  else if (value < 0.6f) return "dirt";
  else if (value < 0.9f) return "ore";
  else                   return "rich ore";
}

int getBiomePenalty(float value, String desired) {
  String biome = getBiome(value);
  int biomeIndex = biomeIndexMap.get(biome);
  int desiredIndex = biomeIndexMap.get(desired);
  
  return max(biomeIndex, desiredIndex) - min(biomeIndex, desiredIndex);
  
}
