float leftUIXOffset = 0;
void renderUI() {
  
  if (buildingMenu!=null) buildingMenu.render();
  
  // Corner displays
  textSize(30);
  textAlign(LEFT);
  fill(0);
  text("Interference " + globalInterference, 10 + leftUIXOffset, 35);
  text("Money $" + formatDp(globalMoney), 10 + leftUIXOffset, 65);
  text("'TAB' for build menu", 10 + leftUIXOffset, height - 10);
  textAlign(RIGHT);
  text("Stage " + stageNumber, width-10, 35);
  text("Goal:\nEarn $" + targets.get(stageNumber), width-10, 65);
  textSize(20);
  text("$" + formatDp(earnedAmount) + "/$" + targets.get(stageNumber), width-10, 125);
  
  // bottom info
  if (buildMode != null && buildMode != BuildingType.none) {
    textSize(30);
    textAlign(CENTER);
    text("Builidng " + buildMode, width/2, height - 15);
  }
}

UIPanel buildingMenu = null;

class UIPanel {
  UIType type;
  
  HashMap<ButtonAction, Button> buttons = new HashMap<>();
  float buttonSize = 100, buttonSpacing = 90, buttonStep = buttonSize+buttonSpacing;
  
  PVector topLeft = new PVector(5, 5), bottomRight = new PVector(250, height-5), center = new PVector((topLeft.x + bottomRight.x)/2, ((topLeft.y + bottomRight.y)/2)); 
  PVector buttonPosDefault = new PVector(center.copy().x - buttonSize/2, topLeft.y + 120), buttonPos = buttonPosDefault.copy();
  ArrayList<Collider> colliders = new ArrayList<>();
  
  float animationTime = 1f;
  
  UIPanel(UIType type){
    this.type = type;
    setupUI();
    initalizePanel(true);
  }

  void setupUI() {
    buttons.put(ButtonAction.a, new Button(this, ButtonAction.a));
    buttons.put(ButtonAction.b, new Button(this, ButtonAction.b));
    buttons.put(ButtonAction.c, new Button(this, ButtonAction.c));
    buttons.put(ButtonAction.d, new Button(this, ButtonAction.d));
    buttons.put(ButtonAction.e, new Button(this, ButtonAction.e));
  }
  
  void initalizePanel(boolean state) {
    if (state) { // setup
      PVector buttonAltPos = buttonPos.copy().add(new PVector(buttonSize, buttonSize));
      colliders.add(gameWorld.createCollider(buttonPos.copy(), buttonAltPos.copy(), buttons.get(ButtonAction.a)));
      buttonPos.y+=buttonStep; buttonAltPos.y+=buttonStep;
      colliders.add(gameWorld.createCollider(buttonPos.copy(), buttonAltPos.copy(), buttons.get(ButtonAction.b)));
      buttonPos.y+=buttonStep; buttonAltPos.y+=buttonStep;
      colliders.add(gameWorld.createCollider(buttonPos.copy(), buttonAltPos.copy(), buttons.get(ButtonAction.c)));   
      buttonPos.y+=buttonStep; buttonAltPos.y+=buttonStep;
      colliders.add(gameWorld.createCollider(buttonPos.copy(), buttonAltPos.copy(), buttons.get(ButtonAction.d)));  
      buttonPos.y+=buttonStep; buttonAltPos.y+=buttonStep;
      colliders.add(gameWorld.createCollider(buttonPos.copy(), buttonAltPos.copy(), buttons.get(ButtonAction.e)));
      buttonPos.y+=buttonStep; buttonAltPos.y+=buttonStep;
      buttonPos = buttonPosDefault.copy();
      
      if (type == UIType.buildings) leftUIXOffset += bottomRight.x;
    }
    else { // destroy
      if (type == UIType.buildings) leftUIXOffset -= bottomRight.x;
    
      for (Collider c : colliders)
        gameWorld.removeCollider(c);
      colliders.clear();
    }
  }
  
  void clickEvent(ButtonAction action) {
    switch (action) {
      case a: buildMode = BuildingType.mine; break;
      case b: buildMode = BuildingType.lumber; break;
      case c: buildMode = BuildingType.relay; break;
      case d: buildMode = BuildingType.storage; break;
      case e: 
      if (stageNumber > 1) 
        buildMode = BuildingType.factory; 
      else
        alertStack.add(new GlobalAlert("Need to be on stage 2\nto use the factory", 4));
      break;
      default: println("invalid uiButton pressed");
    }
  }
  
  void render() {
    if (type == UIType.buildings) {  
      rectMode(CORNERS);
      fill(200);
      rect(topLeft.x, topLeft.y, bottomRight.x, bottomRight.y);
      
      textAlign(CENTER);
      fill(0);
      textSize(60);
      text("Buildings", center.x, topLeft.y+70);
      textSize(25);
      float imageY = buttonPos.copy().y;
      imageMode(CORNER);
      image(mineIcon, buttonPos.copy().x, imageY, buttonSize, buttonSize);
      text("mine: $" + buildingCosts.get(BuildingType.mine), center.copy().x, imageY);
      text("gathers resources\nfrom rock", center.copy().x, imageY + buttonSize + 15);
      image(lumberIcon, buttonPos.copy().x, imageY+=buttonStep, buttonSize, buttonSize);
      text("lumber: $" + buildingCosts.get(BuildingType.lumber), center.copy().x, imageY);
      text("gathers resources\nfrom greenland", center.copy().x, imageY + buttonSize + 15);
      image(relayIcon, buttonPos.copy().x, imageY+=buttonStep, buttonSize, buttonSize);
      text("relay: $" + buildingCosts.get(BuildingType.relay), center.copy().x, imageY);
      text("extends a signals\ntravel", center.copy().x, imageY + buttonSize + 15);
      image(storageIcon, buttonPos.copy().x, imageY+=buttonStep, buttonSize, buttonSize);
      text("storage: $" + buildingCosts.get(BuildingType.storage), center.copy().x, imageY);
      text("stores resources", center.copy().x, imageY + buttonSize + 15);
      image(factoryIcon, buttonPos.copy().x, imageY+=buttonStep, buttonSize, buttonSize);
      if (stageNumber < 2) {textSize(50); fill(255, 0, 0); text("Stage 2", center.copy().x, imageY+buttonSize/2+25); textSize(25); fill(0);}
      text("factory: $" + buildingCosts.get(BuildingType.factory), center.copy().x, imageY);
      text("combines resources\ninto better ones", center.copy().x, imageY + buttonSize + 15);
    }
  }
}
