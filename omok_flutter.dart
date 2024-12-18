// ignore_for_file: constant_identifier_names

import 'package:flutter/material.dart';

void main() {
  runApp(const OmokApp());
}

class OmokApp extends StatelessWidget {
  const OmokApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Omok Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const OmokGameScreen(),
    );
  }
}

class OmokGameScreen extends StatefulWidget {
  const OmokGameScreen({super.key});

  @override
  OmokGameScreenState createState() => OmokGameScreenState();
}

class OmokGameScreenState extends State<OmokGameScreen> {
  static const int BOARD_SIZE = 15;
  static const String PLAYER_X = 'X';
  static const String PLAYER_O = 'O';
  static const String EMPTY = '.';

  late List<List<String>> board;
  late String currentPlayer;
  late bool gameOver;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  void _initializeGame() {
    board = List.generate(BOARD_SIZE, (_) => List.filled(BOARD_SIZE, EMPTY));
    currentPlayer = PLAYER_X;
    gameOver = false;
  }

  void _makeMove(int x, int y) {
    if (!gameOver && _isValidMove(x, y)) {
      setState(() {
        board[x][y] = currentPlayer;

        if (_checkWin(x, y)) {
          _endGame('Player $currentPlayer wins!');
        } else if (_isBoardFull()) {
          _endGame("It's a draw!");
        } else {
          _switchPlayer();
        }
      });
    }
  }

  void _endGame(String message) {
    gameOver = true;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Game Over'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('Play Again'),
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _initializeGame();
                });
              },
            ),
          ],
        );
      },
    );
  }

  int max(int a, int b) => a > b ? a : b;
  double maxD(double a, double b) => a > b ? a : b;
  int min(int a, int b) => a < b ? a : b;
  double minD(double a, double b) => a < b ? a : b;

  void _switchPlayer() {
    currentPlayer = (currentPlayer == PLAYER_X) ? PLAYER_O : PLAYER_X;
  }

  bool _isValidMove(int x, int y) {
    return x >= 0 &&
        x < BOARD_SIZE &&
        y >= 0 &&
        y < BOARD_SIZE &&
        board[x][y] == EMPTY;
  }

  bool _isBoardFull() {
    return board.every((row) => row.every((cell) => cell != EMPTY));
  }

  bool _checkWin(int x, int y) {
    return _checkHorizontal(x, y) ||
        _checkVertical(x, y) ||
        _checkDiagonalRight(x, y) ||
        _checkDiagonalLeft(x, y);
  }

  bool _checkHorizontal(int x, int y) {
    for (int y = 0; y < BOARD_SIZE; y++) {
      int count = 0;
      for (int j = max(0, y - 4); j < min(BOARD_SIZE, y + 5); j++) {
        if (board[x][j] == currentPlayer) {
          count++;
          if (count == 5) return true;
        } else {
          count = 0;
        }
      }
    }
    return false;
  }

  bool _checkVertical(int x, int y) {
    for (int x = 0; x < BOARD_SIZE; x++) {
      int count = 0;
      for (int i = max(0, x - 4); i < min(BOARD_SIZE, x + 5); i++) {
        if (board[i][y] == currentPlayer) {
          count++;
          if (count == 5) return true;
        } else {
          count = 0;
        }
      }
    }
    return false;
  }

  bool _checkDiagonalRight(int x, int y) {
    for (int k = -4; k <= 0; k++) {
      int count = 0;
      for (int i = 0; i < 5; i++) {
        int newX = x + k + i;
        int newY = y + k + i;

        if (newX >= 0 &&
            newX < BOARD_SIZE &&
            newY >= 0 &&
            newY < BOARD_SIZE &&
            board[newX][newY] == currentPlayer) {
          count++;
          if (count == 5) return true;
        } else {
          continue;
        }
      }
    }
    return false;
  }

  bool _checkDiagonalLeft(int x, int y) {
    for (int k = -4; k <= 4; k++) {
      int count = 0;
      for (int i = 0; i < 5; i++) {
        int newX = x + k + i;
        int newY = y - k - i;

        if (newX >= 0 &&
            newX < BOARD_SIZE &&
            newY >= 0 &&
            newY < BOARD_SIZE &&
            board[newX][newY] == currentPlayer) {
          count++;
          if (count == 5) return true;
        } else {
          count = 0;
        }
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Omok Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _initializeGame();
              });
            },
          )
        ],
      ),
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calculate board width (max 750, use full width if smaller)
            double boardWidth = minD(
                minD(constraints.maxWidth * 0.9,
                    constraints.maxHeight * 0.9), // 90% of screen width
                750.0 // Maximum width
                );

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Current Player: $currentPlayer',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                Container(
                  width: boardWidth,
                  height: boardWidth, // Square board
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                  ),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: BOARD_SIZE,
                    ),
                    itemCount: BOARD_SIZE * BOARD_SIZE,
                    itemBuilder: (context, index) {
                      int x = index ~/ BOARD_SIZE;
                      int y = index % BOARD_SIZE;
                      return GestureDetector(
                        onTap: () => _makeMove(x, y),
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Center(
                            child: Text(
                              board[x][y] == EMPTY ? '' : board[x][y],
                              style: TextStyle(
                                  fontSize: boardWidth /
                                      (BOARD_SIZE * 2), // Dynamic font size
                                  fontWeight: FontWeight.bold,
                                  color: board[x][y] == PLAYER_X
                                      ? Colors.blue
                                      : Colors.red),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
