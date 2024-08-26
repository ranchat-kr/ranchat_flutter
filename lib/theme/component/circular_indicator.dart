import 'package:flutter/material.dart';

class CircularIndicator extends StatelessWidget {
  const CircularIndicator({
    super.key,
    required this.child,
    required this.isLoading,
  });

  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        IgnorePointer(
          ignoring: !isLoading,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 222),
            opacity: isLoading ? 1 : 0,
            child: Container(
              color: Colors.black,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                color: Colors.white,
                value: isLoading ? null : 0,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
