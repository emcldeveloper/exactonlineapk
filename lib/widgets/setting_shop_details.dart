// ignore_for_file: sized_box_for_whitespace

import 'package:e_online/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:e_online/widgets/custom_button.dart';
import 'package:e_online/widgets/paragraph_text.dart';
import 'package:e_online/widgets/spacer.dart';
import 'package:get/get_rx/get_rx.dart';

class SettingShopDetails extends StatefulWidget {
  final Function(TimeOfDay? openTime, TimeOfDay? closeTime, bool is24Hours,
      bool isClosed, bool applyToAll,List<String> selectedDays) onSave;

  const SettingShopDetails({super.key, required this.onSave});

  @override
  State<SettingShopDetails> createState() =>
      _SettingShopDetailsBottomSheetState();
}

class _SettingShopDetailsBottomSheetState extends State<SettingShopDetails> {
  bool is24Hours = false;
  bool isClosed = false;
  bool applyToAll = false; // New state for applying to all days
  TimeOfDay? openTime;
  TimeOfDay? closeTime;
  List<String> selectedDays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday'
  ];
  Future<TimeOfDay?> _selectTime(
      BuildContext context, TimeOfDay initialTime) async {
    if (!mounted) return null;
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
          Row(
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    child: Checkbox(
                      value: is24Hours,
                      activeColor: primary,
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
                  SizedBox(width: 10),
                  const Text("Open 24 hours")
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: isClosed,
                    activeColor: primary,
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
          spacer(),
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
                const SizedBox(
                  width: 10,
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
          spacer(),
          Row(
            children: [
              Container(
                width: 20,
                child: Checkbox(
                  value: applyToAll,
                  activeColor: primary,
                  onChanged: (value) {
                    setState(() {
                      applyToAll = value ?? false;
                    });
                  },
                ),
              ),
              SizedBox(width: 10),
              const Text("Apply to all days"),
            ],
          ),
          spacer(),
          if (applyToAll)
            Column(
              children: [
                'Monday',
                'Tuesday',
                'Wednesday',
                'Thursday',
                'Friday',
                'Saturday',
                'Sunday'
              ]
                  .map((item) => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ParagraphText(item),
                          Switch(
                              activeTrackColor: primary,
                              value: selectedDays.contains(item),
                              onChanged: (value) {
                                if (value == false) {
                                  setState(() {
                                    selectedDays.remove(item);
                                  });
                                } else {
                                  setState(() {
                                    selectedDays.add(item);
                                  });
                                }
                              })
                        ],
                      ))
                  .toList(),
            ),
          spacer2(),
          customButton(
            onTap: () {
              try {
                widget.onSave(
                    openTime, closeTime, is24Hours, isClosed, applyToAll,selectedDays);
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
    return Expanded(
      child: Column(
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
      ),
    );
  }
}
