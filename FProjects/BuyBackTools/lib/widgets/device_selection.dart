import 'package:flutter/material.dart';
import 'neo_container.dart';

class DeviceSelectionForm extends StatefulWidget {
  const DeviceSelectionForm({super.key});

  @override
  State<DeviceSelectionForm> createState() => _DeviceSelectionFormState();
}

class _DeviceSelectionFormState extends State<DeviceSelectionForm> {
  String? _selectedDeviceType;
  String? _selectedModel;
  String? _selectedStorage;
  String? _selectedCondition;

  final List<String> _deviceTypes = ['iPhone', 'iPad', 'MacBook', 'Apple Watch'];
  final List<String> _models = ['iPhone 15 Pro Max', 'iPhone 15 Pro', 'iPhone 15 Plus', 'iPhone 15'];
  final List<String> _storageOptions = ['128GB', '256GB', '512GB', '1TB'];
  final List<String> _conditions = ['New', 'Like New', 'Good', 'Fair'];

  Widget _buildSelectionGrid(List<String> items, String? selectedItem, Function(String) onSelect) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.0,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = item == selectedItem;
        
        return GlassButton(
          onPressed: () => onSelect(item),
          isSelected: isSelected,
          height: 40,
          child: Text(
            item,
            style: TextStyle(
              color: isSelected ? theme.primaryColor : textColor,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Device Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 12),
        _buildSelectionGrid(_deviceTypes, _selectedDeviceType, (value) {
          setState(() {
            _selectedDeviceType = value;
          });
        }),
        const SizedBox(height: 24),
        if (_selectedDeviceType != null) ...[
          Text(
            'Model',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildSelectionGrid(_models, _selectedModel, (value) {
            setState(() {
              _selectedModel = value;
            });
          }),
          const SizedBox(height: 24),
        ],
        if (_selectedModel != null) ...[
          Text(
            'Storage',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildSelectionGrid(_storageOptions, _selectedStorage, (value) {
            setState(() {
              _selectedStorage = value;
            });
          }),
          const SizedBox(height: 24),
        ],
        if (_selectedStorage != null) ...[
          Text(
            'Condition',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildSelectionGrid(_conditions, _selectedCondition, (value) {
            setState(() {
              _selectedCondition = value;
            });
          }),
        ],
      ],
    );
  }
} 