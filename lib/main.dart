import 'dart:math';
import 'package:flutter/material.dart';

void main() => runApp(const FootballMathApp());

class FootballMathApp extends StatelessWidget {
  const FootballMathApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'حساب الكرة',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF2E7D32),
        scaffoldBackgroundColor: const Color(0xFFF1F8E9),
      ),
      builder: (context, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const HomeScreen(),
    );
  }
}

enum Op { add, sub, mul }

String opName(Op op) {
  switch (op) {
    case Op.add:
      return 'الجمع';
    case Op.sub:
      return 'الطرح';
    case Op.mul:
      return 'الضرب';
  }
}

String opSymbol(Op op) {
  switch (op) {
    case Op.add:
      return '+';
    case Op.sub:
      return '−';
    case Op.mul:
      return '×';
  }
}

// ------------------------- الشاشة الرئيسية -------------------------

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _button(BuildContext context, Op op, String emoji) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: double.infinity,
        height: 80,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GameScreen(op: op)),
          ),
          child: Text('$emoji  ${opName(op)}',
              style:
                  const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('⚽', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 8),
              const Text('حساب الكرة',
                  style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('اختر نوع الحساب',
                  style: TextStyle(fontSize: 22, color: Colors.black54)),
              const SizedBox(height: 32),
              _button(context, Op.add, '⚽'),
              _button(context, Op.sub, '🥅'),
              _button(context, Op.mul, '👟'),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------- شاشة اللعب -------------------------

class GameScreen extends StatefulWidget {
  final Op op;
  const GameScreen({super.key, required this.op});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final Random _rnd = Random();

  int a = 0;
  int b = 0;
  int answer = 0;
  List<int> options = [];
  int score = 0;
  bool solved = false;
  final Set<int> wrong = {};

  @override
  void initState() {
    super.initState();
    _newQuestion();
  }

  void _newQuestion() {
    switch (widget.op) {
      case Op.add:
        a = 1 + _rnd.nextInt(5);
        b = 1 + _rnd.nextInt(5);
        answer = a + b;
        break;
      case Op.sub:
        a = 2 + _rnd.nextInt(8);
        b = 1 + _rnd.nextInt(a - 1);
        answer = a - b;
        break;
      case Op.mul:
        a = 2 + _rnd.nextInt(4);
        b = 1 + _rnd.nextInt(4);
        answer = a * b;
        break;
    }

    final set = <int>{answer};
    while (set.length < 3) {
      final v = answer - 3 + _rnd.nextInt(7);
      if (v >= 0) set.add(v);
    }
    options = set.toList()..shuffle(_rnd);

    solved = false;
    wrong.clear();
  }

  void _choose(int value) {
    if (solved || wrong.contains(value)) return;
    setState(() {
      if (value == answer) {
        solved = true;
        score++;
      } else {
        wrong.add(value);
      }
    });
  }

  String get _story {
    switch (widget.op) {
      case Op.add:
        return 'سجّل الفريق $a ${_goalWord(a)} في الشوط الأول، '
            'و $b ${_goalWord(b)} في الشوط الثاني.\nكم هدف سجّل؟';
      case Op.sub:
        return 'عند الفريق $a كرات.\nضاعت $b ${b == 1 ? 'كرة' : 'كرات'}.\nكم بقي؟';
      case Op.mul:
        return '$a لاعبين، كل لاعب سجّل $b ${_goalWord(b)}.\nكم هدف في المجموع؟';
    }
  }

  String _goalWord(int n) => n == 1 ? 'هدف' : (n <= 10 ? 'أهداف' : 'هدفًا');

  Widget _balls(int n) {
    return Wrap(
      alignment: WrapAlignment.center,
      children: List.generate(
        n,
        (_) => const Text('⚽', style: TextStyle(fontSize: 30)),
      ),
    );
  }

  Widget _visual() {
    switch (widget.op) {
      case Op.add:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(child: _balls(a)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('+',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            ),
            Flexible(child: _balls(b)),
          ],
        );
      case Op.sub:
        return Column(
          children: [
            _balls(a),
            const Text('−',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
            _balls(b),
          ],
        );
      case Op.mul:
        return Column(
          children: List.generate(
            a,
            (i) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('👟 ', style: TextStyle(fontSize: 26)),
                  _balls(b),
                ],
              ),
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final message = solved
        ? 'هدااااف! ⚽ أحسنت'
        : (wrong.isNotEmpty ? 'قريب! جرّب رقم آخر 🙂' : ' ');

    return Scaffold(
      appBar: AppBar(
        title: Text('حساب ${opName(widget.op)}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: const Color(0xFFC8E6C9),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text('⚽ الأهداف: $score',
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              Text(_story,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, height: 1.6)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCEDC8),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _visual(),
              ),
              const SizedBox(height: 12),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  '$a ${opSymbol(widget.op)} $b = ${solved ? answer : '؟'}',
                  style: const TextStyle(
                      fontSize: 44, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 50,
                child: Center(
                  child: Text(message,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: solved
                              ? Colors.green.shade800
                              : Colors.orange.shade800)),
                ),
              ),
              Row(
                children: options.map((o) {
                  final isWrong = wrong.contains(o);
                  final isRight = solved && o == answer;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: SizedBox(
                        height: 80,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isRight
                                ? Colors.green
                                : (isWrong ? Colors.grey.shade300 : null),
                            foregroundColor: isRight ? Colors.white : null,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                          ),
                          onPressed:
                              (solved || isWrong) ? null : () => _choose(o),
                          child: Text('$o',
                              style: const TextStyle(
                                  fontSize: 34, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 64,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                  onPressed: solved ? () => setState(_newQuestion) : null,
                  child: const Text('السؤال التالي ←',
                      style: TextStyle(fontSize: 24)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}