import 'package:flutter/material.dart';
import 'package:gamename/game/block.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  List<List<Block?>> board = List.generate(8, (_) => List.filled(8, null));

  @override
  void initState() {
    super.initState();

    for (int col = 0; col < 8; col++) {
      board[0][col] = Block(); // rad 0 = toppen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CheckGrid"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      //backgroundColor: const Color.fromARGB(255, 34, 34, 34),
      body: Center(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(60), // padding runt hela grid:en
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  mainAxisSpacing: 3,
                  crossAxisSpacing: 3,
                  childAspectRatio: 1,
                ),
                itemCount: 64,
                itemBuilder: (context, index) {
                  final row = index ~/ 8;
                  final col = index % 8;
                  final block = board[row][col];

                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color:
                          block != null && block.isActive
                              ? Colors.blue
                              : Colors.grey[300],
                    ),
                    child: Image.asset(
                      'assets/images/white_knight.png',
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(color: Colors.blueAccent),
              width: 350,
              child: Row(
                spacing: 1,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image(
                    image: AssetImage('assets/images/white_queen.png'),
                    height: 100,
                    width: 100,
                  ),
                  Image(
                    image: AssetImage('assets/images/white_rock.png'),
                    height: 100,
                    width: 100,
                  ),
                  Image(
                    image: AssetImage('assets/images/white_bishop.png'),
                    height: 100,
                    width: 100,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
