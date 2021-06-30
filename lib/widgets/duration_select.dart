import 'package:flutter/material.dart';
import 'package:komodo_dex/blocs/dialog_bloc.dart';
import 'package:komodo_dex/widgets/small_button.dart';

class DurationSelect extends StatefulWidget {
  const DurationSelect({
    this.value,
    this.options,
    this.disabled,
    this.onChange,
  });

  final String value;
  final List<String> options;
  final bool disabled;
  final Function(String) onChange;

  @override
  _DurationSelectState createState() => _DurationSelectState();
}

class _DurationSelectState extends State<DurationSelect> {
  @override
  Widget build(BuildContext context) {
    return SmallButton(
      onPressed: !widget.disabled
          ? () {
              _buildDurationDialog(widget.options);
            }
          : null,
      child: Row(
        children: <Widget>[
          Text(
            _durations[widget.value] ?? 'duration',
            style: const TextStyle(fontSize: 12),
          ),
          Icon(
            Icons.arrow_drop_down,
            size: 12,
          ),
        ],
      ),
    );
  }

  void _buildDurationDialog(List<String> durations) {
    final List<SimpleDialogOption> options = [];

    for (String duration in durations) {
      if (_durations[duration] != null) {
        options.add(
          SimpleDialogOption(
            onPressed: () {
              widget.onChange(duration);
              dialogBloc.closeDialog(context);
            },
            child: Row(
              children: <Widget>[
                Icon(
                  duration == widget.value
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  size: 16,
                  color: duration == widget.value
                      ? Theme.of(context).accentColor
                      : null,
                ),
                const SizedBox(width: 4),
                Text(
                  _durations[duration] ?? '${duration}s',
                  style: TextStyle(
                      color: duration == widget.value
                          ? Theme.of(context).accentColor
                          : null),
                ),
              ],
            ),
          ),
        );
      }
    }

    dialogBloc.dialog = showDialog<void>(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Duration'),
            children: options,
          );
        }).then((dynamic _) => dialogBloc.dialog = null);
  }
}

Map<String, String> _durations = {
  '60': '1min',
  '180': '3min',
  '300': '5min',
  '900': '15min',
  '1800': '30min',
  '3600': '1hour',
  '7200': '2hours',
  '14400': '4hours',
  '21600': '6hours',
  '43200': '12hours',
  '86400': '24hours',
};
