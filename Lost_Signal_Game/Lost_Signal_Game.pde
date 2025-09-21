//Main
ArrayList<Producer> producers = new ArrayList<>();
ArrayList<Wave> waves = new ArrayList<>();
//Wave w = new Wave(100, new PVector(0, 1));


void setup(){
  size(500, 500);
  //producers.add(new Producer());
}

void draw(){
  background(255);
  Time();
  for (Wave w : waves){
    w.updateWave();
  }
}

float pastTime = 0;
float deltaTime = 0;

void Time(){
  deltaTime = (millis() - pastTime) / 1000;
  pastTime = millis();
}


public void drawVector(PVector center, PVector vector){
  strokeWeight(1);
  stroke(255, 0, 0);
  fill(255, 0, 0);  
  line(center.x, center.y, center.x + vector.x, center.y + vector.y);
}
  
public void mouseClicked(){
  PVector pos = new PVector(mouseX, mouseY);
  PVector dir = new PVector(random(0,0.1f), random(0,0.1f));
  int count = 10;
  
  waves.add(new Wave(pos, dir, count));
} 
  
 //Global Constants
 public PVector zVector = new PVector(0, 0);
