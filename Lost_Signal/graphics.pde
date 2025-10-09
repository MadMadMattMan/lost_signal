// Image gathering
PImage mineIcon, relayIcon, factoryIcon, lumberIcon, storageIcon, bankIcon;
PImage xIcon, toggleIcon, nextIcon, expandIcon, checkboxIcon, checkedboxIcon, highlightedCheckedboxIcon;
PImage tutorialIntro, tutorialBuildings, tutorialCrafting;
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
  expandIcon = loadImage("assets/ui/expand.png");
  
  checkboxIcon = loadImage("assets/ui/checkbox.png");
  checkedboxIcon = loadImage("assets/ui/checkedbox.png");
  highlightedCheckedboxIcon = loadImage("assets/ui/highlightedcheckedbox.png");
  
  tutorialIntro = loadImage("assets/tutorial/intro.png");
  tutorialBuildings = loadImage("assets/tutorial/buildings.png");
  tutorialCrafting = loadImage("assets/tutorial/crafting.png");
}


// Building info screen
class InfoPanel {
  HashMap<ButtonAction, Button> buttons = new HashMap<>();
  ArrayList<Collider> colliders = new ArrayList<>();
  InfoPanel infoPanel, expandedPanel;
  
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
  
  ResourceType input1, input2, selected;
  float input1Count, input2Count;
  float fuelValue;
  
  
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
    this.input1 = bData.input1;
    this.input1Count = bData.input1Count;
    this.input2Count = bData.input2Count;
    this.input2 = bData.input2;
    this.fuelValue = bData.fuelValue;
    
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
    buttons.put(ButtonAction.expand, new Button(this, ButtonAction.expand));
    
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
  InfoPanel(PVector pos, boolean leftSide, ResourceType input1, ResourceType input2, InfoPanel parent) {
    // Setup
    this.leftSide = leftSide;
    this.input1 = input1;
    this.input2 = input2;
    this.selected = input1;
    if (leftSide) {
      topLeft = new PVector(pos.x - xySize.x - offset, pos.y);
      bottomRight = new PVector(topLeft.x + xySize.x, topLeft.y + xySize.y);
      center = new PVector(topLeft.x + xySize.x/2, topLeft.y + xySize.y/2);
    }
    else {
      topLeft = new PVector(pos.x + xySize.x + offset, pos.y);
      bottomRight = new PVector(topLeft.x + xySize.x, topLeft.y + xySize.y);
      center = new PVector(topLeft.x + xySize.x/2, topLeft.y + xySize.y/2);
    }
    
    buttons.put(ButtonAction.a, new Button(this, ButtonAction.a));
    buttons.put(ButtonAction.b, new Button(this, ButtonAction.b));
    buttons.put(ButtonAction.c, new Button(this, ButtonAction.c));
    buttons.put(ButtonAction.d, new Button(this, ButtonAction.d));
    buttons.put(ButtonAction.e, new Button(this, ButtonAction.e));
    buttons.put(ButtonAction.f, new Button(this, ButtonAction.f));
    
    infoPanel = parent;
    initialize(true);
  }
  
  void gathererPanel(BuildingData bData) {
    this.resource = bData.selectedOutput;
    this.prodRate = bData.productionRate;
  }
  
  public void clickEvent(ButtonAction action) {
    switch (action) {
      case destroy: initialize(false); gameWorld.removeBuilding(type, building); break;
      case toggle: building.toggleMode(); break;
      case next: infoPageNum++; if(infoPageNum>5)infoPageNum=0; break;
      case back: infoPageNum--; if(infoPageNum<0)infoPageNum=5; break;
      case expand: {
        if (expandedPanel==null)
          expandedPanel = new InfoPanel(topLeft, leftSide, input1, input2, this); 
        else {
          if (expandedPanel!=null) expandedPanel.initialize(false);
          expandedPanel=null; 
        }
        break;
      }
      
      case a: setSelected(ResourceType.coal); break;
      case b: setSelected(ResourceType.iron); break;
      case c: setSelected(ResourceType.copper); break;
      case d: setSelected(ResourceType.wood); break;
      case e: setSelected(ResourceType.leaves); break;
      case f: setSelected(ResourceType.sap); break;
      
      default: println("unknown InfoPanel button press");
    }
  }
  void setSelected(ResourceType target) {
    if (selected==null) {
      if (target==input1 || target==input2) {
        selected = target;
      }
    }
    else if ((target==input1 && selected==input1) || (target==input2 && selected == input2)){
      selected = null;
    }
    else if ((target==input1 && selected==input2) || (target==input2 && selected==input1)) {
      selected = target;
    }
    else if (selected==input1){
      input1 = target;
      selected = target; 
    }
    else if (selected==input2){
      input2 = target;
      selected = target; 
    }
    
    syncParent();
  }
  
  void initialize(boolean state) {
    if (state) { // setup
      if (type == null) {
        PVector buttonPos = new PVector(topLeft.x + 2, topLeft.y + 5);
        PVector buttonAltPos = buttonPos.copy().add(new PVector(15, 15));
        colliders.add(gameWorld.createCollider(buttonPos.copy(), buttonAltPos.copy(), buttons.get(ButtonAction.a)));
        buttonPos.y+=15; buttonAltPos.y+=15;
        colliders.add(gameWorld.createCollider(buttonPos.copy(), buttonAltPos.copy(), buttons.get(ButtonAction.b)));
        buttonPos.y+=15; buttonAltPos.y+=15;
        colliders.add(gameWorld.createCollider(buttonPos.copy(), buttonAltPos.copy(), buttons.get(ButtonAction.c)));   
        buttonPos.y+=15; buttonAltPos.y+=15;
        colliders.add(gameWorld.createCollider(buttonPos.copy(), buttonAltPos.copy(), buttons.get(ButtonAction.d)));  
        buttonPos.y+=15; buttonAltPos.y+=15;
        colliders.add(gameWorld.createCollider(buttonPos.copy(), buttonAltPos.copy(), buttons.get(ButtonAction.e)));
        buttonPos.y+=15; buttonAltPos.y+=15;
        colliders.add(gameWorld.createCollider(buttonPos.copy(), buttonAltPos.copy(), buttons.get(ButtonAction.f)));
      }
      else if (type == BuildingType.factory) {
        colliders.add(gameWorld.createCollider(destroyButtonPos.copy(), destroyButtonAlt.copy(), buttons.get(ButtonAction.destroy))); 
        colliders.add(gameWorld.createCollider(toggleButtonPos.copy(), toggleButtonAlt.copy(), buttons.get(ButtonAction.expand)));  
      }
      else if (type == BuildingType.bank){
        colliders.add(gameWorld.createCollider(destroyButtonPos.copy(), destroyButtonAlt.copy(), buttons.get(ButtonAction.next)));
        colliders.add(gameWorld.createCollider(toggleButtonPos.copy(), toggleButtonAlt.copy(), buttons.get(ButtonAction.back)));  
      }
      else {
        colliders.add(gameWorld.createCollider(destroyButtonPos.copy(), destroyButtonAlt.copy(), buttons.get(ButtonAction.destroy))); 
        colliders.add(gameWorld.createCollider(toggleButtonPos.copy(), toggleButtonAlt.copy(), buttons.get(ButtonAction.toggle)));
      }
    }
    else { // destroy
      buildingUI.remove(this);
      if (expandedPanel!=null) expandedPanel.initialize(false);
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
  void updateInfo(float newFuelValue, float input1, float input2) {
    this.fuelValue = newFuelValue;
    this.input1Count = input1;
    this.input2Count = input2;
  }
  
  
  public void render() {
    // Panel render
    stroke(0);
    strokeWeight(1);
    fill(200);
    rectMode(CORNER);
    rect(topLeft.x, topLeft.y, xySize.x, xySize.y);
    
    if (type != null) {
      // Title
      fill(0);
      float yOffset = titleSize;
      textSize(titleSize);
      textAlign(CENTER);
      text(titleText, center.x, topLeft.y + yOffset);
      
      if (type == BuildingType.factory) {
        fill(200, 50, 50);
        rect(destroyButtonPos.x, destroyButtonPos.y, destroyButtonSize, destroyButtonSize);
        image(xIcon, (int)(destroyButtonPos.x), (int)(destroyButtonPos.y), (int)destroyButtonSize, (int)destroyButtonSize);
        fill(150, 150, 150);
        rect(toggleButtonPos.x, toggleButtonPos.y, toggleButtonSize, toggleButtonSize);
        image(expandIcon, (int)(toggleButtonPos.x), (int)(toggleButtonPos.y), (int)destroyButtonSize, (int)toggleButtonSize);
        
        fill(0);
        textAlign(LEFT);
        textSize(13);
        text("Input 1:", textXOffset, topLeft.y + (yOffset+=13));
        text(input1+": "+ formatDp(2, input1Count), textXOffset, topLeft.y + (yOffset+=13));
        text("Input 2:", textXOffset, topLeft.y + (yOffset+=13));
        text(input2+": "+ formatDp(2, input2Count), textXOffset, topLeft.y + (yOffset+=13));
        text("Fuel:", textXOffset, topLeft.y + (yOffset+=13));
        text(formatDp(2, fuelValue), textXOffset, topLeft.y + (yOffset+=11));
        
        textAlign(RIGHT);
        textSize(12);
        text("Sell:", destroyButtonPos.x, destroyButtonAlt.y-13);
        text("$"+formatDp(2, sellPrice), destroyButtonPos.x, destroyButtonAlt.y-1);
        textAlign(LEFT);
      }
      else if (type != BuildingType.bank) {
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
            for (ResourceType resource : storage.keySet()) {
              textSize(15);
              String txt = resource.toString() + ": " + floor(storage.get(resource));
              float txtWidth = textWidth(txt) + 2;
              float maxX = 0f;
              if (yOffset+tSize > destroyButtonPos.y-16)
                maxX = xySize.x + 30;
              else
                maxX = xySize.x + 5;
              
              if (txtWidth > maxX) {
                float actualWidth = txtWidth;
                textSize(15 * (xySize.x / actualWidth));
              }
              
              text(txt, textXOffset, topLeft.y + (yOffset+=tSize));
            }
          }
        }        
        else {
          textSize(15);
          String txt = resource.toString() + ": " + formatDp(2, prodRate) + "/s";
          float txtWidth = textWidth(txt);
          if (txtWidth > xySize.x) {
            float actualWidth = txtWidth;
            textSize(15 * (xySize.x / actualWidth));
          }
          text(txt, textXOffset, topLeft.y + (yOffset+=15));
        }
        textAlign(RIGHT);
        textSize(12);
        text("Sell:", destroyButtonPos.x, destroyButtonAlt.y-13);
        text("$"+formatDp(2, sellPrice), destroyButtonPos.x, destroyButtonAlt.y-1);
      }
      else {
       image(nextIcon, (int)(destroyButtonPos.x), (int)(destroyButtonPos.y), (int)destroyButtonSize, (int)destroyButtonSize);
       copy(nextIcon, 0, 0, 100, 100, (int)(toggleButtonPos.x + toggleButtonSize), (int)(toggleButtonPos.y), -(int)toggleButtonSize, (int)toggleButtonSize);
       
       textSize(13);
       textAlign(CENTER);
       text("Send signals\nhere for sale", center.x, topLeft.y + (yOffset+=13));
       text(""+(int)(infoPageNum+1), center.x, bottomRight.y - 2);
       yOffset+=30;
       textAlign(LEFT);
       if (infoPageNum == 0)
         text(" Coal: $" + formatDp(2, resourceValue.get(ResourceType.coal)) + 
              "\n Copper: $" + formatDp(2, resourceValue.get(ResourceType.copper))+ 
              "\n Iron: $" + formatDp(2, resourceValue.get(ResourceType.iron))
              , topLeft.x, topLeft.y + yOffset);
       if (infoPageNum == 1)
         text(" Wood: $" + formatDp(2, resourceValue.get(ResourceType.wood)) +
              "\n Leaves: $" + formatDp(2, resourceValue.get(ResourceType.leaves)) + 
              "\n Sap: $" + formatDp(2, resourceValue.get(ResourceType.sap))
              , topLeft.x, topLeft.y + yOffset);
      else if (infoPageNum == 2) 
         text(" emag: $" + formatDp(2, resourceValue.get(ResourceType.wood)) +
              "\n conductor:\n $" + formatDp(2, resourceValue.get(ResourceType.leaves))
              , topLeft.x, topLeft.y + yOffset);
      else if (infoPageNum == 3)
         text(" planks: $" + formatDp(2, resourceValue.get(ResourceType.leaves)) +
              "\n charcoal:\n $" + formatDp(2, resourceValue.get(ResourceType.wood))
              , topLeft.x, topLeft.y + yOffset);
      else if (infoPageNum == 4)
         text(" lamp: $" + resourceValue.get(ResourceType.wood) +
              "\n curcuit:\n $" + resourceValue.get(ResourceType.leaves)              
              , topLeft.x, topLeft.y + yOffset);
      else if (infoPageNum == 5)
         text(" nails: $" + formatDp(2, resourceValue.get(ResourceType.sap)) + 
              "\n carbonFiber:\n $" + formatDp(2, resourceValue.get(ResourceType.sap))
              , topLeft.x, topLeft.y + yOffset);
      }
      
      
      if (expandedPanel != null) expandedPanel.render();
    }
    else { // the expanded panel
      textSize(15);
      fill(0);
      float yOffset = topLeft.y + 5;
      float xOffset = topLeft.x + 20;
      image(getCheckbox(ResourceType.coal), topLeft.x + 2, yOffset, 15, 15);
      text("Coal", xOffset, yOffset+=15);
      image(getCheckbox(ResourceType.iron), topLeft.x + 2, yOffset, 15, 15);
      text("Iron", xOffset, yOffset+=15);
      image(getCheckbox(ResourceType.copper), topLeft.x + 2, yOffset, 15, 15);
      text("Copper", xOffset, yOffset+=15);
      image(getCheckbox(ResourceType.wood), topLeft.x + 2, yOffset, 15, 15);
      text("Wood", xOffset, yOffset+=15);
      image(getCheckbox(ResourceType.leaves), topLeft.x + 2, yOffset, 15, 15);
      text("Leaves", xOffset, yOffset+=15);
      image(getCheckbox(ResourceType.sap), topLeft.x + 2, yOffset, 15, 15);
      text("Sap", xOffset, yOffset+=15);
      
      String output = "Out: "+craftResult(input1, input2);
      textSize(15);
      float txtWidth = textWidth(output)+1;
      if (txtWidth > xySize.x) {
        float actualWidth = txtWidth;
        textSize(15 * (xySize.x / actualWidth));
      }
      text(output, topLeft.x + 1, bottomRight.y - 5);
    }
  }
  
  PImage getCheckbox(ResourceType type) {
    if (input1==type||input2==type) {
      if (type==selected)
        return highlightedCheckedboxIcon;
      return checkedboxIcon;
    }
    return checkboxIcon;
  }
  
  void syncParent() {
    infoPanel.input1 = this.input1; 
    infoPanel.input2 = this.input2;
    infoPanel.selected = this.selected;
    infoPanel.building.setResource(input1, input2);
  }
}

void renderAlerts(boolean update) {
  GlobalAlert currentAlert = alertStack.peek();
  if (currentAlert != null)
    currentAlert.render(update);
}

class GlobalAlert {
  String message;
  float displayTime;
  boolean paused;
  
  float spawnTime = -1f;
  float time = 0;
  float pauseTime = 0;
  float transferTime = 0.5f;
  float upTime;
  float restY = height/9;
  float xPos = width/2;
  
  GlobalAlert(String msg, float dt) {
    this.message = msg;
    this.displayTime = dt;
   
    upTime = displayTime - transferTime;
  }
  
  void render(boolean update) {
    if (spawnTime==-1f) spawnTime = millis();
    if (!update && !paused) {
      pauseTime = millis();
      paused = true;
    }
    if (!update) {
      float dTime = (millis()-pauseTime);
      spawnTime+=dTime;
      pauseTime = millis();
    }
    if (update && paused)
      paused = false;
      
    time = (millis()-spawnTime)/1000;
    textSize(70);
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

String formatDp(int dp, float value) {
  float multi = pow(10, dp);
  float rounded = round(value*multi)/multi;
  if (rounded >= 10000)
    return "9999+";
  return ""+rounded;
}

// Ground map settings
int algorithmType = 0;
int resolution = 1;
int seed = -1;
int grid;

void initializeGround() {
  seed = round(random(0, 99999));
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
    
  println("\n\nGenerated map with the seed " + seed);
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
