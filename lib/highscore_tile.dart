import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HighscoreTile extends StatelessWidget {
  final String docmentId;
  const HighscoreTile({Key? key, required this.docmentId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //get colitions
    CollectionReference highscores =
        FirebaseFirestore.instance.collection("highscores");

    return FutureBuilder<DocumentSnapshot>(
      future: highscores.doc(docmentId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          return Row(
            children: [
              SizedBox(
                height: 15,
              ),
              Text(
                data['score'].toString(),
                style: GoogleFonts.pressStart2p(
                    fontSize: 10,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(width: 10),
              Text(
                data['name'],
                style: GoogleFonts.pressStart2p(
                    fontSize: 10,
                    color: Colors.green[400],
                    fontWeight: FontWeight.bold),
              ),
            ],
          );
        } else {
          return Text(
            'loading..',
            style: GoogleFonts.pressStart2p(
                fontSize: 10,
                color: Colors.green[400],
                fontWeight: FontWeight.bold),
          );
        }
      },
    );
  }
}
