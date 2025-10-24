import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salims_apps_new/core/utils/card_task_container.dart';
import 'package:salims_apps_new/core/utils/card_task_info.dart';
import 'package:salims_apps_new/core/utils/card_task_parameter.dart';
import 'package:salims_apps_new/core/utils/rounded_clipper.dart';
import 'package:salims_apps_new/core/utils/style.dart';
import 'package:salims_apps_new/ui/views/detail_task/detail_task_viewmodel.dart';
import 'package:stacked/stacked.dart';

import '../../../core/models/task_list_models.dart';

class DetailTaskView extends StatefulWidget {
  TestingOrder? listData;
  DetailTaskView({super.key, this.listData});

  @override
  State<DetailTaskView> createState() => _DetailTaskViewState();
}

class _DetailTaskViewState extends State<DetailTaskView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  int selectedIndex = 0;

  final List<String> tabs = ['Task Info', 'Container Info', 'Parameter'];

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
      viewModelBuilder: () =>
          DetailTaskViewmodel(context: context, listTaskList: widget.listData),
      builder: (context, vm, child) {
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
                                    Color(0xFF1565C0), // Biru navy
                                    Color(0xFF42A5F5), // Biru terang
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Center(
                                child: Text(
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
                              children: List.generate(tabs.length, (index) {
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
                                          tabs[index],
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
                            child: IndexedStack(
                              index: selectedIndex,
                              children: [
                                CardTaskInfo(vm: vm),
                                CardTaskContainer(vm: vm),
                                CardTaskParameter(vm: vm),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                bottomNavigationBar: SafeArea(
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
                                  bool valid1 =
                                      vm.formKey1.currentState!.validate();
                                  // bool valid3 = vm.formKey3.currentState!.validate();
                                  bool isEmptyListCI =
                                      vm.listTakingSampleCI.isEmpty;
                                  bool isEmptyListPar =
                                      vm.listTakingSampleParameter.isEmpty;
                                  if (valid1 &&
                                      !isEmptyListCI &&
                                      !isEmptyListPar) {
                                    print("Semua form terisi ✅");
                                    vm.postDataTakingSample();
                                  } else {
                                    if (!valid1) {
                                      ScaffoldMessenger.of(context!)
                                          .showSnackBar(
                                        SnackBar(
                                          duration: Duration(seconds: 2),
                                          content:
                                              Text("Form Task Info Kosong"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                    // if (!valid3) {
                                    //   ScaffoldMessenger.of(context!).showSnackBar(
                                    //     SnackBar(
                                    //       duration: Duration(seconds: 2),
                                    //       content: Text("Form Parameter Kosong"),
                                    //       backgroundColor: Colors.red,
                                    //     ),
                                    //   );
                                    // }
                                    if (isEmptyListCI) {
                                      ScaffoldMessenger.of(context!)
                                          .showSnackBar(
                                        SnackBar(
                                          duration: Duration(seconds: 2),
                                          content: Text(
                                              "Form Container Info Kosong"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                    if (isEmptyListPar) {
                                      ScaffoldMessenger.of(context!)
                                          .showSnackBar(
                                        SnackBar(
                                          duration: Duration(seconds: 2),
                                          content:
                                              Text("Form Parameter Kosong"),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                    // if(vm.imageString.isEmpty){
                                    //   ScaffoldMessenger.of(context!).showSnackBar(
                                    //     SnackBar(
                                    //       duration: Duration(seconds: 2),
                                    //       content: Text("Gambar tidak boleh Kosong"),
                                    //       backgroundColor: Colors.red,
                                    //     ),
                                    //   );
                                    //
                                    // }
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
                                      backgroundColor:
                                          Colors.green.shade800, // warna elegan
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
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
                                        color: Colors.white, // teks kontras
                                      ),
                                    ),
                                  ),
                                )
                              : Stack()
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
                  : const Stack(),
            ],
          ),
        );
      },
    );
  }
}
