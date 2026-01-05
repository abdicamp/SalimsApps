import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salims_apps_new/core/utils/custom_text_field.dart';
import 'package:salims_apps_new/core/utils/search_dropdown.dart';
import 'package:salims_apps_new/core/utils/app_localizations.dart';
import 'package:salims_apps_new/ui/views/detail_task/detail_task_viewmodel.dart';

import '../assets/assets.gen.dart';

class CardTaskInfo extends StatefulWidget {
  bool? isDetailhistory;
  DetailTaskViewmodel? vm;
  CardTaskInfo({super.key, this.vm, this.isDetailhistory});

  @override
  State<CardTaskInfo> createState() => _CardTaskInfoState();
}

class _CardTaskInfoState extends State<CardTaskInfo> {
  /// Get current location user
  Future<void> _getCurrentLocation() async {
    if (widget.vm == null) return;

    try {
      await widget.vm!.setLocationName();
      // Validasi confirm setelah update lokasi
      widget.vm!.validasiConfirm();
    } catch (e) {
      // Error sudah di-handle di ViewModel
    }
  }

  void _showFullScreenImage(String imageUrl,
      {int initialIndex = 0, bool isVerify = false}) {
    // Buat list semua gambar (URL dan File)
    List<dynamic> allImages = [];

    if (isVerify) {
      // Untuk gambar verifikasi
      allImages.addAll(widget.vm!.imageStringVerifiy);
      allImages.addAll(widget.vm!.imageFilesVerify);
    } else {
      // Untuk gambar biasa
      allImages.addAll(widget.vm!.imageString);
      allImages.addAll(widget.vm!.imageFiles);
    }

    if (allImages.isEmpty) return;

    // Cari index dari imageUrl
    int index = allImages.indexWhere((img) => img == imageUrl);
    if (index == -1) index = initialIndex;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ImageSliderView(
          images: allImages,
          initialIndex: index,
        ),
      ),
    );
  }

  void _showFullScreenImageFile(dynamic imageFile,
      {int initialIndex = 0, bool isVerify = false}) {
    // Buat list semua gambar (URL dan File)
    List<dynamic> allImages = [];

    if (isVerify) {
      // Untuk gambar verifikasi
      allImages.addAll(widget.vm!.imageStringVerifiy);
      allImages.addAll(widget.vm!.imageFilesVerify);
    } else {
      // Untuk gambar biasa
      allImages.addAll(widget.vm!.imageString);
      allImages.addAll(widget.vm!.imageFiles);
    }

    if (allImages.isEmpty) return;

    // Cari index dari imageFile
    int index = allImages.indexWhere((img) => img == imageFile);
    if (index == -1) index = initialIndex;

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ImageSliderView(
          images: allImages,
          initialIndex: index,
        ),
      ),
    );
  }

  // void _showDialog() {
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false, // Tidak bisa ditutup dengan tap di luar dialog
  //     builder: (context) {
  //       return AlertDialog(
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(20),
  //         ),
  //         title: Row(
  //           children: [
  //             Icon(Icons.warning, color: Colors.orange),
  //             SizedBox(width: 8),
  //             Text(AppLocalizations.of(context)?.confirmDialog ?? "Confirm"),
  //           ],
  //         ),
  //         content: Text(
  //           AppLocalizations.of(context)?.confirmChangeLocation ?? "Are you sure you want to change the location?",
  //           style: TextStyle(fontSize: 16),
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               setState(() {
  //                 Navigator.pop(context); // Menutup dialog
  //               });
  //             },
  //             child: Text(AppLocalizations.of(context)?.cancel ?? "Cancel"),
  //           ),
  //           ElevatedButton(
  //             style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
  //             onPressed: () {
  //               setState(() {});
  //               // TODO: tambahkan aksi sesuai kebutuhan
  //               widget.vm!.setLocationName();
  //               Navigator.pop(context); // Menutup dialog
  //             },
  //             child: Text(AppLocalizations.of(context)?.yes ?? "Yes"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    // Debug logging
    if (widget.isDetailhistory == true) {
      if (widget.vm != null) {}
    }

    // Null check untuk vm
    if (widget.vm == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text('ViewModel is null'),
        ),
      );
    }

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
                              child: (widget.vm!.imageFiles.isEmpty &&
                                      widget.vm!.imageString.isEmpty)
                                  ? GestureDetector(
                                      onTap: () async {
                                        if (widget.isDetailhistory! == false) {
                                          await widget.vm!.pickImage();
                                        }
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
                                                Text(
                                                    AppLocalizations.of(context)
                                                            ?.attachment ??
                                                        'Attachment'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Builder(
                                      builder: (context) {
                                        // Untuk history, tidak tampilkan tombol add image
                                        final itemCount = widget
                                                    .isDetailhistory ==
                                                true
                                            ? widget.vm!.imageString.length +
                                                widget.vm!.imageFiles.length
                                            : widget.vm!.imageString.length +
                                                widget.vm!.imageFiles.length +
                                                1;

                                        return DottedBorder(
                                          borderType: BorderType.RRect,
                                          color: Colors.grey,
                                          radius: const Radius.circular(18.0),
                                          dashPattern: const [8, 4],
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(18.0)),
                                            child: GridView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                crossAxisSpacing: 4.0,
                                                mainAxisSpacing: 4.0,
                                              ),
                                              itemCount: itemCount,
                                              itemBuilder: (context, index) {
                                                final urlCount = widget
                                                    .vm!.imageString.length;

                                                // Tombol add image hanya untuk non-history
                                                if (widget.isDetailhistory ==
                                                        false &&
                                                    index ==
                                                        urlCount +
                                                            widget
                                                                .vm!
                                                                .imageFiles
                                                                .length) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        await widget.vm!
                                                            .pickImage();
                                                      },
                                                      child: Image.asset(
                                                        "assets/images/add_image.jpeg",
                                                        height: 50,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  );
                                                }

                                                // 🟦 Gambar dari URL
                                                if (index < urlCount) {
                                                  return Stack(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10)),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              _showFullScreenImage(
                                                                widget.vm!
                                                                        .imageString[
                                                                    index],
                                                                initialIndex:
                                                                    index,
                                                                isVerify: false,
                                                              );
                                                            },
                                                            child:
                                                                Image.network(
                                                              widget.vm!
                                                                      .imageString[
                                                                  index],
                                                              height: 120.0,
                                                              fit: BoxFit.cover,
                                                              loadingBuilder: (context,
                                                                      child,
                                                                      loadingProgress) {
                                                                if (loadingProgress ==
                                                                    null) {
                                                                  return child;
                                                                }
                                                                return Container(
                                                                  height: 120.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .grey[200],
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                10),
                                                                  ),
                                                                  child: Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      value: loadingProgress
                                                                                  .expectedTotalBytes !=
                                                                              null
                                                                          ? loadingProgress
                                                                                  .cumulativeBytesLoaded /
                                                                              loadingProgress
                                                                                  .expectedTotalBytes!
                                                                          : null,
                                                                      strokeWidth: 2,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              errorBuilder: (context,
                                                                      error,
                                                                      stackTrace) =>
                                                                  Container(
                                                                    height: 120.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .grey[200],
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .circular(
                                                                                  10),
                                                                    ),
                                                                    child: const Icon(
                                                                        Icons
                                                                            .broken_image,
                                                                        color: Colors
                                                                            .grey),
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // Tombol close hanya untuk non-history
                                                      if (widget
                                                              .isDetailhistory ==
                                                          false)
                                                        Positioned(
                                                          top: 4,
                                                          right: 4,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                widget.vm!
                                                                    .imageString
                                                                    .removeAt(
                                                                        index);
                                                                widget.vm!
                                                                    .validasiConfirm();
                                                              });
                                                            },
                                                            child:
                                                                const CircleAvatar(
                                                              radius: 12,
                                                              backgroundColor:
                                                                  Colors
                                                                      .black54,
                                                              child: Icon(
                                                                  Icons.close,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 16),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  );
                                                }

                                                // 🟨 Gambar dari File Lokal
                                                final fileIndex =
                                                    index - urlCount;
                                                return Stack(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    10)),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            final urlCount =
                                                                widget
                                                                    .vm!
                                                                    .imageString
                                                                    .length;
                                                            _showFullScreenImageFile(
                                                              widget.vm!
                                                                      .imageFiles[
                                                                  fileIndex],
                                                              initialIndex:
                                                                  urlCount +
                                                                      fileIndex,
                                                              isVerify: false,
                                                            );
                                                          },
                                                          child: Image.file(
                                                            widget.vm!
                                                                    .imageFiles[
                                                                fileIndex],
                                                            height: 120.0,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context,
                                                                    error,
                                                                    stackTrace) =>
                                                                Container(
                                                                  height: 120.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .grey[200],
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                10),
                                                                  ),
                                                                  child: const Icon(
                                                                      Icons
                                                                          .broken_image,
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    // Tombol close hanya untuk non-history
                                                    if (widget
                                                            .isDetailhistory ==
                                                        false)
                                                      Positioned(
                                                        top: 4,
                                                        right: 4,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              widget.vm!
                                                                  .imageFiles
                                                                  .removeAt(
                                                                      fileIndex);
                                                              widget.vm!
                                                                  .validasiConfirm();
                                                            });
                                                          },
                                                          child:
                                                              const CircleAvatar(
                                                            radius: 12,
                                                            backgroundColor:
                                                                Colors.black54,
                                                            child: Icon(
                                                                Icons.close,
                                                                color: Colors
                                                                    .white,
                                                                size: 16),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            SizedBox(height: 15),
                            Row(
                              children: [
                                // TextField Geotag
                                Expanded(
                                  flex: 5,
                                  child: CustomTextField(
                                    readOnly: true,
                                    controller: widget.vm!.locationController!,
                                    label:
                                        AppLocalizations.of(context)?.geotag ??
                                            'Geotag',
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
                                        if (widget.isDetailhistory! == false) {
                                          _getCurrentLocation();
                                        }
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 15),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              child: (widget.vm!.imageFilesVerify.isEmpty &&
                                      widget.vm!.imageStringVerifiy.isEmpty)
                                  ? GestureDetector(
                                      onTap: () async {
                                        if (widget.isDetailhistory! == false) {
                                          await widget.vm!.pickImageVerify();
                                        }
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
                                                SizedBox(height: 5),
                                                Text(AppLocalizations.of(
                                                            context)
                                                        ?.attachmentVerify ??
                                                    'Attachment Verify'),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Builder(
                                      builder: (context) {
                                        // Untuk history, tidak tampilkan tombol add image
                                        final itemCount =
                                            widget.isDetailhistory == true
                                                ? widget.vm!.imageStringVerifiy
                                                        .length +
                                                    widget.vm!.imageFilesVerify
                                                        .length
                                                : widget.vm!.imageStringVerifiy
                                                        .length +
                                                    widget.vm!.imageFilesVerify
                                                        .length +
                                                    1;

                                        return DottedBorder(
                                          borderType: BorderType.RRect,
                                          color: Colors.grey,
                                          radius: const Radius.circular(18.0),
                                          dashPattern: const [8, 4],
                                          child: ClipRRect(
                                            borderRadius:
                                                const BorderRadius.all(
                                                    Radius.circular(18.0)),
                                            child: GridView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              gridDelegate:
                                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                crossAxisSpacing: 4.0,
                                                mainAxisSpacing: 4.0,
                                              ),
                                              itemCount: itemCount,
                                              itemBuilder: (context, index) {
                                                final urlCount = widget.vm!
                                                    .imageStringVerifiy.length;

                                                // Tombol add image hanya untuk non-history
                                                if (widget.isDetailhistory ==
                                                        false &&
                                                    index ==
                                                        urlCount +
                                                            widget
                                                                .vm!
                                                                .imageFilesVerify
                                                                .length) {
                                                  return Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        await widget.vm!
                                                            .pickImageVerify();
                                                      },
                                                      child: Image.asset(
                                                        "assets/images/add_image.jpeg",
                                                        height: 50,
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  );
                                                }

                                                // 🟦 Gambar dari URL
                                                if (index < urlCount) {
                                                  return Stack(
                                                    children: [
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10)),
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              _showFullScreenImage(
                                                                widget.vm!
                                                                        .imageStringVerifiy[
                                                                    index],
                                                                initialIndex:
                                                                    index,
                                                                isVerify: true,
                                                              );
                                                            },
                                                            child:
                                                                Image.network(
                                                              widget.vm!
                                                                      .imageStringVerifiy[
                                                                  index],
                                                              height: 120.0,
                                                              fit: BoxFit.cover,
                                                              loadingBuilder: (context,
                                                                      child,
                                                                      loadingProgress) {
                                                                if (loadingProgress ==
                                                                    null) {
                                                                  return child;
                                                                }
                                                                return Container(
                                                                  height: 120.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .grey[200],
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                10),
                                                                  ),
                                                                  child: Center(
                                                                    child:
                                                                        CircularProgressIndicator(
                                                                      value: loadingProgress
                                                                                  .expectedTotalBytes !=
                                                                              null
                                                                          ? loadingProgress
                                                                                  .cumulativeBytesLoaded /
                                                                              loadingProgress
                                                                                  .expectedTotalBytes!
                                                                          : null,
                                                                      strokeWidth: 2,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              errorBuilder: (context,
                                                                      error,
                                                                      stackTrace) =>
                                                                  Container(
                                                                    height: 120.0,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: Colors
                                                                          .grey[200],
                                                                      borderRadius:
                                                                          BorderRadius
                                                                              .circular(
                                                                                  10),
                                                                    ),
                                                                    child: const Icon(
                                                                        Icons
                                                                            .broken_image,
                                                                        color: Colors
                                                                            .grey),
                                                                  ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // Tombol close hanya untuk non-history
                                                      if (widget
                                                              .isDetailhistory ==
                                                          false)
                                                        Positioned(
                                                          top: 4,
                                                          right: 4,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                widget.vm!
                                                                    .imageStringVerifiy
                                                                    .removeAt(
                                                                        index);
                                                                widget.vm!
                                                                    .validasiConfirm();
                                                              });
                                                            },
                                                            child:
                                                                const CircleAvatar(
                                                              radius: 12,
                                                              backgroundColor:
                                                                  Colors
                                                                      .black54,
                                                              child: Icon(
                                                                  Icons.close,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 16),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  );
                                                }

                                                // 🟨 Gambar dari File Lokal
                                                final fileIndex =
                                                    index - urlCount;
                                                return Stack(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              8.0),
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            const BorderRadius
                                                                .all(
                                                                Radius.circular(
                                                                    10)),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            final urlCount = widget
                                                                .vm!
                                                                .imageStringVerifiy
                                                                .length;
                                                            _showFullScreenImageFile(
                                                              widget.vm!
                                                                      .imageFilesVerify[
                                                                  fileIndex],
                                                              initialIndex:
                                                                  urlCount +
                                                                      fileIndex,
                                                              isVerify: true,
                                                            );
                                                          },
                                                          child: Image.file(
                                                            widget.vm!
                                                                    .imageFilesVerify[
                                                                fileIndex],
                                                            height: 120.0,
                                                            fit: BoxFit.cover,
                                                            errorBuilder: (context,
                                                                    error,
                                                                    stackTrace) =>
                                                                Container(
                                                                  height: 120.0,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .grey[200],
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                10),
                                                                  ),
                                                                  child: const Icon(
                                                                      Icons
                                                                          .broken_image,
                                                                      color: Colors
                                                                          .grey),
                                                                ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    // Tombol close hanya untuk non-history
                                                    if (widget
                                                            .isDetailhistory ==
                                                        false)
                                                      Positioned(
                                                        top: 4,
                                                        right: 4,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              widget.vm!
                                                                  .imageFilesVerify
                                                                  .removeAt(
                                                                      fileIndex);
                                                              widget.vm!
                                                                  .validasiConfirm();
                                                            });
                                                          },
                                                          child:
                                                              const CircleAvatar(
                                                            radius: 12,
                                                            backgroundColor:
                                                                Colors.black54,
                                                            child: Icon(
                                                                Icons.close,
                                                                color: Colors
                                                                    .white,
                                                                size: 16),
                                                          ),
                                                        ),
                                                      ),
                                                  ],
                                                );
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                            ),
                            SizedBox(height: 5),
                            CustomTextField(
                              readOnly: widget.isDetailhistory!,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)
                                          ?.pleaseEnterSomeText ??
                                      'Please enter some text';
                                }
                                return null;
                              },
                              controller: widget.vm!.weatherController!,
                              label: AppLocalizations.of(context)?.weather ??
                                  'Weather',
                              onChanged: (value) {
                                setState(() {
                                  // Trigger rebuild untuk re-validate dan hilangkan error
                                  widget.vm!.formKey1.currentState?.validate();
                                  widget.vm!.validasiConfirm();
                                });
                              },
                            ),
                            SizedBox(height: 5),
                            CustomTextField(
                              readOnly: widget.isDetailhistory!,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)
                                          ?.pleaseEnterSomeText ??
                                      'Please enter some text';
                                }
                                return null;
                              },
                              controller: widget.vm!.windDIrectionController!,
                              label:
                                  AppLocalizations.of(context)?.windDirection ??
                                      'Wind Direction',
                              onChanged: (value) {
                                setState(() {
                                  // Trigger rebuild untuk re-validate dan hilangkan error
                                  widget.vm!.formKey1.currentState?.validate();
                                  widget.vm!.validasiConfirm();
                                });
                              },
                            ),
                            SizedBox(height: 5),
                            CustomTextField(
                              readOnly: widget.isDetailhistory!,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)
                                          ?.pleaseEnterSomeText ??
                                      'Please enter some text';
                                }
                                return null;
                              },
                              controller: widget.vm!.temperaturController!,
                              label: AppLocalizations.of(context)?.temperatur ??
                                  'Temperatur',
                              onChanged: (value) {
                                setState(() {
                                  // Trigger rebuild untuk re-validate dan hilangkan error
                                  widget.vm!.formKey1.currentState?.validate();
                                  widget.vm!.validasiConfirm();
                                });
                              },
                            ),
                            SizedBox(height: 5),
                            CustomTextField(
                              readOnly: widget.isDetailhistory!,
                              maxLines: 4,
                              // validator: (value) {
                              //   if (value == null || value.isEmpty) {
                              //     return AppLocalizations.of(context)?.pleaseEnterSomeText ?? 'Please enter some text';
                              //   }
                              //   return null;
                              // },
                              controller: widget.vm!.descriptionController!,
                              label:
                                  AppLocalizations.of(context)?.description ??
                                      'Description',
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

// Class untuk Image Slider dengan zoom
class _ImageSliderView extends StatefulWidget {
  final List<dynamic> images;
  final int initialIndex;

  const _ImageSliderView({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_ImageSliderView> createState() => _ImageSliderViewState();
}

class _ImageSliderViewState extends State<_ImageSliderView> {
  late PageController _pageController;
  late int _currentIndex;
  final Map<int, TransformationController> _transformationControllers = {};
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // Initialize transformation controllers untuk semua gambar
    for (int i = 0; i < widget.images.length; i++) {
      _transformationControllers[i] = TransformationController();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var controller in _transformationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} / ${widget.images.length}',
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.images.length,
        physics: _isZoomed
            ? const NeverScrollableScrollPhysics()
            : const PageScrollPhysics(),
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            // Reset zoom saat pindah halaman
            _isZoomed = false;
            if (_transformationControllers[index] != null) {
              _transformationControllers[index]!.value = Matrix4.identity();
            }
          });
        },
        itemBuilder: (context, index) {
          final image = widget.images[index];
          final controller =
              _transformationControllers[index] ?? TransformationController();

          return Center(
            child: InteractiveViewer(
              transformationController: controller,
              minScale: 0.5,
              maxScale: 4.0,
              onInteractionStart: (details) {
                // Cek jika user mulai zoom
                if (details.pointerCount > 1) {
                  setState(() {
                    _isZoomed = true;
                  });
                }
              },
              onInteractionEnd: (details) {
                // Cek jika zoom sudah selesai (scale kembali ke 1.0)
                final scale = controller.value.getMaxScaleOnAxis();
                setState(() {
                  _isZoomed =
                      scale > 1.1; // Threshold kecil untuk menghindari flicker
                });
              },
              child: _buildImage(image),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImage(dynamic image) {
    if (image is String) {
      // Image dari URL
      return Image.network(
        image,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 100),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              color: Colors.white,
            ),
          );
        },
      );
    } else {
      // Image dari File
      return Image.file(
        image,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Center(
          child: Icon(Icons.broken_image, color: Colors.grey, size: 100),
        ),
      );
    }
  }
}
