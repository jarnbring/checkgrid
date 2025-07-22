import 'package:flutter/material.dart';

class StoreButton extends StatelessWidget {
  final String title;
  final double price;
  final IconData icon;
  final double screenWidth;
  final bool isHighlighted = false;
  final String? discountText;

  const StoreButton({
    super.key,
    required this.title,
    required this.price,
    required this.icon,
    required this.screenWidth,
    this.discountText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: screenWidth * 0.75,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(64, 0, 0, 0),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors:
                  isHighlighted
                      ? [Colors.orange, Colors.red]
                      : [Colors.lightGreen, Colors.green],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: Colors.white, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      "£$price",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (discountText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    discountText!,
                    style: const TextStyle(
                      color: Colors.yellowAccent,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
