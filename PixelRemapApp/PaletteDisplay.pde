
public class PaletteDisplay {
  private float _x;
  private float _y;
  private float _w;
  private float _h;

  private color[] _palette;

  PaletteDisplay(float xArg, float yArg, float wArg, float hArg) {
    _x = xArg;
    _y = yArg;
    _w = wArg;
    _h = hArg;

    _palette = new color[1];
    _palette[0] = color(0);
  }

  public void draw(PGraphics g) {
    g.noStroke();
    g.fill(32);
    g.rect(_x, _y, _w, _h);

    drawPalette(g);
    drawBorder(g);
  }

  private void drawPalette(PGraphics g) {
    for (int i = 0; i < _palette.length; i++) {
      g.fill(_palette[_palette.length - i - 1]);
      g.rect(_x, _y, _w, _h * (1 - (float) i / _palette.length));
    }
  }

  private void drawBorder(PGraphics g) {
    g.stroke(255);
    g.noFill();
    g.rect(_x, _y, _w, _h);
  }

  public void setPalette(color[] p) {
    _palette = p;
  }
}
