import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:covid_savehealt/screen/Home.dart';
import 'package:covid_savehealt/screen/input_symptom.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';

class SymptomForm3 extends StatefulWidget {
  @override
  _SymptomForm3State createState() => _SymptomForm3State();
}

class _SymptomForm3State extends State<SymptomForm3> {
  final Future<FirebaseApp> firebase = Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: 'AIzaSyCdXxDzlGGstdD5WIGeHU_96kVEUCA8t4U',
      appId: '1:834357843533:android:4c16b737e81ae65b62ae04',
      messagingSenderId: '',
      projectId: 'project-covid-b3074',
    ),
  );

  final formKey = GlobalKey<FormState>();
  Map<String, String> symptoms = {
    '1. มีไข้ / วัดอุณหภูมิได้ 37.5 C ขึ้นไปหรือไม่': '',
    '2. ไอ มีน้ำมูก เจ็บคอ': '',
    '3. ถ่ายเหลว': '',
    '4. จมูกไม่ได้กลิ่น ลิ้นไม่รับรส': '',
    '5. ตาแดง มีผื่น': '',
    '6. ไม่มีโรคประจำตัวร่วม': '',
    '7. แน่นหน้าอก / หายใจไม่ค่อยสะดวก / หายใจเร็ว หายใจลำบาก ไอแล้วรู้สึกเหนื่อย ':
        '',
    '8. ถ่ายเหลวมากกว่า 3 ครั้ง/วัน': '',
    '9. อ่อนเพลีย เวียนศีรษะ / หน้ามืด วิงเวียน': '',
    '10. หอบเหนื่อย พูดไม่เป็นประโยค/ แน่นหน้าอกตลอดเวลา หายใจแล้วเจ็บหน้าอก':
        '',
    '11. ซึม เรียกไม่รู้สึกตัว ตอบสนองช้า': '',
  };

  bool _isValidForm() {
    for (var value in symptoms.values) {
      if (value == '') {
        return false;
      }
    }
    return true;
  }

  Future<void> sendDataToFirestore() async {
    if (!_isValidForm()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณาตอบคำถามให้ครบทุกข้อ',
              style: GoogleFonts.prompt(fontSize: 23)),
        ),
      );
      return;
    }

    // Create a map to store the selected symptoms
    Map<String, String> selectedSymptoms = {};
    bool hasCovidSymptoms = false;
    bool hasOtherSymptoms = false;

    for (var entry in symptoms.entries) {
      if (entry.value == 'Y') {
        selectedSymptoms[entry.key] = entry.value;
        if ([
          '1. มีไข้ / วัดอุณหภูมิได้ 37.5 C ขึ้นไปหรือไม่',
          '2. ไอ มีน้ำมูก เจ็บคอ',
          '4. จมูกไม่ได้กลิ่น ลิ้นไม่รับรส'
        ].contains(entry.key)) {
          hasCovidSymptoms = true;
        } else {
          hasOtherSymptoms = true;
        }
      }
      if (hasCovidSymptoms) {
        _showDialog(
          context,
          title: 'อาการเบื้องต้นของผู้ติดเชื้อ!',
          content: 'คำแนะนำจากการทำแบบประเมินอาการ:\n1.แยกห้องพัก...',
        );
      } else if (hasOtherSymptoms) {
        // ignore: use_build_context_synchronously
        _showDialog(
          context,
          title: 'คุณไม่มีอาการเสี่ยงติดเชื้อโควิด',
          content: 'แต่อาจจะติดโรคร้ายแรงอื่นๆ',
        );
      } else {
        _showDialog(
          context,
          title: 'คุณสุขภาพร่างกายแข็งแรงดี',
          content: null,
        );
      }
    }

    // Check if there are any selected symptoms
    if (selectedSymptoms.isNotEmpty) {
      try {
        await FirebaseFirestore.instance.collection('patients').add({
          'symptoms': selectedSymptoms,
        });
        // Show a success dialog
        // _showDialog(
        //   context,
        //   title: 'อาการถูกบันทึกแล้ว!',
        //   content: 'ขอบคุณที่ให้ข้อมูล',
        // );
      } catch (e) {
        print('Error adding data to Firestore: $e');
      }
    } else {}
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firebase,
      builder: ((context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text("Error")),
            body: Center(child: Text("${snapshot.error}")),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(70),
              child: AppBar(
                backgroundColor: Colors.red[300],
                title: Center(
                  child: Text(
                    'แบบประเมินอาการ',
                    style: GoogleFonts.prompt(fontSize: 25),
                  ),
                ),
              ),
            ),
            backgroundColor: Colors.pink[50],
            body: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 30),
                    ...symptoms.keys.map((String symptom) {
                      return ListTile(
                        title: Text(
                          symptom,
                          style: GoogleFonts.prompt(fontSize: 18),
                        ),
                        subtitle: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio(
                              value: 'Y',
                              groupValue: symptoms[symptom],
                              onChanged: (value) {
                                setState(() {
                                  symptoms[symptom] = value!;
                                });
                              },
                            ),
                            Text('มี', style: GoogleFonts.prompt(fontSize: 18)),
                            Radio(
                              value: 'N',
                              groupValue: symptoms[symptom],
                              onChanged: (value) {
                                setState(() {
                                  symptoms[symptom] = value!;
                                });
                              },
                            ),
                            Text('ไม่มี',
                                style: GoogleFonts.prompt(fontSize: 18)),
                          ],
                        ),
                      );
                    }).toList(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 20.0),
                      child: ElevatedButton.icon(
                        onPressed: sendDataToFirestore,
                        label: Text('เช็คอาการ',
                            style: GoogleFonts.prompt(fontSize: 23)),
                        icon: Icon(Icons.check),
                        style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          backgroundColor: Colors.green[300],
                          minimumSize: const Size(250, 50),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }
        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        );
      }),
    );
  }

  void _showDialog(BuildContext context,
      {required String title, String? content}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: content != null ? Text(content) : null,
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InputDataSymptom(),
                  ),
                );
              },
              child: Text('ใช่'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Home(),
                  ),
                );
              },
              child: Text('ไม่'),
            ),
          ],
        );
      },
    );
  }
}
