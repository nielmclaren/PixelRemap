
class DeepGrayscaleImage {
  float[] values;
  private PImage _image;
  private boolean _isImageDirty;
  private int _width;
  private int _height;

  DeepGrayscaleImage(int w, int h) {
    values = new float[w * h];
    _image = new PImage(w, h, ALPHA);
    _isImageDirty = true;
    _width = w;
    _height = h;
  }

  color getPixel(int x, int y) {
    return color(values[y * _width + x]);
  }

  void setPixel(int x, int y, color v) {
    values[y * _width + x] = brightness(v);
    _isImageDirty = true;
  }

  float getValue(int x, int y) {
    return values[y * _width + x];
  }

  void setValue(int x, int y, float v) {
    values[y * _width + x] = v;
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
      _image.pixels[i] = color(values[i]);
    }

    _image.updatePixels();

    _isImageDirty = false;
  }

  void setImage(PImage inputImg) {
    println("setImage");
    inputImg.loadPixels();
    int pixelCount = inputImg.width * inputImg.height;
    for (int i = 0; i < pixelCount; i++) {
      values[i] = brightness(inputImg.pixels[i]);
    }
    _isImageDirty = true;
  }
}
