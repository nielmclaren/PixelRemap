
class FloatGrayscaleBrush {
  FloatGrayscaleImage _image;
  int _width;
  int _height;
  int _size;
  float _value;
  int _step;
  int _prevStepX;
  int _prevStepY;

  FloatGrayscaleBrush(FloatGrayscaleImage image, int w, int h) {
    _image = image;
    _width = w;
    _height = h;

    _size = 10;
    _value = 255;
    _step = 5;
    _prevStepX = 0;
    _prevStepY = 0;
  }

  int size() {
    return _size;
  }

  FloatGrayscaleBrush size(int v) {
    _size = v;
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

  void squareBrush(int targetX, int targetY) {
    for (int x = targetX - _size; x <= targetX + _size; x++) {
      if (x < 0 || x >= _width) continue;
      for (int y = targetY - _size; y <= targetY + _size; y++) {
        if (y < 0 || y >= _width) continue;
        _image.setValue(x, y, _image.getValue(x, y) + 0.5 * _value);
      }
    }
  }

  void squareFalloffBrush(int targetX, int targetY) {
    float falloff = 0.88;

    for (int x = targetX - _size; x <= targetX + _size; x++) {
      if (x < 0 || x >= _width) continue;
      for (int y = targetY - _size; y <= targetY + _size; y++) {
        if (y < 0 || y >= _height) continue;
        float dx = abs(x - targetX);
        float dy = abs(y - targetY);

        float factor = max(dx, dy) / _size;
        factor = 1 + 1 / pow(factor + falloff, 2) - 1 / pow(falloff, 2);
        factor = constrain(factor, 0, 1);

        float currentValue = _image.getValue(x, y);
        _image.setValue(x, y, constrain(currentValue + factor * _value, 0, 255));
      }
    }
  }

  void circleBrush(int targetX, int targetY) {
    for (int x = targetX - _size; x <= targetX + _size; x++) {
      if (x < 0 || x >= _width) continue;
      for (int y = targetY - _size; y <= targetY + _size; y++) {
        if (y < 0 || y >= _height) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        if (dx * dx  +  dy * dy > _size * _size) continue;
        // FIXME: Factor out blend mode.
        _image.setValue(x, y, _image.getValue(x, y) + 0.5 * _value);
      }
    }
  }

  void circleFalloffBrush(int targetX, int targetY) {
    float falloff = 0.88;
    int brushSizeSq = _size * _size;

    for (int x = targetX - _size; x <= targetX + _size; x++) {
      if (x < 0 || x >= _width) continue;
      for (int y = targetY - _size; y <= targetY + _size; y++) {
        if (y < 0 || y >= _height) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        float dSq = dx * dx + dy * dy;
        if (dSq > brushSizeSq) continue;

        float factor = sqrt(dSq) / _size;
        factor = 1 + 1 / pow(factor + falloff, 2) - 1 / pow(falloff, 2);
        factor = constrain(factor, 0, 1);

        float currentValue = _image.getValue(x, y);
        _image.setValue(x, y, constrain(currentValue + factor * _value, 0, 255));
      }
    }
  }

  void voronoiBrush(int targetX, int targetY) {
    for (int x = targetX - _size; x <= targetX + _size; x++) {
      if (x < 0 || x >= _width) continue;
      for (int y = targetY - _size; y <= targetY + _size; y++) {
        if (y < 0 || y >= _height) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        float v = constrain(map(dx * dx + dy * dy, 0, _size * _size, _value, 0), 0, 255);

        float currentValue = _image.getValue(x, y);
        _image.setValue(x, y, max(currentValue, v));
      }
    }
  }

  void waveBrush(int targetX, int targetY, int wavelength) {
    for (int x = targetX - _size; x <= targetX + _size; x++) {
      if (x < 0 || x >= _width) continue;
      for (int y = targetY - _size; y <= targetY + _size; y++) {
        if (y < 0 || y >= _height) continue;
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

  void waveFalloffBrush(int targetX, int targetY, int wavelength) {
    float falloff = 0.88;
    for (int x = targetX - _size; x <= targetX + _size; x++) {
      if (x < 0 || x >= _width) continue;
      for (int y = targetY - _size; y <= targetY + _size; y++) {
        if (y < 0 || y >= _height) continue;
        float dx = x - targetX;
        float dy = y - targetY;
        float d = sqrt(dx * dx  +  dy * dy);
        if (d > _size) continue;

        float factor = d / _size;
        factor = 1 + 1 / pow(factor + falloff, 2) - 1 / pow(falloff, 2);
        factor = constrain(factor, 0, 1);

        factor *= (cos(d / wavelength * (2 * PI)) + 1) / 2;

        float currentValue = _image.getValue(x, y);
        _image.setValue(x, y, constrain(currentValue + factor * _value, 0, 255));
      }
    }
  }
}
