import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdf_text/flutter_pdf_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:math';

// void main() {
//   runApp(MaterialApp(home: ProspectusQA()));
// }

class ProspectusQA extends StatefulWidget {
  const ProspectusQA({super.key});

  @override
  State<ProspectusQA> createState() => _ProspectusQAState();
}

class _ProspectusQAState extends State<ProspectusQA> {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _controller = TextEditingController();
  bool isloading = false;

  bool _isListening = false;
  String _pdfText = "Please upload prospectus file.";
  String _answer = "";

  Future<void> _pickAndExtractPDF() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        isloading = true;
      });
      final file = File(result.files.single.path!);

      final pdfDoc = await PDFDoc.fromPath(file.path);
      String text1 = await pdfDoc.text;
      setState(() {
        _pdfText = "Upload Complete";
        _answer = '';
         isloading = false;
      });
    }
  }

  Future<void> _listen() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech.listen(
          onResult: (val) {
            if (val.finalResult) {
              setState(() {
                _isListening = false;
                _controller.text = val.recognizedWords;
              });
              _processQuestion(val.recognizedWords);
            }
          },
        );
      }
    } else {
      _speech.stop();
      setState(() => _isListening = false);
    }
  }

  Future<void> _processQuestion(String question) async {
    if (_pdfText.isEmpty || _pdfText == "Please upload a prospectus.") {
      setState(() => _answer = "Please upload a prospectus file first.");
      return;
    }

    final bestMatch = findBestMatch(question, _pdfText);
    setState(() => _answer = bestMatch);
    await _tts.speak(bestMatch);
  }

  String findBestMatch(String question, String fullText) {
    final qWords = _normalize(question);
    final docSentences =
        fullText.split(RegExp(r'[.?!]\s+')).map(_normalize).toList();

    final idf = _computeIDF([qWords, ...docSentences]);
    final questionTF = _computeTF(qWords);
    final questionTFIDF = {
      for (final key in questionTF.keys) key: questionTF[key]! * (idf[key] ?? 0)
    };

    double bestScore = 0.5;
    int bestIndex = -1;

    for (int i = 0; i < docSentences.length; i++) {
      final sentenceTF = _computeTF(docSentences[i]);
      final sentenceTFIDF = {
        for (final key in sentenceTF.keys)
          key: sentenceTF[key]! * (idf[key] ?? 0)
      };
      final score = _cosineSimilarity(questionTFIDF, sentenceTFIDF);
      if (score > bestScore) {
        bestScore = score;
        bestIndex = i;
      }
    }

    final sentences = fullText.split(RegExp(r'[.?!]\s+'));
    return bestIndex != -1
        ? sentences[bestIndex].trim()
        : "Sorry, I couldn't find an answer.";
  }

  final _stopWords = {
    'the',
    'is',
    'are',
    'can',
    'i',
    'you',
    'when',
    'what',
    'where',
    'how',
    'a',
    'an',
    'in',
    'of',
    'to',
    'on',
    'for'
  };

  List<String> _normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(RegExp(r'\s+'))
        .where((word) => !_stopWords.contains(word))
        .map((w) => _rootify(w))
        .toList();
  }

  String _rootify(String word) {
    return word.replaceAll(RegExp(r'(ing|ed|es|s)$'), '');
  }

  Map<String, double> _computeTF(List<String> words) {
    final tf = <String, double>{};
    final total = words.length;
    for (final word in words) {
      tf[word] = (tf[word] ?? 0) + 1;
    }
    tf.updateAll((key, value) => value / total);
    return tf;
  }

  Map<String, double> _computeIDF(List<List<String>> docs) {
    final idf = <String, double>{};
    final totalDocs = docs.length;
    for (final doc in docs) {
      final uniqueWords = doc.toSet();
      for (final word in uniqueWords) {
        idf[word] = (idf[word] ?? 0) + 1;
      }
    }
    idf.updateAll((key, value) => log(totalDocs / value));
    return idf;
  }

  double _cosineSimilarity(Map<String, double> vec1, Map<String, double> vec2) {
    final allKeys = {...vec1.keys, ...vec2.keys};
    double dot = 0, mag1 = 0, mag2 = 0;
    for (final key in allKeys) {
      final v1 = vec1[key] ?? 0;
      final v2 = vec2[key] ?? 0;
      dot += v1 * v2;
      mag1 += v1 * v1;
      mag2 += v2 * v2;
    }
    return (mag1 == 0 || mag2 == 0) ? 0 : dot / (sqrt(mag1) * sqrt(mag2));
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD), // Light blue background
      appBar: AppBar(
        title: const Text(
          "Prospectus",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF2196F3), // Material Blue
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            tooltip: "Upload PDF",
            onPressed: _pickAndExtractPDF,
          ),
        ],
      ),
      body: isloading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    elevation: 5,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      child: TextField(
                        controller: _controller,
                        onSubmitted: _processQuestion,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Ask a question',
                          labelStyle: TextStyle(color: Colors.blueGrey),
                          suffixIcon: Icon(Icons.send, color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isListening
                          ? Colors.redAccent
                          : const Color(0xFF64B5F6),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                    ),
                    icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                    label: Text(
                      _isListening ? "Listening..." : "Speak",
                      style: const TextStyle(fontSize: 16),
                    ),
                    onPressed: _listen,
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Container(
                      width: w * 0.9,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        child: Text(
                          _answer.isEmpty ? _pdfText : _answer,
                          style: const TextStyle(
                              fontSize: 16, color: Colors.black87),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
