
class BrushSettings implements Cloneable {
  int _width;
  int _height;

  float _value;
  int _step;
  int _type;
  float _waveCount;

  int _blendMode;

  BrushSettings() {
    _width = 50;
    _height = 30;

    _value = 1;
    _step = 5;
    _type = BrushType.RECT;
    _waveCount = 4;

    _blendMode = BlendMode.ADD;
  }

  int width() {
    return _width;
  }

  BrushSettings width(int v) {
    _width = v;
    return this;
  }

  int height() {
    return _height;
  }

  BrushSettings height(int v) {
    _height = v;
    return this;
  }

  float value() {
    return _value;
  }

  BrushSettings value(float v) {
    _value = v;
    return this;
  }

  int step() {
    return _step;
  }

  BrushSettings step(int v) {
    _step = v;
    return this;
  }

  int type() {
    return _type;
  }

  BrushSettings type(int v) {
    _type = v;
    return this;
  }

  float waveCount() {
    return _waveCount;
  }

  BrushSettings waveCount(float v) {
    _waveCount = v;
    return this;
  }

  int blendMode() {
    return _blendMode;
  }

  BrushSettings blendMode(int v) {
    _blendMode = v;
    return this;
  }

  Object clone() {
    return new BrushSettings()
      .width(_width)
      .height(_height)
      .value(_value)
      .step(_step)
      .type(_type)
      .waveCount(_waveCount)
      .blendMode(_blendMode);
  }
}
