import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import '../widgets/themed_container.dart';

class LegalScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.frameColor,
      appBar: AppBar(
        title: Text(
          title,
          style: AppTheme.outfit(
            context: context,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: AppTheme.getBackgroundDecoration(context),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ThemedContainer(
              type: ContainerType.glass,
              radius: 24,
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: double.infinity),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    content,
                    style: AppTheme.outfit(context: context, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
