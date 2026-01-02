import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salims_apps_new/core/utils/custom_text_field.dart';
import 'package:salims_apps_new/core/utils/data_table_CI_view.dart';
import 'package:salims_apps_new/core/utils/search_dropdown.dart';
import 'package:salims_apps_new/core/utils/app_localizations.dart';
import 'package:salims_apps_new/ui/views/detail_task/detail_task_viewmodel.dart';

class CardTaskContainer extends StatefulWidget {
  bool? isDetailhistory;
  DetailTaskViewmodel? vm;
  CardTaskContainer({super.key, this.vm, this.isDetailhistory});

  @override
  State<CardTaskContainer> createState() => _CardTaskContainerState();
}

class _CardTaskContainerState extends State<CardTaskContainer> {
  @override
  Widget build(BuildContext context) {
    // Debug logging
    if (widget.isDetailhistory == true) {
      if (widget.vm != null) {}
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: SingleChildScrollView(
        child: Form(
          key: widget.vm?.formKey2,
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
                        child: widget.isDetailhistory == true
                            ? (widget.vm?.listTakingSampleCI == null ||
                                    widget.vm!.listTakingSampleCI.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Text(
                                        'No container information available',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ),
                                  )
                                : DataTableCIView(
                                    listTakingSample:
                                        widget.vm!.listTakingSampleCI,
                                    vm: widget.vm!,
                                  ))
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Equipment",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Padding(
                                    padding: const EdgeInsets.all(4),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors
                                              .black, // Warna garis border
                                          width: 0.5, // Ketebalan garis border
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          15,
                                        ), // Sudut melengkung (opsional)
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: CustomSearchableDropDown(
                                          key: widget.vm?.dropdownKeyEquipment,
                                          isReadOnly: widget.isDetailhistory!,
                                          items: widget.vm!.equipmentlist ?? [],
                                          label: AppLocalizations.of(context)
                                                  ?.searchEquipment ??
                                              'Search Equipment',
                                          padding: EdgeInsets.zero,
                                          // searchBarHeight: SDP.sdp(40),
                                          hint: 'Search Equipment',
                                          // initialIndex: index,

                                          dropdownHintText:
                                              AppLocalizations.of(context)
                                                      ?.searchEquipmentHint ??
                                                  'Search Equipment',
                                          dropdownItemStyle:
                                              GoogleFonts.getFont(
                                            "Lato",
                                          ),
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() {
                                                widget.vm?.equipmentSelect =
                                                    value;
                                              });
                                            }
                                          },
                                          dropDownMenuItems: widget
                                                  .vm!.equipmentlist
                                                  ?.map((e) {
                                                return '${e.equipmentname}';
                                              }).toList() ??
                                              [],
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: CustomTextField(
                                          keyboardType: TextInputType.number,
                                          inputFormater: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]'),
                                            ), // hanya angka 0-9
                                          ],
                                          readOnly: widget.isDetailhistory!,
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return AppLocalizations.of(
                                                          context)
                                                      ?.pleaseEnterSomeText ??
                                                  'Please enter some text';
                                            }
                                            return null;
                                          },
                                          controller:
                                              widget.vm!.conQTYController!,
                                          label: AppLocalizations.of(context)
                                                  ?.unitQTY ??
                                              'Unit QTY',
                                        ),
                                      ),
                                      SizedBox(width: 7),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Unit UOM',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: Colors.black,
                                                  width: 0.5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: CustomSearchableDropDown(
                                                  key: widget
                                                      .vm?.dropdownKeyConUOM,
                                                  isReadOnly:
                                                      widget.isDetailhistory!,
                                                  items:
                                                      widget.vm!.unitList ?? [],
                                                  label: AppLocalizations.of(
                                                              context)
                                                          ?.conUOM ??
                                                      'Con UOM',
                                                  padding: EdgeInsets.zero,
                                                  dropdownHintText:
                                                      AppLocalizations.of(
                                                                  context)
                                                              ?.conUOM ??
                                                          'Search Unit',
                                                  dropdownItemStyle:
                                                      GoogleFonts.getFont(
                                                          "Lato"),
                                                  onChanged: (value) {
                                                    if (value != null) {
                                                      setState(() {
                                                        widget.vm?.conSelect =
                                                            value;
                                                      });
                                                    }
                                                  },
                                                  dropDownMenuItems: widget
                                                          .vm!.unitList
                                                          ?.map((e) {
                                                        return '${e.name}';
                                                      }).toList() ??
                                                      [],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: CustomTextField(
                                          keyboardType: TextInputType.number,
                                          inputFormater: [
                                            FilteringTextInputFormatter.allow(
                                              RegExp(r'[0-9]'),
                                            ), // hanya angka 0-9
                                          ],
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return AppLocalizations.of(
                                                          context)
                                                      ?.pleaseEnterSomeText ??
                                                  'Please enter some text';
                                            }
                                            return null;
                                          },
                                          controller:
                                              widget.vm!.volQTYController!,
                                          label: AppLocalizations.of(context)
                                                  ?.volumeQTY ??
                                              'Volume QTY',
                                        ),
                                      ),
                                      SizedBox(width: 7),
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              AppLocalizations.of(context)
                                                      ?.volumeUOM ??
                                                  'Volume UOM',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: 12),
                                            Container(
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                border: Border.all(
                                                  color: Colors.black,
                                                  width: 0.5,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(15),
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: CustomSearchableDropDown(
                                                  key: widget
                                                      .vm?.dropdownKeyVolUOM,
                                                  isReadOnly:
                                                      widget.isDetailhistory!,
                                                  items:
                                                      widget.vm!.unitList ?? [],
                                                  label: AppLocalizations.of(
                                                              context)
                                                          ?.volUOM ??
                                                      'Vol UOM',
                                                  padding: EdgeInsets.zero,
                                                  dropdownHintText:
                                                      AppLocalizations.of(
                                                                  context)
                                                              ?.volUOM ??
                                                          'Search Unit',
                                                  dropdownItemStyle:
                                                      GoogleFonts.getFont(
                                                          "Lato"),
                                                  onChanged: (value) {
                                                    if (value != null) {
                                                      setState(() {
                                                        widget.vm?.volSelect =
                                                            value;
                                                      });
                                                    }
                                                  },
                                                  dropDownMenuItems: widget
                                                          .vm!.unitList
                                                          ?.map((e) {
                                                        return '${e.name}';
                                                      }).toList() ??
                                                      [],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 5),
                                  CustomTextField(
                                    maxLines: 4,
                                    // validator: (value) {
                                    //   if (value == null || value.isEmpty) {
                                    //     return 'Please enter some text';
                                    //   }
                                    //   return null;
                                    // },
                                    controller:
                                        widget.vm!.descriptionCIController!,
                                    label: AppLocalizations.of(context)
                                            ?.description ??
                                        'Description',
                                  ),
                                  SizedBox(height: 5),
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors
                                            .blue.shade800, // warna elegan
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ), // tombol rounded
                                        ),
                                        elevation: 4, // efek bayangan halus
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (widget.vm!.formKey2.currentState!
                                              .validate()) {
                                            if (widget.vm!.equipmentSelect ==
                                                    null ||
                                                widget.vm!.conSelect == null ||
                                                widget.vm!.volSelect == null) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  duration:
                                                      Duration(seconds: 2),
                                                  content: Text(AppLocalizations
                                                              .of(context)
                                                          ?.formCannotBeEmpty ??
                                                      "Form cannot be empty"),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            } else {
                                              widget.vm?.addListCI();
                                            }
                                          }
                                        });
                                      },
                                      child: const Text(
                                        "Add",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white, // teks kontras
                                        ),
                                      ),
                                    ),
                                  ),
                                  widget.vm!.listTakingSampleCI.isNotEmpty
                                      ? DataTableCIView(
                                          listTakingSample:
                                              widget.vm?.listTakingSampleCI,
                                          vm: widget.vm!,
                                        )
                                      : Stack()
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
