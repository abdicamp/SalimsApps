import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salims_apps_new/core/models/task_list_models.dart';
import 'package:salims_apps_new/core/models/parameter_models.dart';
import 'package:salims_apps_new/core/models/equipment_response_models.dart';
import 'package:salims_apps_new/ui/views/detail_task/detail_task_view.dart';
import 'package:salims_apps_new/ui/views/task_list/task_list_viewmodel.dart';

import 'colors.dart';

class TaskItem extends StatelessWidget {
  TaskListViewmodel? vm;
  final TestingOrder? listData;
  final dynamic listParameterAndEquipment;

  TaskItem({super.key, this.listData, this.listParameterAndEquipment ,this.vm});

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
                              if (listData!.tsnumber == null || listData!.tsnumber == "") {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => DetailTaskView(
                                      listData: listData,
                                      isDetailhistory: false,
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Kalender Mini (Tanggal)
                                Container(
                                  width: 60,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.skyBlue,
                                        AppColors.limeLight,
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
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
                                        "${listData!.samplecatname}",
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
                                listData!.tsnumber != null && listData!.tsnumber != ""
                                    ? const SizedBox.shrink()
                                    : const Icon(
                                        Icons.arrow_forward_ios,
                                        size: 16,
                                        color: Colors.grey,
                                      )
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          // ExpansionTile untuk Parameter dan Equipment
                          if (listParameterAndEquipment != null)
                            _buildParameterAndEquipmentExpansion(),
                          const SizedBox(height: 10),
                          listData!.tsnumber != null && listData!.tsnumber != ""
                              ? Align(
                                  alignment: Alignment
                                      .centerRight, // tombol di pojok kanan
                                  child: SizedBox(
                                    height: 34, // tinggi tombol kecil

                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
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
                                                  isDetailhistory: false,

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
                  listData?.tsnumber != null && listData?.tsnumber != ""
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
                      : const SizedBox.shrink()
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

  Widget _buildParameterAndEquipmentExpansion() {
    // Parse data dari listParameterAndEquipment
    List<TestingOrderParameter> parameters = [];
    List<Equipment> equipments = [];

    if (listParameterAndEquipment != null) {
      try {
        // Ambil testing_order_parameters
        final dataPars = listParameterAndEquipment['testing_order_parameters'];
        if (dataPars is List) {
          parameters = dataPars
              .map((e) => TestingOrderParameter.fromJson(e as Map<String, dynamic>))
              .toList();
        }

        // Ambil testing_order_equipment
        final dataEquipments = listParameterAndEquipment['testing_order_equipment'];
        if (dataEquipments is List) {
          equipments = dataEquipments
              .map((e) => Equipment.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      } catch (e) {
        // Error parsing parameter and equipment handled silently
      }
    }

    // Jika tidak ada data, jangan tampilkan ExpansionTile
    if (parameters.isEmpty && equipments.isEmpty) {
      return const SizedBox.shrink();
    }

    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      title: Row(
        children: [
          Icon(Icons.science, size: 18, color: AppColors.skyBlue),
          const SizedBox(width: 8),
          Text(
            "Parameter & Equipment",
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
      children: [
        // Section Parameters
        if (parameters.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.list_alt, size: 16, color: Colors.blue.shade700),
                    const SizedBox(width: 6),
                    Text(
                      "Parameters (${parameters.length})",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...parameters.map((param) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 6, right: 8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  param.parname,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (param.parcode.isNotEmpty)
                                  Text(
                                    "Code: ${param.parcode}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                if (param.methodid.isNotEmpty)
                                  Text(
                                    "Method ID: ${param.methodid}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Section Equipment
        if (equipments.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.build, size: 16, color: Colors.green.shade700),
                    const SizedBox(width: 6),
                    Text(
                      "Equipment (${equipments.length})",
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...equipments.map((equip) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.only(top: 6, right: 8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade400,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  equip.equipmentname,
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                if (equip.equipmentcode.isNotEmpty)
                                  Text(
                                    "Code: ${equip.equipmentcode}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                if (equip.serialnumber.isNotEmpty)
                                  Text(
                                    "Serial: ${equip.serialnumber}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                if (equip.type.isNotEmpty)
                                  Text(
                                    "Type: ${equip.type}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
