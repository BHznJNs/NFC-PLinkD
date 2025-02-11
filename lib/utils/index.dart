const String appScheme = 'nfcplinkd';
const String linkHost = 'link';

Uri linkIdUriFactory(String id) =>
  Uri(scheme: appScheme, host: linkHost, path: id);

class CustomError extends Error {
  CustomError({required this.title, required this.content});
  final String title;
  final String content;
}
