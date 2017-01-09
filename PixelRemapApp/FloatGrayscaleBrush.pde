
class FloatGrayscaleBrush {
  FloatGrayscaleImage _image;
  int _imageWidth;
  int _imageHeight;

  int _size;
  int _width;
  int _height;

  float _value;
  int _step;
  int _prevStepX;
  int _prevStepY;

  String _type;

  float _wavelength;

  FloatGrayscaleBrush(FloatGrayscaleImage image, int w, int h) {
    _image = image;
    _imageWidth = w;
    _imageHeight = h;

    _size = 10;
    _width = 50;
    _height = 30;

    _value = 255;
    _step = 5;
    _prevStepX = 0;
    _prevStepY = 0;

    _type = "rect";

    _wavelength = 55;
  }

  int size() {
    return _size;
  }

  FloatGrayscaleBrush size(int v) {
    _size = v;
    return this;
  }

  int width() {
    return _width;
  }

  FloatGrayscaleBrush width(int v) {
    _width = v;
    return this;
  }

  int height() {
    return _height;
  }

  FloatGrayscaleBrush height(int v) {
    _height = v;
    return this;
  }

  float value() {
    return _value;
  }

  FloatGrayscaleBrush value(float v) {
    _value = v;
    return this;
  }

  int step() {
    return _step;
  }

  FloatGrayscaleBrush step(int v) {
    _step = v;
    return this;
  }

  boolean stepCheck(int x, int y) {
    float dx = x - _prevStepX;
    float dy = y - _prevStepY;
    return _step * _step < dx * dx  +  dy * dy;
  }

  FloatGrayscaleBrush stepped(int x, int y) {
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

  String type() {
    return _type;
  }

  FloatGrayscaleBrush type(String v) {
    _type = v;
    return this;
  }

  float wavelength() {
    return _wavelength;
  }

  FloatGrayscaleBrush wavelength(float v) {
    _wavelength = v;
    return this;
  }

  void draw(int x, int y) {
    switch (_type) {
      case "rect":
        brush.rectBrush(x, y);
        break;
      case "rectFalloff":
        brush.rectFalloffBrush(x, y);
        break;
      case "ellipse":
        brush.ellipseBrush(x, y);
        break;
      case "ellipseFalloff":
        brush.ellipseFalloffBrush(x, y);
        break;
      case "voronoi":
        brush.voronoiBrush(x, y);
        break;
      case "wave":
        brush.waveBrush(x, y, _wavelength);
        break;
      case "waveFalloff":
        brush.waveFalloffBrush(x, y, _wavelength);
        break;
      default:
    }
  }

  void rectBrush(int targetX, int targetY) {
    int halfWidth = floor(_width/2);
    int halfHeight = floor(_height/2);

    for (int x = targetX - halfWidth; x <= targetX + halfWidth; x++) {
      if (x < 0 || x >= _imageWidth) continue;
      for (int y = targetY - halfHeight; y <= targetY + halfHeight; y++) {
        if (y < 0 || y >= _imageWidth) continue;
        _image.setValue(x, y, _image.getValue(x, y) + 0.5 * _value);
      }
    }
  }

  void rectFalloffBrush(int targetX, int targetY) {
    int halfWidth = floor(_width/2);
    int halfHeight = floor(_height/2);

    for (int x = targetX - halfWidth; x <= targetX + halfWidth; x++) {
      if (x < 0 || x >= _imageWidth) continue;
      for (int y = targetY - halfHeight; y <= targetY + halfHeight; y++) {
        if (y < 0 || y >= _imageHeight) continue;
        float dx = abs(x - targetX);
        float dy = abs(y - targetY);

        float factor = max(dx / halfWidth, dy / halfHeight);
        factor = getFalloff(factor);
        factor = constrain(factor, 0, 1);

        float currentValue = _image.getValue(x, y);
        _image.setValue(x, y, constrain(currentValue + factor * _value, 0, 255));
      }
    }
  }

  void ellipseBrush(int targetX, int targetY) {
    int halfWidth = floor(_width/2);
    int halfHeight = floor(_height/2);

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
        _image.setValue(x, y, _image.getValue(x, y) + 0.5 * _value);
      }
    }
  }

  void ellipseFalloffBrush(int targetX, int targetY) {
    int halfWidth = floor(_width/2);
    int halfHeight = floor(_height/2);

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

        if (x == 100 && y == 100) {
          println(dSq, factor);
        }

        float currentValue = _image.getValue(x, y);
        _image.setValue(x, y, constrain(currentValue + factor * _value, 0, 255));
      }
    }
  }

  void voronoiBrush(int targetX, int targetY) {
    int halfWidth = floor(_width/2);
    int halfHeight = floor(_height/2);

    float wSq = halfWidth * halfWidth;
    float hSq = halfHeight * halfHeight;

    for (int x = targetX - halfWidth; x <= targetX + halfWidth; x++) {
      if (x < 0 || x >= _imageWidth) continue;
      for (int y = targetY - halfHeight; y <= targetY + halfHeight; y++) {
        if (y < 0 || y >= _imageHeight) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        float v = constrain(map(dx * dx / wSq + dy * dy / hSq, 0, 1, _value, 0), 0, 255);

        float currentValue = _image.getValue(x, y);
        _image.setValue(x, y, max(currentValue, v));
      }
    }
  }

  void waveBrush(int targetX, int targetY, float wavelength) {
    for (int x = targetX - _size; x <= targetX + _size; x++) {
      if (x < 0 || x >= _imageWidth) continue;
      for (int y = targetY - _size; y <= targetY + _size; y++) {
        if (y < 0 || y >= _imageHeight) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        float d = sqrt(dx * dx  +  dy * dy);
        if (d > _size) continue;

        float factor = (cos(d / wavelength * (2 * PI)) + 1) / 2;

        float currentValue = _image.getValue(x, y);
        _image.setValue(x, y, constrain(currentValue + factor * _value, 0, 255));
      }
    }
  }

  void waveFalloffBrush(int targetX, int targetY, float wavelength) {
    for (int x = targetX - _size; x <= targetX + _size; x++) {
      if (x < 0 || x >= _imageWidth) continue;
      for (int y = targetY - _size; y <= targetY + _size; y++) {
        if (y < 0 || y >= _imageHeight) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        float d = sqrt(dx * dx  +  dy * dy);
        if (d > _size) continue;

        float factor = d / _size;
        factor = getFalloff(factor);
        factor = constrain(factor, 0, 1);

        factor *= (cos(d / wavelength * (2 * PI)) + 1) / 2;

        float currentValue = _image.getValue(x, y);
        _image.setValue(x, y, constrain(currentValue + factor * _value, 0, 255));
      }
    }
  }

  private float getFalloff(float v) {
    float falloff = 0.88;
    return 1 + 1 / pow(v + falloff, 2) - 1 / pow(falloff, 2);
  }
}
