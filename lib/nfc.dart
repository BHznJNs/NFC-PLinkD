import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_plinkd/utils/index.dart';

Future<void> writeNFC(String data) async {
  NdefMessage message = NdefMessage([
    NdefRecord.createUri(Uri.parse("$scheme://data?id=$data")), // 自定义 URI 格式
  ]);

  try {
    await NfcManager.instance.startSession(
      onDiscovered: (NfcTag tag) async {
        var ndef = Ndef.from(tag);
        if (ndef == null) {
          NfcManager.instance.stopSession(alertMessage: "标签不支持 NDEF");
          return;
        }
        try {
          await ndef.write(message);
          NfcManager.instance.stopSession(alertMessage: "写入成功");
        } catch (e) {
          NfcManager.instance.stopSession(alertMessage: "写入失败: $e");
        }
      },
    );
  } catch (e) {
    print("NFC 写入失败: $e");
  }
}