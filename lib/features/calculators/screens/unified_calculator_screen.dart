import 'package:flutter/material.dart';
import 'package:construction_app/features/calculators/screens/smart_calculator_wizard.dart';

class UnifiedCalculatorScreen extends StatelessWidget {
  const UnifiedCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Directly launch the new smart wizard for a clean, focused experience
    return const SmartCalculatorWizard();
  }
}
