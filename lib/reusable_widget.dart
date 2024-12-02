import 'package:flutter/material.dart';

// Button widget with simple label
TextButton myButton(String label) {
  return TextButton(
    onPressed: () {},
    child: Text(
      label,
      style: const TextStyle(color: Colors.black, fontSize: 17),
    ),
  );
}

// Custom button widget with a container and action callback
Container myButton2(BuildContext context, String label, VoidCallback onTap) {
  return Container(
    height: 50,
    width: 300,
    decoration: BoxDecoration(
      color: Colors.blueAccent,
      borderRadius: BorderRadius.circular(60),
    ),
    child: TextButton(
      onPressed: onTap,
      child: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
    ),
  );
}

// Custom text field widget for email and password inputs
Widget myTextForm(
  IconData icon,
  String labelText,
  bool obscureText,
  bool isPassword,
  TextEditingController controller,
  VoidCallback? onPressed, {
  TextInputType? keyboardType,
  int? maxLength,
  String? Function(String?)? validator,
}) {
  return Container(
    height: 60,
    width: 400,
    child: TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLength: maxLength,
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 255, 255, 255),
        prefixIcon: Icon(icon),
        focusColor: Colors.blueAccent,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 81, 181, 243),
            width: 2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color.fromARGB(255, 38, 173, 240),
            width: 2,
          ),
        ),
        labelText: labelText,
        labelStyle: const TextStyle(fontSize: 10),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off),
                onPressed: onPressed,  // Toggling password visibility
              )
            : null,
      ),
    ),
  );
}

// Logo widget for displaying an image that can be tapped
Widget logoWidget(String fName, double height, double width) {
  return GestureDetector(
    child: Image.asset(
      fName,
      height: height,
      width: width,
    ),
    onTap: () {},  // Add any action you want when the logo is tapped
  );
}

