import 'package:web/web.dart' as web;

bool isCupertino() {
  final _devices = [
    'iPad Simulator',
    'iPhone Simulator',
    'iPod Simulator',
    'iPad',
    'iPhone',
    'iPod',
    'Mac OS X',
  ];

  final String _agent = web.window.navigator.userAgent;
  for (final device in _devices) {
    if (_agent.contains(device)) {
      return true;
    }
  }
  return false;
}
