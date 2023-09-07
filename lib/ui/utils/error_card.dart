import 'package:flutter/material.dart';

class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
      ),
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                child: Icon(Icons.error_outline_rounded),
              ),
              Flexible(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}