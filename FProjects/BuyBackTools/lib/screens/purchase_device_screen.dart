import 'package:flutter/material.dart';
import '../widgets/imei_input_field.dart';
import '../widgets/neo_container.dart';
import '../widgets/neo_stepper.dart';
import '../widgets/device_selection.dart';
import '../widgets/device_details_form.dart';
import '../widgets/seller_info_form.dart';
import '../helpers/keyboard_dismiss_wrapper.dart';
import '../widgets/glass_container.dart';
import '../widgets/neo_container.dart';

class PurchaseDeviceScreen extends StatefulWidget {
  const PurchaseDeviceScreen({super.key});

  @override
  State<PurchaseDeviceScreen> createState() => _PurchaseDeviceScreenState();
}

class _PurchaseDeviceScreenState extends State<PurchaseDeviceScreen> {
  final TextEditingController _imeiController = TextEditingController();
  int _currentStep = 0;
  final List<String> _steps = [
    'IMEI',
    'Device',
    'Details',
    'Seller',
    'Review',
    'Sign',
  ];

  void _handleCameraTap() {
    // TODO: Implement camera functionality
  }

  void _handleNextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
    }
  }

  void _handlePreviousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Enter Device IMEI';
      case 1:
        return 'Select Device';
      case 2:
        return 'Device Details';
      case 3:
        return 'Seller Information';
      case 4:
        return 'Review Details';
      case 5:
        return 'Sign Agreement';
      default:
        return '';
    }
  }

  String _getStepDescription() {
    switch (_currentStep) {
      case 0:
        return 'Please enter the IMEI or serial number';
      case 1:
        return 'Choose the device type, model, and specifications';
      case 2:
        return 'Enter additional device details and included items';
      case 3:
        return 'Enter the seller\'s contact information';
      case 4:
        return 'Review all entered information before proceeding';
      case 5:
        return 'Sign the bill of sale agreement';
      default:
        return '';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            ImeiInputField(
              controller: _imeiController,
            ),
          ],
        );
      case 1:
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32),
            DeviceSelectionForm(),
          ],
        );
      case 2:
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32),
            DeviceDetailsForm(),
          ],
        );
      case 3:
        return const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32),
            SellerInfoForm(),
          ],
        );
      case 4:
        return const Center(
          child: Text('Review page under construction'),
        );
      case 5:
        return const Center(
          child: Text('Signature page under construction'),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3436);
    final secondaryTextColor = isDark ? Colors.grey[400] : const Color(0xFF7A8C98);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: backgroundColor,
        title: Text(
          'Purchase Device',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: textColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: KeyboardDismissOnTap(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: NeoStepper(
                  currentStep: _currentStep,
                  steps: _steps,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: GlassContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getStepTitle(),
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _getStepDescription(),
                            style: TextStyle(
                              fontSize: 15,
                              color: secondaryTextColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                          _buildStepContent(),
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              if (_currentStep > 0)
                                GlassButton(
                                  width: 120,
                                  height: 45,
                                  onPressed: _handlePreviousStep,
                                  child: Text(
                                    'Previous',
                                    style: TextStyle(
                                      color: textColor,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                )
                              else
                                const SizedBox(width: 120),
                              GlassButton(
                                width: 120,
                                height: 45,
                                onPressed: _handleNextStep,
                                child: Text(
                                  _currentStep == _steps.length - 1 ? 'Finish' : 'Next',
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _imeiController.dispose();
    super.dispose();
  }
} 