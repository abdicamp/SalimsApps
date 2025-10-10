import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:salims_apps_new/core/utils/card_task.dart';
import 'package:salims_apps_new/core/utils/custom_text_field.dart';
import 'package:salims_apps_new/core/utils/rounded_clipper.dart';
import 'package:salims_apps_new/ui/views/task_list/task_list_viewmodel.dart';
import 'package:stacked/stacked.dart';

class TaskListView extends StatefulWidget {
  const TaskListView({super.key});

  @override
  State<TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<TaskListView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => TaskListViewmodel(context: context),
      builder: (context, vm, child) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            body: Column(
              children: [
                
                Expanded(
                  flex: 2,
                  child: Stack(
                    children: [
                      ClipPath(
                        clipper: BottomRoundedClipper(),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1565C0), // Biru navy
                                Color(0xFF42A5F5), // Biru terang
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              "List Task",
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 10,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextField(
                          readOnly: true,
                          controller: vm.tanggalCtrl,
                          onTap: () {
                            vm.pickDateRange();
                          },
                          decoration: InputDecoration(
                            hintText: "Date",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.date_range,
                              color: Colors.grey.shade600,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.blue.shade400,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        TextField(
                          onChanged: (value) {
                            setState(() {
                              // vm.onSearchTextChangedMyRequest(value);
                            });
                          },
                          decoration: InputDecoration(
                            hintText: "Search task...",
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.grey.shade600,
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 16,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                color: Colors.blue.shade400,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 15),
                        Column(
                          children: vm.listTask.map((e) {
                            return TaskItem(
                              listData: e,
                            );
                          }).toList(),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
