import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:flutter/material.dart';

class SettingShopDetails extends StatefulWidget {
  final Function(TimeOfDay? openTime, TimeOfDay? closeTime, bool is24Hours,
      bool isClosed) onSave;

  const SettingShopDetails({super.key, required this.onSave});

  @override
  State<SettingShopDetails> createState() =>
      _SettingShopDetailsBottomSheetState();
}

class _SettingShopDetailsBottomSheetState extends State<SettingShopDetails> {
  bool is24Hours = false;
  bool isClosed = false;
  TimeOfDay? openTime;
  TimeOfDay? closeTime;

  Future<TimeOfDay?> _selectTime(
      BuildContext context, TimeOfDay initialTime) async {
    if (!mounted) return null; // Prevent crashes if context is not mounted
    try {
      return await showTimePicker(
        context: context,
        initialTime: initialTime,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child!,
          );
        },
      );
    } catch (e) {
      debugPrint("Time Picker Error: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          spacer(),
          ParagraphText("Set Time",
              fontWeight: FontWeight.bold, fontSize: 16.0),
          spacer1(),

          // Checkboxes
          Row(
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    child: Checkbox(
                      value: is24Hours,
                      onChanged: (value) {
                        setState(() {
                          is24Hours = value ?? false;
                          if (is24Hours) {
                            isClosed = false;
                            openTime = null;
                            closeTime = null;
                          }
                        });
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  const Text("Open 24 hours")
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: isClosed,
                    onChanged: (value) {
                      setState(() {
                        isClosed = value ?? false;
                        if (isClosed) {
                          is24Hours = false;
                          openTime = null;
                          closeTime = null;
                        }
                      });
                    },
                  ),
                  const Text("Closed")
                ],
              )
            ],
          ),
          spacer1(),

          // Time Pickers
          if (!is24Hours && !isClosed) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimePicker(
                  label: "Open Time",
                  selectedTime: openTime,
                  onTap: () async {
                    final time =
                        await _selectTime(context, openTime ?? TimeOfDay.now());
                    if (time != null) {
                      setState(() => openTime = time);
                    }
                  },
                ),
                _buildTimePicker(
                  label: "Close Time",
                  selectedTime: closeTime,
                  onTap: () async {
                    final time = await _selectTime(
                        context, closeTime ?? TimeOfDay.now());
                    if (time != null) {
                      setState(() => closeTime = time);
                    }
                  },
                ),
              ],
            ),
          ],
          spacer2(),
          // Save Button
          customButton(
            onTap: () {
              try {
                widget.onSave(openTime, closeTime, is24Hours, isClosed);
              } catch (e) {
                debugPrint("Error during onSave: $e");
              }
              if (mounted) Navigator.pop(context);
            },
            text: "Save Changes",
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker({
    required String label,
    required TimeOfDay? selectedTime,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ParagraphText(label, fontWeight: FontWeight.bold),
        InkWell(
          onTap: onTap,
          child: Container(
            width: 180,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              selectedTime != null
                  ? selectedTime.format(context)
                  : "Select Time",
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ],
    );
  }
}
