import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FormattedPhoneNumber extends StatefulWidget {
  @override
  _FormattedPhoneNumberState createState() => _FormattedPhoneNumberState();
}

class _FormattedPhoneNumberState extends State<FormattedPhoneNumber> {
  String text = "";

  convert(TextEditingValue oldValue, TextEditingValue newValue) {
    print("OldValue: ${oldValue.text}, NewValue: ${newValue.text}");
    String newText = newValue.text;

    if (newText.length == 10) {
      // The below code gives a range error if not 10.
      RegExp phone = RegExp(r'(\d{3})(\d{3})(\d{4})');
      var matches = phone.allMatches(newValue.text);
      var match = matches.elementAt(0);
      newText = '(${match.group(1)}) ${match.group(2)}-${match.group(3)}';
    }

    // TODO limit text to the length of a formatted phone number?

    setState(() {
      text = newText;
    });

    return TextEditingValue(
        text: newText,
        selection: TextSelection(
            baseOffset: newValue.text.length,
            extentOffset: newValue.text.length));
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              inputFormatters: [
                TextInputFormatter.withFunction(
                    (oldValue, newValue) => convert(oldValue, newValue)),
              ],
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "input",
                  labelText: "Converts to phone number format"),

              // Fixes a problem with text-caret only being at the start of the textfield.
              controller: TextEditingController.fromValue(new TextEditingValue(
                  text: text,
                  selection: new TextSelection.collapsed(offset: text.length))),
            ),
          ),
        ],
      ),
    );
  }
}
