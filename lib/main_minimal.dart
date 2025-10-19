import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Japa Mahamantra',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
        useMaterial3: true,
      ),
      home: const JapaMinimalScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class JapaMinimalScreen extends StatefulWidget {
  const JapaMinimalScreen({super.key});

  @override
  State<JapaMinimalScreen> createState() => _JapaMinimalScreenState();
}

class _JapaMinimalScreenState extends State<JapaMinimalScreen> {
  int _currentBead = 0;
  int _currentRound = 0;
  int _targetRounds = 108;
  bool _isSessionActive = false;
  Duration _sessionDuration = Duration.zero;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Japa Mahamantra'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Мантра
            Container(
              padding: const EdgeInsets.all(20),
              child: const Text(
                'Hare Krishna Hare Krishna\nKrishna Krishna Hare Hare',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 40),

            // Мала (108 бусин)
            Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.purple, width: 2),
              ),
              child: Stack(
                children: List.generate(108, (index) {
                  final angle = (index * 2 * 3.14159) / 108;
                  final x = 150 + 140 * cos(angle);
                  final y = 150 + 140 * sin(angle);

                  return Positioned(
                    left: x - 5,
                    top: y - 5,
                    child: GestureDetector(
                      onTap: () {
                        if (_isSessionActive && index == _currentBead) {
                          setState(() {
                            _currentBead++;
                            if (_currentBead >= 108) {
                              _currentBead = 0;
                              _currentRound++;
                            }
                          });
                        }
                      },
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index <= _currentBead
                              ? Colors.purple
                              : Colors.grey[300],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 40),

            // Статистика
            Text(
              'Круг: $_currentRound / $_targetRounds',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              'Бусина: $_currentBead / 108',
              style: const TextStyle(fontSize: 18),
            ),

            const SizedBox(height: 40),

            // Кнопки управления
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isSessionActive = !_isSessionActive;
                    });
                  },
                  child: Text(_isSessionActive ? 'Пауза' : 'Старт'),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentBead = 0;
                      _currentRound = 0;
                      _isSessionActive = false;
                    });
                  },
                  child: const Text('Сброс'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Импорт для cos и sin уже добавлен в начале файла
