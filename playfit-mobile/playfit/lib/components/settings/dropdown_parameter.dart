import 'package:flutter/material.dart';

// class DropDownParameter<T> extends StatefulWidget {
//   final String title;
//   final T currentValue;
//   final List<T> items;
//   final void Function(T?) onChanged;
//   final String Function(T) itemLabelBuilder;

//   const DropDownParameter({super.key,
//     required this.title,
//     required this.currentValue,
//     required this.items,
//     required this.onChanged,
//     required this.itemLabelBuilder,
//   });

//   @override
//   State<DropDownParameter> createState() => _DropDownParameterState();
// }

// class _DropDownParameterState extends State<DropDownParameter> {
//   @override
//   Widget build(BuildContext context) {
//     return ListTile(
//       leading: Icon(Icons.circle, size: 10, color: const Color(0xFFE07C27)),
//       title: Text(widget.title, style: TextStyle(fontSize: 16)),
//       trailing: DropdownButton<String>(
//         value: widget.currentValue,
//         underline: Container(),
//         items: widget.items.map((item) => DropdownMenuItem(value: item, child: Text(ite))).toList(),
//         onChanged: widget.onChanged,
//       ),
//     );
//   }
// }

class DropdownParameter<T> extends StatelessWidget {
  final String title;
  final T currentValue;
  final List<T> items;
  final void Function(T?) onChanged;
  final String Function(T) itemLabelBuilder;

  const DropdownParameter({
    super.key,
    required this.title,
    required this.currentValue,
    required this.items,
    required this.onChanged,
    required this.itemLabelBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(Icons.circle, size: 10, color: const Color(0xFFE07C27)),
      title: Text(title, style: TextStyle(fontSize: 16)),
      trailing: DropdownButton<T>(
        value: currentValue,
        underline: Container(),
        items: items
            .map((item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabelBuilder(item),
                  ),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}
