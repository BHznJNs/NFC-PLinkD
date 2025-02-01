import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nfc_plinkd/components/dialog.dart';
import 'package:nfc_plinkd/db.dart';
import 'package:nfc_plinkd/pages/link_view.dart';
import 'package:nfc_plinkd/utils/index.dart';
import 'package:nfc_plinkd/utils/nfc.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ReadPage extends StatefulWidget {
  const ReadPage({super.key});

  @override
  State<StatefulWidget> createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  Function? stopReading;

  Future<void> startReadingNFC() async {
    if (!await checkNFCAvailability()) {
      // ignore: use_build_context_synchronously
      showCustomError(context, NFCError.NFCFunctionDisabled);
      return;
    }
    stopReading = await tryStartReadNFCData(
      onRead: (data) async {
        final uri = Uri.parse(data);
        if (uri.host != linkHost || uri.pathSegments.isEmpty) {
          throw NFCError.NFCTagDataInvalid;
        }
        final targetId = uri.pathSegments[0];
        final (link, resources) = await DatabaseHelper.instance.fetchLink(targetId);
        final appDir = (await getApplicationDocumentsDirectory()).path;
        // ignore: use_build_context_synchronously
        // Navigator.of(context).push(
        //   MaterialPageRoute(builder: (context) => LinkView(
        //     resourcePathList: resources.map((resource) =>
        //       path.join(appDir, resource.path)
        //     ).toList(),
        //   )
        // ));
      },
      onError: (e) {
        if (e is CustomError) {
          showCustomError(context, e);
        } else if (e is FormatException) {
          final e = NFCError.NFCTagDataInvalid;
          showCustomError(context, e);
        } else {
          showAlert(context, 'NFC tag reading error', e.toString());
        }
      }
    );
  }

  @override
  void initState() {
    super.initState();
    startReadingNFC();
  }
  @override
  void dispose() {
    stopReading?.call();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 64),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Approach an NFC Tag',
            style: TextStyle(fontSize: 20),
          ),
          Container(
            height: 64,
            margin: const EdgeInsets.symmetric(vertical: 32),
            child: const Center(
              child: SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator.adaptive(),
              ),
            )
          )
        ],
      )
    );
  }
}
