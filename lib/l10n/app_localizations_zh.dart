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
  String get settingsPage_languages_title => '语言';

  @override
  String get settingsPage_exportData_title => '导出数据';

  @override
  String get settingsPage_exportData_generatingArchive => '正在整理文件，请稍候…';

  @override
  String get settingsPage_exportData_successMsg => '你的数据已成功保存。';

  @override
  String get settingsPage_importData_title => '导入数据';

  @override
  String get settingsPage_importData_processingArchive => '解析数据中，请等待...';

  @override
  String get settingsPage_importData_successMsg => '数据已被成功导入。';

  @override
  String get settingsPage_languageSettingsPage_title => '语言设置';

  @override
  String get settingsPage_languageSettingsPage_useDevideLanguage => '跟随系统设置';

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
  String get custom_dialog_action_copyErrMsg => '复制错误信息';

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
  String get custom_dialog_unexpectedError_title => '未知错误';

  @override
  String get custom_dialog_nfc_approach_title => '靠近 NFC 标签';

  @override
  String get nfcError_function_disabled_title => 'NFC 功能已禁用';

  @override
  String get nfcError_function_disabled_content => '请启用手机的 NFC 功能后重试。';

  @override
  String get nfcError_tag_unusable_title => 'NFC 标签不可用';

  @override
  String get nfcError_tag_unusable_content => '靠近的 NFC 标签不可读写，可能已锁定或不支持 NDEF。';

  @override
  String get nfcError_tag_write_failed_title => 'NFC 写入失败';

  @override
  String get nfcError_tag_write_failed_content => '写入 NFC 标签时发生错误，请重试。';

  @override
  String get nfcError_tag_data_invalid_title => 'NFC 标签数据无效';

  @override
  String get nfcError_tag_data_invalid_content => '从 NFC 标签读取的数据格式不符合预期。它可能不是有效的 URI，或与本应用不兼容。请确保标签包含正确的数据类型。';

  @override
  String get nfcError_tag_formated_title => 'NFC 标签已格式化';

  @override
  String get nfcError_tag_formated_content => '靠近的 NFC 标签已格式化，请再次靠近以写入数据。';

  @override
  String get nfcError_tag_empty_title => 'NFC 标签为空';

  @override
  String get nfcError_tag_empty_content => '靠近的 NFC 标签为空。';

  @override
  String get linkError_dataNotFound_title => '未找到链接数据';

  @override
  String get linkError_dataNotFound_content => '此链接的数据未找到，可能已被删除。';

  @override
  String get importError_invalidData_title => '无效的数据文件';

  @override
  String get importError_invalidData_content => '数据文件格式不匹配。请确保您选择的是由本应用导出的数据文件。';
}

/// The translations for Chinese, as used in China (`zh_CN`).
class SZhCn extends SZh {
  SZhCn(): super('zh_CN');

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
  String get settingsPage_languages_title => '语言';

  @override
  String get settingsPage_exportData_title => '导出数据';

  @override
  String get settingsPage_exportData_generatingArchive => '正在整理文件，请稍候…';

  @override
  String get settingsPage_exportData_successMsg => '你的数据已成功保存。';

  @override
  String get settingsPage_importData_title => '导入数据';

  @override
  String get settingsPage_importData_processingArchive => '解析数据中，请等待...';

  @override
  String get settingsPage_importData_successMsg => '数据已被成功导入。';

  @override
  String get settingsPage_languageSettingsPage_title => '语言设置';

  @override
  String get settingsPage_languageSettingsPage_useDevideLanguage => '跟随系统设置';

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
  String get custom_dialog_action_copyErrMsg => '复制错误信息';

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
  String get custom_dialog_unexpectedError_title => '未知错误';

  @override
  String get custom_dialog_nfc_approach_title => '靠近 NFC 标签';

  @override
  String get nfcError_function_disabled_title => 'NFC 功能已禁用';

  @override
  String get nfcError_function_disabled_content => '请启用手机的 NFC 功能后重试。';

  @override
  String get nfcError_tag_unusable_title => 'NFC 标签不可用';

  @override
  String get nfcError_tag_unusable_content => '靠近的 NFC 标签不可读写，可能已锁定或不支持 NDEF。';

  @override
  String get nfcError_tag_write_failed_title => 'NFC 写入失败';

  @override
  String get nfcError_tag_write_failed_content => '写入 NFC 标签时发生错误，请重试。';

  @override
  String get nfcError_tag_data_invalid_title => 'NFC 标签数据无效';

  @override
  String get nfcError_tag_data_invalid_content => '从 NFC 标签读取的数据格式不符合预期。它可能不是有效的 URI，或与本应用不兼容。请确保标签包含正确的数据类型。';

  @override
  String get nfcError_tag_formated_title => 'NFC 标签已格式化';

  @override
  String get nfcError_tag_formated_content => '靠近的 NFC 标签已格式化，请再次靠近以写入数据。';

  @override
  String get nfcError_tag_empty_title => 'NFC 标签为空';

  @override
  String get nfcError_tag_empty_content => '靠近的 NFC 标签为空。';

  @override
  String get linkError_dataNotFound_title => '未找到链接数据';

  @override
  String get linkError_dataNotFound_content => '此链接的数据未找到，可能已被删除。';

  @override
  String get importError_invalidData_title => '无效的数据文件';

  @override
  String get importError_invalidData_content => '数据文件格式不匹配。请确保您选择的是由本应用导出的数据文件。';
}
