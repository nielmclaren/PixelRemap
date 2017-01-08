import controlP5.*;

String inputFilename;

ControlP5 cp5;

int margin;
int paletteWidth;
int imageWidth;
int imageHeight;
int imageX;
int imageY;

Palette palette;
PaletteDisplay paletteDisplay;
RadioButton brushTypeRadio;

PGraphics inputImg, outputImg;
FloatGrayscaleImage deepImage;

FloatGrayscaleBrush brush;

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
  deepImage = new FloatGrayscaleImage(imageWidth, imageHeight);

  setupBrush();
  setupUi();
  setupPalette();

  reset();
}

void setupBrush() {
  brush = new FloatGrayscaleBrush(deepImage, imageWidth, imageHeight)
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

  int currX = imageX + imageWidth + margin;
  int currY = margin;

  paletteDisplay = new PaletteDisplay(margin, margin, paletteWidth, height - 2 * margin);

  cp5 = new ControlP5(this);
  cp5.addSlider("paletteOffsetSlider")
    .setPosition(currX, currY)
    .setSize(240, 20)
    .setRange(0, 1);
  currY += 30;

  cp5.addSlider("paletteRepeatSlider")
    .setPosition(currX, currY)
    .setSize(240, 20)
    .setRange(1, 50)
    .setValue(1)
    .setNumberOfTickMarks(50)
    .snapToTickMarks(true)
    .showTickMarks(false);
  currY += 30;

  brushTypeRadio = cp5.addRadioButton("brushType")
    .setPosition(currX, currY)
    .setSize(20,20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setSpacingColumn(150)
    .setItemsPerRow(2)
    .addItem("rect", 0)
    .addItem("rectFalloff", 1)
    .addItem("circle", 2)
    .addItem("circleFalloff", 3)
    .addItem("voronoi", 4)
    .addItem("wave", 5)
    .addItem("waveFalloff", 6)
    .activate(7);
  currY += 100;

  cp5.addSlider("brushValueSlider")
    .setPosition(currX, currY)
    .setSize(240, 20)
    .setRange(0, 255)
    .setValue(32);
  currY += 30;

  cp5.addSlider("brushSizeSlider")
    .setPosition(currX, currY)
    .setSize(240, 20)
    .setRange(1, 500)
    .setValue(150);
  currY += 30;

  cp5.addSlider("brushWidthSlider")
    .setPosition(currX, currY)
    .setSize(240, 20)
    .setRange(1, 500)
    .setValue(150);
  currY += 30;

  cp5.addSlider("brushHeightSlider")
    .setPosition(currX, currY)
    .setSize(240, 20)
    .setRange(1, 500)
    .setValue(150);
  currY += 30;

  cp5.addSlider("brushWavelengthSlider")
    .setPosition(currX, currY)
    .setSize(240, 20)
    .setRange(1, 250)
    .setValue(50);
  currY += 30;
}

void setupPalette() {
  palette = new Palette()
    .repeatCount(1)
    .isMirrored(false)
    .isReversed(false)
    .addFilename("mirage_sunset.png")
    .addFilename("neon.png")
    .addFilename("powerlines_palette01.png")
    .addFilename("vaporwave.png")
    .addFilename("stripe02.png")
    .addFilename("stripe01.png")
    .addFilename("flake04.png")
    .addFilename("blacktogradient.png")
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
    image(inputImage, imageX, imageY, imageWidth, imageHeight);
  }
  else {
    updateOutputImage();
    image(outputImg, imageX, imageY, imageWidth, imageHeight);
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
    brush.stepped(mouseX - imageX, mouseY - imageY);
  }
}

void mouseDragged() {
  if (isDragging && brush.stepCheck(mouseX - imageX, mouseY - imageY)) {
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
        brush.type("rect");
        break;
      case 1:
        brush.type("rectFalloff");
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
  } else if (event.isFrom(cp5.getController("brushValueSlider"))) {
    brush.value(event.getValue());
  } else if (event.isFrom(cp5.getController("brushSizeSlider"))) {
    int v = floor(event.getValue());
    brush.size(v);
    cp5.getController("brushWidthSlider").setValue(v);
    cp5.getController("brushHeightSlider").setValue(v);
    brush.width(v);
    brush.height(v);
  } else if (event.isFrom(cp5.getController("brushWidthSlider"))) {
    brush.width(floor(event.getValue()));
  } else if (event.isFrom(cp5.getController("brushHeightSlider"))) {
    brush.height(floor(event.getValue()));
  } else if (event.isFrom(cp5.getController("brushWavelengthSlider"))) {
    brush.wavelength(event.getValue());
  }
}

void drawBrush(int x, int y) {
  brush.draw(x, y);
}

boolean mouseHitTestImage() {
  return mouseX > imageX && mouseX < imageX + imageWidth
      && mouseY > imageY && mouseY < imageY + imageHeight;
}
