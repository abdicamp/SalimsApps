import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salims_apps_new/core/utils/custom_text_field.dart';
import 'package:salims_apps_new/core/utils/data_table_CI_view.dart';
import 'package:salims_apps_new/core/utils/data_table_Par_view.dart';
import 'package:salims_apps_new/core/utils/search_dropdown.dart';
import 'package:salims_apps_new/ui/views/detail_task/detail_task_viewmodel.dart';

class CardTaskParameter extends StatefulWidget {
  bool? isDetailhistory;
  DetailTaskViewmodel? vm;
  CardTaskParameter({super.key, this.vm, this.isDetailhistory});

  @override
  State<CardTaskParameter> createState() => _CardTaskParameterState();
}

class _CardTaskParameterState extends State<CardTaskParameter> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      child: SingleChildScrollView(
        child: Form(
          key: widget.vm?.formKey3,
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

                       widget.isDetailhistory == true ? DataTableParView(
                         listTakingSampleParameter:
                         widget.vm?.listTakingSampleParameter,
                         vm: widget.vm!,
                       ) :  Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Parameter",
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
                                    isReadOnly: false,
                                    items: widget.vm!.listParameter,
                                    label: 'Search Parameter',
                                    padding: EdgeInsets.zero,
                                    // searchBarHeight: SDP.sdp(40),
                                    hint: 'Search Parameter',
                                    // initialIndex: index,
                                    dropdownHintText: 'Cari Search Parameter',
                                    dropdownItemStyle: GoogleFonts.getFont(
                                      "Lato",
                                    ),
                                    onChanged: (value) {
                                      if (value != null) {
                                        setState(() {
                                          widget.vm?.parameterSelect = value;
                                        });
                                      }
                                    },
                                    dropDownMenuItems:
                                        widget.vm!.listParameter!.map((e) {
                                              return '${e.parname}';
                                            }).toList() ??
                                            [],
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 5),
                            CustomTextField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                              controller: widget.vm!.institutController!,
                              label: 'Institu Result',
                            ),
                            SizedBox(height: 5),
                            SizedBox(height: 5),
                            CustomTextField(
                              maxLines: 4,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter some text';
                                }
                                return null;
                              },
                              controller: widget.vm!.descriptionParController!,
                              label: 'Description',
                            ),
                            Row(
                              children: [
                                Text("Is Calibration"),
                                Checkbox(
                                  checkColor: Colors.black,
                                  fillColor:
                                      WidgetStatePropertyAll(Colors.white),
                                  value: widget.vm?.isCalibration,
                                  onChanged: (bool? value) {
                                    setState(() {
                                      widget.vm?.isCalibration = value!;
                                    });
                                  },
                                ),
                              ],
                            ),
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
                                    if (widget.vm!.formKey3.currentState!
                                        .validate()) {
                                      if (widget.vm!.parameterSelect == null) {
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
                                        widget.vm?.addListParameter();

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
                            widget.vm!.listTakingSampleParameter.isNotEmpty
                                ? DataTableParView(
                              listTakingSampleParameter:
                              widget.vm?.listTakingSampleParameter,
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
