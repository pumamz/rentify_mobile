import 'dart:async';

class RefreshNotifier {
  static final RefreshNotifier _instance = RefreshNotifier._();
  factory RefreshNotifier() => _instance;
  RefreshNotifier._();

  final _controller = StreamController<String>.broadcast();
  Stream<String> get stream => _controller.stream;

  void refresh(String screen) => _controller.add(screen);
  void refreshAll() => _controller.add('all');
  void triggerLogout() => _controller.add('logout');
  void dispose() => _controller.close();
}
