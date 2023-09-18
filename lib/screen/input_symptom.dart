import 'package:flutter/material.dart';

class InputDataSymptom extends StatefulWidget {
  const InputDataSymptom({super.key});

  @override
  State<InputDataSymptom> createState() => _InputDataSymptomState();
}

class _InputDataSymptomState extends State<InputDataSymptom> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("บันทึกผลตรวจโควิดประจำวัน"),
      ),
      body: Container(),
    );
  }
}
