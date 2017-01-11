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

  // Need an instance to get the brush constants.
  // FIXME: Use static constants somehow.
  brush = new FloatGrayscaleBrush(deepImage, imageWidth, imageHeight);

  setupUi();
  setupBrush();
  setupPalette();
  brushChanged();

  reset();
}

void setupBrush() {
  brush = new FloatGrayscaleBrush(deepImage, imageWidth, imageHeight)
    .type(brush.TYPE_WAVE_FALLOFF)
    .value(32)
    .step(15)
    .width(300)
    .height(300)
    .waveCount(10);
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
    .setRange(0, 1)
    .setValue(0);
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

  brushTypeRadio = cp5.addRadioButton("brushTypeRadio")
    .setPosition(currX, currY)
    .setSize(20,20)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setSpacingColumn(150)
    .setItemsPerRow(2)
    .addItem("rect", brush.TYPE_RECT)
    .addItem("rectFalloff", brush.TYPE_RECT_FALLOFF)
    .addItem("ellipse", brush.TYPE_ELLIPSE)
    .addItem("ellipseFalloff", brush.TYPE_ELLIPSE_FALLOFF)
    .addItem("voronoi", brush.TYPE_VORONOI)
    .addItem("wave", brush.TYPE_WAVE)
    .addItem("waveFalloff", brush.TYPE_WAVE_FALLOFF)
    .activate(7);
  currY += 100;

  cp5.addSlider("brushValueSlider")
    .setPosition(currX, currY)
    .setSize(240, 20)
    .setRange(0, 255);
  currY += 30;

  cp5.addSlider("brushSizeSlider")
    .setPosition(currX, currY)
    .setSize(240, 20)
    .setRange(1, 1000)
    .setNumberOfTickMarks(1000)
    .snapToTickMarks(true)
    .showTickMarks(false);
  currY += 30;

  cp5.addSlider("brushWidthSlider")
    .setPosition(currX, currY)
    .setSize(240, 20)
    .setRange(1, 1000)
    .setNumberOfTickMarks(1000)
    .snapToTickMarks(true)
    .showTickMarks(false);
  currY += 30;

  cp5.addSlider("brushHeightSlider")
    .setPosition(currX, currY)
    .setSize(240, 20)
    .setRange(1, 1000)
    .setNumberOfTickMarks(1000)
    .snapToTickMarks(true)
    .showTickMarks(false);
  currY += 30;

  cp5.addSlider("brushWaveCountSlider")
    .setPosition(currX, currY)
    .setSize(240, 20)
    .setRange(0.0, 20.0)
    .setNumberOfTickMarks(20 * 4 + 1)
    .showTickMarks(false)
    .snapToTickMarks(true);
  currY += 30;
}

void setupPalette() {
  palette = new Palette()
    .repeatCount(1)
    .isMirrored(false)
    .isReversed(false)
    .addFilename("cavegrad.png")
    .addFilename("halograd.png")
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
    brush.drawOutline(mouseX, mouseY);
  }
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

void drawThing() {
  int count = 60;
  brush.type(brush.TYPE_RECT_FALLOFF)
    .value(160)
    .width(imageWidth / (count - 1))
    .height(imageHeight);

  for (int i = 0; i < count; i++) {
    brush.draw(i * imageWidth / (count - 1), imageHeight/2);
  }

  brush.type(brush.TYPE_RECT_FALLOFF)
    .width(imageWidth)
    .height(imageHeight / (count - 1));

  for (int i = 0; i < count; i++) {
    brush.draw(imageWidth/2, i * imageHeight / (count - 1));
  }

}

void brushChanged() {
  if (cp5 == null || brush == null) {
    return;
  }

  brushTypeRadio.deactivateAll();
  if (brush.type() >= 0) {
    brushTypeRadio.activate(brush.type());
  }

  cp5.getController("brushValueSlider").setValue(brush.value());
  cp5.getController("brushSizeSlider").setValue(brush.width());
  cp5.getController("brushWidthSlider").setValue(brush.width());
  cp5.getController("brushHeightSlider").setValue(brush.height());
  cp5.getController("brushWaveCountSlider").setValue(brush.waveCount());
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
    brush.type(int(event.getValue()));
  } else if (event.isFrom(cp5.getController("brushValueSlider"))) {
    brush.value(event.getValue());
  } else if (event.isFrom(cp5.getController("brushSizeSlider"))) {
    int v = floor(event.getValue());
    if (cp5.getController("brushWidthSlider") != null) {
      cp5.getController("brushWidthSlider").setValue(v);
    }
    if (cp5.getController("brushHeightSlider") != null) {
      cp5.getController("brushHeightSlider").setValue(v);
    }
    brush.width(v);
    brush.height(v);
  } else if (event.isFrom(cp5.getController("brushWidthSlider"))) {
    brush.width(floor(event.getValue()));
  } else if (event.isFrom(cp5.getController("brushHeightSlider"))) {
    brush.height(floor(event.getValue()));
  } else if (event.isFrom(cp5.getController("brushWaveCountSlider"))) {
    brush.waveCount(event.getValue());
  }
}

void drawBrush(int x, int y) {
  brush.draw(x, y);
}

boolean mouseHitTestImage() {
  return mouseX > imageX && mouseX < imageX + imageWidth
      && mouseY > imageY && mouseY < imageY + imageHeight;
}
