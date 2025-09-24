class Collider {
  String colliderId;
  ArrayList<Integer> colliderIndecies;
  
  Building building = null;
  
  ArrayList<BuildingType> buildingTypes = new ArrayList<>();

  boolean renderColliders = true;
  PVector xPoints; // minX, maxX
  PVector yPoints; // minY, maxY

  boolean isPhysicalCollider; // bounce collisions

  // Basic box collider constructor
  Collider(PVector topLeft, PVector bottomRight, boolean isPhysicalCollider) {
    // Sort and store x and y bounds
    xPoints = new PVector(min(topLeft.x, bottomRight.x), max(topLeft.x, bottomRight.x));
    yPoints = new PVector(min(topLeft.y, bottomRight.y), max(topLeft.y, bottomRight.y));
    this.isPhysicalCollider = isPhysicalCollider;
    // Calculate which cells this collider intersects
    calculateInterceptingIndexes();
  }
  // Advanced box collider constructor
  Collider(PVector topLeft, PVector bottomRight, boolean isPhysicalCollider, Building building, ArrayList<BuildingType> buildingTypes) {
    xPoints = new PVector(min(topLeft.x, bottomRight.x), max(topLeft.x, bottomRight.x));
    yPoints = new PVector(min(topLeft.y, bottomRight.y), max(topLeft.y, bottomRight.y));
    this.isPhysicalCollider = isPhysicalCollider;
    this.building = building;
    this.buildingTypes = buildingTypes;
    // Calculate which cells this collider intersects
    calculateInterceptingIndexes();
  }

  // Check if a position collides with this collider
  public CollisionData isColliding(PVector otherPosition, float radius, Building origin, ArrayList<BuildingType> target) {
    // If a collision occurs
    if (isBetween(xPoints, otherPosition.x, radius) &&
        isBetween(yPoints, otherPosition.y, radius) &&
        !isOrigin(origin)) {
      if (targetMatch(target) && building != null){ // if matching and not a obstructor - do full collision
        return new CollisionData(isPhysicalCollider, collisionNormal(otherPosition), building);
      }
      println("basic");
      return new CollisionData(isPhysicalCollider, collisionNormal(otherPosition)); // general collision
    }
    return new CollisionData(); // No collision
  }

  // Check if this collider is in a given cell
  public boolean isInCell(int index) {
    return colliderIndecies.contains(index);
  }

  // Utility: check if a value is within a range
  boolean isBetween(PVector range, float value, float radius) {
    return ((value + radius) >= range.x && (value - radius) <= range.y);
  }
  
  boolean targetMatch(ArrayList<BuildingType> target) {
    for (BuildingType t : buildingTypes) {
      if (target.contains(t))
        return true;
    }
    return false;
  }
  
  boolean isOrigin(Building origin) {
    if (origin != null && building != null)
      return building.equals(origin);
    return false;
  }
  
  PVector collisionNormal(PVector otherPosition) {
    // Calculate distances to each edge
    float leftDist   = abs(otherPosition.x - xPoints.x);
    float rightDist  = abs(xPoints.y - otherPosition.x);
    float topDist    = abs(otherPosition.y - yPoints.x);
    float bottomDist = abs(yPoints.y - otherPosition.y);

    // Find the minimum distance - closest edge
    float minDist = min(leftDist, rightDist, topDist);
    minDist = min(minDist, bottomDist);

    PVector normal = new PVector(0, 0);
    if (minDist == leftDist) {
      normal.set(-1, 0); // From left
    } else if (minDist == rightDist) {
      normal.set(1, 0); // From right
    } else if (minDist == topDist) {
      normal.set(0, -1); // From top
    } else if (minDist == bottomDist) {
      normal.set(0, 1); // From bottom
    }

    return normal;
  }
  
  // Indexing
  // Calculates the indecies the box intercepts and stores them
  void calculateInterceptingIndexes() {
    ArrayList<Integer> interceptingIndecies = new ArrayList<>();

    PVector cellSize = gameWorld.getCellStep();
  
    // Correctly use floor for start, ceil-1 for end (to include partial overlaps)
    int colStart = (int)floor(xPoints.x / cellSize.x);
    int colEnd   = (int)ceil(xPoints.y / cellSize.x);
    int rowStart = (int)floor(yPoints.x / cellSize.y);
    int rowEnd   = (int)ceil(yPoints.y / cellSize.y);
  
    // Clamp within grid bounds  
    int maxIndex = gameWorld.cellDimension;
    colStart = constrain(colStart, 0, maxIndex);
    colEnd   = constrain(colEnd, 0, maxIndex) - 1;
    rowStart = constrain(rowStart, 0, maxIndex);
    rowEnd   = constrain(rowEnd, 0, maxIndex) - 1;
  
    for (int row = rowStart; row <= rowEnd; row++) {
      for (int col = colStart; col <= colEnd; col++) {
        String key = row + "," + col;
        Integer index = gameWorld.cellIndices.get(key);
        if (index != null && !interceptingIndecies.contains(index)) {
          interceptingIndecies.add(index);
        }
      }
    }
    colliderIndecies = interceptingIndecies;
  }
  
  // Getters
  ArrayList<Integer> getColliderIndecies() {
    return colliderIndecies;
  }
  
  // Render the collider visually
  void render() {
    // render settings
    fill(255, 0, 0);
    stroke(255, 0, 0);
    strokeWeight(2);
  
    // finds the width and height
    float w = xPoints.y - xPoints.x;
    float h = yPoints.y - yPoints.x;
  
    rect(xPoints.x, yPoints.x, w, h);
  }
}
