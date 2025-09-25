PImage factory;
void collectImages() {
  factory = loadImage("assets/buildings/factory.png"); 
}



// Ground map settings
int resolution = 1;
int seed = 0;
int grid;

PImage groundMap;



void initializeGround() {
  noiseSeed(seed);
  noiseDetail(resolution);
  grid = gameWorld.cellDimension;
  groundMap = generatePerlinGround();
}

color max = color(255, 190, 200);
color min = color(50, 40, 25);          
float bias = 0.25;
float noiseVal;
float noiseScale=0.01;

PImage generatePerlinGround() {
  PImage map = createImage(width, height, RGB);
  map.loadPixels();
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      noiseVal = noise(x * noiseScale, y * noiseScale);
      color col = lerpColor(min, max, noiseVal - bias);
      map.pixels[x + y * width] = col;
    }
  }
  map.updatePixels();
  return map;
}
/**
PImage generateGridGround() {
  PImage map = createImage(width, height, RGB);
  map.loadPixels();
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      noiseVal = noise(x * noiseScale, y * noiseScale);
      color col = lerpColor(min, max, noiseVal - bias);
      map.pixels[x + y * width] = col;
    }
  }
  map.updatePixels();
  return map;
}
*/
