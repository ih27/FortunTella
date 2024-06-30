import 'package:flutter/material.dart';
import '../controllers/fortune_teller.dart';
import '../controllers/openai_fortune_teller.dart';
import '../controllers/gemini_fortune_teller.dart';
import '../helpers/constants.dart';
import '../services/firestore_service.dart';
import '../widgets/form_button.dart';

class FortuneTellScreen extends StatefulWidget {
  const FortuneTellScreen({super.key});

  @override
  _FortuneTellScreenState createState() => _FortuneTellScreenState();
}

class _FortuneTellScreenState extends State<FortuneTellScreen> {
  final TextEditingController _questionController = TextEditingController();
  FortuneTeller? _fortuneTeller;
  List<TextSpan> _fortuneSpans = [];
  bool _isLoading = false;
  String _selectedFortuneTeller = 'OpenAI';
  final List<String> _fortuneTellers = ['OpenAI', 'Gemini'];
  List<String> _randomQuestions = [];
  final int _numberOfQuestionsPerCategory = 2;

  @override
  void initState() {
    super.initState();
    _initializeFortuneTeller();
    _fetchRandomQuestions();
  }

  void _initializeFortuneTeller() {
    if (_selectedFortuneTeller == 'OpenAI') {
      _fortuneTeller = OpenAIFortuneTeller(PersonaInstructions.fortuneTeller);
    } else {
      _fortuneTeller = GeminiFortuneTeller(PersonaInstructions.wiseSage);
    }
  }

  Future<void> _fetchRandomQuestions() async {
    final randomQuestions = await FirestoreService.fetchRandomQuestions(
        _numberOfQuestionsPerCategory);
    setState(() {
      _randomQuestions = randomQuestions;
    });
  }

  void _getFortune(String question) {
    setState(() {
      _isLoading = true;
      _fortuneSpans = [];
    });

    try {
      if (_fortuneTeller != null) {
        _fortuneTeller!.getFortune(question).listen(
          (fortunePart) {
            setState(() {
              _fortuneSpans = List.from(_fortuneSpans)
                ..add(TextSpan(text: fortunePart));
            });
          },
          onDone: () {
            setState(() {
              _fortuneSpans = List.from(_fortuneSpans)
                ..add(const TextSpan(text: '🔮'));
              _isLoading = false;
            });
          },
          onError: (error) {
            setState(() {
              _fortuneSpans = List.from(_fortuneSpans)
                ..add(
                    TextSpan(text: 'Unexpected error occurred. Error: $error'));
              _isLoading = false;
            });
          },
        );
      } else {
        setState(() {
          _fortuneSpans = List.from(_fortuneSpans)
            ..add(const TextSpan(text: 'No fortune teller selected.'));
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _fortuneSpans = List.from(_fortuneSpans)
          ..add(TextSpan(text: 'Failed to fetch fortune. Error: $e'));
        _isLoading = false;
      });
    }
  }

  void _onFortuneTellerChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedFortuneTeller = newValue;
        _initializeFortuneTeller();
      });
    }
  }

  void _onQuestionSelected(String question) {
    _getFortune(question);
  }

  @override
  Widget build(BuildContext context) {
    return _fortuneSpans.isEmpty ? _buildInitialScreen() : _buildAnswerScreen();
  }

  Widget _buildInitialScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Ask your question and get a fortune reading!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Text('Choose your fortune teller:'),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedFortuneTeller,
                  onChanged: _onFortuneTellerChanged,
                  items: _fortuneTellers
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _questionController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Your Question',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          FormButton(
            text: 'Get Fortune',
            onPressed: () => _getFortune(_questionController.text),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _randomQuestions.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _onQuestionSelected(_randomQuestions[index]),
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4.0),
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4.0),
                    ),
                    child: Text(_randomQuestions[index]),
                  ),
                );
              },
            ),
          ),
          if (_isLoading) const CircularProgressIndicator(),
        ],
      ),
    );
  }

  Widget _buildAnswerScreen() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: RichText(
                text: TextSpan(
                  children: _fortuneSpans,
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.normal,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          FormButton(
            text: 'Continue',
            onPressed: () {
              setState(() {
                _questionController.clear();
                _fortuneSpans = [];
                _fetchRandomQuestions();
              });
            },
          ),
        ],
      ),
    );
  }
}
