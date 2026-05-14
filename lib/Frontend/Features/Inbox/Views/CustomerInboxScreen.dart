import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:near_me/Frontend/Features/Chat/Views/RealtimeInboxScreen.dart';

class CustomerInboxScreen extends ConsumerWidget {
  const CustomerInboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Simply delegate to the RealtimeInboxScreen which handles the logic
    return const RealtimeInboxScreen();
  }
}
