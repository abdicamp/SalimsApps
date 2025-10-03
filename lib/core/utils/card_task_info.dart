import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salims_apps_new/core/utils/custom_text_field.dart';
import 'package:salims_apps_new/core/utils/search_dropdown.dart';
import 'package:salims_apps_new/ui/views/detail_task/detail_task_viewmodel.dart';

class CardTaskInfo extends StatefulWidget {
  DetailTaskViewmodel? vm;
  CardTaskInfo({super.key, this.vm});

  @override
  State<CardTaskInfo> createState() => _CardTaskInfoState();
}

class _CardTaskInfoState extends State<CardTaskInfo> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: SingleChildScrollView(
        child: Form(
          key: widget.vm!.formKey1,
          child: Column(
            children: [
              Stack(
                children: [
                  Card(
                    color: Color(0xFF42A5F5),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: 110,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Sample Loc",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 5),
                            Padding(
                              padding: const EdgeInsets.all(4),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  border: Border.all(
                                    color: Colors.black, // Warna garis border
                                    width: 0.5, // Ketebalan garis border
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    15,
                                  ), // Sudut melengkung (opsional)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CustomSearchableDropDown(
                                    isReadOnly: false,
                                    items: widget.vm!.sampleLocationList!,
                                    label: 'Search Sample Loc',
                                    padding: EdgeInsets.zero,
                                    // searchBarHeight: SDP.sdp(40),
                                    hint: 'Search Sample Loc',
                                    // initialIndex: index,
                                    dropdownHintText: 'Cari Search Sample Loc',
                                    dropdownItemStyle: GoogleFonts.getFont(
                                      "Lato",
                                    ),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          widget.vm?.sampleLocationSelect =
                                              value;
                                        });
                                      }
                                    },
                                    dropDownMenuItems:
                                        widget.vm!.sampleLocationList!.map((e) {
                                          return '${e.locationname}';
                                        }).toList() ??
                                        [],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            CustomTextField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                              controller: widget.vm!.weatherController!,
                              label: 'Weather',
                            ),
                            SizedBox(height: 5),
                            CustomTextField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                              controller: widget.vm!.windDIrectionController!,
                              label: 'Wind Direction',
                            ),
                            SizedBox(height: 5),
                            CustomTextField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                              controller: widget.vm!.temperaturController!,
                              label: 'Temperatur',
                            ),
                            SizedBox(height: 5),
                            CustomTextField(
                              maxLines: 4,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                              controller: widget.vm!.descriptionController!,
                              label: 'Description',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
