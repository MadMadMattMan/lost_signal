class Building {
  // Buliding data
  PVector position;
  PVector target;
  PVector xySize = new PVector(10, 10);
  
  // Building
  ArrayList<Resource> storedResources = new ArrayList<>();
  
  Collider collider;
  
  // Constructor
  Building(PVector pos, BuildingType type) {
    // General
    position = pos;
    collider = gameWorld.createCollider(cornerOffset(true), cornerOffset(false), true, defaultLayers);
    
    // Type specific
    switch (type) {
      case mine:
        createMine();
        break;
      // case export:
    }
  }
  
  void createMine() {
    
  }
  
  
  // Setup
  PVector cornerOffset(boolean top) {
    PVector result;
    if (top)
      result = new PVector(position.x - xySize.x, position.y - xySize.y);
    else
      result = new PVector(position.x + xySize.x, position.y + xySize.y);
    return result;
  }
}

public class Resource { 
  
}

public enum BuildingType {
  mine,
  
  // export
}
