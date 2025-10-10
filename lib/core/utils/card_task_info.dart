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
