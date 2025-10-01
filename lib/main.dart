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
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const WordSearchGame(),
    );
  }
}

class WordSearchGame extends StatefulWidget {
  const WordSearchGame({super.key});

  @override
  _WordSearchGameState createState() => _WordSearchGameState();
}

class _WordSearchGameState extends State<WordSearchGame> {
  final int gridSize = 8; // Cuadrícula más pequeña para celulares (8x8)
  late List<List<String>> grid; // Cuadrícula de letras
  final List<String> words = ['FLUTTER', 'DART', 'WIDGET', 'ICONO']; // Palabras a buscar
  final List<String> foundWords = []; // Palabras encontradas
  String selectedLetters = ''; // Letras seleccionadas
  List<Offset> selectedPositions = []; // Posiciones seleccionadas

  @override
  void initState() {
    super.initState();
    grid = _generateGrid();
    _placeWords();
  }

  // Genera una cuadrícula con letras aleatorias
  List<List<String>> _generateGrid() {
    final random = Random();
    return List.generate(gridSize, (_) => List.generate(gridSize, (_) => 
        String.fromCharCode(65 + random.nextInt(26)))); // Letras de A-Z
  }

  // Coloca las palabras horizontalmente en la cuadrícula
  void _placeWords() {
    final random = Random();
    for (String word in words) {
      int row = random.nextInt(gridSize);
      int col = random.nextInt(gridSize - word.length);
      for (int i = 0; i < word.length; i++) {
        grid[row][col + i] = word[i];
      }
    }
  }

  // Verifica si las letras seleccionadas forman una palabra válida
  void _checkWord() {
    if (words.contains(selectedLetters) && !foundWords.contains(selectedLetters)) {
      setState(() {
        foundWords.add(selectedLetters);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('¡Encontraste: $selectedLetters!')),
      );
    }
    setState(() {
      selectedLetters = '';
      selectedPositions = [];
    });
  }

  @override
  Widget build(BuildContext context) {
    // Obtener el tamaño de la pantalla para ajustar la cuadrícula
    final screenWidth = MediaQuery.of(context).size.width;
    final cellSize = screenWidth / (gridSize + 1); // Tamaño dinámico de las celdas

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sopa de Letras'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icono decorativo
                const Icon(
                  Icons.favorite,
                  color: Colors.red,
                  size: 40.0, // Tamaño ajustado para móviles
                ),
                const SizedBox(height: 10),
                // Cuadrícula de la sopa de letras
                Container(
                  width: screenWidth * 0.95, // 95% del ancho de la pantalla
                  height: screenWidth * 0.95, // Cuadrado para mantener proporción
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: gridSize,
                      childAspectRatio: 1,
                    ),
                    itemCount: gridSize * gridSize,
                    itemBuilder: (context, index) {
                      int row = index ~/ gridSize;
                      int col = index % gridSize;
                      bool isSelected = selectedPositions.contains(Offset(row.toDouble(), col.toDouble()));
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (!isSelected) {
                              selectedPositions.add(Offset(row.toDouble(), col.toDouble()));
                              selectedLetters += grid[row][col];
                              _checkWord();
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue[100] : Colors.grey[200],
                            border: Border.all(color: Colors.black54),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Center(
                            child: Text(
                              grid[row][col],
                              style: TextStyle(
                                fontSize: cellSize * 0.4, // Tamaño de fuente dinámico
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                // Lista de palabras a encontrar
                Text(
                  'Palabras: ${words.join(", ")}',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 5),
                // Palabras encontradas
                Text(
                  'Encontradas: ${foundWords.isEmpty ? "Ninguna" : foundWords.join(", ")}',
                  style: const TextStyle(fontSize: 16, color: Colors.green),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}