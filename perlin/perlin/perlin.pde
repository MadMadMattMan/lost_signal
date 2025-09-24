

void setup(){
  size(500, 500);
  setupNoise();
}

int detail = 2;
int seed = 0;
int grid = 5;

float delay = 2;
float lastChange = 0;

void setupNoise(){
  noiseDetail(detail);
  noiseSeed(seed);
}

color max = color(255, 0, 0);
color min = color(0, 255, 0);
float step = 0.25;
float noiseVal;
float noiseScale=0.01;

void draw(){
  background(0);
  
  if ((millis() - lastChange) >= delay * 1000) {
    lastChange = millis();
    noiseSeed(seed++);
  }
  
  
  stroke(255);
  for (int y = 0; y <= height; y += height/grid) {
    for (int x = 0; x <= width; x += width/grid) {
      noiseVal = noise((x) * noiseScale, (y) * noiseScale);
      fill(lerpColor(min, max, roundToStep(noiseVal)));
      rect(x - width/grid, y - height/grid, x + width/grid, y + height/grid);
    }
  }
}

public float roundToStep(float number) {
  return Math.round(number / step) * step;
}
