// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class SEn extends S {
  SEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'NFC PLinkD';

  @override
  String get drawer_createPage => 'Create a Link';

  @override
  String get drawer_readPage => 'Read a Link';

  @override
  String get drawer_galleryPage => 'Link Gallery';

  @override
  String get drawer_settingPage => 'Settings';

  @override
  String get createPage_title => 'Create a Link';

  @override
  String get createPage_image => 'Take a photo';

  @override
  String get createPage_video => 'Record a Video';

  @override
  String get createPage_audio => 'Record a Audio';

  @override
  String get createPage_weblink => 'Attach a Web Link';

  @override
  String get readPage_approachNFCTagHint => 'Approach an NFC Tag';

  @override
  String get readPage_readStopped => 'Stopped';

  @override
  String get readPage_readError_dialog_title => 'NFC tag reading error';

  @override
  String get galleryPage_emptyText => 'No links available. Please create one!';

  @override
  String get galleryPage_popup_open => 'Open';

  @override
  String get galleryPage_popup_write => 'Write';

  @override
  String get galleryPage_popup_delete => 'Delete';

  @override
  String get settingsPage_applicationTheme_title => 'Application theme';

  @override
  String get settingsPage_applicationTheme_light => 'Light';

  @override
  String get settingsPage_applicationTheme_dark => 'Dark';

  @override
  String get settingsPage_applicationTheme_system => 'System';

  @override
  String get settingsPage_useBuiltinVideoPlayer_title => 'Use built-in video player';

  @override
  String get settingsPage_useBuiltinVideoPlayer_description => 'Or use system default player';

  @override
  String get settingsPage_useBuiltinAudioPlayer_title => 'Use built-in audio player';

  @override
  String get settingsPage_useBuiltinAudioPlayer_description => 'Or use system default player';

  @override
  String get recorderPage_title => 'Record a Audio';

  @override
  String get editLinkPage_title => 'Edit a Link';

  @override
  String get editLinkPage_no_content_msg => 'There is no content, please add some.';

  @override
  String get editLinkPage_success_msg => 'You data was successfully saved, press \"OK\" to back.';

  @override
  String get editLinkPage_actionLabel_image => 'Take a photo';

  @override
  String get editLinkPage_actionLabel_video => 'Record a video';

  @override
  String get editLinkPage_actionLabel_audio => 'Record a audio';

  @override
  String get editLinkPage_actionLabel_weblink => 'Attach a web link';

  @override
  String get editLinkPage_actionLabel_upload => 'Upload some resource';

  @override
  String get editLinkPage_linkName_hint => 'Input link name here...';

  @override
  String get editLinkPage_dialog_action_save => 'Save';

  @override
  String get editLinkPage_dialog_action_delete => 'Delete';

  @override
  String get editLinkPage_dialog_title => 'Edit Item';

  @override
  String get editLinkPage_dialog_description_hint => 'Input the descriptions here...';

  @override
  String get resourceList_item_noDescription_hint => 'No description';

  @override
  String get custom_dialog_action_cancel => 'Cancel';

  @override
  String get custom_dialog_action_delete => 'Delete';

  @override
  String get custom_dialog_action_confirm => 'Confirm';

  @override
  String get custom_dialog_action_ok => 'OK';

  @override
  String get custom_dialog_delete_title => 'Confirm Deletion';

  @override
  String get custom_dialog_delete_content => 'Are you sure you want to delete this item? This action cannot be undone, so please proceed with caution.';

  @override
  String get custom_dialog_weblink_title => 'Website Link';

  @override
  String get custom_dialog_weblink_invalidUrlMsg => 'Invalid URL';

  @override
  String get custom_dialog_success_title => 'Success';

  @override
  String get custom_dialog_nfc_approach_title => 'Approach an NFC Tag';

  @override
  String get nfc_error_function_disabled_title => 'NFC Function Disabled';

  @override
  String get nfc_error_function_disabled_content => 'Please enable the NFC function of your phone and retry.';

  @override
  String get nfc_error_tag_unusable_title => 'NFC Tag Unusable';

  @override
  String get nfc_error_tag_unusable_content => 'The approached NFC tag is not writable or readable, it may be locked or does not support NDEF.';

  @override
  String get nfc_error_tag_write_failed_title => 'NFC Write Failed';

  @override
  String get nfc_error_tag_write_failed_content => 'An error occurred while writing to the NFC tag. Please try again.';

  @override
  String get nfc_error_tag_data_invalid_title => 'NFC Tag Data Invalid';

  @override
  String get nfc_error_tag_data_invalid_content => 'The data read from the NFC tag is not in the expected format. It may not be a valid URI or not compatible with this application. Please ensure the tag contains the correct data type for this app.';

  @override
  String get nfc_error_tag_formated_title => 'NFC Tag Formated';

  @override
  String get nfc_error_tag_formated_content => 'The approached NFC tag is formated, please approach again to write data.';

  @override
  String get nfc_error_tag_empty_title => 'NFC Tag Empty';

  @override
  String get nfc_error_tag_empty_content => 'The approached NFC tag is empty.';
}
