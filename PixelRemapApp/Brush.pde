
class Brush {
  DeepGrayscaleImage _image;
  int _imageWidth;
  int _imageHeight;

  BrushSettings _brushSettings;

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
    return (BrushSettings)_brushSettings.clone();
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
    draw(x, y, 0);
  }

  void draw(int x, int y, float timeOffset) {
    switch (_brushSettings.type()) {
      case BrushType.RECT:
        brush.rectBrush(x, y);
        break;
      case BrushType.RECT_FALLOFF:
        brush.rectFalloffBrush(x, y);
        break;
      case BrushType.ELLIPSE:
        brush.ellipseBrush(x, y);
        break;
      case BrushType.ELLIPSE_FALLOFF:
        brush.ellipseFalloffBrush(x, y);
        break;
      case BrushType.VORONOI:
        brush.voronoiBrush(x, y);
        break;
      case BrushType.WAVE:
        brush.waveBrush(x, y, timeOffset);
        break;
      case BrushType.WAVE_FALLOFF:
        brush.waveFalloffBrush(x, y, timeOffset);
        break;
      case BrushType.RECT_WAVE:
        brush.rectWaveBrush(x, y, timeOffset);
        break;
      default:
    }
  }

  void drawOutline(int x, int y) {
    noFill();
    stroke(128);
    strokeWeight(2);

    switch (_brushSettings.type()) {
      case BrushType.RECT:
      case BrushType.RECT_FALLOFF:
      case BrushType.RECT_WAVE:
        rectMode(CENTER);
        rect(mouseX, mouseY, _brushSettings.width(), _brushSettings.height());
        break;
      case BrushType.ELLIPSE:
      case BrushType.ELLIPSE_FALLOFF:
      case BrushType.VORONOI:
      case BrushType.WAVE:
      case BrushType.WAVE_FALLOFF:
        ellipseMode(CENTER);
        ellipse(mouseX, mouseY, _brushSettings.width(), _brushSettings.height());
        break;
      default:
    }
  }

  void rectBrush(int targetX, int targetY) {
    int halfWidth = floor(_brushSettings.width()/2);
    int halfHeight = floor(_brushSettings.height()/2);

    for (int x = targetX - halfWidth; x <= targetX + halfWidth; x++) {
      if (x < 0 || x >= _imageWidth) continue;
      for (int y = targetY - halfHeight; y <= targetY + halfHeight; y++) {
        if (y < 0 || y >= _imageWidth) continue;
        _image.setFloatValue(x, y, blendFloatValue(_image.getFloatValue(x, y), _brushSettings.value()));
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

        _image.setFloatValue(x, y, blendFloatValue(_image.getFloatValue(x, y), factor * _brushSettings.value()));
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

        _image.setFloatValue(x, y, blendFloatValue(_image.getFloatValue(x, y), _brushSettings.value()));
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

        _image.setFloatValue(x, y, blendFloatValue(_image.getFloatValue(x, y), factor * _brushSettings.value()));
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

  void waveBrush(int targetX, int targetY, float timeOffset) {
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

        float factor = (cos((d * _brushSettings.waveCount() - timeOffset) * 2 * PI) + 1) / 2;

        _image.setFloatValue(x, y, blendFloatValue(_image.getFloatValue(x, y), factor * _brushSettings.value()));
      }
    }
  }

  void waveFalloffBrush(int targetX, int targetY, float timeOffset) {
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

        factor *= (cos((d * _brushSettings.waveCount() - timeOffset) * 2 * PI) + 1) / 2;

        _image.setFloatValue(x, y, blendFloatValue(_image.getFloatValue(x, y), factor * _brushSettings.value()));
      }
    }
  }

  void rectWaveBrush(int targetX, int targetY, float timeOffset) {
    int halfWidth = floor(_brushSettings.width()/2);
    int halfHeight = floor(_brushSettings.height()/2);
    int size = halfWidth;

    for (int x = targetX - halfWidth; x <= targetX + halfWidth; x++) {
      if (x < 0 || x >= _imageWidth) continue;
      for (int y = targetY - halfHeight; y <= targetY + halfHeight; y++) {
        if (y < 0 || y >= _imageWidth) continue;
        float factor = (cos((x * _brushSettings.waveCount() / size - timeOffset) * 2 * PI) + 1) / 2;
        _image.setFloatValue(x, y, blendFloatValue(_image.getFloatValue(x, y), factor * _brushSettings.value()));
      }
    }
  }

  private float blendFloatValue(float original, float target) {
    int blendMode = _brushSettings.blendMode();
    switch (blendMode) {
      case BlendMode.BLEND:
        return target;
      case BlendMode.ADD:
        return constrain(original + target, 0, 1);
      case BlendMode.SUBTRACT:
        return constrain(original - target, 0, 1);
      default:
        return target;
    }
  }

  private float getFalloff(float v) {
    float falloff = 0.88;
    return 1 + 1 / pow(v + falloff, 2) - 1 / pow(falloff, 2);
  }
}
