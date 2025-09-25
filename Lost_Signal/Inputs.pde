// Called when a mouse click occurs
PVector clickLocation = new PVector();
Building clickBuilding;
PVector releaseLocation = new PVector();
Building releaseBuilding;

PVector aimDir = new PVector();

boolean lmDown = false;
boolean rmDown = false;

void mousePressed() {
  clickLocation.set(mouseX, mouseY);
  ArrayList<CollisionData> clickData = gameWorld.checkCollision(clickLocation.copy(), 5, null, defaultBuildingType);
  clickBuilding = (clickData.size() > 0) ? clickData.get(0).building : null;
    
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
  }
}

void mouseReleased() {
   releaseLocation.set(mouseX, mouseY);
  ArrayList<CollisionData> clickData = gameWorld.checkCollision(releaseLocation.copy(), 5, null, defaultBuildingType);
  releaseBuilding = (clickData.size() > 0) ? clickData.get(0).building : null;
  if (mouseButton == LEFT) {
    lmDown = false;
    if (releaseBuilding == null) {
      addBuilding(releaseLocation.copy(), buildMode); // Only add if no building exists
    } else {
      println("Release location already has a building. Skipping add.");
    }
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
   if (key == '1') {
     buildMode = BuildingType.test;
   }
   else if (key == '2') {
     buildMode = BuildingType.relay;
   }
   else {
     buildMode = BuildingType.none; 
   }
   
   
   println("current mode: " + buildMode);
}
