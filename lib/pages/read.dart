import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nfc_plinkd/components/custom_dialog.dart';
import 'package:nfc_plinkd/utils/index.dart';
import 'package:nfc_plinkd/utils/nfc.dart';
import 'package:nfc_plinkd/utils/open_Link.dart';

class ReadPage extends StatefulWidget {
  const ReadPage({super.key});

  @override
  State<StatefulWidget> createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  Function? stopReading;
  bool isReading = false;

  Future<void> startReadingNFC() async {
    if (!await checkNFCAvailability()) {
      if (mounted) showCustomError(context, NFCError.NFCFunctionDisabled);
      return;
    }
    stopReading = await tryStartReadNFCData(
      onRead: (data) async {
        final uri = Uri.parse(data);
        await openLinkWithUri(uri, 
          context: context,
          onBack: startReadingNFC,
        );
        await stopReading?.call();
        setState(() => isReading = false);
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
    setState(() => isReading = true);
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
      child: isReading
        ? Column(
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
                  child: SizedBox.square(
                    dimension: 64,
                    child: CircularProgressIndicator.adaptive(),
                  ),
                )
              )
            ],
          )
        : Center(
            child: Text('Stopped',
              style: TextStyle(fontSize: 28)
            )
          ) 
    );
  }
}
