class Signal { // Defines the particles that transfer data 
  // Vars
  Resource contents = null;
  Building origin = null;
  ArrayList<BuildingType> targetBuildings = defaultBuildingType;
  
  // Local kinematics
  PVector position;
  PVector velocity;
  PVector bounces = new PVector();
  float speed = 5f;
  
  // Local shape
  float radius;
  color col = color(214, 37, 152);
  
  // Local lifetime
  int birthTime = 0;  // Used to calculate the age, milliseconds enlapsed when generated
  float maxAge = 5;  // Max age in seconds
  boolean destroy = false;
  
  // Constructors
  Signal(PVector startPos, PVector startVelo, Building origin, ArrayList<BuildingType> targetBuildings, Resource resource) {   
    position = startPos;
    velocity = startVelo.setMag(speed);
    
    this.origin = origin;
    this.targetBuildings = targetBuildings;
    
    birthTime = millis();
    maxAge += random(-0.5f, 0.5f); // Some variation to make it feel more natural
    
    contents = resource;
    if (contents == null)
      col = color(214, 37, 152);
    else {
      PVector colorRGB = resourceSignalColor.get(contents.getType());
      col = color(colorRGB.x, colorRGB.y, colorRGB.z);
    }
  }
  Signal(PVector startPos, PVector startVelo) { // Dataless constructor
    position = startPos;
    velocity = startVelo.setMag(speed);
    birthTime = millis();
    maxAge += random(-0.5f, 0.5f); // Some variation to make it feel more natural
    contents = null;
  }
  
  // Updaters
  boolean update() {
    // Check for death
    if (isOld() || gameWorld.offScreen(position) || destroy)
      return false; // return inactive

    // Kinematics
    /// Collisions
    ArrayList<CollisionData> collisionData = gameWorld.checkCollision(position, radius, origin, targetBuildings);
    for (CollisionData c : collisionData) {
      if (c.collisionResult && !c.invalidCollision) {
        if (c.physicalCollision)
          bounces.add(c.collisionNormal);
        if (c.consumeable) {
          c.building.consume(this);
        }
      }
    }
    
    /// Move
    if (bounces.x != 0 || bounces.y != 0) { // bounce with constant speed
      velocity = reflect(velocity.copy(), bounces).setMag(speed);
      origin = null; // origin emit after one bounce2
    }
    position.add(velocity.setMag(speed));
    
    // Rendering
    render();
    return true; // return active
  }
  
  void render() {
    noStroke();
    fill(col);
    circle(position.x, position.y, radius);
  }

  // General getters
  boolean isOld() {
    // gets how old the signal is with 0 being newborn and 1 being expired
    float ageRatio = (millis() - birthTime) / (maxAge * 1000);
    // Sets size based on age
    radius = lerp(10, 2, ageRatio);
    
    return (ageRatio >= 1);
  }
  /// Calculate the reflected velocity
  PVector reflect(PVector incoming, PVector normal) {
    bounces = new PVector();
    float dot = incoming.dot(normal);
    PVector result = incoming.sub(normal.mult(2*dot)); // r = i - 2(i.n)n
    return result;
  }
  
  void applyForce(PVector force) {
    velocity.add(force);
    velocity.setMag(speed);
  }
  
  Signal copy(){
    return new Signal(position, velocity, origin, targetBuildings, contents);
  }
}
