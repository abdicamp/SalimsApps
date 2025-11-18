import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salims_apps_new/core/utils/custom_text_field.dart';
import 'package:salims_apps_new/core/utils/data_table_CI_view.dart';
import 'package:salims_apps_new/core/utils/search_dropdown.dart';
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
                        child:

                       widget.isDetailhistory == true ? DataTableCIView(
                         listTakingSample:
                         widget.vm?.listTakingSampleCI,
                         vm: widget.vm!,
                       ) : Column(
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
                                    color: Colors.black, // Warna garis border
                                    width: 0.5, // Ketebalan garis border
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    15,
                                  ), // Sudut melengkung (opsional)
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: CustomSearchableDropDown(
                                    isReadOnly: widget.isDetailhistory!,
                                    items: widget.vm!.equipmentlist ?? [],
                                    label: 'Search Equipment',
                                    padding: EdgeInsets.zero,
                                    // searchBarHeight: SDP.sdp(40),
                                    hint: 'Search Equipment',
                                    // initialIndex: index,
                                    dropdownHintText: 'Cari Search Equipment',
                                    dropdownItemStyle: GoogleFonts.getFont(
                                      "Lato",
                                    ),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          widget.vm?.equipmentSelect = value;
                                        });
                                      }
                                    },
                                    dropDownMenuItems:
                                        widget.vm!.equipmentlist?.map((e) {
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
                                    readOnly: widget.isDetailhistory!,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter some text';
                                      }
                                      return null;
                                    },
                                    controller: widget.vm!.conQTYController!,
                                    label: 'Unit QTY',
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
                                        height: 53,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15),
                                          ),
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: DropdownButton<String>(

                                            value: widget.vm!.conSelect?.code,
                                            isExpanded: true,
                                            underline: SizedBox(),
                                            hint: Text("Con UOM"),
                                            padding: EdgeInsets.all(4),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                            items: widget.vm?.unitList?.map((
                                              item,
                                            ) {
                                              return DropdownMenuItem<String>(
                                                value: item
                                                    .code, // kode yg disimpan
                                                child: Text(
                                                  "${item.name}",
                                                ), // yg ditampilkan
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              setState(() {});
                                              final selectedItem = widget
                                                  .vm!.unitList!
                                                  .firstWhere(
                                                (element) =>
                                                    element.code == newValue,
                                              );
                                              widget.vm!.conSelect =
                                                  selectedItem;
                                            },
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
                                      if (value == null || value.isEmpty) {
                                        return 'Please enter some text';
                                      }
                                      return null;
                                    },
                                    controller: widget.vm!.volQTYController!,
                                    label: 'Volume QTY',
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
                                        'Volume UOM',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      Container(
                                        height: 53,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(15),
                                          ),
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: DropdownButton<String>(
                                            value: widget.vm!.volSelect?.code,
                                            isExpanded: true,
                                            underline: SizedBox(),
                                            hint: Text("Vol UOM"),
                                            padding: EdgeInsets.all(4),
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                            ),
                                            items: widget.vm?.unitList?.map((
                                              item,
                                            ) {
                                              return DropdownMenuItem<String>(
                                                value: item
                                                    .code, // kode yg disimpan
                                                child: Text(
                                                  "${item.name}",
                                                ), // yg ditampilkan
                                              );
                                            }).toList(),
                                            onChanged: (String? newValue) {
                                              setState(() {});
                                              final selectedItem = widget
                                                  .vm!.unitList!
                                                  .firstWhere(
                                                (element) =>
                                                    element.code == newValue,
                                              );
                                              widget.vm!.volSelect =
                                                  selectedItem;
                                            },
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
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                              controller: widget.vm!.descriptionCIController!,
                              label: 'Description',
                            ),
                            SizedBox(height: 5),
                            SizedBox(
                              width: MediaQuery.of(context).size.width,
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
                                    if (widget.vm!.formKey2.currentState!
                                        .validate()) {
                                      if (widget.vm!.equipmentSelect == null ||
                                          widget.vm!.conSelect == null ||
                                          widget.vm!.volSelect == null) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            duration: Duration(seconds: 2),
                                            content:
                                                Text("Form tidak boleh Kosong"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      } else {
                                        widget.vm?.addListCI();
                                        print(
                                            "panjang data : ${widget.vm?.listTakingSampleCI.length}");
                                        print(
                                            "panjang data : ${widget.vm?.listTakingSampleCI.map((e) {
                                          print("data item : ${e}");
                                          return e.toJson();
                                        }).toList()}");
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
