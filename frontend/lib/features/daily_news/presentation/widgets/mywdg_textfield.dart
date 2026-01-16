import 'package:flutter/material.dart';

class MyWdgTextField extends StatelessWidget {
  final String? title;
  final TextEditingController controller;
  final String hintText;
  final int? maxLines;
  final EdgeInsetsGeometry padding;
  final String? errorText;
  final bool isRequired;
  final String? helpText;
  final int? maxLength;
  final bool obscureText;
  final Function(String)? onSubmitted;

  const MyWdgTextField({
    Key? key,
    required this.controller,
    this.title,
    required this.hintText,
    this.maxLines = 1,
    this.padding = const EdgeInsets.all(16),
    this.errorText,
    this.isRequired = false,
    this.helpText,
    this.maxLength,
    this.obscureText = false,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if(title != null) Text(
              title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (helpText != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showHelpDialog(context),
                child: Icon(
                  Icons.help_outline,
                  size: 18,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
        if (title != null) const SizedBox(height: 8),
        Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: errorText != null
                  ? Colors.red.shade300
                  : Colors.grey.shade200,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            maxLength: maxLength,
            onSubmitted: (value) => onSubmitted != null ? onSubmitted!(value) : null,
            obscureText: obscureText,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: TextStyle(color: Colors.grey.shade400),
              border: InputBorder.none,
              isDense: true,
              counterText: '', // Hide default counter to maintain clean UI
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 4),
            child: Text(
              errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title ?? "Info",
            style: const TextStyle(
                fontFamily: 'Butler', fontWeight: FontWeight.bold)),
        content: Text(helpText!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Entendido', style: TextStyle(color: Colors.blue)),
          ),
        ],
      ),
    );
  }
}
