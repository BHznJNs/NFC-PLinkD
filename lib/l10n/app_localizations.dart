import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S? of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('zh')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'NFC PLinkD'**
  String get appTitle;

  /// No description provided for @drawer_createPage.
  ///
  /// In en, this message translates to:
  /// **'Create a Link'**
  String get drawer_createPage;

  /// No description provided for @drawer_readPage.
  ///
  /// In en, this message translates to:
  /// **'Read a Link'**
  String get drawer_readPage;

  /// No description provided for @drawer_galleryPage.
  ///
  /// In en, this message translates to:
  /// **'Link Gallery'**
  String get drawer_galleryPage;

  /// No description provided for @drawer_settingPage.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get drawer_settingPage;

  /// No description provided for @createPage_title.
  ///
  /// In en, this message translates to:
  /// **'Create a Link'**
  String get createPage_title;

  /// No description provided for @createPage_image.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get createPage_image;

  /// No description provided for @createPage_video.
  ///
  /// In en, this message translates to:
  /// **'Record a Video'**
  String get createPage_video;

  /// No description provided for @createPage_audio.
  ///
  /// In en, this message translates to:
  /// **'Record a Audio'**
  String get createPage_audio;

  /// No description provided for @createPage_weblink.
  ///
  /// In en, this message translates to:
  /// **'Attach a Web Link'**
  String get createPage_weblink;

  /// No description provided for @readPage_approachNFCTagHint.
  ///
  /// In en, this message translates to:
  /// **'Approach an NFC Tag'**
  String get readPage_approachNFCTagHint;

  /// No description provided for @readPage_readStopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get readPage_readStopped;

  /// No description provided for @readPage_readError_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'NFC tag reading error'**
  String get readPage_readError_dialog_title;

  /// No description provided for @galleryPage_emptyText.
  ///
  /// In en, this message translates to:
  /// **'No links available. Please create one!'**
  String get galleryPage_emptyText;

  /// No description provided for @galleryPage_popup_open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get galleryPage_popup_open;

  /// No description provided for @galleryPage_popup_write.
  ///
  /// In en, this message translates to:
  /// **'Write'**
  String get galleryPage_popup_write;

  /// No description provided for @galleryPage_popup_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get galleryPage_popup_delete;

  /// No description provided for @settingsPage_applicationTheme_title.
  ///
  /// In en, this message translates to:
  /// **'Application theme'**
  String get settingsPage_applicationTheme_title;

  /// No description provided for @settingsPage_applicationTheme_light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsPage_applicationTheme_light;

  /// No description provided for @settingsPage_applicationTheme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsPage_applicationTheme_dark;

  /// No description provided for @settingsPage_applicationTheme_system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsPage_applicationTheme_system;

  /// No description provided for @settingsPage_useBuiltinVideoPlayer_title.
  ///
  /// In en, this message translates to:
  /// **'Use built-in video player'**
  String get settingsPage_useBuiltinVideoPlayer_title;

  /// No description provided for @settingsPage_useBuiltinVideoPlayer_description.
  ///
  /// In en, this message translates to:
  /// **'Or use system default player'**
  String get settingsPage_useBuiltinVideoPlayer_description;

  /// No description provided for @settingsPage_useBuiltinAudioPlayer_title.
  ///
  /// In en, this message translates to:
  /// **'Use built-in audio player'**
  String get settingsPage_useBuiltinAudioPlayer_title;

  /// No description provided for @settingsPage_useBuiltinAudioPlayer_description.
  ///
  /// In en, this message translates to:
  /// **'Or use system default player'**
  String get settingsPage_useBuiltinAudioPlayer_description;

  /// No description provided for @recorderPage_title.
  ///
  /// In en, this message translates to:
  /// **'Record a Audio'**
  String get recorderPage_title;

  /// No description provided for @editLinkPage_title.
  ///
  /// In en, this message translates to:
  /// **'Edit a Link'**
  String get editLinkPage_title;

  /// No description provided for @editLinkPage_no_content_msg.
  ///
  /// In en, this message translates to:
  /// **'There is no content, please add some.'**
  String get editLinkPage_no_content_msg;

  /// No description provided for @editLinkPage_success_msg.
  ///
  /// In en, this message translates to:
  /// **'You data was successfully saved, press \"OK\" to back.'**
  String get editLinkPage_success_msg;

  /// No description provided for @editLinkPage_actionLabel_image.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get editLinkPage_actionLabel_image;

  /// No description provided for @editLinkPage_actionLabel_video.
  ///
  /// In en, this message translates to:
  /// **'Record a video'**
  String get editLinkPage_actionLabel_video;

  /// No description provided for @editLinkPage_actionLabel_audio.
  ///
  /// In en, this message translates to:
  /// **'Record a audio'**
  String get editLinkPage_actionLabel_audio;

  /// No description provided for @editLinkPage_actionLabel_weblink.
  ///
  /// In en, this message translates to:
  /// **'Attach a web link'**
  String get editLinkPage_actionLabel_weblink;

  /// No description provided for @editLinkPage_actionLabel_upload.
  ///
  /// In en, this message translates to:
  /// **'Upload some resource'**
  String get editLinkPage_actionLabel_upload;

  /// No description provided for @editLinkPage_linkName_hint.
  ///
  /// In en, this message translates to:
  /// **'Input link name here...'**
  String get editLinkPage_linkName_hint;

  /// No description provided for @editLinkPage_dialog_action_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get editLinkPage_dialog_action_save;

  /// No description provided for @editLinkPage_dialog_action_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get editLinkPage_dialog_action_delete;

  /// No description provided for @editLinkPage_dialog_title.
  ///
  /// In en, this message translates to:
  /// **'Edit Item'**
  String get editLinkPage_dialog_title;

  /// No description provided for @editLinkPage_dialog_description_hint.
  ///
  /// In en, this message translates to:
  /// **'Input the descriptions here...'**
  String get editLinkPage_dialog_description_hint;

  /// No description provided for @resourceList_item_noDescription_hint.
  ///
  /// In en, this message translates to:
  /// **'No description'**
  String get resourceList_item_noDescription_hint;

  /// No description provided for @custom_dialog_action_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get custom_dialog_action_cancel;

  /// No description provided for @custom_dialog_action_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get custom_dialog_action_delete;

  /// No description provided for @custom_dialog_action_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get custom_dialog_action_confirm;

  /// No description provided for @custom_dialog_action_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get custom_dialog_action_ok;

  /// No description provided for @custom_dialog_delete_title.
  ///
  /// In en, this message translates to:
  /// **'Confirm Deletion'**
  String get custom_dialog_delete_title;

  /// No description provided for @custom_dialog_delete_content.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item? This action cannot be undone, so please proceed with caution.'**
  String get custom_dialog_delete_content;

  /// No description provided for @custom_dialog_weblink_title.
  ///
  /// In en, this message translates to:
  /// **'Website Link'**
  String get custom_dialog_weblink_title;

  /// No description provided for @custom_dialog_weblink_invalidUrlMsg.
  ///
  /// In en, this message translates to:
  /// **'Invalid URL'**
  String get custom_dialog_weblink_invalidUrlMsg;

  /// No description provided for @custom_dialog_success_title.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get custom_dialog_success_title;

  /// No description provided for @custom_dialog_nfc_approach_title.
  ///
  /// In en, this message translates to:
  /// **'Approach an NFC Tag'**
  String get custom_dialog_nfc_approach_title;

  /// No description provided for @nfc_error_function_disabled_title.
  ///
  /// In en, this message translates to:
  /// **'NFC Function Disabled'**
  String get nfc_error_function_disabled_title;

  /// No description provided for @nfc_error_function_disabled_content.
  ///
  /// In en, this message translates to:
  /// **'Please enable the NFC function of your phone and retry.'**
  String get nfc_error_function_disabled_content;

  /// No description provided for @nfc_error_tag_unusable_title.
  ///
  /// In en, this message translates to:
  /// **'NFC Tag Unusable'**
  String get nfc_error_tag_unusable_title;

  /// No description provided for @nfc_error_tag_unusable_content.
  ///
  /// In en, this message translates to:
  /// **'The approached NFC tag is not writable or readable, it may be locked or does not support NDEF.'**
  String get nfc_error_tag_unusable_content;

  /// No description provided for @nfc_error_tag_write_failed_title.
  ///
  /// In en, this message translates to:
  /// **'NFC Write Failed'**
  String get nfc_error_tag_write_failed_title;

  /// No description provided for @nfc_error_tag_write_failed_content.
  ///
  /// In en, this message translates to:
  /// **'An error occurred while writing to the NFC tag. Please try again.'**
  String get nfc_error_tag_write_failed_content;

  /// No description provided for @nfc_error_tag_data_invalid_title.
  ///
  /// In en, this message translates to:
  /// **'NFC Tag Data Invalid'**
  String get nfc_error_tag_data_invalid_title;

  /// No description provided for @nfc_error_tag_data_invalid_content.
  ///
  /// In en, this message translates to:
  /// **'The data read from the NFC tag is not in the expected format. It may not be a valid URI or not compatible with this application. Please ensure the tag contains the correct data type for this app.'**
  String get nfc_error_tag_data_invalid_content;

  /// No description provided for @nfc_error_tag_formated_title.
  ///
  /// In en, this message translates to:
  /// **'NFC Tag Formated'**
  String get nfc_error_tag_formated_title;

  /// No description provided for @nfc_error_tag_formated_content.
  ///
  /// In en, this message translates to:
  /// **'The approached NFC tag is formated, please approach again to write data.'**
  String get nfc_error_tag_formated_content;

  /// No description provided for @nfc_error_tag_empty_title.
  ///
  /// In en, this message translates to:
  /// **'NFC Tag Empty'**
  String get nfc_error_tag_empty_title;

  /// No description provided for @nfc_error_tag_empty_content.
  ///
  /// In en, this message translates to:
  /// **'The approached NFC tag is empty.'**
  String get nfc_error_tag_empty_content;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return SEn();
    case 'zh': return SZh();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
