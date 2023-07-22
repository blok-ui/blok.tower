package blok.tower.content;

enum abstract ContentType(String) to String {
  final RouteLink = '@link';
  final Text = '@text';
  final Fragment = '@fragment';
}
