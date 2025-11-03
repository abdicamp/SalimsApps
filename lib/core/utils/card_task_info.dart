import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salims_apps_new/core/utils/custom_text_field.dart';
import 'package:salims_apps_new/core/utils/search_dropdown.dart';
import 'package:salims_apps_new/ui/views/detail_task/detail_task_viewmodel.dart';

import '../assets/assets.gen.dart';

class CardTaskInfo extends StatefulWidget {
  DetailTaskViewmodel? vm;
  CardTaskInfo({super.key, this.vm});

  @override
  State<CardTaskInfo> createState() => _CardTaskInfoState();
}

class _CardTaskInfoState extends State<CardTaskInfo> {
  void _showDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Tidak bisa ditutup dengan tap di luar dialog
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text("Konfirmasi"),
            ],
          ),
          content: Text(
            "Apakah kamu yakin ingin mengubah lokasi nya ?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  Navigator.pop(context); // Menutup dialog
                });
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                setState(() {});
                // TODO: tambahkan aksi sesuai kebutuhan
                widget.vm!.setLocationName();
                Navigator.pop(context); // Menutup dialog
              },
              child: Text("Yes"),
            ),
          ],
        );
      },
    );
  }

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
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: widget.vm!.imageFiles.isEmpty
                                  ? GestureDetector(
                                      onTap: () async {
                                        await widget.vm!.pickImage();
                                        print("klik");
                                      },
                                      child: DottedBorder(
                                        borderType: BorderType.RRect,
                                        color: Colors.grey,
                                        radius: const Radius.circular(18.0),
                                        dashPattern: const [8, 4],
                                        child: Center(
                                          child: SizedBox(
                                            height: 120.0,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Assets.icons.image.svg(),
                                                const Text('Lampiran'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : DottedBorder(
                                      borderType: BorderType.RRect,
                                      color: Colors.grey,
                                      radius: const Radius.circular(18.0),
                                      dashPattern: const [8, 4],
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                          Radius.circular(18.0),
                                        ),
                                        child: GridView.builder(
                                          shrinkWrap:
                                              true, // penting jika tidak berada dalam Expanded
                                          physics:
                                              const NeverScrollableScrollPhysics(), // biar tidak tabrakan scroll
                                          gridDelegate:
                                              const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 3,
                                            crossAxisSpacing: 4.0,
                                            mainAxisSpacing: 4.0,
                                          ),
                                          itemCount:
                                              widget.vm!.imageFiles.length + 1,
                                          itemBuilder: (context, index) {
                                            if (index ==
                                                widget.vm!.imageFiles.length) {
                                              return Padding(
                                                padding: const EdgeInsets.all(
                                                  10,
                                                ),
                                                child: GestureDetector(
                                                  onTap: () async {
                                                    await widget.vm!
                                                        .pickImage();
                                                  },
                                                  child: Image.asset(
                                                    "assets/images/add_image.jpeg",
                                                    height: 50,
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Stack(
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                      8.0,
                                                    ),
                                                    child: ClipRRect(
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                        Radius.circular(
                                                          10,
                                                        ),
                                                      ),
                                                      child: Image.file(
                                                        widget.vm!
                                                            .imageFiles[index],
                                                        height: 120.0,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () {
                                                      setState(() {
                                                        widget.vm!.imageFiles
                                                            .removeAt(
                                                          index,
                                                        );
                                                      });
                                                    },
                                                    child: Icon(
                                                      Icons.delete,
                                                      color: Colors.red,
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                            ),
                            SizedBox(height: 5),
                            Row(
                              children: [
                                // TextField Geotag
                                Expanded(
                                  flex: 5,
                                  child: CustomTextField(
                                    readOnly: true,
                                    controller: widget.vm!.locationController!,
                                    label: 'Geotag',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Tombol kotak untuk cek lokasi
                                Padding(
                                  padding: const EdgeInsets.only(top: 25),
                                  child: Container(
                                    height:
                                        50, // samakan tinggi dengan TextField
                                    width: 55,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.grey, width: 1),
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.white,
                                    ),
                                    child: IconButton(
                                      icon: const Icon(Icons.location_searching,
                                          color: Colors.black),
                                      onPressed: () {
                                        _showDialog();
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            widget.vm!.isChangeLocation == true
                                ? CustomTextField(
                                    maxLines: 3,
                                    controller: widget.vm!.addressController!,
                                    label: 'Addres',
                                  )
                                : Stack(),
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
