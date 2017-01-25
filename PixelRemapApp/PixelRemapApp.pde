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

PGraphics inputImage, outputImage;
DeepGrayscaleImage deepImage;

Brush brush;

boolean showInputImage;
boolean isDragging;

FileNamer animationFolderNamer, fileNamer;

void setup() {
  size(1280, 830, P2D);
  smooth();

  inputFilename = "input.png";

  PImage inputTempImage = loadImage(inputFilename);
  imageWidth = inputTempImage.width;
  imageHeight = inputTempImage.height;

  showInputImage = false;
  isDragging = false;

  animationFolderNamer = new FileNamer("output/anim", "/");
  fileNamer = new FileNamer("output/export", "png");

  inputImage = createGraphics(imageWidth, imageHeight, P2D);
  outputImage = createGraphics(imageWidth, imageHeight, P2D);
  deepImage = new DeepGrayscaleImage(imageWidth, imageHeight);

  // Need an instance to get the brush constants.
  // FIXME: Use static constants somehow.
  brush = new Brush(deepImage, imageWidth, imageHeight);

  setupUi();
  setupBrush();
  setupPalette();
  brushChanged();

  reset();
}

void setupBrush() {
  brush = new Brush(deepImage, imageWidth, imageHeight)
    .type(brush.TYPE_WAVE_FALLOFF)
    .value(32.0 / 256.0)
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
    .addItem("rectWaveBrush", brush.TYPE_RECT_WAVE);
  brushTypeRadio.activate(brush.TYPE_WAVE_FALLOFF);
  currY += 100;

  cp5.addSlider("brushValueSlider")
    .setPosition(currX, currY)
    .setSize(240, 20)
    .setRange(0, 1);
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
    .addFilename("pinkredgrad.png")
    .addFilename("mirage_sunset_dark.png")
    .addFilename("mirage_sunset.png")
    .addFilename("doraemon_palette.png")
    .addFilename("cavegrad.png")
    .addFilename("halograd.png")
    .addFilename("neon.png")
    .addFilename("stripe02.png")
    .addFilename("flake01.png");
  paletteChanged();
}

void draw() {
  updateRepeatCount();

  background(0);

  if (showInputImage) {
    PImage inputImage = deepImage.getImageRef();
    image(inputImage, imageX, imageY, imageWidth, imageHeight);
  }
  else {
    float offset = cp5.getController("paletteOffsetSlider").getValue();
    updateOutputImage(offset);
    image(outputImage, imageX, imageY, imageWidth, imageHeight);
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

void updateOutputImage(float offset) {
  outputImage.beginDraw();
  outputImage.loadPixels();
  outputImage.pixels[0] = color(0);
  for (int y = 0; y < outputImage.height; y++) {
    for (int x = 0; x < outputImage.width; x++) {
      outputImage.pixels[y * outputImage.width + x] = translateValue(deepImage.getFloatValue(x, y), offset);
    }
  }
  outputImage.updatePixels();
  outputImage.endDraw();
}

color translateValue(float v, float offset) {
  color[] colors = palette.getColorsRef();
  int len = colors.length;
  float value = (v + offset) * len;
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
  PImage inputTempImage = loadImage(inputFilename);

  inputImage.beginDraw();
  inputImage.image(inputTempImage, 0, 0);
  inputImage.endDraw();

  inputImage.loadPixels();

  deepImage.setImage(inputImage);

  drawThing();
}

void drawThing() {
  int strokeCount = 12;
  for (int i = 0; i < strokeCount; i++) {
    int size = floor(random(800));
    brush
      .width(size)
      .height(size)
      .waveCount(floor(size / 40) + 0.5)
      .value(random(0, 0.5))
      .type(brush.TYPE_WAVE_FALLOFF);

    drawBrush(floor(random(imageWidth)), floor(random(imageHeight)));
  }

  palette
    .repeatCount(2)
    .isMirrored(true);
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
    case 'a':
      saveAnimation();
      break;
    case 'e':
    case ' ':
      reset();
      break;
    case 'p':
      palette.loadNext();
      paletteChanged();
      break;
    case 't':
      showInputImage = !showInputImage;
      break;
    case 'r':
      saveRender();
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

void saveRender() {
  String filename = fileNamer.next();
  outputImage.save(filename);

  String rawFilename = getRawFilename(filename);
  PImage inputImage = deepImage.getImageRef();
  inputImage.save(savePath(rawFilename));
}

void saveAnimation() {
  FileNamer frameNamer = new FileNamer(animationFolderNamer.next() + "frame", "png");

  int frameCount = 200;
  for (int i = 0; i < frameCount; i++) {
    String filename = frameNamer.next();
    updateOutputImage((float)i / frameCount);

    outputImage.save(filename);
  }
}

String getRawFilename(String filename) {
  int index;

  index = filename.lastIndexOf('.');
  String pathAndBaseName = filename.substring(0, index);
  String extension = filename.substring(index);

  return pathAndBaseName + "raw" + extension;
}
