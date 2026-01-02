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

  /// Build bottom navigation bar dengan tombol Save dan Confirm
  Widget _buildBottomNavigationBar(DetailTaskViewmodel vm) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          height: 50,
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildSaveButton(vm),
              ),
              const SizedBox(width: 10),
              if (vm.isConfirm == true)
                Expanded(
                  flex: 2,
                  child: _buildConfirmButton(vm),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build Save button
  Widget _buildSaveButton(DetailTaskViewmodel vm) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      onPressed: () => vm.handleSave(),
      child: const Text(
        "Save",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Build Confirm button
  Widget _buildConfirmButton(DetailTaskViewmodel vm) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade800,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      onPressed: () => vm.confirm(),
      child: const Text(
        "Confirm",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
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
                          // Kotak peringatan jika data equipment atau parameter belum lengkap
                          vm.listTaskList?.tsnumber != ""
                              ? Builder(
                                  builder: (context) {
                                    // Cek kondisi untuk menampilkan peringatan
                                    bool showWarning = false;
                                    String warningMessage =
                                        "Data Equipment atau parameter belum lengkap";

                                    // Cek jika ada parameter wajib tapi belum semua diisi
                                    if (vm.listParameter.isNotEmpty &&
                                        (vm.allExistParameter == false ||
                                            vm.allExistParameter == null)) {
                                      showWarning = true;
                                    }

                                    // Cek jika equipment kosong
                                    if (vm.listTakingSampleCI.isEmpty) {
                                      showWarning = true;
                                    }

                                    // Jangan tampilkan peringatan jika history
                                    if (widget.isDetailhistory == true) {
                                      showWarning = false;
                                    }

                                    if (showWarning) {
                                      return Container(
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 4),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: Colors.red[50],
                                          border: Border.all(
                                              color: Colors.red, width: 1.0),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(
                                              Icons.warning_amber_rounded,
                                              color: Colors.red[700],
                                              size: 20,
                                            ),
                                            SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                warningMessage,
                                                style: TextStyle(
                                                  color: Colors.red[700],
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }
                                    return SizedBox.shrink();
                                  },
                                )
                              : Stack(),

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
                    : _buildBottomNavigationBar(vm),
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
