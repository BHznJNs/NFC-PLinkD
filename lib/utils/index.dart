const String appScheme = 'nfcplinkd';
const String linkHost = 'link';

class CustomError extends Error {
  CustomError({required this.title, required this.content});
  final String title;
  final String content;
}
