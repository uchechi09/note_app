import 'package:flutter/material.dart';
import 'package:note_app/utils/constant.dart';

class ColorSelector extends StatelessWidget {
  final String selectedColor;
  final Function(String) onColorSelected;

   ColorSelector({
    Key? key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Left arrow
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.grey),
            onPressed: () {
              // Optional: Implement scrolling logic
              
            },
          ),
          
          // Color circles
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: AppConstants.noteColors.length,
              itemBuilder: (context, index) {
                final color = AppConstants.noteColors[index];
                final colorHex = AppConstants.getHexFromColor(color);
                final isSelected = colorHex == selectedColor;
                
                return GestureDetector(
                  onTap: () => onColorSelected(colorHex),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color,
                      border: isSelected
                          ? Border.all(color: Colors.black, width: 3)
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Right arrow
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.grey),
            onPressed: () {
              // Optional: Implement scrolling logic
            },
          ),
        ],
      ),
    );
  }
}