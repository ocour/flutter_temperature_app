import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/services/api/temperature_api_service.dart';

import '../../services/api/exceptions.dart';
import '../../services/api/thing_name.dart';
import '../utils/temperature_app_app_bar.dart';
import '../utils/temperature_device_card.dart';
import 'ble/device_provisioning_screen.dart';
import 'thing_temperature_data_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _things = <ThingName>[];
  bool _isLoading = false;

  void startLoading() {
    setState(() {
      _isLoading = true;
    });
  }

  void stopLoading() {
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _getThings() async {
    try {
      startLoading();
      final result = await context.read<TemperatureApiService>().getAllThings();
      setState(() {
        _things.clear();
        _things.addAll(result);
      });
    } on ApiUnauthorizedException {
      displayErrorSnackBar("Error: unauthorized");
    } catch (e) {
      displayErrorSnackBar("Error: $e");
    } finally {
      stopLoading();
    }
  }

  void displayErrorSnackBar(String message) {
    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: Theme.of(context).colorScheme.onError,
          ),
          const SizedBox(
            width: 16.0,
          ),
          Flexible(
            child: Text(
              message,
            ),
          ),
        ],
      ),
      action: SnackBarAction(
        label: "Dismiss",
        onPressed: () {},
      ),
      behavior: SnackBarBehavior.floating,
    );

    // Find the ScaffoldMessenger in the widget tree
    // and use it to show a SnackBar.
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getThings();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TemperatureAppAppBar(title: "Temperature App"),
      floatingActionButton: FloatingActionButton.large(
        onPressed: () {
          Navigator.of(context).pushNamed(DeviceProvisioningScreen.routeName);
        },
        tooltip: "Provision new device",
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          _isLoading
              ? const LinearProgressIndicator()
              : const SizedBox.shrink(),
          Expanded(
            child: RefreshIndicator(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              color: Theme.of(context).colorScheme.primary,
              onRefresh: () async {
                await _getThings();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _things.isNotEmpty
                    ? ThingListView(things: _things)
                    : ListView(
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        children: [
                          Center(
                            child: _isLoading
                                ? null
                                : const Text(
                                    "Register a new sensor by clicking the plus(+) button"),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ThingListView extends StatelessWidget {
  const ThingListView({super.key, required this.things});

  final List<ThingName> things;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics:
          const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      itemCount: things.length,
      itemBuilder: (_, index) {
        return TemperatureDeviceCard(
          name: things[index].thingName,
          onTap: () {
            Navigator.of(context).pushNamed(
                ThingTemperatureDataScreen.routeName,
                arguments: things[index]);
          },
        );
      },
      separatorBuilder: (BuildContext context, int index) =>
          const Divider(height: 16, thickness: 0),
    );
  }
}
