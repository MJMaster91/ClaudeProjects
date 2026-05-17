import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notification_listener_service/notification_listener_service.dart';
import 'package:notification_listener_service/notification_event.dart';
import '../models/contact.dart';
import 'contacts_provider.dart';

final unreadWhatsappProvider =
    StateNotifierProvider<WhatsappNotifier, Map<int, int>>(
  (ref) => WhatsappNotifier(ref),
);

class WhatsappNotifier extends StateNotifier<Map<int, int>> {
  WhatsappNotifier(this._ref) : super({}) {
    _startListening();
  }

  final Ref _ref;
  StreamSubscription<ServiceNotificationEvent>? _sub;

  void _startListening() {
    _sub = NotificationListenerService.notificationsStream.listen(_onEvent);
  }

  void _onEvent(ServiceNotificationEvent event) {
    final pkg = event.packageName;
    if (pkg != 'com.whatsapp' && pkg != 'com.whatsapp.w4b') return;

    final title = event.title?.trim();
    if (title == null || title.isEmpty) return;

    final contacts = _ref.read(contactsProvider).valueOrNull;
    if (contacts == null) return;

    Contact? match;
    for (final c in contacts) {
      if (c.hasWhatsapp &&
          c.name.trim().toLowerCase() == title.toLowerCase()) {
        match = c;
        break;
      }
    }
    if (match == null || match.id == null) return;

    state = Map.from(state)..[match.id!] = (state[match.id!] ?? 0) + 1;
  }

  void clearUnread(int contactId) {
    if (!state.containsKey(contactId)) return;
    state = Map.from(state)..remove(contactId);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
