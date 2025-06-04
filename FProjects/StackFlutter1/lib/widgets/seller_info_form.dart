import 'package:flutter/material.dart';
import 'neo_container.dart';

class SellerInfoForm extends StatefulWidget {
  const SellerInfoForm({super.key});

  @override
  State<SellerInfoForm> createState() => _SellerInfoFormState();
}

class _SellerInfoFormState extends State<SellerInfoForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType? keyboardType,
    String? hintText,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 8),
        NeoContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines ?? 1,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF7A8C98),
              ),
            ),
            style: const TextStyle(
              color: Color(0xFF2D3436),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          'Full Name',
          _nameController,
          hintText: 'Enter seller\'s full name',
        ),
        const SizedBox(height: 24),
        _buildTextField(
          'Email',
          _emailController,
          keyboardType: TextInputType.emailAddress,
          hintText: 'Enter seller\'s email address',
        ),
        const SizedBox(height: 24),
        _buildTextField(
          'Phone Number',
          _phoneController,
          keyboardType: TextInputType.phone,
          hintText: 'Enter seller\'s phone number',
        ),
        const SizedBox(height: 24),
        _buildTextField(
          'Address',
          _addressController,
          maxLines: 3,
          hintText: 'Enter seller\'s address',
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }
} 