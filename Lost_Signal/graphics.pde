// Image gathering
PImage mineIcon, relayIcon, factoryIcon, lumberIcon, storageIcon, bankIcon;
PImage xIcon, toggleIcon, nextIcon;
void collectImages() {
  mineIcon = loadImage("assets/buildings/mine.png"); 
  relayIcon = loadImage("assets/buildings/relay.png"); 
  factoryIcon = loadImage("assets/buildings/factory.png"); 
  lumberIcon = loadImage("assets/buildings/lumber.png"); 
  storageIcon = loadImage("assets/buildings/storage.png");
  bankIcon = loadImage("assets/buildings/bank.png");
  
  xIcon = loadImage("assets/ui/x.png");
  toggleIcon = loadImage("assets/ui/toggle.png");
  nextIcon = loadImage("assets/ui/next.png");
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
  boolean aimMode;
  HashMap<ResourceType, Float> storage;
  float sellPrice;
  
  boolean leftSide = true;
  PVector center = new PVector();
  PVector topLeft = new PVector();
  PVector bottomRight;
  PVector xySize = new PVector(80, 120);
  int offset = 5;
  
  float textXOffset;
  String titleText;
  float titleSize;
  
  float infoPageNum = 0;
  
  InfoPanel(BuildingData bData) {   
    this.building = bData.building;
    this.type = bData.type;
    
    PVector buildingPos = bData.pos;
    PVector buildingSize = bData.xySize;
    
    if (buildingPos.x < 200)
      leftSide = false;
    
    this.resource = bData.selectedOutput;
    this.prodRate = bData.productionRate;
    this.aimMode = bData.aimMode;
    this.storage = bData.storage;
    this.sellPrice = bData.sellPrice;
    
    if (leftSide) {
      topLeft = new PVector(buildingPos.x - buildingSize.x - xySize.x - offset, buildingPos.y + buildingSize.y - xySize.y);
      bottomRight = new PVector(topLeft.x + xySize.x, topLeft.y + xySize.y);
      center = new PVector(topLeft.x + xySize.x/2, topLeft.y + xySize.y/2);
    }
    else {
      topLeft = new PVector(buildingPos.x + buildingSize.x + offset, buildingPos.y + buildingSize.y - xySize.y);
      bottomRight = new PVector(topLeft.x + xySize.x, topLeft.y + xySize.y);
      center = new PVector(topLeft.x + xySize.x/2, topLeft.y + xySize.y/2);
    }
    
    buttons.put(ButtonAction.destroy, new Button(this, ButtonAction.destroy));
    buttons.put(ButtonAction.toggle, new Button(this, ButtonAction.toggle));
    buttons.put(ButtonAction.next, new Button(this, ButtonAction.next));
    buttons.put(ButtonAction.back, new Button(this, ButtonAction.back));
    
    destroyButtonPos = new PVector(bottomRight.x - destroyButtonSize, bottomRight.y - destroyButtonSize);
    destroyButtonAlt = bottomRight.copy();
    toggleButtonPos = new PVector(topLeft.x, bottomRight.y - toggleButtonSize);
    toggleButtonAlt = new PVector(topLeft.x + toggleButtonSize, bottomRight.y);
    
    textXOffset = topLeft.x + 2;
    titleText = type.toString();
    
    textSize(25); // Start with a base size
    float baseSize = 25;
    float maxWidth = xySize.x - 10; // Add some padding
    float actualWidth = textWidth(titleText);
    
    // Scale down if needed
    if (actualWidth > maxWidth) {
      titleSize = baseSize * (maxWidth / actualWidth);
    } 
    else
      titleSize = baseSize;
  }
  
  void gathererPanel(BuildingData bData) {
    this.resource = bData.selectedOutput;
    this.prodRate = bData.productionRate;
  }
  
  public void clickEvent(ButtonAction action) {
    switch (action) {
      case destroy: initialize(false); gameWorld.removeBuilding(type, building); break;
      case toggle: building.toggleMode(); break;
      case next: infoPageNum++; if(infoPageNum>1)infoPageNum=0; break;
      case back: infoPageNum--; if(infoPageNum<0)infoPageNum=1; break;
      default: println("unknown InfoPanel button press");
    }
  }
  
  void initialize(boolean state) {
    if (state) { // setup
      if (type != BuildingType.bank){
        colliders.add(gameWorld.createCollider(destroyButtonPos.copy(), destroyButtonAlt.copy(), buttons.get(ButtonAction.destroy))); 
        colliders.add(gameWorld.createCollider(toggleButtonPos.copy(), toggleButtonAlt.copy(), buttons.get(ButtonAction.toggle))); 
      }
      else {
        colliders.add(gameWorld.createCollider(destroyButtonPos.copy(), destroyButtonAlt.copy(), buttons.get(ButtonAction.next)));
        colliders.add(gameWorld.createCollider(toggleButtonPos.copy(), toggleButtonAlt.copy(), buttons.get(ButtonAction.back))); 
      }
    }
    else { // destroy
      for (Collider c : colliders) {
        gameWorld.removeCollider(c);
      }
      globalMoney += sellPrice;
      colliders.clear();
    }
  }
  
  void updateInfo(ResourceType newResource, float newProdRate) {
    resource = newResource;
    this.prodRate = newProdRate;
  }
  void updateInfo(boolean aimMode) {
    this.aimMode = aimMode; 
  }
  
  public void render() {
    // Panel render
    stroke(0);
    strokeWeight(1);
    fill(200);
    rectMode(CORNER);
    rect(topLeft.x, topLeft.y, xySize.x, xySize.y);
    
    // Title
    fill(0);
    float yOffset = titleSize;
    textSize(titleSize);
    textAlign(CENTER);
    text(titleText, center.x, topLeft.y + yOffset);
    
    if (type != BuildingType.bank) {
      fill(200, 50, 50);
      rect(destroyButtonPos.x, destroyButtonPos.y, destroyButtonSize, destroyButtonSize);
      image(xIcon, (int)(destroyButtonPos.x), (int)(destroyButtonPos.y), (int)destroyButtonSize, (int)destroyButtonSize);
      fill(150, 150, 150);
      rect(toggleButtonPos.x, toggleButtonPos.y, toggleButtonSize, toggleButtonSize);
      image(toggleIcon, (int)(toggleButtonPos.x), (int)(toggleButtonPos.y), (int)destroyButtonSize, (int)toggleButtonSize);
      
      //Text render
      fill(0);
      textSize(15);
      textAlign(LEFT);
      if (type == BuildingType.relay) {
        text("Aiming: ", textXOffset, topLeft.y + (yOffset+=15));
        text(""+aimMode, textXOffset, topLeft.y + (yOffset+=12));
      }
      else if (type == BuildingType.storage) {
        text("Stored: ", textXOffset, topLeft.y + (yOffset+=15));
        if (storage.keySet().size() < 1)
          text("Empty", textXOffset, topLeft.y + (yOffset+=12));
        else {
          int rows = storage.keySet().size();
          float tSize = 15;
          if (rows > 3)
            tSize = 60f/rows;
          textSize(tSize);
          for (ResourceType resource : storage.keySet())
            text(resource + ": " + floor(storage.get(resource)), textXOffset, topLeft.y + (yOffset+=tSize));
        }
      }
      else {
        textSize(15);
        String txt = resource.toString() + ": " + formatDp(prodRate) + "/s";
        float txtWidth = textWidth(txt);
        if (txtWidth > xySize.x) {
          float actualWidth = txtWidth;
          textSize(15 * (xySize.x / actualWidth));
        }
        text(txt, textXOffset, topLeft.y + (yOffset+=15));
      }
      textAlign(RIGHT);
      textSize(13);
      text("Sell:", destroyButtonAlt.x, destroyButtonPos.y-14);
      text("$"+formatDp(sellPrice), destroyButtonAlt.x, destroyButtonPos.y-1);
    }
    else {
     image(nextIcon, (int)(destroyButtonPos.x), (int)(destroyButtonPos.y), (int)destroyButtonSize, (int)destroyButtonSize);
     copy(nextIcon, 0, 0, 100, 100, (int)(toggleButtonPos.x + toggleButtonSize), (int)(toggleButtonPos.y), -(int)toggleButtonSize, (int)toggleButtonSize);
     
     textSize(13);
     textAlign(CENTER);
     text("Send signals\nhere for sale", center.x, topLeft.y + (yOffset+=13));
     yOffset+=30;
     textAlign(LEFT);
     if (infoPageNum == 0)
       text("Coal: $" + resourceValue.get(ResourceType.coal) + 
            "\nCopper: $" + resourceValue.get(ResourceType.copper) + 
            "\nIron: $" + resourceValue.get(ResourceType.iron)
            , topLeft.x, topLeft.y + yOffset);
     if (infoPageNum == 1)
       text("Wood: $" + resourceValue.get(ResourceType.wood) +
            "\nLeaves: $" + resourceValue.get(ResourceType.leaves) + 
            "\nSap: $" + resourceValue.get(ResourceType.sap)
            , topLeft.x, topLeft.y + yOffset);
    }
  }
}

class GlobalAlert {
  String message;
  float displayTime;
  
  float spawnTime;
  float time = 0;
  float transferTime = 2f;
  float upTime;
  float restY = height/10;
  float xPos = width/2;
  
  GlobalAlert(String msg, float dt) {
    this.message = msg;
    this.displayTime = dt;
    spawnTime = millis();
    upTime = displayTime - transferTime;
  }
  
  void render() {
    time = (millis()-spawnTime)/1000;
    textSize(50);
    fill(0);
    textAlign(CENTER);
    
    if (time < transferTime) {
      text(message, xPos, lerp(-100, restY, time/transferTime));
    }
    else if (time > upTime) {
      text(message, xPos, lerp(restY, -100, (time-upTime)/transferTime));
    }
    else
      text(message, xPos, restY);
      
    if (time > displayTime)
      alertStack.poll();
  }
}

String formatDp(float value) {
  float adjDollar = round(value*100)/100f; //1.1111111 -> 111 -> 1.11
  return ""+adjDollar;
}

void renderUI() {
  textSize(30);
  textAlign(LEFT);
  fill(0);
  text("Interference " + globalInterference, 10, 35);
  text("Money $" + formatDp(globalMoney), 10, 65);
  textAlign(RIGHT);
  text("Stage " + stageNumber, width-10, 35);
  text("Target:\nEarn " + targets.get(stageNumber), width-10, 65);
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
