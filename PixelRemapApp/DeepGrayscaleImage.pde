
class DeepGrayscaleImage {
  private short[] values;
  private PImage _image;
  private boolean _isImageDirty;
  private int _width;
  private int _height;

  DeepGrayscaleImage(int w, int h) {
    values = new short[w * h];
    _image = new PImage(w, h, ALPHA);
    _isImageDirty = true;
    _width = w;
    _height = h;
  }

  color getPixel(int x, int y) {
    return color(deepToFloat(values[y * _width + x]) * 256.0);
  }

  void setPixel(int x, int y, color v) {
    values[y * _width + x] = floatToDeep(brightness(v) / 256.0);
    _isImageDirty = true;
  }

  short getValue(int x, int y) {
    return values[y * _width + x];
  }

  void setValue(int x, int y, short v) {
    values[y * _width + x] = v;
    _isImageDirty = true;
  }

  float getFloatValue(int x, int y) {
    return deepToFloat(values[y * _width + x]);
  }

  void setFloatValue(int x, int y, float v) {
    values[y * _width + x] = floatToDeep(v);
    _isImageDirty = true;
  }

  PImage getImageRef() {
    if (_isImageDirty) {
      updateImage();
    }
    return _image;
  }

  private void updateImage() {
    _image.loadPixels();

    int pixelCount = _width * _height;
    for (int i = 0; i < pixelCount; i++) {
      _image.pixels[i] = color(deepToFloat(values[i]) * 256.0);
    }

    _image.updatePixels();

    _isImageDirty = false;
  }

  void setImage(PImage inputImg) {
    inputImg.loadPixels();

    int pixelCount = inputImg.width * inputImg.height;
    for (int i = 0; i < pixelCount; i++) {
      values[i] = floatToDeep(brightness(inputImg.pixels[i]) / 256.0);
    }
    _isImageDirty = true;
  }

  private float deepToFloat(int v) {
    return ((float)v - Short.MIN_VALUE) / (Short.MAX_VALUE - Short.MIN_VALUE);
  }

  private short floatToDeep(float v) {
    return (short)(v * (Short.MAX_VALUE - Short.MIN_VALUE - 1) + Short.MIN_VALUE);
  }
}
