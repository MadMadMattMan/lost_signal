// Called when a mouse click occurs
void mouseClicked() {
  PVector clickLocation = new PVector(mouseX, mouseY);
  addBuilding(clickLocation, buildMode);
}

// Called when a key click occurs
void keyPressed() {
   if (key == '1') {
     buildMode = BuildingType.test;
   }
   if (key == '2') {
     buildMode = BuildingType.relay;
   }
   
   
   println("current mode: " + buildMode);
}
