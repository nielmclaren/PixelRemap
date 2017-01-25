
class BrushSettings {
  int _width;
  int _height;

  float _value;
  int _step;
  int _type;
  float _waveCount;

  public final int TYPE_RECT = 0;
  public final int TYPE_RECT_FALLOFF = 1;
  public final int TYPE_ELLIPSE = 2;
  public final int TYPE_ELLIPSE_FALLOFF = 3;
  public final int TYPE_VORONOI = 4;
  public final int TYPE_WAVE = 5;
  public final int TYPE_WAVE_FALLOFF = 6;
  public final int TYPE_RECT_WAVE = 7;

  BrushSettings() {
    _width = 50;
    _height = 30;

    _value = 1;
    _step = 5;
    _type = TYPE_RECT;
    _waveCount = 4;
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
}
