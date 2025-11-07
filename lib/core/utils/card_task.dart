import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salims_apps_new/core/models/task_list_models.dart';
import 'package:salims_apps_new/ui/views/detail_task/detail_task_view.dart';
import 'package:salims_apps_new/ui/views/task_list/task_list_viewmodel.dart';

class TaskItem extends StatelessWidget {
  TaskListViewmodel? vm;
  final TestingOrder? listData;

  TaskItem({super.key, this.listData, this.vm});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Stack(
        children: [
          Card(
            color: Colors.blueAccent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
            ),
          ),
          Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Stack(
                children: [
                  // Card utama
                  Card(
                    color: Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: Colors.black.withOpacity(0.15),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              if (listData!.tsnumber == "") {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => DetailTaskView(
                                      listData: listData,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Kalender Mini (Tanggal)
                                Container(
                                  width: 60,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF42A5F5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        listData!.samplingdate.split("-")[2],
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        _getMonthName(int.parse(listData!
                                            .samplingdate
                                            .split("-")[1])),
                                        style: GoogleFonts.poppins(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 14),
                                // Detail Task
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        listData!.reqnumber,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      Text(
                                        listData!.ptsnumber,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "${listData!.sampleno} • ${listData!.samplecategory}",
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: Colors.grey[700],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        listData!.servicetype,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          color: const Color(0xFF42A5F5),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Icon(Icons.location_on,
                                              size: 14, color: Colors.red[400]),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              "${listData!.zonaname} - ${listData!.subzonaname}",
                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black54,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                listData!.tsnumber != ""
                                    ? Stack()
                                    : const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.grey,
                                      )
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          listData!.tsnumber != ""
                              ? Align(
                                  alignment: Alignment
                                      .centerRight, // tombol di pojok kanan
                                  child: SizedBox(
                                    height: 34, // tinggi tombol kecil

                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue.shade800,
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6, horizontal: 10),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        elevation: 3,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                DetailTaskView(
                                              listData: listData,
                                            ),
                                          ),
                                        );
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: const [
                                          Icon(
                                            Icons.edit, // ikon pensil
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          SizedBox(
                                              width:
                                                  5), // jarak kecil antara ikon dan teks
                                          Text(
                                            "Edit",
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  ),

                  // Kotak "On Saved" di kanan atas
                  listData?.tsnumber != ""
                      ? Positioned(
                          right: 16,
                          top: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFB2DFDB), // warna hijau lembut
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              "On Saved",
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: const Color(
                                    0xFF004D40), // teks hijau tua lembut
                              ),
                            ),
                          ),
                        )
                      : Stack()
                ],
              )),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des",
    ];
    return months[month - 1];
  }
}
