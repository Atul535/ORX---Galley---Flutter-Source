import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});
  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  int? _playerScore;
  bool? _hasStarted;
  Animation? _snakeAnimation;
  AnimationController? _snakeController;
  final List _snake = [404, 405, 406, 407];
  final int _noOfSquares = 1000;
  final Duration _duration = const Duration(milliseconds: 250);
  final int _squareSize = 50;
  String? _currentSnakeDirection;
  int? _snakeFoodPosition;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _setUpGame();
  }

  void _setUpGame() {
    _playerScore = 0;
    _currentSnakeDirection = 'RIGHT';
    _hasStarted = true;
    do {
      _snakeFoodPosition = _random.nextInt(_noOfSquares);
    } while (_snake.contains(_snakeFoodPosition));
    _snakeController = AnimationController(vsync: this, duration: _duration);
    _snakeAnimation =
        CurvedAnimation(curve: Curves.easeInOut, parent: _snakeController!);
  }

  void _gameStart() {
    Timer.periodic(const Duration(milliseconds: 250), (Timer timer) {
      _updateSnake();
      if (_hasStarted!) timer.cancel();
    });
  }

  bool _gameOver() {
    for (int i = 0; i < _snake.length - 1; i++) {
      if (_snake.last == _snake[i]) {
        return true;
      }
    }
    return false;
  }

  void _updateSnake() {
    if (!_hasStarted!) {
      setState(() {
        _playerScore = (_snake.length - 4) * 100;
        switch (_currentSnakeDirection) {
          case 'DOWN':
            if (_snake.last > _noOfSquares) {
              _snake.add(
                  _snake.last + _squareSize - (_noOfSquares + _squareSize));
            } else {
              _snake.add(_snake.last + _squareSize);
            }
            break;
          case 'UP':
            if (_snake.last < _squareSize) {
              _snake.add(
                  _snake.last - _squareSize + (_noOfSquares + _squareSize));
            } else {
              _snake.add(_snake.last - _squareSize);
            }
            break;
          case 'RIGHT':
            if ((_snake.last + 1) % _squareSize == 0) {
              _snake.add(_snake.last + 1 - _squareSize);
            } else {
              _snake.add(_snake.last + 1);
            }
            break;
          case 'LEFT':
            if ((_snake.last) % _squareSize == 0) {
              _snake.add(_snake.last - 1 + _squareSize);
            } else {
              _snake.add(_snake.last - 1);
            }
        }

        if (_snake.last != _snakeFoodPosition) {
          _snake.removeAt(0);
        } else {
          do {
            _snakeFoodPosition = _random.nextInt(_noOfSquares);
          } while (_snake.contains(_snakeFoodPosition));
        }

        if (_gameOver()) {
          setState(() {
            _hasStarted = !_hasStarted!;
          });
          Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => GameOver(score: _playerScore!)));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SnakeGameFlutter',
            style: TextStyle(color: Colors.white, fontSize: 20.0)),
        centerTitle: false,
        backgroundColor: Colors.redAccent,
        actions: <Widget>[
          Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Text('Score: $_playerScore',
                style: const TextStyle(fontSize: 16.0)),
          ))
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Colors.redAccent,
          elevation: 20,
          label: Text(
            _hasStarted! ? 'Start' : 'Pause',
            style: const TextStyle(),
          ),
          onPressed: () {
            setState(() {
              if (_hasStarted!) {
                _snakeController?.forward();
              } else {
                _snakeController?.reverse();
              }
              _hasStarted = !_hasStarted!;
              _gameStart();
            });
          },
          icon: AnimatedIcon(
              icon: AnimatedIcons.play_pause,
              progress: _snakeAnimation as Animation<double>)),
      body: Center(
        child: GestureDetector(
          onVerticalDragUpdate: (drag) {
            if (drag.delta.dy > 0 && _currentSnakeDirection != 'UP') {
              _currentSnakeDirection = 'DOWN';
            } else if (drag.delta.dy < 0 && _currentSnakeDirection != 'DOWN') {
              _currentSnakeDirection = 'UP';
            }
          },
          onHorizontalDragUpdate: (drag) {
            if (drag.delta.dx > 0 && _currentSnakeDirection != 'LEFT') {
              _currentSnakeDirection = 'RIGHT';
            } else if (drag.delta.dx < 0 && _currentSnakeDirection != 'RIGHT') {
              _currentSnakeDirection = 'LEFT';
            }
          },
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: GridView.builder(
              itemCount: _squareSize + _noOfSquares,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _squareSize),
              itemBuilder: (BuildContext context, int index) {
                return Center(
                  child: Container(
                    color: Colors.white,
                    padding: _snake.contains(index)
                        ? const EdgeInsets.all(1)
                        : const EdgeInsets.all(0),
                    child: ClipRRect(
                      borderRadius:
                          index == _snakeFoodPosition || index == _snake.last
                              ? BorderRadius.circular(7)
                              : _snake.contains(index)
                                  ? BorderRadius.circular(2.5)
                                  : BorderRadius.circular(1),
                      child: Container(
                          color: _snake.contains(index)
                              ? Colors.black
                              : index == _snakeFoodPosition
                                  ? Colors.green
                                  : Colors.blue),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class GameOver extends StatelessWidget {
  final int score;

  const GameOver({super.key, this.score = 0});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: Colors.blue,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Text('Game Over',
              style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: 50.0,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  shadows: [
                    Shadow(
                        // bottomLeft
                        offset: Offset(-1.5, -1.5),
                        color: Colors.black),
                    Shadow(
                        // bottomRight
                        offset: Offset(1.5, -1.5),
                        color: Colors.black),
                    Shadow(
                        // topRight
                        offset: Offset(1.5, 1.5),
                        color: Colors.black),
                    Shadow(
                        // topLeft
                        offset: Offset(-1.5, 1.5),
                        color: Colors.black),
                  ])),
          const SizedBox(height: 50.0),
          Text('Your Score is: $score',
              style: const TextStyle(color: Colors.white, fontSize: 20.0)),
          const SizedBox(height: 50.0),
          IconButton(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
            color: Colors.redAccent,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const GamePage()));
            },
            icon: const Icon(Icons.refresh, color: Colors.white, size: 30.0),
          ),
        ],
      ),
    ));
  }
}
