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

ArrayList<Action> actions;

float waveOffset;

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

  actions = new ArrayList<Action>();

  animationFolderNamer = new FileNamer("output/anim", "/");
  fileNamer = new FileNamer("output/export", "png");

  inputImage = createGraphics(imageWidth, imageHeight, P2D);
  outputImage = createGraphics(imageWidth, imageHeight, P2D);
  deepImage = new DeepGrayscaleImage(imageWidth, imageHeight);

  waveOffset = 0;

  setupUi();
  setupBrush();
  setupPalette();
  brushChanged();

  reset();
}

void setupBrush() {
  brush = new Brush(deepImage, imageWidth, imageHeight)
    .brushSettings(new BrushSettings()
      .type(BrushType.WAVE_FALLOFF)
      .value(32.0 / 256.0)
      .step(15)
      .width(300)
      .height(300)
      .waveCount(10));
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
    .addItem("rect", BrushType.RECT)
    .addItem("rectFalloff", BrushType.RECT_FALLOFF)
    .addItem("ellipse", BrushType.ELLIPSE)
    .addItem("ellipseFalloff", BrushType.ELLIPSE_FALLOFF)
    .addItem("voronoi", BrushType.VORONOI)
    .addItem("wave", BrushType.WAVE)
    .addItem("waveFalloff", BrushType.WAVE_FALLOFF)
    .addItem("rectWave", BrushType.RECT_WAVE);
  brushTypeRadio.activate(BrushType.WAVE_FALLOFF);
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

  cp5.addSlider("brushWaveOffsetSlider")
    .setPosition(currX, currY)
    .setSize(240, 20)
    .setRange(0.0, 1.0)
    .setNumberOfTickMarks(20 + 1)
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
    .addFilename("mirage_sunset_dark.png")
    .addFilename("pinkredgrad.png")
    .addFilename("mirage_sunset.png")
    .addFilename("doraemon_palette.png")
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
    float paletteOffset = cp5.getController("paletteOffsetSlider").getValue();
    waveOffset = cp5.getController("brushWaveOffsetSlider").getValue();
    updateOutputImage(paletteOffset);
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

void updateOutputImage(float paletteOffset) {
  outputImage.beginDraw();
  outputImage.loadPixels();
  outputImage.pixels[0] = color(0);
  for (int y = 0; y < outputImage.height; y++) {
    for (int x = 0; x < outputImage.width; x++) {
      outputImage.pixels[y * outputImage.width + x] = translateValue(deepImage.getFloatValue(x, y), paletteOffset);
    }
  }
  outputImage.updatePixels();
  outputImage.endDraw();
}

color translateValue(float v, float paletteOffset) {
  color[] colors = palette.getColorsRef();
  int len = colors.length;
  float value = (v + paletteOffset) * len;
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
}

void redraw() {
  reset();
  replayActions();
}

void brushChanged() {
  if (cp5 == null || brush == null) {
    return;
  }

  BrushSettings brushSettings = brush.brushSettings();

  brushTypeRadio.deactivateAll();
  if (brush.brushSettings().type() >= 0) {
    brushTypeRadio.activate(brushSettings.type());
  }

  cp5.getController("brushValueSlider").setValue(brushSettings.value());
  cp5.getController("brushSizeSlider").setValue(brushSettings.width());
  cp5.getController("brushWidthSlider").setValue(brushSettings.width());
  cp5.getController("brushHeightSlider").setValue(brushSettings.height());
  cp5.getController("brushWaveCountSlider").setValue(brushSettings.waveCount());
}

void keyReleased() {
  switch (key) {
    case 'a':
      saveAnimation();
      break;
    case 'b':
      toggleBlendMode();
      break;
    case 'c':
      clearActions();
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
    case 'h':
      replayActions();
      break;
    case 'z':
      actions.remove(actions.size() - 1);
      reset();
      replayActions();
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
  BrushSettings brushSettings = brush.brushSettings();

  if(event.isFrom(brushTypeRadio)) {
    brushSettings.type(int(event.getValue()));
    brush.brushSettings(brushSettings);
  } else if (event.isFrom(cp5.getController("brushValueSlider"))) {
    brushSettings.value(event.getValue());
    brush.brushSettings(brushSettings);
  } else if (event.isFrom(cp5.getController("brushSizeSlider"))) {
    int v = floor(event.getValue());
    if (cp5.getController("brushWidthSlider") != null) {
      cp5.getController("brushWidthSlider").setValue(v);
    }
    if (cp5.getController("brushHeightSlider") != null) {
      cp5.getController("brushHeightSlider").setValue(v);
    }
    brushSettings.width(v);
    brushSettings.height(v);
    brush.brushSettings(brushSettings);
  } else if (event.isFrom(cp5.getController("brushWidthSlider"))) {
    brushSettings.width(floor(event.getValue()));
    brush.brushSettings(brushSettings);
  } else if (event.isFrom(cp5.getController("brushHeightSlider"))) {
    brushSettings.height(floor(event.getValue()));
    brush.brushSettings(brushSettings);
  } else if (event.isFrom(cp5.getController("brushWaveCountSlider"))) {
    brushSettings.waveCount(event.getValue());
    brush.brushSettings(brushSettings);
  } else if (event.isFrom(cp5.getController("brushWaveOffsetSlider"))) {
    redraw();
  }
}

void drawBrush(int x, int y) {
  BrushAction action = new BrushAction()
      .brushSettings(brush.brushSettings())
      .position(x, y);
  doBrushAction(action);
  actions.add(action);
}

void doBrushAction(BrushAction action) {
  brush.brushSettings(action.brushSettings());
  brush.draw(action.x(), action.y(), waveOffset);
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

  int frameCount = 50;
  for (int i = 0; i < frameCount; i++) {
    String filename = frameNamer.next();
    reset();
    waveOffset = (float)i / frameCount;
    replayActions();
    updateOutputImage(0);

    outputImage.save(filename);
  }
}

void toggleBlendMode() {
  if (brush.brushSettings().blendMode() == BlendMode.ADD) {
    BrushSettings settings = brush.brushSettings();
    settings.blendMode(BlendMode.SUBTRACT);
    brush.brushSettings(settings);
  } else {
    brush.brushSettings(
        brush.brushSettings().blendMode(BlendMode.ADD));
  }
}

String getRawFilename(String filename) {
  int index;

  index = filename.lastIndexOf('.');
  String pathAndBaseName = filename.substring(0, index);
  String extension = filename.substring(index);

  return pathAndBaseName + "raw" + extension;
}

void clearActions() {
  actions = new ArrayList<Action>();
}

void replayActions() {
  for (int i = 0; i < actions.size(); i++) {
    Action action = actions.get(i);
    if (action.type() == ActionType.BRUSH) {
      BrushAction brushAction = (BrushAction)action;
      doBrushAction(brushAction);
    }
  }
}
