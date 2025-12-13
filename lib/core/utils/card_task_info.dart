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
  void _showFullScreenImage(String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                imageUrl,
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFullScreenImageFile(dynamic imageFile) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            iconTheme: const IconThemeData(color: Colors.white),
            leading: IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.file(
                imageFile,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }

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
              Text(AppLocalizations.of(context)?.confirmDialog ?? "Confirm"),
            ],
          ),
          content: Text(
            AppLocalizations.of(context)?.confirmChangeLocation ?? "Are you sure you want to change the location?",
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  Navigator.pop(context); // Menutup dialog
                });
              },
              child: Text(AppLocalizations.of(context)?.cancel ?? "Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                setState(() {});
                // TODO: tambahkan aksi sesuai kebutuhan
                widget.vm!.setLocationName();
                Navigator.pop(context); // Menutup dialog
              },
              child: Text(AppLocalizations.of(context)?.yes ?? "Yes"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Debug logging
    if (widget.isDetailhistory == true) {
      if (widget.vm != null) {
      }
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
                              child: (widget.vm!.imageFiles.isEmpty && widget.vm!.imageString.isEmpty)
                                  ? GestureDetector(
                                onTap: () async {
                                  if(widget.isDetailhistory! == false){
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
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Assets.icons.image.svg(),
                                          Text(AppLocalizations.of(context)?.attachment ?? 'Attachment'),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                                  : Builder(
                                      builder: (context) {
                                        // Untuk history, tidak tampilkan tombol add image
                                        final itemCount = widget.isDetailhistory == true
                                            ? widget.vm!.imageString.length + widget.vm!.imageFiles.length
                                            : widget.vm!.imageString.length + widget.vm!.imageFiles.length + 1;
                                        
                                        return DottedBorder(
                                          borderType: BorderType.RRect,
                                          color: Colors.grey,
                                          radius: const Radius.circular(18.0),
                                          dashPattern: const [8, 4],
                                          child: ClipRRect(
                                            borderRadius: const BorderRadius.all(Radius.circular(18.0)),
                                            child: GridView.builder(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount: 3,
                                                crossAxisSpacing: 4.0,
                                                mainAxisSpacing: 4.0,
                                              ),
                                              itemCount: itemCount,
                                              itemBuilder: (context, index) {
                                                final urlCount = widget.vm!.imageString.length;
                                                
                                                // Tombol add image hanya untuk non-history
                                                if (widget.isDetailhistory == false && index == urlCount + widget.vm!.imageFiles.length) {
                                                  return Padding(
                                                    padding: const EdgeInsets.all(10),
                                                    child: GestureDetector(
                                                      onTap: () async {
                                                        await widget.vm!.pickImage();
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
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: ClipRRect(
                                                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              _showFullScreenImage(widget.vm!.imageString[index]);
                                                            },
                                                            child: Image.network(
                                                              widget.vm!.imageString[index],
                                                              height: 120.0,
                                                              fit: BoxFit.cover,
                                                              errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image, color: Colors.grey),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      // Tombol close hanya untuk non-history
                                                      if (widget.isDetailhistory == false)
                                                        Positioned(
                                                          top: 4,
                                                          right: 4,
                                                          child: GestureDetector(
                                                            onTap: () {
                                                              setState(() {
                                                                widget.vm!.imageString.removeAt(index);
                                                              });
                                                            },
                                                            child: const CircleAvatar(
                                                              radius: 12,
                                                              backgroundColor: Colors.black54,
                                                              child: Icon(Icons.close, color: Colors.white, size: 16),
                                                            ),
                                                          ),
                                                        ),
                                                    ],
                                                  );
                                                }

                                                // 🟨 Gambar dari File Lokal
                                                final fileIndex = index - urlCount;
                                                return Stack(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: ClipRRect(
                                                        borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            _showFullScreenImageFile(widget.vm!.imageFiles[fileIndex]);
                                                          },
                                                          child: Image.file(
                                                            widget.vm!.imageFiles[fileIndex],
                                                            height: 120.0,
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    // Tombol close hanya untuk non-history
                                                    if (widget.isDetailhistory == false)
                                                      Positioned(
                                                        top: 4,
                                                        right: 4,
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            setState(() {
                                                              widget.vm!.imageFiles.removeAt(fileIndex);
                                                            });
                                                          },
                                                          child: const CircleAvatar(
                                                            radius: 12,
                                                            backgroundColor: Colors.black54,
                                                            child: Icon(Icons.close, color: Colors.white, size: 16),
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
                            Row(
                              children: [
                                // TextField Geotag
                                Expanded(
                                  flex: 5,
                                  child: CustomTextField(
                                    readOnly: true,
                                    controller: widget.vm!.locationController!,
                                    label: AppLocalizations.of(context)?.geotag ?? 'Geotag',
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
                                        if(widget.isDetailhistory! == false){
                                          _showDialog();
                                        }

                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            widget.vm!.isChangeLocation == true || widget.isDetailhistory == true
                                ? CustomTextField(
                              readOnly: widget.isDetailhistory!,
                                    maxLines: 3,
                                    controller: widget.vm!.addressController!,
                                    label: AppLocalizations.of(context)?.address ?? 'Address',
                                  )
                                : Stack(),
                            SizedBox(height: 5),
                            CustomTextField(
                              readOnly: widget.isDetailhistory!,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)?.pleaseEnterSomeText ?? 'Please enter some text';
                                }
                                return null;
                              },
                              controller: widget.vm!.weatherController!,
                              label: AppLocalizations.of(context)?.weather ?? 'Weather',
                            ),
                            SizedBox(height: 5),
                            CustomTextField(
                              readOnly: widget.isDetailhistory!,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)?.pleaseEnterSomeText ?? 'Please enter some text';
                                }
                                return null;
                              },
                              controller: widget.vm!.windDIrectionController!,
                              label: AppLocalizations.of(context)?.windDirection ?? 'Wind Direction',
                            ),
                            SizedBox(height: 5),
                            CustomTextField(
                              readOnly: widget.isDetailhistory!,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)?.pleaseEnterSomeText ?? 'Please enter some text';
                                }
                                return null;
                              },
                              controller: widget.vm!.temperaturController!,
                              label: AppLocalizations.of(context)?.temperatur ?? 'Temperatur',
                            ),
                            SizedBox(height: 5),
                            CustomTextField(
                              readOnly: widget.isDetailhistory!,
                              maxLines: 4,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return AppLocalizations.of(context)?.pleaseEnterSomeText ?? 'Please enter some text';
                                }
                                return null;
                              },
                              controller: widget.vm!.descriptionController!,
                              label: AppLocalizations.of(context)?.description ?? 'Description',
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
