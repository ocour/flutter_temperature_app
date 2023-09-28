import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:temperature_app/services/api/temperature_api_service.dart';
import 'package:temperature_app/services/api/temperature_data.dart';
import 'package:temperature_app/ui/utils/temperature_app_app_bar.dart';

import '../../services/api/exceptions.dart';
import '../../services/api/thing_name.dart';

class ThingTemperatureDataScreen extends StatefulWidget {
  const ThingTemperatureDataScreen({super.key, required this.thing});

  static const String routeName = "temperature-data";
  final ThingName thing;

  @override
  State<ThingTemperatureDataScreen> createState() =>
      _ThingTemperatureDataScreenState();
}

class _ThingTemperatureDataScreenState
    extends State<ThingTemperatureDataScreen> {
  final _temperatureData = <TemperatureData>[];
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

  Future<void> _getTemperatureData() async {
    try {
      startLoading();
      final thing = widget.thing;
      final result =
          await context.read<TemperatureApiService>().getTemperatureData(thing);
      setState(() {
        _temperatureData.clear();
        _temperatureData.addAll(result);
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
      _getTemperatureData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TemperatureAppAppBar(
        title: widget.thing.thingName,
        showMenu: false,
      ),
      body: Column(
        children: [
          if (_isLoading) const LinearProgressIndicator(),
          Expanded(
            child: RefreshIndicator(
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              color: Theme.of(context).colorScheme.primary,
              onRefresh: () async {
                _getTemperatureData();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _temperatureData.isNotEmpty
                    ? ListView.separated(
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        itemCount: _temperatureData.length,
                        itemBuilder: (context, index) => TemperatureTile(
                          data: _temperatureData[index],
                        ),
                        separatorBuilder: (context, index) =>
                            const Divider(height: 16, thickness: 0),
                      )
                    : ListView(
                        physics: const BouncingScrollPhysics(
                            parent: AlwaysScrollableScrollPhysics()),
                        children: [
                          Center(
                            child: _isLoading
                                ? null
                                : const Text("No temperature data"),
                          )
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

class TemperatureTile extends StatelessWidget {
  const TemperatureTile({super.key, required this.data});

  final TemperatureData data;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.thermostat_rounded),
      title: Text("${data.temperature}\u2103"),
      subtitle: Text("${data.timeStamp.toLocal()}"),
    );
  }
}
