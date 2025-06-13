import 'package:flutter/material.dart';
import 'neo_container.dart';
import 'glass_container.dart';

class DeviceDetailsForm extends StatefulWidget {
  const DeviceDetailsForm({super.key});

  @override
  State<DeviceDetailsForm> createState() => _DeviceDetailsFormState();
}

class _DeviceDetailsFormState extends State<DeviceDetailsForm> {
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final List<String> _selectedAccessories = [];

  final List<String> _availableAccessories = [
    'Charger',
    'Original Box',
    'Case',
    'Screen Protector',
    'Earphones',
    'Manual',
  ];

  Widget _buildTextField(String label, TextEditingController controller, {int? maxLines}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);
    final hintTextColor = isDark ? Colors.grey[400] : const Color(0xFF7A8C98);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 8),
        GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintStyle: TextStyle(
                color: hintTextColor,
              ),
            ),
            style: TextStyle(
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccessoriesGrid() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _availableAccessories.length,
      itemBuilder: (context, index) {
        final accessory = _availableAccessories[index];
        final isSelected = _selectedAccessories.contains(accessory);
        
        return GlassButton(
          onPressed: () {
            setState(() {
              if (isSelected) {
                _selectedAccessories.remove(accessory);
              } else {
                _selectedAccessories.add(accessory);
              }
            });
          },
          isSelected: isSelected,
          child: Text(
            accessory,
            style: TextStyle(
              color: isSelected ? theme.primaryColor : textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField('Color', _colorController),
        const SizedBox(height: 24),
        _buildTextField('Year (Optional)', _yearController),
        const SizedBox(height: 24),
        const Text(
          'Included Accessories',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 16),
        _buildAccessoriesGrid(),
        const SizedBox(height: 24),
        _buildTextField('Additional Notes', _notesController, maxLines: 4),
      ],
    );
  }

  @override
  void dispose() {
    _colorController.dispose();
    _yearController.dispose();
    _notesController.dispose();
    super.dispose();
  }
} 