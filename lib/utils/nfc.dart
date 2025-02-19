import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:nfc_plinkd/l10n/app_localizations.dart';
import 'package:nfc_plinkd/utils/index.dart';

typedef StopReadingClossure = Future<void> Function();

Future<StopReadingClossure> tryStartReadNFCData(BuildContext context, {
  Function(String)? onRead,
  Function(Object)? onError,
}) async {
  await NfcManager.instance.startSession(
    onDiscovered: (NfcTag tag) async {
      final ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        onError?.call(NFCError.NFCTagUnusable(context)); return;
      }

      NdefMessage data;
      try {
        data = await ndef.read();
      } catch(_) {
        if (context.mounted) onError?.call(NFCError.NFCTagEmpty(context));
        return;
      }

      if (data.records.isEmpty) {
        if (context.mounted) onError?.call(NFCError.NFCTagEmpty(context));
        return;
      }
      final record = data.records[0];
      if (record.typeNameFormat != NdefTypeNameFormat.nfcWellknown) {
        if (context.mounted) onError?.call(NFCError.NFCTagDataInvalid(context));
        return;
      }
      final uri = String.fromCharCodes(record.payload.sublist(1));
      try {
        await onRead?.call(uri);
      } catch(e) {
        await onError?.call(e);
      }
    },
  );
  return () async =>
    await NfcManager.instance.stopSession();
}

Future<StopReadingClossure> tryWriteNFCData(BuildContext context, List<NdefRecord> data, {
  Function()?         onWrite,
  Function(NFCError)? onError,
}) async {
  await NfcManager.instance.startSession(
    onDiscovered: (NfcTag tag) async {
      final ndef = Ndef.from(tag);
      if (ndef == null || !ndef.isWritable) {
        await NfcManager.instance.stopSession();
        if (context.mounted) onError?.call(NFCError.NFCTagUnusable(context));
        return;
      }

      final ndefFormatable = NdefFormatable.from(tag);
      if (ndefFormatable != null) {
        final defaultMessage = NdefMessage([NdefRecord.createText('')]);
        await ndefFormatable.format(defaultMessage);
        await NfcManager.instance.stopSession();
        if (context.mounted) onError?.call(NFCError.NFCTagFormated(context));
        return;
      }

      final message = NdefMessage(data);
      try { await ndef.write(message); }
      catch (_) {
        await NfcManager.instance.stopSession();
        if (context.mounted) onError?.call(NFCError.NFCTagWriteFailed(context));
        return;
      }
      await NfcManager.instance.stopSession();
      onWrite?.call();
    },
  );
  return () async =>
    await NfcManager.instance.stopSession();
}

Future<bool> checkNFCAvailability() async {
  return await NfcManager.instance.isAvailable();
}

class NFCError extends CustomError {
  NFCError({required super.title, required super.content});

  // ignore: non_constant_identifier_names
  static NFCError NFCFunctionDisabled(BuildContext context) {
    final l10n = S.of(context)!;
    return NFCError(
      title: l10n.nfcError_function_disabled_title,
      content: l10n.nfcError_function_disabled_content,
    );
  }
  // ignore: non_constant_identifier_names
  static NFCError NFCTagUnusable(BuildContext context) {
    final l10n = S.of(context)!;
    return NFCError(
      title: l10n.nfcError_tag_unusable_title,
      content: l10n.nfcError_tag_unusable_content,
    );
  }
  // ignore: non_constant_identifier_names
  static NFCError NFCTagWriteFailed(BuildContext context) {
    final l10n = S.of(context)!;
    return NFCError(
      title: l10n.nfcError_tag_write_failed_title,
      content: l10n.nfcError_tag_write_failed_content,
    );
  }
  // ignore: non_constant_identifier_names
  static NFCError NFCTagDataInvalid(BuildContext context) {
    final l10n = S.of(context)!;
    return NFCError(
      title: l10n.nfcError_tag_data_invalid_title,
      content: l10n.nfcError_tag_data_invalid_content,
    );
  }
  // ignore: non_constant_identifier_names
  static NFCError NFCTagFormated(BuildContext context) {
    final l10n = S.of(context)!;
    return NFCError(
      title: l10n.nfcError_tag_formated_title,
      content: l10n.nfcError_tag_formated_content,
    );
  }
  // ignore: non_constant_identifier_names
  static NFCError NFCTagEmpty(BuildContext context) {
    final l10n = S.of(context)!;
    return NFCError(
      title: l10n.nfcError_tag_empty_title,
      content: l10n.nfcError_tag_empty_content,
    );
  }
}
