import controlP5.*;


ControlP5 cp5;

int margin;

int nextPaletteIndex;
ArrayList<String> paletteFilenames;
color[] palette;
PaletteSlider paletteSlider;
int paletteWidth;
PGraphics inputImg, outputImg;

Brush brush;
int brushSize;
color brushColor;
int brushStep;
int prevStepX;
int prevStepY;

int imageX;
int imageY;

boolean showInputImg;
boolean isDragging;

FileNamer fileNamer;

void setup() {
  size(1280, 830, P2D);
  smooth();

  PImage inputTempImg = loadImage("input.png");

  margin = 15;
  paletteWidth = 40;

  cp5 = new ControlP5(this);
  cp5.addSlider("paletteOffsetSlider")
    .setPosition(margin + paletteWidth + margin + inputTempImg.width + margin, margin)
    .setSize(240, 20)
    .setRange(0, 1);

  paletteSlider = new PaletteSlider(margin, margin, paletteWidth, height - 2 * margin);

  nextPaletteIndex = 0;
  paletteFilenames = new ArrayList<String>();
  paletteFilenames.add("stripey02.png");
  paletteFilenames.add("flake01.png");
  paletteFilenames.add("blobby.png");
  loadNextPalette();

  showInputImg = false;
  isDragging = false;

  fileNamer = new FileNamer("output/export", "png");

  inputImg = createGraphics(inputTempImg.width, inputTempImg.height, P2D);
  outputImg = createGraphics(inputImg.width, inputImg.height, P2D);

  brushColor = color(128);
  brushStep = 15;
  brushSize = 70;
  brush = new Brush(inputImg, inputImg.width, inputImg.height);

  reset();
}

void draw() {
  background(0);

  imageX = margin + paletteWidth + margin;
  imageY = margin;

  if (showInputImg) {
    inputImg.updatePixels();
    image(inputImg, imageX, imageY);
  }
  else {
    updateOutputImg();
    outputImg.updatePixels();
    image(outputImg, imageX, imageY);
  }

  paletteSlider.draw(g);
}

void drawPalette(int paletteX, int paletteY, int paletteWidth, int paletteHeight) {
  noStroke();
  fill(32);
  rect(paletteX, paletteY, paletteWidth, paletteHeight);

  for (int i = 0; i < palette.length; i++) {
    fill(palette[i]);
    rect(
      paletteX, paletteY,
      paletteWidth, paletteHeight * (1 - (float) i / palette.length));
  }
}

void reset() {
  PImage inputTempImg = loadImage("input.png");

  inputImg.beginDraw();
  inputImg.image(inputTempImg, 0, 0);
  inputImg.endDraw();

  inputImg.loadPixels();
}

void toggleInputOutput() {
  showInputImg = !showInputImg;
}

void updateOutputImg() {
  outputImg.loadPixels();
  for (int i = 0; i < outputImg.width * outputImg.height; i++) {
    outputImg.pixels[i] = translatePixel(inputImg.pixels[i]);
  }
}

void loadNextPalette() {
  String paletteFilename = paletteFilenames.get(nextPaletteIndex);
  nextPaletteIndex = (nextPaletteIndex + 1) % paletteFilenames.size();

  PImage paletteImg = loadImage(paletteFilename);
  palette = new color[paletteImg.width];
  paletteImg.loadPixels();
  for (int i = 0; i < paletteImg.width; i++) {
    palette[i] = paletteImg.pixels[i];
  }
  paletteSlider.setPalette(palette);
}

void keyReleased() {
  switch (key) {
    case 'e':
    case ' ':
      reset();
      break;
    case 'c':
      clear();
      break;
    case 'p':
      loadNextPalette();
      break;
    case 't':
      toggleInputOutput();
      break;
    case 'r':
      save(fileNamer.next());
      break;
  }
}

void mousePressed() {
  paletteSlider.mousePressed();

  if (mouseHitTestImage()) {
    isDragging = true;
  }
}

void mouseDragged() {
  paletteSlider.mouseDragged();

  if (isDragging && stepCheck(mouseX, mouseY)) {
    drawBrush(mouseX - imageX, mouseY - imageY);
    stepped(mouseX - imageX, mouseY - imageY);
  }
}

void mouseReleased() {
  paletteSlider.mouseReleased();

  if (isDragging) {
    drawBrush(mouseX - imageX, mouseY - imageY);
    stepped(mouseX - imageX, mouseY - imageY);
  }

  isDragging = false;
}

void drawBrush(int x, int y) {
  //brush.squareBrush(x, y, brushSize, brushColor);
  //brush.squareFalloffBrush(x, y, brushSize, brushColor);
  //brush.circleBrush(x, y, brushSize, brushColor);
  brush.circleFalloffBrush(x, y, brushSize, brushColor);
  //brush.voronoiBrush(x, y, brushSize, brushColor);
}

boolean mouseHitTestImage() {
  return mouseX > imageX && mouseX < imageX + inputImg.width
      && mouseY > imageY && mouseY < imageY + inputImg.height;
}

boolean stepCheck(int x, int y) {
  float dx = x - prevStepX;
  float dy = y - prevStepY;
  return brushStep * brushStep < dx * dx  +  dy * dy;
}

void stepped(int x, int y) {
  prevStepX = x;
  prevStepY = y;
}

color translatePixel(color c) {
  float b = brightness(c);
  int len = palette.length;
  float paletteLow = len * paletteSlider.getLow();
  float paletteHigh = len * paletteSlider.getHigh();
  float offset = cp5.getController("paletteOffsetSlider").getValue();
  float value = map(b, 0, 255, paletteLow, paletteHigh) + offset * len;
  int index = floor(value % len);
  if (index >= len) {
    index--;
  }
  return palette[index];
}

float randf(float low, float high) {
  return low + random(1) * (high - low);
}

int randi(int low, int high) {
  return low + floor(random(1) * (high - low));
}