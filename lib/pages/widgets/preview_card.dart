import 'package:flutter/material.dart';

class PreviewCard extends StatelessWidget {
  final double width;
  final double height;
  final Widget child;
  final bool showArrow;
  final Widget? destinationPage;

  const PreviewCard({
    Key? key,
    required this.width,
    required this.height,
    this.showArrow = false,
    this.destinationPage,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: destinationPage != null
          ? () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => destinationPage!),
              )
          : null,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            child,
            if (showArrow)
              Positioned(
                right: 16,
                top: 0,
                bottom: 0,
                child: Center(
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.grey[400],
                    size: 20,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
