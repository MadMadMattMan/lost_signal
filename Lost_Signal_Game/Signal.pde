class Signal{
  //Ref
  Wave currentWave;
  
  //Vars
  PVector position = new PVector(250, 250);
  PVector velocity = new PVector(0, 1);
  PVector acceleration = new PVector(0, 0);
  
  float diam = 5;
  color col = color(0, 0, 0);
  
  int maxBounces = 2;
  int bounces = 0;
  
  int  lifeTime = 1; //Lifetime in seconds
  int birthTime;
  boolean alive = true;
  
  //Constructor 
  Signal(PVector startPos, PVector startVelo, Wave wave){
    position = startPos;
    velocity = startVelo;
    currentWave = wave;
    birthTime = millis();
  }
  
  //Methods
  void updateSignal(){
    if (alive) {
      signalPhysics();
      drawSignal();
      if ((millis() - birthTime)/1000 >= lifeTime)
        currentWave.destroySignal(this);
    }
  }
  
  void signalPhysics(){
    //Update Velocity
    float speed = 1;
    velocity.add(acceleration.normalize());
    velocity = velocity.normalize().mult(speed);
    acceleration.mult(0); 
    
    //Update Position
    position.add(velocity);
    
    //Edge collision
    if ((position.x + diam/2) > width || (position.x - diam/2) < 0){
      velocity.x *= -0.9f;
      position.add(velocity);
      bounces++;
    }
    if ((position.y + diam/2) > height || (position.y - diam/2) < 0){
      velocity.y *= -0.9f;
      position.add(velocity);
      bounces++;
    }
      //Dampening
      ///velocity.mult(0.999f);
  }
  
  void addForce(PVector force){
     acceleration.add(force);
  }
  
  //Renders
  void drawSignal(){
    noStroke();
    fill(col);
    ellipse(position.x, position.y, diam, diam);
  }
}
