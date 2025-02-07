import 'package:flutter/material.dart';

class CheckboxFormField extends FormField<bool> {
  CheckboxFormField(
      {Widget? title,
      void Function(bool?)? onChanged,
      FormFieldValidator<bool>? validator,
      bool initialValue = false,
      bool autovalidate = false})
      : super(
            validator: validator,
            initialValue: initialValue,
            builder: (FormFieldState<bool> state) {
              return CheckboxListTile(
                dense: state.hasError,
                title: title,
                value: state.value,
                onChanged: (val) {
                  state.didChange(val);
                  onChanged?.call(val);
                },
                subtitle: state.hasError
                    ? Builder(
                        builder: (BuildContext context) => Text(
                          state.errorText ?? "",
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.error),
                        ),
                      )
                    : null,
                controlAffinity: ListTileControlAffinity.leading,
              );
            });
}

// import 'package:flutter/material.dart';

// class CheckboxFormField extends FormField<bool> {
//   final Widget title;
//   final bool isChecked;

//   CheckboxFormField({
//     super.key,
//     required this.title,
//     required this.isChecked,
//     super.validator,
//   }) : super(
//             autovalidateMode: AutovalidateMode.onUserInteraction,
//             initialValue: isChecked,
//             builder: (FormFieldState<bool> state) {
//               return CheckboxListTile(
//                 title: title,
//                 value: state.value,
//                 onChanged: (val) {
//                   state.didChange(val);
//                 },
//                 subtitle: state.hasError
//                     ? Builder(
//                         builder: (BuildContext context) => Text(
//                           state.errorText ?? "",
//                           style: TextStyle(
//                               color: Theme.of(context).colorScheme.error),
//                         ),
//                       )
//                     : null,
//                 controlAffinity: ListTileControlAffinity.leading,
//               );
//             });
// }

