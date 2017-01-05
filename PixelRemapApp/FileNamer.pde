
class FileNamer {
  int currIndex;
  String prefix;
  String postfix;
  String extension;

  FileNamer() {
    currIndex = 0;
    prefix = "export";
    postfix = "";
    extension = "";
  }

  FileNamer(String _prefix, String _extension) {
    currIndex = 0;
    prefix = _prefix;
    postfix = "";
    extension = _extension;
  }

  FileNamer(String _prefix, String _postfix, String _extension) {
    currIndex = 0;
    prefix = _prefix;
    postfix = _postfix;
    extension = _extension;
  }

  String curr() {
    return getFilename(currIndex);
  }

  String next() {
    File file;
    while ((file = new File(sketchPath(getFilename(currIndex)))).exists() && currIndex < 1000) {
      currIndex++;
    }
    return getFilename(currIndex);
  }

  private String getFilename(int n) {
    String s = prefix + nf(n, 4) + postfix;
    if (extension == null || extension == "") return s;
    if (extension == "/") return s + extension;
    return s + "." + extension;
  }
}