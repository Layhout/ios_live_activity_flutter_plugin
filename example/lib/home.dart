import 'dart:async';

import 'package:flutter/material.dart';
import 'package:live_activity_plugin/live_activity_plugin.dart';
import 'package:permission_handler/permission_handler.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  StartLiveActivityResponse? _liveActivityResponse;
  String _liveActivityState = "N/A";

  @override
  void initState() {
    super.initState();

    init();
  }

  void init() async {
    if (await Permission.notification.isGranted != true) {
      await Permission.notification.request();
    }

    await LiveActivityManager.init();
    debugPrint('🟢 ${await LiveActivityManager.isActivitiesAllowed()}');
  }

  void _testUpdateLiveActivity() async {
    _liveActivityResponse = await LiveActivityManager.startLiveActivity(data: {
      'title': 'Order Placed',
      'description': 'Your order has been placed',
      'step': 0,
      'distance': 3,
    });

    setState(() {
      _liveActivityState = 'Started';
    });

    await Future.delayed(const Duration(seconds: 5));

    await LiveActivityManager.updateLiveActivity(
      activityId: _liveActivityResponse?.id ?? "",
      data: {
        'title': 'Preparing Order',
        'description': 'We are preparing your order',
        'step': 1,
        'distance': 3,
      },
    );

    await Future.delayed(const Duration(seconds: 5));

    await LiveActivityManager.updateLiveActivity(
      activityId: _liveActivityResponse?.id ?? "",
      data: {
        'title': 'Delivering Order',
        'description': 'Delivering by 12:30 PM',
        'step': 2,
        'distance': 3,
      },
    );

    await Future.delayed(const Duration(seconds: 5));

    await LiveActivityManager.updateLiveActivity(
      activityId: _liveActivityResponse?.id ?? "",
      data: {
        'title': 'Completed',
        'description': 'Thank you for ordering with us! Enjoy!',
        'step': 3,
        'distance': 3,
      },
    );

    await Future.delayed(const Duration(seconds: 5));

    setState(() {
      _liveActivityState = 'Closing';
    });

    await LiveActivityManager.endLiveActivity(
      activityId: _liveActivityResponse?.id ?? "",
      endIn: const Duration(seconds: 5),
    );

    setState(() {
      _liveActivityState = 'Closed';
      _liveActivityResponse = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Testing Live Activity",
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(
                height: 8,
              ),
              const Text(
                "Press \"Simulate Place an Order,\" swipe down, and view the live activity on your lock screen.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 16,
              ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _testUpdateLiveActivity,
                  child: const Text('Simulate place an order'),
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              Text(
                "Live Activity state: $_liveActivityState",
                textAlign: TextAlign.center,
              ),
              Text(
                "Live Activity id: ${_liveActivityResponse?.id ?? "null"}",
                textAlign: TextAlign.center,
              ),
              Text(
                "Push token: ${_liveActivityResponse?.pushToken ?? "null"}",
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
