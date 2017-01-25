
class Brush {
  DeepGrayscaleImage _image;
  int _imageWidth;
  int _imageHeight;

  BrushSettings _brushSettings;

  // FIXME: These are duplicated from BrushSettings.
  // Gotta get static final types working.
  public final int TYPE_RECT = 0;
  public final int TYPE_RECT_FALLOFF = 1;
  public final int TYPE_ELLIPSE = 2;
  public final int TYPE_ELLIPSE_FALLOFF = 3;
  public final int TYPE_VORONOI = 4;
  public final int TYPE_WAVE = 5;
  public final int TYPE_WAVE_FALLOFF = 6;
  public final int TYPE_RECT_WAVE = 7;

  int _prevStepX;
  int _prevStepY;

  Brush(DeepGrayscaleImage image, int w, int h) {
    _image = image;
    _imageWidth = w;
    _imageHeight = h;

    _brushSettings = new BrushSettings();

    _prevStepX = 0;
    _prevStepY = 0;
  }

  BrushSettings brushSettings() {
    return _brushSettings;
  }

  Brush brushSettings(BrushSettings v) {
    _brushSettings = v;
    return this;
  }

  boolean stepCheck(int x, int y) {
    int step = _brushSettings.step();
    float dx = x - _prevStepX;
    float dy = y - _prevStepY;
    return step * step < dx * dx  +  dy * dy;
  }

  Brush stepped(int x, int y) {
    _prevStepX = x;
    _prevStepY = y;
    return this;
  }

  color getPixel(int x, int y) {
    return _image.getPixel(x, y);
  }

  void setPixel(int x, int y, color v) {
    _image.setPixel(x, y, v);
  }

  void draw(int x, int y) {
    switch (_brushSettings.type()) {
      case TYPE_RECT:
        brush.rectBrush(x, y);
        break;
      case TYPE_RECT_FALLOFF:
        brush.rectFalloffBrush(x, y);
        break;
      case TYPE_ELLIPSE:
        brush.ellipseBrush(x, y);
        break;
      case TYPE_ELLIPSE_FALLOFF:
        brush.ellipseFalloffBrush(x, y);
        break;
      case TYPE_VORONOI:
        brush.voronoiBrush(x, y);
        break;
      case TYPE_WAVE:
        brush.waveBrush(x, y);
        break;
      case TYPE_WAVE_FALLOFF:
        brush.waveFalloffBrush(x, y);
        break;
      case TYPE_RECT_WAVE:
        brush.rectWaveBrush(x, y);
        break;
      default:
        println("Unexpected brush type: " + _brushSettings.type());
    }
  }

  void drawOutline(int x, int y) {
    noFill();
    stroke(128);
    strokeWeight(2);

    switch (_brushSettings.type()) {
      case TYPE_RECT:
      case TYPE_RECT_FALLOFF:
      case TYPE_RECT_WAVE:
        rectMode(CENTER);
        rect(mouseX, mouseY, _brushSettings.width(), _brushSettings.height());
        break;
      case TYPE_ELLIPSE:
      case TYPE_ELLIPSE_FALLOFF:
      case TYPE_VORONOI:
      case TYPE_WAVE:
      case TYPE_WAVE_FALLOFF:
        ellipseMode(CENTER);
        ellipse(mouseX, mouseY, _brushSettings.width(), _brushSettings.height());
        break;
      default:
        println("Unexpected brush type: " + _brushSettings.type());
    }
  }

  void rectBrush(int targetX, int targetY) {
    int halfWidth = floor(_brushSettings.width()/2);
    int halfHeight = floor(_brushSettings.height()/2);

    for (int x = targetX - halfWidth; x <= targetX + halfWidth; x++) {
      if (x < 0 || x >= _imageWidth) continue;
      for (int y = targetY - halfHeight; y <= targetY + halfHeight; y++) {
        if (y < 0 || y >= _imageWidth) continue;
        _image.setFloatValue(x, y, constrain(_image.getFloatValue(x, y) + _brushSettings.value(), 0, 1));
      }
    }
  }

  void rectFalloffBrush(int targetX, int targetY) {
    int halfWidth = floor(_brushSettings.width()/2);
    int halfHeight = floor(_brushSettings.height()/2);

    for (int x = targetX - halfWidth; x <= targetX + halfWidth; x++) {
      if (x < 0 || x >= _imageWidth) continue;
      for (int y = targetY - halfHeight; y <= targetY + halfHeight; y++) {
        if (y < 0 || y >= _imageHeight) continue;
        float dx = abs(x - targetX);
        float dy = abs(y - targetY);

        float factor = max(dx / halfWidth, dy / halfHeight);
        factor = getFalloff(factor);
        factor = constrain(factor, 0, 1);

        float currentValue = _image.getFloatValue(x, y);
        _image.setFloatValue(x, y, constrain(currentValue + factor * _brushSettings.value(), 0, 1));
      }
    }
  }

  void ellipseBrush(int targetX, int targetY) {
    int halfWidth = floor(_brushSettings.width()/2);
    int halfHeight = floor(_brushSettings.height()/2);

    float wSq = halfWidth * halfWidth;
    float hSq = halfHeight * halfHeight;

    for (int x = targetX - halfWidth; x <= targetX + halfWidth; x++) {
      if (x < 0 || x >= _imageWidth) continue;
      for (int y = targetY - halfHeight; y <= targetY + halfHeight; y++) {
        if (y < 0 || y >= _imageHeight) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        if (dx * dx / wSq  +  dy * dy / hSq > 1) continue;
        // FIXME: Factor out blend mode.
        _image.setFloatValue(x, y, _image.getFloatValue(x, y) + _brushSettings.value());
      }
    }
  }

  void ellipseFalloffBrush(int targetX, int targetY) {
    int halfWidth = floor(_brushSettings.width()/2);
    int halfHeight = floor(_brushSettings.height()/2);

    float wSq = halfWidth * halfWidth;
    float hSq = halfHeight * halfHeight;

    for (int x = targetX - halfWidth; x <= targetX + halfWidth; x++) {
      if (x < 0 || x >= _imageWidth) continue;
      for (int y = targetY - halfHeight; y <= targetY + halfHeight; y++) {
        if (y < 0 || y >= _imageHeight) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        float dSq = dx * dx / wSq + dy * dy / hSq;
        if (dSq > 1) continue;

        float factor = sqrt(dSq);
        factor = getFalloff(factor);
        factor = constrain(factor, 0, 1);

        float currentValue = _image.getFloatValue(x, y);
        _image.setFloatValue(x, y, constrain(currentValue + factor * _brushSettings.value(), 0, 1));
      }
    }
  }

  void voronoiBrush(int targetX, int targetY) {
    int halfWidth = floor(_brushSettings.width()/2);
    int halfHeight = floor(_brushSettings.height()/2);

    float wSq = halfWidth * halfWidth;
    float hSq = halfHeight * halfHeight;

    for (int x = targetX - halfWidth; x <= targetX + halfWidth; x++) {
      if (x < 0 || x >= _imageWidth) continue;
      for (int y = targetY - halfHeight; y <= targetY + halfHeight; y++) {
        if (y < 0 || y >= _imageHeight) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        float v = constrain(map(dx * dx / wSq + dy * dy / hSq, 0, 1, _brushSettings.value(), 0), 0, 1);

        float currentValue = _image.getFloatValue(x, y);
        _image.setFloatValue(x, y, max(currentValue, v));
      }
    }
  }

  void waveBrush(int targetX, int targetY) {
    int halfWidth = floor(_brushSettings.width()/2);
    int halfHeight = floor(_brushSettings.height()/2);

    float wSq = halfWidth * halfWidth;
    float hSq = halfHeight * halfHeight;

    for (int x = targetX - halfWidth; x <= targetX + halfWidth; x++) {
      if (x < 0 || x >= _imageWidth) continue;
      for (int y = targetY - halfHeight; y <= targetY + halfHeight; y++) {
        if (y < 0 || y >= _imageHeight) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        float d = sqrt(dx * dx / wSq  +  dy * dy / hSq);
        if (d > 1) continue;

        float factor = (cos(d * _brushSettings.waveCount() * 2 * PI) + 1) / 2;

        float currentValue = _image.getFloatValue(x, y);
        _image.setFloatValue(x, y, constrain(currentValue + factor * _brushSettings.value(), 0, 1));
      }
    }
  }

  void waveFalloffBrush(int targetX, int targetY) {
    int halfWidth = floor(_brushSettings.width()/2);
    int halfHeight = floor(_brushSettings.height()/2);

    float wSq = halfWidth * halfWidth;
    float hSq = halfHeight * halfHeight;

    for (int x = targetX - halfWidth; x <= targetX + halfWidth; x++) {
      if (x < 0 || x >= _imageWidth) continue;
      for (int y = targetY - halfHeight; y <= targetY + halfHeight; y++) {
        if (y < 0 || y >= _imageHeight) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        float d = sqrt(dx * dx / wSq +  dy * dy / hSq);
        if (d > 1) continue;

        float factor = d;
        factor = getFalloff(factor);
        factor = constrain(factor, 0, 1);

        factor *= (cos(d * _brushSettings.waveCount() * 2 * PI) + 1) / 2;

        float currentValue = _image.getFloatValue(x, y);
        _image.setFloatValue(x, y, constrain(currentValue + factor * _brushSettings.value(), 0, 1));
      }
    }
  }

  void rectWaveBrush(int targetX, int targetY) {
    int halfWidth = floor(_brushSettings.width()/2);
    int halfHeight = floor(_brushSettings.height()/2);
    int size = halfWidth;

    for (int x = targetX - halfWidth; x <= targetX + halfWidth; x++) {
      if (x < 0 || x >= _imageWidth) continue;
      for (int y = targetY - halfHeight; y <= targetY + halfHeight; y++) {
        if (y < 0 || y >= _imageWidth) continue;
        float factor = (cos(x * _brushSettings.waveCount() / size * 2 * PI) + 1) / 2;
        float currentValue = _image.getFloatValue(x, y);
        _image.setFloatValue(x, y, constrain(currentValue + factor * _brushSettings.value(), 0, 1));
      }
    }
  }

  private float getFalloff(float v) {
    float falloff = 0.88;
    return 1 + 1 / pow(v + falloff, 2) - 1 / pow(falloff, 2);
  }
}
