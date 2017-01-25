
class BrushAction extends Action {
  private BrushSettings _brushSettings;
  private int _x;
  private int _y;

  public int type() {
    return ActionType.BRUSH;
  }

  BrushSettings brushSettings() {
    return _brushSettings;
  }

  BrushAction brushSettings(BrushSettings v) {
    _brushSettings = v;
    return this;
  }

  int x() {
    return _x;
  }

  BrushAction x(int v) {
    _x = v;
    return this;
  }

  int y() {
    return _y;
  }

  BrushAction y(int v) {
    _y = v;
    return this;
  }

  BrushAction position(int x, int y) {
    _x = x;
    _y = y;
    return this;
  }
}
