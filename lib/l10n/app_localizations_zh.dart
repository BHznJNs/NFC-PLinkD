// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class SZh extends S {
  SZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => '电纸链接';

  @override
  String get drawer_createPage => '创建链接';

  @override
  String get drawer_readPage => '读取链接';

  @override
  String get drawer_galleryPage => '总览';

  @override
  String get drawer_settingPage => '设置';

  @override
  String get createPage_title => '创建链接';

  @override
  String get createPage_image => '拍照';

  @override
  String get createPage_video => '录制视频';

  @override
  String get createPage_audio => '录制音频';

  @override
  String get createPage_weblink => '附加网页链接';

  @override
  String get readPage_approachNFCTagHint => '请靠近 NFC 标签';

  @override
  String get readPage_readStopped => '已停止';

  @override
  String get readPage_readError_dialog_title => 'NFC 标签读取错误';

  @override
  String get galleryPage_emptyText => '还没有链接，快去创建吧！';

  @override
  String get galleryPage_popup_open => '打开';

  @override
  String get galleryPage_popup_write => '写入';

  @override
  String get galleryPage_popup_delete => '删除';

  @override
  String get settingsPage_applicationTheme_title => '应用主题';

  @override
  String get settingsPage_applicationTheme_light => '浅色';

  @override
  String get settingsPage_applicationTheme_dark => '深色';

  @override
  String get settingsPage_applicationTheme_system => '系统默认';

  @override
  String get settingsPage_useBuiltinVideoPlayer_title => '使用内置视频播放器';

  @override
  String get settingsPage_useBuiltinVideoPlayer_description => '或使用系统默认播放器';

  @override
  String get settingsPage_useBuiltinAudioPlayer_title => '使用内置音频播放器';

  @override
  String get settingsPage_useBuiltinAudioPlayer_description => '或使用系统默认播放器';

  @override
  String get settingsPage_exportData_title => '导出数据';

  @override
  String get settingsPage_exportData_generatingArchive => '正在整理文件，请稍候…';

  @override
  String get settingsPage_exportData_successMsg => '你的数据已成功保存。';

  @override
  String get settingsPage_importData_title => '导入数据';

  @override
  String get settingsPage_importData_processingArchive => 'Processing data, please wait...';

  @override
  String get settingsPage_importData_successMsg => 'Data has been successfully imported.';

  @override
  String get recorderPage_title => '录制音频';

  @override
  String get editLinkPage_title => '编辑链接';

  @override
  String get editLinkPage_no_content_msg => '没有内容，请添加一些。';

  @override
  String get editLinkPage_success_msg => '数据已成功保存，按“确定”返回。';

  @override
  String get editLinkPage_actionLabel_image => '拍照';

  @override
  String get editLinkPage_actionLabel_video => '录制视频';

  @override
  String get editLinkPage_actionLabel_audio => '录制音频';

  @override
  String get editLinkPage_actionLabel_weblink => '附加网页链接';

  @override
  String get editLinkPage_actionLabel_upload => '上传资源';

  @override
  String get editLinkPage_linkName_hint => '在此输入链接名称...';

  @override
  String get editLinkPage_dialog_action_save => '保存';

  @override
  String get editLinkPage_dialog_action_delete => '删除';

  @override
  String get editLinkPage_dialog_title => '编辑';

  @override
  String get editLinkPage_dialog_description_hint => '在此输入描述...';

  @override
  String get resourceList_item_noDescription_hint => '无描述';

  @override
  String get custom_dialog_action_cancel => '取消';

  @override
  String get custom_dialog_action_delete => '删除';

  @override
  String get custom_dialog_action_copyErrMsg => 'Copy error message';

  @override
  String get custom_dialog_action_confirm => '确认';

  @override
  String get custom_dialog_action_ok => '确定';

  @override
  String get custom_dialog_delete_title => '确认删除';

  @override
  String get custom_dialog_delete_content => '您确定要删除此项目吗？此操作无法撤销，请谨慎操作。';

  @override
  String get custom_dialog_weblink_title => '网站链接';

  @override
  String get custom_dialog_weblink_invalidUrlMsg => '无效的 URL';

  @override
  String get custom_dialog_success_title => '成功';

  @override
  String get custom_dialog_unexpectedError_title => 'Unexpected Error';

  @override
  String get custom_dialog_nfc_approach_title => '靠近 NFC 标签';

  @override
  String get nfcError_function_disabled_title => 'NFC Function Disabled';

  @override
  String get nfcError_function_disabled_content => 'Please enable the NFC function of your phone and retry.';

  @override
  String get nfcError_tag_unusable_title => 'NFC Tag Unusable';

  @override
  String get nfcError_tag_unusable_content => 'The approached NFC tag is not writable or readable, it may be locked or does not support NDEF.';

  @override
  String get nfcError_tag_write_failed_title => 'NFC Write Failed';

  @override
  String get nfcError_tag_write_failed_content => 'An error occurred while writing to the NFC tag. Please try again.';

  @override
  String get nfcError_tag_data_invalid_title => 'NFC Tag Data Invalid';

  @override
  String get nfcError_tag_data_invalid_content => 'The data read from the NFC tag is not in the expected format. It may not be a valid URI or not compatible with this application. Please ensure the tag contains the correct data type for this app.';

  @override
  String get nfcError_tag_formated_title => 'NFC Tag Formated';

  @override
  String get nfcError_tag_formated_content => 'The approached NFC tag is formated, please approach again to write data.';

  @override
  String get nfcError_tag_empty_title => 'NFC Tag Empty';

  @override
  String get nfcError_tag_empty_content => 'The approached NFC tag is empty.';

  @override
  String get importError_invalidData_title => 'Invalid Data';

  @override
  String get importError_invalidData_content => 'It appears the selected file is not a valid NFC PLinkD data file. Please try importing the correct file.';
}
