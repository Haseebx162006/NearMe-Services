import 'package:flutter/material.dart';
import '../Components/custom_textfield.dart';
import '../Components/custom_button.dart';

class CreateGigScreen extends StatelessWidget {
  const CreateGigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3E2723)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Create New Gig',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E2723),
          ),
        ),
      ),
      body: Column(
        children: [
          // Step Progress Indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                _buildStepHeader('Basic Info', true),
                _buildStepHeader('Pricing', false),
                _buildStepHeader('Details', false),
                _buildStepHeader('Review', false),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CustomTextField(
                    label: 'Gig Title',
                    hintText: 'e.g., Professional House Cleaning',
                    prefixIcon: Icons.title,
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Category',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        hint: const Text(
                          'Select category',
                          style: TextStyle(fontFamily: 'Poppins', fontSize: 14),
                        ),
                        items: const [],
                        onChanged: (value) {},
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Upload Images',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF3E2723),
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Dashed Upload Placeholder
                  Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9F6F2),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: Colors.grey.withOpacity(0.3),
                        style: BorderStyle.solid, // Note: For real dashed use a package/painter, simplified here
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.upload_outlined, size: 40, color: Color(0xFF8D6E63)),
                        const SizedBox(height: 12),
                        const Text(
                          'Click to upload or drag and drop',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Color(0xFF8D6E63),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'PNG, JPG up to 5MB',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Continue Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: CustomPrimaryButton(
              label: 'Continue',
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepHeader(String title, bool isActive) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 4,
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFFC7A76D) : const Color(0xFFF3E5D8),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? const Color(0xFF3E2723) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
