// Called when a mouse click occurs
PVector clickLocation = new PVector();
Building clickBuilding;
Button clickButton;

PVector releaseLocation = new PVector();
Building releaseBuilding;

PVector holdLocation = new PVector();

PVector aimDir = new PVector();

boolean lmDown = false;
boolean rmDown = false;

double startHoldTime = 0;
double holdTime = 0;
double holdMargin = 100;

boolean validPlacement = false;

void mousePressed() {
  // gather click data
  clickLocation.set(mouseX, mouseY);
  clickBuilding = clickBuilding(clickLocation);
  clickButton = clickButton(clickLocation);
    
  if (mouseButton == LEFT) {
    lmDown = true;
    if (clickButton != null) {
      clickButton.click(); 
    }
  }
  if (mouseButton == RIGHT) {
    rmDown = true;
  }
  
  startHoldTime = millis(); // start hold timer
}
void updateMouse() {
  holdLocation.set(mouseX, mouseY);
  
  if (rmDown) { // right mouse is held down
    holdTime = millis() - startHoldTime;
    if (clickBuilding != null && holdTime > holdMargin && clickBuilding != theBank) { // right mouse is being held on a building & has held for more than .05s
      stroke(0,0, 255);
      strokeWeight(5);
      PVector startPos = clickBuilding.getBuildingPosition();
      aimDir = new PVector(holdLocation.x - startPos.x, holdLocation.y - startPos.y).normalize();
      line(startPos.x, startPos.y, startPos.x+aimDir.x*100, startPos.y+aimDir.y*100);
      
      PVector end = new PVector(startPos.x + aimDir.x * 100, startPos.y + aimDir.y * 100);
      line(startPos.x, startPos.y, end.x, end.y);
    }
  }
  if (lmDown) { // left mouse is held down
    holdTime = millis() - startHoldTime;
    if (buildMode != BuildingType.none && holdTime > holdMargin) { // building is selected for placing
      int buildCost = floor(buildingCosts.get(buildMode));
      validPlacement = (checkPlacement(new PVector(holdLocation.x, holdLocation.y), new PVector(25,25)) && buildCost <= globalMoney);
      placingGraphic(buildCost);
    }
  }
}

void mouseReleased() {
  // gather click data
  releaseLocation.set(mouseX, mouseY);
  releaseBuilding = clickBuilding(releaseLocation);
  
  if (mouseButton == LEFT) { // released left
    lmDown = false;
    if (validPlacement) { // validPlacement set if holding, so if building hold is released
      addBuilding(releaseLocation.copy(), buildMode);
      buildMode = BuildingType.none; // reset
      validPlacement = false;
    }
    else if (releaseBuilding != null) { // clicked on a building
      releaseBuilding.toggleInfo();
    }
  }

  if (mouseButton == RIGHT) {
    rmDown = false; 
    if (clickBuilding != null) {
      if (aimDir.x == 0 && aimDir.y == 0) {aimDir = new PVector(1, 0);}
      clickBuilding.setAim(aimDir.copy()); 
    }
  }
  
  holdTime = 0;
}


// Called when a key click occurs
void keyPressed() {
  if (key == ' ' && (isGameOn || isGamePaused)) {
     isGameOn = !isGameOn;
     isGamePaused = true;
     if (isGameOn && tutorial == null) {
       pauseMainMenu.initalize(false); 
       pauseMainMenu = null;
     }
   }
   if (isGameOn) {
     if (key == '1') 
       buildMode = BuildingType.mine;
     else if (key == '2') 
       buildMode = BuildingType.lumber;
     else if (key == '3')
       buildMode = BuildingType.relay;
     else if (key == '4')
       buildMode = BuildingType.storage;
     else if (key == '5') { 
     if (stageNumber > 1) 
        buildMode = BuildingType.factory; 
      else
        alertStack.add(new GlobalAlert("Need to be on stage 2\nto use the factory", 3));
      }
     else if (key == 'p')
       globalMoney+=100;
     else if (key == TAB) {
       if (buildingMenu == null) 
         buildingMenu = new UIPanel(UIType.buildings); 
       else {
         buildingMenu.initalize(false);
         buildingMenu = null; 
       }
     }
   }
   
       
   else 
     buildMode = BuildingType.none; 
   
   println("\n\ncurrent mode: " + buildMode);
}

Button clickButton(PVector location) {
  ArrayList<CollisionData> clickData = gameWorld.checkCollision(location.copy(), 1, null, defaultBuildingType);
  Button clickButton = null;
  for (CollisionData cData : clickData) {
    clickButton = cData.button;
    if (clickButton != null)
      return clickButton;
  }
  return null;
}

Building clickBuilding(PVector location) {
  ArrayList<CollisionData> clickData = gameWorld.checkCollision(location.copy(), 1, null, defaultBuildingType);
  Building clickBuilding = null;
  for (CollisionData cData : clickData) {
    clickBuilding = cData.building;
    if (clickBuilding != null)
      return clickBuilding;
  }
  return null;
}

void placingGraphic(int buildCost) {
  color uiColor;
  if (validPlacement) 
    uiColor = color(0, 255, 0);    
  else 
    uiColor = color(255, 0, 0);
  
  stroke(uiColor);
  strokeWeight(2);
  noFill();
  rectMode(CENTER);
  square(holdLocation.x, holdLocation.y, 50); // outline
  circle(holdLocation.x, holdLocation.y, 10); // resource pickup
  fill(uiColor);
  textSize(20);
  textAlign(CENTER);
  text("Placing " + buildMode.toString(), holdLocation.x, holdLocation.y - 30);
  text("Cost $" + formatDp(2, buildCost), holdLocation.x, holdLocation.y + 50);
  stroke(0);
  }
  
boolean checkPlacement(PVector location, PVector size) {
  // check all corner collisions
  ArrayList<CollisionData> collisions = new ArrayList<>();
  for (int i = 0; i < 4; i++) {
    collisions.addAll(gameWorld.checkCollision(cornerOffset(location, size, i), 2, null, defaultBuildingType));
  }
  for (CollisionData c : collisions) {
      if (c.collisionResult || c.invalidCollision)
        return false;
    }
  return true; // true if no collisions
}
