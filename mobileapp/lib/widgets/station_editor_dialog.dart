import 'package:flutter/material.dart';

import 'package:mobileapp/models/station.dart';
import 'package:mobileapp/services/station_service.dart';
import 'package:mobileapp/widgets/gold_text_field.dart';

class StationEditorDialog extends StatefulWidget {
  const StationEditorDialog({
    required this.stationService,
    this.station,
    super.key,
  });

  final StationService stationService;
  final Station? station;

  @override
  State<StationEditorDialog> createState() => _StationEditorDialogState();
}

class _StationEditorDialogState extends State<StationEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _locationController;
  late final TextEditingController _tempController;
  late final TextEditingController _loadController;
  late final TextEditingController _hashrateController;
  late final TextEditingController _minedController;

  @override
  void initState() {
    super.initState();
    final station = widget.station;
    _nameController = TextEditingController(text: station?.name ?? '');
    _locationController = TextEditingController(text: station?.location ?? '');
    _tempController = TextEditingController(
      text: station?.metrics.temperatureC.toStringAsFixed(0) ?? '',
    );
    _loadController = TextEditingController(
      text: station?.metrics.loadPercent.toStringAsFixed(0) ?? '',
    );
    _hashrateController = TextEditingController(
      text: station?.metrics.hashrateThs.toStringAsFixed(0) ?? '',
    );
    _minedController = TextEditingController(
      text: station?.metrics.minedBtc.toStringAsFixed(3) ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _tempController.dispose();
    _loadController.dispose();
    _hashrateController.dispose();
    _minedController.dispose();
    super.dispose();
  }

  double _parseDouble(TextEditingController controller) {
    return double.parse(controller.text.replaceAll(',', '.'));
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final station = widget.stationService.buildStation(
      id: widget.station?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      location: _locationController.text,
      temperatureC: _parseDouble(_tempController),
      loadPercent: _parseDouble(_loadController),
      hashrateThs: _parseDouble(_hashrateController),
      minedBtc: _parseDouble(_minedController),
    );

    Navigator.pop(context, station);
  }

  @override
  Widget build(BuildContext context) {
    final station = widget.station;

    return AlertDialog(
      title: Text(station == null ? 'Нова станція' : 'Редагувати станцію'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GoldTextField(
                label: 'Назва',
                controller: _nameController,
                validator: (value) =>
                    widget.stationService.validateRequired(value, 'Назва'),
              ),
              const SizedBox(height: 12),
              GoldTextField(
                label: 'Локація',
                controller: _locationController,
                validator: (value) => widget.stationService.validateRequired(
                  value,
                  'Локація',
                ),
              ),
              const SizedBox(height: 12),
              GoldTextField(
                label: 'Температура (C)',
                controller: _tempController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => widget.stationService.validateNumber(
                  value,
                  'Температура',
                  min: 0,
                ),
              ),
              const SizedBox(height: 12),
              GoldTextField(
                label: 'Навантаження (%)',
                controller: _loadController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => widget.stationService.validateNumber(
                  value,
                  'Навантаження',
                  min: 0,
                  max: 100,
                ),
              ),
              const SizedBox(height: 12),
              GoldTextField(
                label: 'Хешрейт (TH/s)',
                controller: _hashrateController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => widget.stationService.validateNumber(
                  value,
                  'Хешрейт',
                  min: 0,
                ),
              ),
              const SizedBox(height: 12),
              GoldTextField(
                label: 'Добуто (BTC)',
                controller: _minedController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) => widget.stationService.validateNumber(
                  value,
                  'Добуто',
                  min: 0,
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Скасувати'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Зберегти'),
        ),
      ],
    );
  }
}
