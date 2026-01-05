import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salims_apps_new/core/utils/app_localizations.dart';
import 'package:salims_apps_new/state_global/state_global.dart';
import 'package:salims_apps_new/ui/views/home/home_viewmodel.dart';
import 'package:badges/badges.dart' as badges;
import 'package:salims_apps_new/ui/views/notification_history/notification_history_view.dart';
import 'package:stacked/stacked.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/colors.dart';
import '../detail_task/detail_task_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with WidgetsBindingObserver {
  bool _lastBusyState = false;
  HomeViewmodel? _viewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Refresh notification count when app comes to foreground
      _viewModel?.checkNewNotifications();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => HomeViewmodel(context: context),
      onViewModelReady: (vm) {
        _viewModel = vm;
      },
      builder: (context, vm, child) {
        // Only update loading state if it changed to avoid unnecessary callbacks
        if (_lastBusyState != vm.isBusy) {
          _lastBusyState = vm.isBusy;
          // Use WidgetsBinding to update loading state after build phase
          // This prevents calling setState/notifyListeners during build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final loadingState = context.read<GlobalLoadingState>();
              if (vm.isBusy) {
                loadingState.show();
              } else {
                loadingState.hide();
              }
            }
          });
        }
        return Stack(
          children: [
            GestureDetector(
              onTap: () {
                FocusScope.of(context).unfocus();
              },
              child: Scaffold(
                backgroundColor: Colors.white,
                body: RefreshIndicator(
                  onRefresh: () async {
                    await vm.runAllFunction();
                  },
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 15),
                                  Padding(
                                    padding: const EdgeInsets.all(15),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)
                                                      ?.hello ??
                                                  "Hello!",
                                              style: GoogleFonts.poppins(
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                // Notifikasi dengan gradient background
                                                InkWell(
                                                  onTap: () async {
                                                    // Mark notifications as read when tapped
                                                    await vm
                                                        .markNotificationsAsRead();
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            NotificationHistoryView(),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          AppColors.skyBlue,
                                                          AppColors.limeLight,
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      ),
                                                    ),
                                                    child: badges.Badge(
                                                      showBadge:
                                                          vm.newNotificationCount >
                                                              0,
                                                      badgeContent: Text(
                                                        vm.newNotificationCount >
                                                                99
                                                            ? '99+'
                                                            : '${vm.newNotificationCount}',
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 12,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                      badgeStyle: const badges
                                                          .BadgeStyle(
                                                        badgeColor: Colors.red,
                                                        padding:
                                                            EdgeInsets.all(5),
                                                      ),
                                                      child: const Icon(
                                                        Icons
                                                            .notifications_outlined,
                                                        color: Colors.white,
                                                        size: 26,
                                                      ),
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(width: 14),

                                                // Logout dengan gradient background yang sama
                                                InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(50),
                                                  onTap: () => vm.logout(),
                                                  child: Container(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    decoration:
                                                        const BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      gradient: LinearGradient(
                                                        colors: [
                                                          AppColors.skyBlue,
                                                          AppColors.limeLight,
                                                        ],
                                                        begin:
                                                            Alignment.topLeft,
                                                        end: Alignment
                                                            .bottomRight,
                                                      ),
                                                    ),
                                                    child: const Icon(
                                                      Icons.logout,
                                                      color: Colors.white,
                                                      size: 26,
                                                    ),
                                                  ),
                                                ),

                                                const SizedBox(width: 12),
                                              ],
                                            )
                                          ],
                                        ),
                                        Text(
                                          "${vm.username}",
                                          style: GoogleFonts.poppins(
                                            fontSize: 25,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // ====== Card berlapis + gradient ======
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Stack(
                                      children: [
                                        // Lapisan 1
                                        Card(
                                          color: const Color(
                                              0xFF004D40), // hijau tua cenderung biru
                                          child: SizedBox(
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            height: 50,
                                          ),
                                        ),

                                        // Lapisan 2
                                        const Padding(
                                          padding: EdgeInsets.only(top: 4),
                                          child: Card(
                                            color: Color(
                                                0xFF00695C), // hijau teal lebih muda
                                            child: SizedBox(
                                              width: double.infinity,
                                              height: 50,
                                            ),
                                          ),
                                        ),

                                        // Lapisan 3
                                        const Padding(
                                          padding: EdgeInsets.only(top: 8),
                                          child: Card(
                                            color: Color(
                                                0xFF00796B), // hijau kebiruan
                                            child: SizedBox(
                                              width: double.infinity,
                                              height: 50,
                                            ),
                                          ),
                                        ),

                                        // Lapisan 4
                                        const Padding(
                                          padding: EdgeInsets.only(top: 12),
                                          child: Card(
                                            color: Color(
                                                0xFF26A69A), // hijau teal terang
                                            child: SizedBox(
                                              width: double.infinity,
                                              height: 50,
                                            ),
                                          ),
                                        ),

                                        // Lapisan 5 (utama dengan gradient dan isi)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 16),
                                          child: Card(
                                            elevation: 8,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Container(
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              decoration: BoxDecoration(
                                                gradient: const LinearGradient(
                                                  colors: [
                                                    AppColors.skyBlue,
                                                    AppColors.limeLight,
                                                  ],
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              padding: const EdgeInsets.all(16),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  // Judul card
                                                  Text(
                                                    AppLocalizations.of(context)
                                                            ?.nearestAssignmentLocation ??
                                                        "Nearest Assignment Location",
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Colors
                                                          .white, // teks hijau tua
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),

                                                  // Radius
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.gps_fixed,
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                      const SizedBox(width: 7),
                                                      Text(
                                                        "${vm.radius} m",
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 10),

                                                  // Nama subzona
                                                  Row(
                                                    children: [
                                                      const Icon(
                                                        Icons.location_on,
                                                        color: Colors.white,
                                                        size: 15,
                                                      ),
                                                      const SizedBox(width: 7),
                                                      Text(
                                                        "${vm.dataNearestLocation?.subzonaname ?? ''}",
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const SizedBox(height: 5),

                                                  // Alamat
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 22),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            2,
                                                        child: const Text(
                                                          // kalau mau, bisa ganti jadi non-const biar pakai vm langsung
                                                          // tapi di sini ikut pattern kamu:
                                                          "",
                                                          style: TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  // Address as dynamic text (dikeluarkan dari const biar pakai vm)
                                                  Row(
                                                    children: [
                                                      const SizedBox(width: 22),
                                                      SizedBox(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width /
                                                            2.2,
                                                        child: Text(
                                                          "${vm.dataNearestLocation?.address ?? ''}",
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 10,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),

                                                  const SizedBox(height: 20),

                                                  // Tombol Check Location
                                                  InkWell(
                                                    onTap: () {
                                                      if (vm.listTask
                                                          .isNotEmpty && vm.lat != null && vm.lng != null) {
                                                        vm.openMap(
                                                            vm.lat, vm.lng);
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.05),
                                                            blurRadius: 2,
                                                            offset:
                                                                const Offset(
                                                                    0, 1),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            AppLocalizations.of(
                                                                        context)
                                                                    ?.checkLocation ??
                                                                "Check Location",
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.9),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Icon(
                                                            Icons.chevron_right,
                                                            size: 13,
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.6),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(height: 10),

                                                  // Tombol To Do Task
                                                  InkWell(
                                                    onTap: () {
                                                      if (vm.listTask
                                                          .isNotEmpty) {
                                                        Navigator.of(context)
                                                            .push(
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                DetailTaskView(
                                                              listData: vm
                                                                  .dataNearestLocation,
                                                              isDetailhistory:
                                                                  false,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                        horizontal: 10,
                                                        vertical: 4,
                                                      ),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white
                                                            .withOpacity(0.2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: Colors.black
                                                                .withOpacity(
                                                                    0.05),
                                                            blurRadius: 2,
                                                            offset:
                                                                const Offset(
                                                                    0, 1),
                                                          ),
                                                        ],
                                                      ),
                                                      child: Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Text(
                                                            AppLocalizations.of(
                                                                        context)
                                                                    ?.toDoTask ??
                                                                "To do task",
                                                            style: GoogleFonts
                                                                .poppins(
                                                              fontSize: 11,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              color: Colors
                                                                  .white
                                                                  .withOpacity(
                                                                      0.9),
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Icon(
                                                            Icons.chevron_right,
                                                            size: 13,
                                                            color: Colors.white
                                                                .withOpacity(
                                                                    0.6),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              // Gambar di pojok kanan bawah
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Image.asset(
                                  "assets/images/logo.png",
                                  width: 180,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),

                          // Filter Date Section
                          TextField(
                            readOnly: true,
                            controller: vm.dateFilterController,
                            onTap: () {
                              vm.pickDateRange();
                            },
                            decoration: InputDecoration(
                              hintText:
                                  AppLocalizations.of(context)?.date ?? "Date",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.date_range,
                                color: Colors.grey.shade600,
                                size: 20,
                              ),
                              suffixIcon:
                                  vm.dateFilterController?.text.isNotEmpty ??
                                          false
                                      ? IconButton(
                                          onPressed: () {
                                            vm.resetDateFilter();
                                          },
                                          icon: Icon(
                                            Icons.clear,
                                            color: Colors.grey.shade600,
                                            size: 20,
                                          ),
                                        )
                                      : null,
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
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Stack(
                            children: [
                              Card(
                                color: Color(0xFF1565C0),
                                child: SizedBox(
                                  height: 30,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Card(
                                  color: Colors.white,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 20,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.blue.withOpacity(
                                                  0.2,
                                                ), // soft bg
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  12,
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(12),
                                              child: Image.asset(
                                                "assets/images/tube.png",
                                                width: 28,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)
                                                          ?.outstanding ??
                                                      "Outstanding",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 55,
                                                  height: 55,
                                                  child:
                                                      CircularProgressIndicator(
                                                    value: double.parse(vm
                                                            .totalListTask
                                                            .toString()) /
                                                        100,
                                                    strokeWidth: 6,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                            Color>(Colors.blue),
                                                    backgroundColor:
                                                        Colors.grey[200]!,
                                                  ),
                                                ),
                                                Text(
                                                  "${vm.totalListTask}",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              AppLocalizations.of(context)
                                                      ?.percentCompleted ??
                                                  "% Completed",
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ===== Science =====
                          Stack(
                            children: [
                              Card(
                                color: Colors.green,
                                child: SizedBox(
                                  height: 30,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Card(
                                  color: Colors.white,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 20,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.green.withOpacity(
                                                  0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  12,
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(12),
                                              child: Image.asset(
                                                "assets/images/tube.png",
                                                width: 28,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)
                                                          ?.finish ??
                                                      "Finish",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 55,
                                                  height: 55,
                                                  child:
                                                      CircularProgressIndicator(
                                                    value:
                                                        vm.totalListTaskHistory /
                                                            100,
                                                    strokeWidth: 6,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.green),
                                                    backgroundColor:
                                                        Colors.grey[200]!,
                                                  ),
                                                ),
                                                Text(
                                                  "${vm.totalListTaskHistory}",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              AppLocalizations.of(context)
                                                      ?.percentCompleted ??
                                                  "% Completed",
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // ===== Chemistry =====
                          Stack(
                            children: [
                              Card(
                                color: Colors.purpleAccent,
                                child: SizedBox(
                                  height: 30,
                                  width: MediaQuery.of(context).size.width,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Card(
                                  color: Colors.white,
                                  elevation: 4,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 16,
                                      horizontal: 20,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                color:
                                                    Colors.purple.withOpacity(
                                                  0.2,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                  12,
                                                ),
                                              ),
                                              padding: const EdgeInsets.all(12),
                                              child: Image.asset(
                                                "assets/images/tube.png",
                                                width: 28,
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  AppLocalizations.of(context)
                                                          ?.performa ??
                                                      "Performa",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Stack(
                                              alignment: Alignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 55,
                                                  height: 55,
                                                  child:
                                                      CircularProgressIndicator(
                                                    // v boleh null; kalau null/NaN/Infinity → pakai spinner indeterminate
                                                    value: (() {
                                                      final v = vm
                                                          .totalPerforma; // double?
                                                      if (v == null ||
                                                          v.isNaN ||
                                                          v.isInfinite)
                                                        return null;

                                                      // Kalau kamu simpan sebagai persen (0–100), ubah ke 0–1
                                                      final normalized = v > 1.0
                                                          ? v / 100.0
                                                          : v;

                                                      // Pastikan tetap 0–1
                                                      return normalized.clamp(
                                                          0.0, 1.0);
                                                    })(),
                                                    strokeWidth: 6,
                                                    valueColor:
                                                        const AlwaysStoppedAnimation<
                                                                Color>(
                                                            Colors.purple),
                                                    backgroundColor:
                                                        Colors.grey[200]!,
                                                  ),
                                                ),
                                                Text(
                                                  "${vm.totalPerforma?.toStringAsFixed(2) ?? '0.00'}",
                                                  style: GoogleFonts.poppins(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              AppLocalizations.of(context)
                                                      ?.percentCompleted ??
                                                  "% Completed",
                                              style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                          ],
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
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
