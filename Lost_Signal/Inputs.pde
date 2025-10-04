// Called when a mouse click occurs
PVector clickLocation = new PVector();
Building clickBuilding;
PVector releaseLocation = new PVector();
Building releaseBuilding;
Button releaseButton;
PVector holdLocation = new PVector();

PVector aimDir = new PVector();

boolean lmDown = false;
boolean rmDown = false;

double startHoldTime = 0;
double holdTime = 0;

boolean validPlacement = false;

void mousePressed() {
  // gather click data
  clickLocation.set(mouseX, mouseY);
  clickBuilding = clickBuilding(clickLocation);
    
  if (mouseButton == LEFT) {
    lmDown = true;
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
    if (clickBuilding != null && holdTime > 200) { // right mouse is being held on a building & has held for more than .2s
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
    if (buildMode != BuildingType.none && holdTime > 200) { // building is selected for placing
      validPlacement = checkPlacement(new PVector(holdLocation.x, holdLocation.y), new PVector(25,25));
      if (validPlacement)
        stroke(0, 255, 0);
      else
        stroke(255, 0, 0);
        
      noFill();
      rectMode(CENTER);
      square(holdLocation.x, holdLocation.y, 50); // outline
      circle(holdLocation.x, holdLocation.y, 10); // resource pickup
    }
  }
}

void mouseReleased() {
  // gather click data
  releaseLocation.set(mouseX, mouseY);
  
  releaseButton = clickButton(releaseLocation);
  releaseBuilding = clickBuilding(releaseLocation);
  
  if (mouseButton == LEFT) { // released left
    lmDown = false;
    if (releaseButton != null) {
      releaseButton.click(); 
    }
    else if (validPlacement) { // validPlacement set if holding, so if building hold is released
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
      clickBuilding.setAim(aimDir.copy()); 
    }
  }
  
  holdTime = 0;
}


// Called when a key click occurs
void keyPressed() {
   if (key == '1') 
     buildMode = BuildingType.test;
   else if (key == '2') 
     buildMode = BuildingType.relay;
   else if (key == '3')
     buildMode = BuildingType.mine;
   else 
     buildMode = BuildingType.none; 
   
   println("\n\ncurrent mode: " + buildMode);
}

Button clickButton(PVector location) {
  ArrayList<CollisionData> clickData = gameWorld.checkCollision(location.copy(), 1, null, defaultBuildingType); // persice click
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
