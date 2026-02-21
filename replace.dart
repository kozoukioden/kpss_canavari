import 'dart:io';

void main() {
  final file = File('colab_notebooks/04_rag_testing.ipynb');
  var content = file.readAsStringSync();
  content = content.replaceAll('AIzaSyAxZ2TFVRz9eorr_SAQ_kP3-PhKhtCZoAE', 'YOUR_GEMINI_API_KEY_HERE');
  file.writeAsStringSync(content);
}
