import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salims_apps_new/core/utils/app_localizations.dart';
import 'package:salims_apps_new/core/utils/card_task_container.dart';
import 'package:salims_apps_new/core/utils/card_task_info.dart';
import 'package:salims_apps_new/core/utils/card_task_parameter.dart';
import 'package:salims_apps_new/core/utils/rounded_clipper.dart';
import 'package:salims_apps_new/core/utils/style.dart';
import 'package:salims_apps_new/ui/views/detail_task/detail_task_viewmodel.dart';
import 'package:stacked/stacked.dart';

import '../../../core/models/task_list_models.dart';

class DetailTaskView extends StatefulWidget {
  bool? isDetailhistory;
  TestingOrder? listData;
  DetailTaskView({super.key, this.listData, this.isDetailhistory});

  @override
  State<DetailTaskView> createState() => _DetailTaskViewState();
}

class _DetailTaskViewState extends State<DetailTaskView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int selectedIndex = 0;

  List<String> getTabs(BuildContext context) {
    return [
      AppLocalizations.of(context)?.taskInfo ?? 'Task Info',
      AppLocalizations.of(context)?.containerInfo ?? 'Container Info',
      AppLocalizations.of(context)?.parameter ?? 'Parameter',
    ];
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => DetailTaskViewmodel(
          context: context,
          listTaskList: widget.listData,
          isDetailhistory: widget.isDetailhistory),
      builder: (context, vm, child) {
        // Debug logging

        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Stack(
            children: [
              Scaffold(
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
                                    Color(0xFF4CAF50), // hijau
                                    Color(0xFF2196F3),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  AppLocalizations.of(context)?.detailTask ??
                                      "Detail Task",
                                  style: GoogleFonts.lato(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 16, // posisi dari kiri
                            top: 5,
                            bottom: 0,
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Center(
                                child: SvgPicture.asset(
                                  "assets/icons/back.svg",
                                  color: Colors.white,
                                  width: 30,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 9,
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.symmetric(horizontal: 16),
                            padding: EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(getTabs(context).length,
                                  (index) {
                                bool isSelected = selectedIndex == index;
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () =>
                                        setState(() => selectedIndex = index),
                                    child: AnimatedContainer(
                                      duration: Duration(milliseconds: 250),
                                      padding: EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 6,
                                                  offset: Offset(0, 3),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Center(
                                        child: Text(
                                          getTabs(context)[index],
                                          style: TextStyle(
                                            color: isSelected
                                                ? Colors.black
                                                : Colors.grey,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ),
                          SizedBox(height: 10),
                          Expanded(
                            child: Builder(
                              builder: (context) {
                                return IndexedStack(
                                  index: selectedIndex,
                                  children: [
                                    CardTaskInfo(
                                      vm: vm,
                                      isDetailhistory: widget.isDetailhistory,
                                    ),
                                    CardTaskContainer(
                                      vm: vm,
                                      isDetailhistory: widget.isDetailhistory,
                                    ),
                                    CardTaskParameter(
                                      vm: vm,
                                      isDetailhistory: widget.isDetailhistory,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: widget.isDetailhistory == true
                    ? const SizedBox.shrink()
                    : SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(
                            16.0,
                          ), // kasih jarak dari tepi
                          child: SizedBox(
                            height: 50,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.blue.shade800, // warna elegan
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          12,
                                        ), // tombol rounded
                                      ),
                                      elevation: 4, // efek bayangan halus
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        bool valid1 = vm.formKey1.currentState!
                                            .validate();
                                        // bool valid3 = vm.formKey3.currentState!.validate();
                                        bool isEmptyListCI =
                                            vm.listTakingSampleCI.isEmpty;

                                        bool isEmptyListPar = vm
                                            .listTakingSampleParameter.isEmpty;

                                        bool isNotEmptyListCI =
                                            vm.equipmentlist.isNotEmpty;

                                        bool isNotEmptyListPar =
                                            vm.listParameter.isNotEmpty;

                                        if (valid1 &&
                                            isNotEmptyListCI &&
                                            isNotEmptyListPar) {
                                          if (vm.listTakingSampleCI
                                                  .isNotEmpty &&
                                              vm.listTakingSampleParameter
                                                  .isNotEmpty) {
                                            vm.postDataTakingSample();
                                          } else {
                                            if (vm.listTakingSampleCI.isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  duration:
                                                      Duration(seconds: 2),
                                                  content: Text(AppLocalizations
                                                              .of(context)
                                                          ?.formParameterEmpty ??
                                                      "Form Container Info is Empty"),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }

                                            if (vm.listTakingSampleParameter
                                                .isEmpty) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  duration:
                                                      Duration(seconds: 2),
                                                  content: Text(AppLocalizations
                                                              .of(context)
                                                          ?.formParameterEmpty ??
                                                      "Form Parameter is Empty"),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            }
                                          }
                                        } else {
                                          if (!valid1) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                duration: Duration(seconds: 2),
                                                content: Text(AppLocalizations
                                                            .of(context)
                                                        ?.formTaskInfoEmpty ??
                                                    "Form Task Info is Empty"),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          }

                                          // if (vm.imageFiles.isEmpty &&
                                          //     vm.imageFilesVerify.isEmpty) {
                                          //   ScaffoldMessenger.of(context)
                                          //       .showSnackBar(
                                          //     SnackBar(
                                          //       duration: Duration(seconds: 2),
                                          //       content: Text(AppLocalizations
                                          //                   .of(context)
                                          //               ?.formTaskInfoEmpty ??
                                          //           "Gambar minimal harus"),
                                          //       backgroundColor: Colors.red,
                                          //     ),
                                          //   );
                                          // }

                                          if (vm.equipmentlist.isNotEmpty &&
                                              vm.listParameter.isNotEmpty) {
                                            if (vm.listTakingSampleCI
                                                    .isNotEmpty &&
                                                vm.listTakingSampleParameter
                                                    .isNotEmpty) {
                                              vm.postDataTakingSample();
                                            } else {
                                              if (vm
                                                  .listTakingSampleCI.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    duration:
                                                        Duration(seconds: 2),
                                                    content: Text(AppLocalizations
                                                                .of(context)
                                                            ?.formTaskInfoEmpty ??
                                                        "Form Container Info is Empty"),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                              if (vm.listTakingSampleParameter
                                                  .isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    duration:
                                                        Duration(seconds: 2),
                                                    content: Text(AppLocalizations
                                                                .of(context)
                                                            ?.formTaskInfoEmpty ??
                                                        "Form Parameter is Empty"),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          } else {
                                            if (vm.equipmentlist.isNotEmpty) {
                                              if (vm
                                                  .listTakingSampleCI.isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    duration:
                                                        Duration(seconds: 2),
                                                    content: Text(AppLocalizations
                                                                .of(context)
                                                            ?.formTaskInfoEmpty ??
                                                        "Form Container Info is Empty"),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              } else {
                                                vm.postDataTakingSample();
                                              }
                                            }

                                            if (vm.listParameter.isNotEmpty) {
                                              if (vm.listTakingSampleParameter
                                                  .isEmpty) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    duration:
                                                        Duration(seconds: 2),
                                                    content: Text(AppLocalizations
                                                                .of(context)
                                                            ?.formTaskInfoEmpty ??
                                                        "Form Parameter is Empty"),
                                                    backgroundColor: Colors.red,
                                                  ),
                                                );
                                              }
                                            }
                                          }
                                        }
                                      });
                                    },
                                    child: const Text(
                                      "Save",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white, // teks kontras
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 10,
                                ),
                                vm.isConfirm!
                                    ? Expanded(
                                        flex: 2,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors
                                                .green.shade800, // warna elegan
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                12,
                                              ), // tombol rounded
                                            ),
                                            elevation: 4, // efek bayangan halus
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              vm.confirm();
                                            });
                                          },
                                          child: const Text(
                                            "Confirm",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  Colors.white, // teks kontras
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink()
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
              vm.isBusy
                  ? const Stack(
                      children: [
                        ModalBarrier(
                          dismissible: false,
                          color: const Color.fromARGB(118, 0, 0, 0),
                        ),
                        Center(child: loadingSpinWhite),
                      ],
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        );
      },
    );
  }
}
