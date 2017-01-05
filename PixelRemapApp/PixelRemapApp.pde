import controlP5.*;

String inputFilename;

ControlP5 cp5;

int margin;
int paletteWidth;
int imageWidth;
int imageHeight;

Palette palette;
PaletteDisplay paletteDisplay;
RadioButton brushTypeRadio;

PGraphics inputImg, outputImg;
FloatGrayscaleImage deepImage;

FloatGrayscaleBrush brush;

int imageX;
int imageY;

boolean showInputImg;
boolean isDragging;

FileNamer fileNamer;

void setup() {
  size(1280, 830, P2D);
  smooth();

  inputFilename = "input.png";

  PImage inputTempImg = loadImage(inputFilename);
  imageWidth = inputTempImg.width;
  imageHeight = inputTempImg.height;

  showInputImg = false;
  isDragging = false;

  fileNamer = new FileNamer("output/export", "png");

  inputImg = createGraphics(imageWidth, imageHeight, P2D);
  outputImg = createGraphics(imageWidth, imageHeight, P2D);
  deepImage = new FloatGrayscaleImage(inputImg.width, inputImg.height);

  setupBrush();
  setupUi();
  setupPalette();

  reset();
}

void setupBrush() {
  brush = new FloatGrayscaleBrush(deepImage, inputImg.width, inputImg.height)
    .size(300)
    .value(32)
    .step(15)
    .type("waveFalloff");
}

void setupUi() {
  margin = 15;
  paletteWidth = 40;

  imageX = margin + paletteWidth + margin;
  imageY = margin;

  paletteDisplay = new PaletteDisplay(margin, margin, paletteWidth, height - 2 * margin);

  cp5 = new ControlP5(this);
  cp5.addSlider("paletteOffsetSlider")
    .setPosition(margin + paletteWidth + margin + imageWidth + margin, margin)
    .setSize(240, 20)
    .setRange(0, 1);

  cp5.addSlider("paletteRepeatSlider")
    .setPosition(margin + paletteWidth + margin + imageWidth + margin, margin + 30)
    .setSize(240, 20)
    .setRange(1, 50)
    .setValue(1)
    .setNumberOfTickMarks(50)
    .snapToTickMarks(true)
    .showTickMarks(false);

  brushTypeRadio = cp5.addRadioButton("brushType")
    .setPosition(margin + paletteWidth + margin + imageWidth + margin, margin + 30 + 30)
    .setSize(20,20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setSpacingColumn(150)
    .setItemsPerRow(2)
    .addItem("square", 0)
    .addItem("squareFalloff", 1)
    .addItem("circle", 2)
    .addItem("circleFalloff", 3)
    .addItem("voronoi", 4)
    .addItem("wave", 5)
    .addItem("waveFalloff", 6)
    .activate(7);

  cp5.addSlider("brushSizeSlider")
    .setPosition(margin + paletteWidth + margin + imageWidth + margin, margin + 30 + 30 + 100)
    .setSize(240, 20)
    .setRange(1, 500)
    .setValue(150);
}

void setupPalette() {
  palette = new Palette()
    .repeatCount(1)
    .isMirrored(false)
    .isReversed(false)
    .addFilename("powerlines_palette01.png")
    .addFilename("vaporwave.png")
    .addFilename("stripe02.png")
    .addFilename("stripe01.png")
    .addFilename("flake04.png")
    .addFilename("blacktogradient.png")
    .addFilename("neon.png")
    .addFilename("flake03.png")
    .addFilename("flake02.png")
    .addFilename("stripey02.png")
    .addFilename("flake01.png")
    .addFilename("blobby.png");
  paletteChanged();
}

void draw() {
  updateRepeatCount();

  background(0);

  if (showInputImg) {
    PImage inputImage = deepImage.getImageRef();
    image(inputImage, imageX, imageY);
  }
  else {
    updateOutputImage();
    image(outputImg, imageX, imageY);
  }

  paletteDisplay.draw(g);

  if (mouseHitTestImage()) {
    drawBrushSize();
  }
}

void drawBrushSize() {
  noFill();
  stroke(128);
  strokeWeight(2);

  ellipseMode(RADIUS);
  ellipse(mouseX, mouseY, brush.size(), brush.size());
}

void updateRepeatCount() {
  int sliderValue = max(1, floor(cp5.getController("paletteRepeatSlider").getValue()));
  if (sliderValue != palette.repeatCount()) {
    palette.repeatCount(sliderValue);
    paletteChanged();
  }
}

void updateOutputImage() {
  outputImg.loadPixels();
  for (int y = 0; y < outputImg.height; y++) {
    for (int x = 0; x < outputImg.width; x++) {
      outputImg.pixels[(outputImg.height - y - 1) * outputImg.width + x] = translateValue(deepImage.getValue(x, y));
    }
  }
  outputImg.updatePixels();
}

color translateValue(float v) {
  color[] colors = palette.getColorsRef();
  int len = colors.length;
  float offset = cp5.getController("paletteOffsetSlider").getValue();
  float value = (v / 256.0 + offset) * len;
  int index = floor(value % len);
  if (index >= len) {
    index--;
  }
  return colors[index];
}

void paletteChanged() {
  paletteDisplay.setPalette(palette.getColorsRef());
}

void reset() {
  PImage inputTempImg = loadImage(inputFilename);

  inputImg.beginDraw();
  inputImg.image(inputTempImg, 0, 0);
  inputImg.endDraw();

  inputImg.loadPixels();

  deepImage.setImage(inputImg);
}

void keyReleased() {
  switch (key) {
    case 'e':
    case ' ':
      reset();
      break;
    case 'p':
      palette.loadNext();
      paletteChanged();
      break;
    case 't':
      showInputImg = !showInputImg;
      break;
    case 'r':
      save(fileNamer.next());
      break;
    case 'm':
      palette.toggleMirrored();
      paletteChanged();
      break;
    case 'v':
      palette.toggleReversed();
      paletteChanged();
      break;
  }
}

void mousePressed() {
  if (mouseHitTestImage()) {
    isDragging = true;
  }
}

void mouseDragged() {
  if (isDragging && brush.stepCheck(mouseX, mouseY)) {
    drawBrush(mouseX - imageX, mouseY - imageY);
    brush.stepped(mouseX - imageX, mouseY - imageY);
  }
}

void mouseReleased() {
  if (isDragging) {
    drawBrush(mouseX - imageX, mouseY - imageY);
    brush.stepped(mouseX - imageX, mouseY - imageY);
  }

  isDragging = false;
}

void controlEvent(ControlEvent event) {
  if(event.isFrom(brushTypeRadio)) {
    // FIXME: Get the radio button label value instead of switching.
    println("Brush: " + int(event.getValue()));
    switch (int(event.getValue())) {
      case 0:
        brush.type("square");
        break;
      case 1:
        brush.type("squareFalloff");
        break;
      case 2:
        brush.type("circle");
        break;
      case 3:
        brush.type("circleFalloff");
        break;
      case 4:
        brush.type("voronoi");
        break;
      case 5:
        brush.type("wave");
        break;
      case 6:
        brush.type("waveFalloff");
        break;
      default:
    }
  } else if (event.isFrom(cp5.getController("brushSizeSlider"))) {
    brush.size(floor(event.getValue()));
  }
}

void drawBrush(int x, int y) {
  brush.draw(x, y);
}

boolean mouseHitTestImage() {
  return mouseX > imageX && mouseX < imageX + inputImg.width
      && mouseY > imageY && mouseY < imageY + inputImg.height;
}
