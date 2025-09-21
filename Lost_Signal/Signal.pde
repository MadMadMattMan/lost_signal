class Signal { // Defines the particles that transfer data 
  // Vars
  String contents;
  ArrayList<Integer> layers = new ArrayList<>() {{add(0);}}; // default layer
  
  // Local kinematics
  PVector position;
  PVector velocity;
  PVector bounces = new PVector();
  float speed = 5f;
  
  // Local shape
  float radius = 1;
  color col = color(0, 0, 0);
  
  // Local lifetime
  int birthTime = 0;  // Used to calculate the age, milliseconds enlapsed when generated
  float maxAge = 20;  // Max age in seconds
  
  // Constructors
  Signal(PVector startPos, PVector startVelo, String data) {   
    position = startPos;
    velocity = startVelo.normalize().mult(speed);
    
    birthTime = millis();
    maxAge += random(-0.5f, 0.5f); // Some variation to make it feel more natural
    
    contents = data;
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
    if (isOld() || gameWorld.offScreen(position))
      return false; // return inactive

    // Kinematics
    /// Collisions
    ArrayList<CollisionData> collisionData = gameWorld.checkCollision(position, radius, layers);
    for (CollisionData c : collisionData) {
      if (c.collisionResult)
          bounces.add(c.collisionNormal);
    }
    
    /// Move
    if (bounces.x != 0 || bounces.y != 0)  // bounce with constant speed
      velocity = reflect(velocity.copy(), bounces).setMag(speed);
    position.add(velocity);
    
    // Rendering
    render();
    return true; // return active
  }
  
  void render() {
    noStroke();
    fill(0);
    circle(position.x, position.y, radius);
  }

  // General getters
  boolean isOld() {
    // gets how old the signal is with 0 being newborn and 1 being expired
    float ageRatio = (millis() - birthTime)/(maxAge * 1000);
    // Sets size based on age
    radius = lerp(7, 2, ageRatio);
    
    return ageRatio >= 1;
  }
  /// Calculate the reflected velocity
  PVector reflect(PVector incoming, PVector normal) {
    bounces = new PVector();
    float dot = incoming.dot(normal);
    PVector result = incoming.sub(normal.mult(2*dot)); // r = i - 2(i.n)n
    return result;
  }
}
