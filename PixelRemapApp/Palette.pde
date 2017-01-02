
class Palette {
  color[] _colors;

  ArrayList<String> _filenames;
  int _filenameIndex;

  int _repeatCount;
  boolean _isMirrored;
  boolean _isReversed;

  Palette() {
    _colors = new color[1];
    _colors[0] = color(0);

    _filenames = new ArrayList<String>();
    _filenameIndex = 0;

    _repeatCount = 1;
    _isMirrored = false;
    _isReversed = false;
  }

  color[] getColorsRef() {
    return _colors;
  }

  int repeatCount() {
    return _repeatCount;
  }

  Palette repeatCount(int v) {
    _repeatCount = v;
    reload();
    return this;
  }

  boolean isMirrored() {
    return _isMirrored;
  }

  Palette isMirrored(boolean v) {
    _isMirrored = v;
    reload();
    return this;
  }

  Palette toggleMirrored() {
    _isMirrored = !_isMirrored;
    reload();
    return this;
  }

  boolean isReversed() {
    return _isReversed;
  }

  Palette isReversed(boolean v) {
    _isReversed = v;
    reload();
    return this;
  }

  Palette toggleReversed() {
    _isReversed = !_isReversed;
    reload();
    return this;
  }

  Palette addFilename(String filename) {
    _filenames.add(filename);

    if (_filenames.size() == 1) {
      reload();
    }

    return this;
  }

  void loadPrevious() {
    _filenameIndex = (_filenameIndex + _filenames.size() - 1) % _filenames.size();
    reload();
  }

  void loadNext() {
    _filenameIndex = (_filenameIndex + 1) % _filenames.size();
    reload();
  }

  private void reload() {
    if (!_filenames.isEmpty()) {
      String filename = _filenames.get(_filenameIndex);
      load(filename);
    }
  }

  private void load(String filename) {
    PImage paletteImg = loadImage(filename);
    _colors = new color[paletteImg.width * _repeatCount];
    paletteImg.loadPixels();
    for (int repeat = 0; repeat < _repeatCount; repeat++) {
      for (int i = 0; i < paletteImg.width; i++) {
        int index = i;
        if (_isReversed) {
          index = paletteImg.width - index - 1;
        }
        if (_isMirrored && repeat % 2 == 1) {
          index = (repeat + 1) * paletteImg.width - index - 1;
        }
        else {
          index = repeat * paletteImg.width + index;
        }
        _colors[index] = paletteImg.pixels[i];
      }
    }
  }
}
