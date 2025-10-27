import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salims_apps_new/state_global/state_global.dart';
import 'package:salims_apps_new/ui/views/home/home_viewmodel.dart';
import 'package:badges/badges.dart' as badges;
import 'package:stacked/stacked.dart';
import 'package:provider/provider.dart';

import '../detail_task/detail_task_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder.reactive(
      viewModelBuilder: () => HomeViewmodel(context: context),
      builder: (context, vm, child) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          vm.isBusy
              ? context.read<GlobalLoadingState>().show()
              : context.read<GlobalLoadingState>().hide();
        });
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset("assets/images/salims.png", width: 120),
                    Row(
                      children: [
                        badges.Badge(
                          showBadge: 1 > 0,
                          badgeContent: Text(
                            '1',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          badgeStyle: const badges.BadgeStyle(
                            badgeColor: Colors.red,
                          ),
                          child: const Icon(
                            Icons.notifications,
                            color: Colors.black, // warna icon notifikasi
                            size: 28, // opsional: atur ukuran
                          ),
                        ),
                        SizedBox(width: 20),
                        IconButton(
                          onPressed: () {
                            vm.logout();
                          },
                          icon: Icon(Icons.logout, color: Colors.black),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                  ],
                ),
              ),
              backgroundColor: Colors.white,
              body: RefreshIndicator(

                onRefresh: () async {
                  await vm.runAllFunction();
                },
                child: SingleChildScrollView(
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
                                Padding(
                                  padding: const EdgeInsets.all(15),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Hello!",
                                        style: GoogleFonts.poppins(
                                          fontSize: 30,
                                          fontWeight: FontWeight.bold,
                                        ),
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

                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Stack(
                                    children: [
                                      // Lapisan 1
                                      Card(
                                        color: const Color(
                                          0xFF0D47A1,
                                        ), // Biru tua
                                        child: SizedBox(
                                          width: MediaQuery.of(
                                            context,
                                          ).size.width,
                                          height: 50,
                                        ),
                                      ),

                                      // Lapisan 2
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Card(
                                          color: const Color(
                                            0xFF1565C0,
                                          ), // Biru navy
                                          child: SizedBox(
                                            width: MediaQuery.of(
                                              context,
                                            ).size.width,
                                            height: 50,
                                          ),
                                        ),
                                      ),

                                      // Lapisan 3
                                      Padding(
                                        padding: const EdgeInsets.only(top: 8),
                                        child: Card(
                                          color: const Color(
                                            0xFF1976D2,
                                          ), // Biru medium
                                          child: SizedBox(
                                            width: MediaQuery.of(
                                              context,
                                            ).size.width,
                                            height: 50,
                                          ),
                                        ),
                                      ),

                                      // Lapisan 4
                                      Padding(
                                        padding: const EdgeInsets.only(top: 12),
                                        child: Card(
                                          color: const Color(
                                            0xFF42A5F5,
                                          ), // Biru terang
                                          child: SizedBox(
                                            width: MediaQuery.of(
                                              context,
                                            ).size.width,
                                            height: 50,
                                          ),
                                        ),
                                      ),

                                      // Lapisan 5 (utama dengan gradient dan isi)
                                      Padding(
                                        padding:  EdgeInsets.only(top: 16),
                                        child: Card(
                                          elevation: 8,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Container(
                                            width: MediaQuery.of(
                                              context,
                                            ).size.width,
                                            decoration: BoxDecoration(
                                              gradient:  LinearGradient(
                                                colors: [
                                                  Color(0xFF1565C0), // Biru navy
                                                  Color(
                                                    0xFF42A5F5,
                                                  ), // Biru terang
                                                ],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                12,
                                              ),
                                            ),
                                            padding:  EdgeInsets.all(16),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  "Nearest Assigment Location",
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),

                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .gps_fixed,
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
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .location_on,
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
                                                Row(
                                                  children: [

                                                    const SizedBox(width: 22),
                                                    SizedBox(
                                                      width: MediaQuery.of(context).size.width / 2,
                                                      child: Text(
                                                        "${vm.dataNearestLocation?.address ?? ''}",
                                                        style: const TextStyle(
                                                          fontSize: 10,
                                                          color: Colors.white,

                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 20),
                                                InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      vm.openMap(vm.lat, vm.lng);
                                                    });
                                                    // Navigator.of(context).push(
                                                    //   MaterialPageRoute(
                                                    //     builder: (context) => DetailTaskView(
                                                    //       listData: vm.dataNearestLocation,
                                                    //     ),
                                                    //   ),
                                                    // );
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // 🔹 lebih kecil dari sebelumnya
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.2), // 🔹 transparan lembut
                                                      borderRadius: BorderRadius.circular(10), // sedikit lebih kecil radius
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.05), // bayangan sangat halus
                                                          blurRadius: 2,
                                                          offset: const Offset(0, 1),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          "Check Location",
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 11, // 🔹 lebih kecil agar proporsional
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.white.withOpacity(0.9), // teks tetap jelas
                                                          ),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Icon(
                                                          Icons.chevron_right,
                                                          size: 13, // 🔹 sedikit lebih kecil
                                                          color: Colors.white.withOpacity(0.6), // 🔹 putih transparan
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 10),
                                                InkWell(
                                                  onTap: () {

                                                    Navigator.of(context).push(
                                                      MaterialPageRoute(
                                                        builder: (context) => DetailTaskView(
                                                          listData: vm.dataNearestLocation,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // 🔹 lebih kecil dari sebelumnya
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.2), // 🔹 transparan lembut
                                                      borderRadius: BorderRadius.circular(10), // sedikit lebih kecil radius
                                                      boxShadow: [
                                                        BoxShadow(
                                                          color: Colors.black.withOpacity(0.05), // bayangan sangat halus
                                                          blurRadius: 2,
                                                          offset: const Offset(0, 1),
                                                        ),
                                                      ],
                                                    ),
                                                    child: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          "To do task",
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 11, // 🔹 lebih kecil agar proporsional
                                                            fontWeight: FontWeight.w600,
                                                            color: Colors.white.withOpacity(0.9), // teks tetap jelas
                                                          ),
                                                        ),
                                                        const SizedBox(width: 4),
                                                        Icon(
                                                          Icons.chevron_right,
                                                          size: 13, // 🔹 sedikit lebih kecil
                                                          color: Colors.white.withOpacity(0.6), // 🔹 putih transparan
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
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Image.asset(
                                "assets/images/micro.png",
                                width: 200,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
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
                                              borderRadius: BorderRadius.circular(
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
                                                child: CircularProgressIndicator(
                                                  value: double.parse(vm.totalListTask.toString()) / 100,
                                                  strokeWidth: 6,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.blue),
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
                                              borderRadius: BorderRadius.circular(
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
                                                child: CircularProgressIndicator(
                                                  value: vm.totalListTaskHistory / 100,
                                                  strokeWidth: 6,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.green),
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
                                              color: Colors.purple.withOpacity(
                                                0.2,
                                              ),
                                              borderRadius: BorderRadius.circular(
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
                                                child: CircularProgressIndicator(
                                                  value: vm.totalPerforma,
                                                  strokeWidth: 6,
                                                  valueColor:
                                                      AlwaysStoppedAnimation<
                                                        Color
                                                      >(Colors.purple),
                                                  backgroundColor:
                                                      Colors.grey[200]!,
                                                ),
                                              ),
                                              Text(
                                                "${vm.totalPerforma}",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
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
          ],
        );
      },
    );
  }
}
