import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nfc_plinkd/components/custom_dialog.dart';
import 'package:nfc_plinkd/utils/index.dart';
import 'package:nfc_plinkd/utils/nfc.dart';
import 'package:nfc_plinkd/utils/open_link.dart';

class ReadPage extends StatefulWidget {
  const ReadPage({super.key});

  @override
  State<StatefulWidget> createState() => _ReadPageState();
}

class _ReadPageState extends State<ReadPage> {
  Function? stopReading;
  bool isReading = false;

  Future<void> startReadingNFC() async {
    final l10n = S.of(context)!;
    if (!await checkNFCAvailability()) {
      if (mounted) showCustomError(context, NFCError.NFCFunctionDisabled(context));
      return;
    }
    if (!mounted) return;
    stopReading = await tryStartReadNFCData(
      context,
      onRead: (data) async {
        final uri = Uri.parse(data);
        await openLinkWithUri( 
          context, uri,
          onBack: startReadingNFC,
        );
        await stopReading?.call();
        setState(() => isReading = false);
      },
      onError: (e) {
        if (e is CustomError) {
          showCustomError(context, e);
        } else if (e is FormatException) {
          final e = NFCError.NFCTagDataInvalid(context);
          showCustomError(context, e);
        } else {
          showAlert(context, l10n.readPage_readError_dialog_title, e.toString());
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
    final l10n = S.of(context)!;
    final approaching = Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          l10n.readPage_approachNFCTagHint,
          style: const TextStyle(fontSize: 20),
        ),
        Container(
          width: 64,
          height: 64,
          margin: const EdgeInsets.symmetric(vertical: 32),
          alignment: Alignment.center,
          child: const CircularProgressIndicator.adaptive(),
        )
      ],
    ));
    final stoppedHint = Center(
      child: Text(l10n.readPage_readStopped,
        style: const TextStyle(fontSize: 28)
      )
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: 64),
      child: isReading
        ? approaching
        : stoppedHint,
    );
  }
}
