// Called when a mouse click occurs
PVector clickLocation = new PVector();
Building clickBuilding;
PVector releaseLocation = new PVector();
Building releaseBuilding;

PVector aimDir = new PVector();

boolean lmDown = false;
boolean rmDown = false;
boolean validPlacement = true;

void mousePressed() {
  clickLocation.set(mouseX, mouseY);
  clickBuilding = clickBuilding(clickLocation);
    
  println("clicked on " + clickBuilding);
  if (mouseButton == LEFT) {
    lmDown = true;
  }
  if (mouseButton == RIGHT) {
    rmDown = true;
    println("rmDown = true");
  }
}
void updateMouse() {   
  if (rmDown && clickBuilding != null) {
    stroke(0,0, 255);
    strokeWeight(5);
    PVector startPos = clickBuilding.getBuildingPosition();
    aimDir = new PVector(mouseX - startPos.x, mouseY - startPos.y).normalize();
    line(startPos.x, startPos.y, startPos.x+aimDir.x*100, startPos.y+aimDir.y*100);
    
    PVector end = new PVector(startPos.x + aimDir.x * 100, startPos.y + aimDir.y * 100);
    line(startPos.x, startPos.y, end.x, end.y);
  }
  if (lmDown && buildMode != BuildingType.none) {
    validPlacement = checkPlacement(new PVector(mouseX, mouseY), new PVector(25,25));
    if (validPlacement)
      stroke(0, 255, 0);
    else
      stroke(255, 0, 0);
      
    noFill();
    rectMode(CENTER);
    square(mouseX, mouseY, 50);
    circle(mouseX, mouseY, 10);
  }
}

void mouseReleased() {
  releaseLocation.set(mouseX, mouseY);
  releaseBuilding = clickBuilding(releaseLocation);
  if (mouseButton == LEFT) {
    lmDown = false;
    if (validPlacement && buildMode != BuildingType.none) {
      addBuilding(releaseLocation.copy(), buildMode); // Only add if no building exists
      buildMode = BuildingType.none;
    }
    else if (!validPlacement && releaseBuilding != null)
      println("Release location already has a building\n");
    else if (!validPlacement)
      println("Release location too close to another collider\n");
  }


  if (mouseButton == RIGHT) {
    rmDown = false; 
    if (clickBuilding != null) {
      clickBuilding.setAim(aimDir.copy()); 
    }
  }
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
   
   println("current mode: " + buildMode);
}

Building clickBuilding(PVector location) {
  ArrayList<CollisionData> clickData = gameWorld.checkCollision(location.copy(), 1, null, defaultBuildingType); // persice click
  if (clickData.size() <= 0) {
    println("forgiving click");
    clickData = gameWorld.checkCollision(location.copy(), 25, null, defaultBuildingType); // forgiving click
  }
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
