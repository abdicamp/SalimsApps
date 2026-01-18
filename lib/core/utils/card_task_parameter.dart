import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salims_apps_new/core/utils/custom_text_field.dart';
import 'package:salims_apps_new/core/utils/data_table_Par_view.dart';
import 'package:salims_apps_new/core/utils/search_dropdown.dart';
import 'package:salims_apps_new/core/utils/app_localizations.dart';
import 'package:salims_apps_new/ui/views/detail_task/detail_task_viewmodel.dart';
import 'package:salims_apps_new/core/models/formula_exec_models.dart';

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
    // Debug logging
    if (widget.isDetailhistory == true) {
      if (widget.vm != null) {}
    }

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
                        child: widget.isDetailhistory == true
                            ? (widget.vm?.listTakingSampleParameter == null ||
                                    widget.vm!.listTakingSampleParameter.isEmpty
                                ? Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(20.0),
                                      child: Text(
                                        'No parameter information available',
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      ),
                                    ),
                                  )
                                : DataTableParView(
                                    listTakingSampleParameter:
                                        widget.vm!.listTakingSampleParameter,
                                    vm: widget.vm!,
                                  ))
                            : Column(
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
                                        child: Builder(
                                          builder: (context) {
                                            // Cari index parameter yang dipilih untuk initialIndex
                                            int? initialIndex;
                                            if (widget.vm?.parameterSelect != null && widget.vm!.listParameter.isNotEmpty) {
                                              final parcode = widget.vm!.parameterSelect!.parcode.toString().trim().toUpperCase();
                                              for (int i = 0; i < widget.vm!.listParameter.length; i++) {
                                                final paramParcode = widget.vm!.listParameter[i].parcode.toString().trim().toUpperCase();
                                                if (paramParcode == parcode) {
                                                  initialIndex = i;
                                                  break;
                                                }
                                              }
                                            }
                                            
                                            return CustomSearchableDropDown(
                                          key: widget.vm?.dropdownKeyParameter,
                                          isReadOnly: false,
                                          items: widget.vm!.listParameter,
                                          label: AppLocalizations.of(context)
                                                  ?.searchParameter ??
                                              'Search Parameter',
                                          padding: EdgeInsets.zero,
                                          hint: 'Search Parameter',
                                              initialIndex: initialIndex,
                                          dropdownHintText:
                                              AppLocalizations.of(context)
                                                      ?.searchParameterHint ??
                                                  'Search Parameter',
                                          dropdownItemStyle:
                                              GoogleFonts.getFont(
                                            "Lato",
                                          ),
                                          onChanged: (value) {
                                            if (value != null) {
                                              setState(() {
                                                widget.vm?.parameterSelect =
                                                    value;
                                                    // Update list equipment ketika parameter dipilih
                                                  
                                                    widget.vm
                                                        ?.updateParameterEquipment();
                                                    widget.vm?.getFormulaListForQC(widget.vm?.parameterSelect?.parcode);
                                                    print("formulaExecList: ${widget.vm?.parameterSelect?.parcode}");
                                              });
                                            }
                                          },
                                              dropDownMenuItems:
                                                  widget.vm!.listParameter.map((e) {
                                                return '${e.parname}';
                                              }).toList(),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  // Dropdown Equipment Parameter (muncul jika parameter dipilih dan ada detail)
                                  if (widget.vm?.parameterSelect != null &&
                                      widget.vm!.listParameterEquipment
                                          .isNotEmpty)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Text(
                                            "Parameter Equipment",
                                            style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(4),
                                          child: Container(
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
                                              child: Builder(
                                                builder: (context) {
                                                  // Cari index equipment yang dipilih untuk initialIndex
                                                  int? initialIndex;
                                                  if (widget.vm?.parameterEquipmentSelect != null && widget.vm!.listParameterEquipment.isNotEmpty) {
                                                    final equipmentcode = widget.vm!.parameterEquipmentSelect!.equipmentcode.toString().trim().toUpperCase();
                                                    for (int i = 0; i < widget.vm!.listParameterEquipment.length; i++) {
                                                      final eqCode = widget.vm!.listParameterEquipment[i].equipmentcode.toString().trim().toUpperCase();
                                                      if (eqCode == equipmentcode) {
                                                        initialIndex = i;
                                                        break;
                                                      }
                                                    }
                                                  }
                                                  
                                                  return CustomSearchableDropDown(
                                                    key: widget.vm
                                                        ?.dropdownKeyParameterEquipment,
                                                    isReadOnly: false,
                                                    items: widget
                                                        .vm!.listParameterEquipment,
                                                    label: 'Equipment Parameter',
                                                    padding: EdgeInsets.zero,
                                                    hint:
                                                        'Search Equipment Parameter',
                                                    initialIndex: initialIndex,
                                                    dropdownHintText:
                                                        'Search Equipment Parameter',
                                                    dropdownItemStyle:
                                                        GoogleFonts.getFont("Lato"),
                                                    onChanged: (value) {
                                                      if (value != null) {
                                                        setState(() {
                                                          widget.vm
                                                                  ?.parameterEquipmentSelect =
                                                              value;
                                                        });
                                                      }
                                                    },
                                                    dropDownMenuItems: widget
                                                        .vm!.listParameterEquipment
                                                        .map((e) {
                                                      return '${e.equipmentname} (${e.equipmentcode})';
                                                    }).toList(),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (widget.vm?.parameterSelect != null &&
                                      widget.vm!.listParameterEquipment
                                          .isNotEmpty)
                                    SizedBox(height: 5),

                                  SizedBox(height: 5),
                                  SizedBox(height: 5),
                                  
                                  // Formula Table (muncul jika parameter dipilih)
                                  if (widget.vm?.parameterSelect != null &&
                                      widget.vm?.formulaExecList != null)
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 10),
                                        // Dropdown untuk menambahkan formula dari parameter lain
                                        if (widget.vm?.parameterSelect?.parcode != null)
                                          Builder(
                                            builder: (context) {
                                              // availableFormulaList sudah di-update dari API saat edit parameter
                                              final availableList = widget.vm?.availableFormulaList ?? [];
                                              
                                              if (availableList.isNotEmpty)
                                                return Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets.all(4),
                                                      child: Text(
                                                        "Add Formula",
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets.all(4),
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          border: Border.all(
                                                            color: Colors.black,
                                                            width: 0.5,
                                                          ),
                                                          borderRadius: BorderRadius.circular(15),
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.all(8.0),
                                                          child: CustomSearchableDropDown(
                                                            key: widget.vm?.dropdownKeyAvailableFormula,
                                                            isReadOnly: false,
                                                            items: availableList,
                                                            label: 'Select Formula to Add',
                                                            padding: EdgeInsets.zero,
                                                            hint: 'Search Formula',
                                                            dropdownHintText: 'Search Formula',
                                                            dropdownItemStyle: GoogleFonts.getFont("Lato"),
                                                            onChanged: (value) {
                                                              if (value != null) {
                                                                setState(() {
                                                                  widget.vm?.addFormulaFromAvailable(value);
                                                                  widget.vm?.dropdownKeyAvailableFormula.currentState?.clearValue();
                                                                });
                                                              }
                                                            },
                                                            dropDownMenuItems: availableList
                                                                .map((e) {
                                                              return '${e.formulaname} (${e.formulacode})';
                                                            }).toList(),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(height: 10),
                                                  ],
                                                );
                                              return SizedBox.shrink();
                                            },
                                          ),
                                        Text(
                                          'FORMULA',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        widget.vm!.formulaExecList.isNotEmpty
                                            ? SingleChildScrollView(
                                                scrollDirection: Axis.horizontal,
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    _buildFormulaTableHeader(),
                                                    ...(() {
                                                      // Sort formula berdasarkan formulalevel ascending, lalu formulano ascending
                                                      final originalList = widget.vm!.formulaExecList;
                                                      // Buat list dengan original index untuk tracking
                                                      final indexedList = originalList.asMap().entries.toList();
                                                      indexedList.sort((a, b) {
                                                        if (a.value.formulalevel != b.value.formulalevel) {
                                                          return a.value.formulalevel.compareTo(b.value.formulalevel);
                                                        }
                                                        return a.value.formulano.compareTo(b.value.formulano);
                                                      });
                                                      
                                                      // Sort formula_detail berdasarkan detailno ascending untuk setiap formula
                                                      final result = <Map<String, dynamic>>[];
                                                      for (var entry in indexedList) {
                                                        final originalIndex = entry.key;
                                                        final formula = entry.value;
                                                        final sortedDetails = List<FormulaDetail>.from(formula.formula_detail);
                                                        sortedDetails.sort((a, b) => a.detailno.compareTo(b.detailno));
                                                        // Buat FormulaExec baru dengan detail yang sudah di-sort
                                                        final sortedFormula = FormulaExec(
                                                          formulacode: formula.formulacode,
                                                          formulaname: formula.formulaname,
                                                          refcode: formula.refcode,
                                                          formulaversion: formula.formulaversion,
                                                          formulalevel: formula.formulalevel,
                                                          description: formula.description,
                                                          samplecode: formula.samplecode,
                                                          version: formula.version,
                                                          formula_detail: sortedDetails,
                                                          formulano: formula.formulano,
                                                        );
                                                        result.add({
                                                          'formula': sortedFormula,
                                                          'originalIndex': originalIndex,
                                                        });
                                                      }
                                                      
                                                      return result;
                                                    })().map((data) {
                                                      final formula = data['formula'] as FormulaExec;
                                                      final originalIndex = data['originalIndex'] as int;
                                                      final isExpanded = widget.vm?.isExpanded(originalIndex) ?? false;

                                                      return Column(
                                                        children: [
                                                          _buildFormulaRow(
                                                            context,
                                                            originalIndex,
                                                            formula,
                                                            isExpanded,
                                                            () => widget.vm?.toggleExpand(originalIndex),
                                                          ),
                                                          if (isExpanded)
                                                            _buildFormulaDetailTable(
                                                              context,
                                                              originalIndex,
                                                              formula,
                                                            ),
                                                        ],
                                                      );
                                                    }),
                                                  ],
                                                ),
                                              )
                                            : Container(
                                                padding: EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                  color: Colors.grey[100],
                                                  borderRadius: BorderRadius.circular(8),
                                                  border: Border.all(color: Colors.grey[300]!),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    'No formula data available',
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                        SizedBox(height: 10),
                                      ],
                                    ),
                                  CustomTextField(
                                    maxLines: 4,
                                    // validator: (value) {
                                    //   if (value == null || value.isEmpty) {
                                    //     return AppLocalizations.of(context)?.pleaseEnterSomeText ?? 'Please enter some text';
                                    //   }
                                    //   return null;
                                    // },
                                    controller:
                                        widget.vm!.descriptionParController!,
                                    label: AppLocalizations.of(context)
                                            ?.description ??
                                        'Description',
                                  ),

                                  Row(
                                    children: [
                                      // Tombol Cancel (muncul jika sedang edit)
                                      if (widget.vm?.isEditingParameter == true)
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.only(right: 8),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.grey[600],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                elevation: 4,
                                              ),
                                              onPressed: () {
                                          setState(() {
                                                  widget.vm?.cancelEditParameter();
                                          });
                                        },
                                              child: const Text(
                                                "Cancel",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      // Tombol Add/Update
                                      Expanded(
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                            backgroundColor: widget.vm?.isEditingParameter == true
                                                ? Colors.orange.shade700
                                                : Colors.blue.shade800,
                                        shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                        ),
                                            elevation: 4,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          if (widget.vm!.formKey3.currentState!
                                              .validate()) {
                                            if (widget.vm!.parameterSelect ==
                                                null) {
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
                                              widget.vm?.addListParameter();
                                            }
                                          }
                                        });
                                      },
                                          child: Text(
                                            widget.vm?.isEditingParameter == true
                                                ? "Update"
                                                : "Add",
                                            style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 10),
                                  widget.vm!.listTakingSampleParameter
                                          .isNotEmpty
                                      ? DataTableParView(
                                          listTakingSampleParameter: widget
                                              .vm?.listTakingSampleParameter,
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

  // ============================================================================
  // FORMULA TABLE WIDGETS
  // ============================================================================

  Widget _buildFormulaTableHeader() {
    return IntrinsicWidth(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue[50],
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: Row(
          children: [
            _buildFormulaHeaderCell('', width: 50),
            _buildFormulaHeaderCell('No', width: 80),
            _buildFormulaHeaderCell('Formula Code', width: 150),
            _buildFormulaHeaderCell('Formula Name', width: 200),
            // _buildFormulaHeaderCell('Version', width: 100), // Hidden
            // _buildFormulaHeaderCell('Reference Code', width: 150), // Hidden
            _buildFormulaHeaderCell('Formula Level', width: 120),
            _buildFormulaHeaderCell('Action', width: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaHeaderCell(String text, {double? width}) {
    return SizedBox(
      width: width ?? 100,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildFormulaRow(
    BuildContext context,
    int index,
    dynamic formula,
    bool isExpanded,
    VoidCallback? onToggle,
  ) {
    return IntrinsicWidth(
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Center(
                  child: InkWell(
                    onTap: onToggle,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        isExpanded ? Icons.remove : Icons.add,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _buildFormulaCell('${index + 1}', width: 80),
            _buildFormulaCell(formula.formulacode, width: 150),
            _buildFormulaCell(formula.formulaname, width: 200),
            // _buildFormulaCell('${formula.formulaversion}', width: 100), // Hidden
            // _buildFormulaCell(formula.refcode, width: 150), // Hidden
            _buildFormulaCell('${formula.formulalevel}', width: 120),
            SizedBox(
              width: 100,
              child: Padding(
                padding: EdgeInsets.all(8),
                                                child: InkWell(
                                                  onTap: () {
                                                    widget.vm?.deleteFormula(
                                                      index,
                                                      widget.vm?.parameterSelect?.parcode,
                                                    );
                                                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.delete,
                          size: 14,
                          color: Colors.red[700],
                        ),
                        SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Delete',
                            style: GoogleFonts.poppins(
                              fontSize: 11,
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaCell(String text, {double? width}) {
    return SizedBox(
      width: width ?? 100,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  Widget _buildFormulaDetailTable(
    BuildContext context,
    int index,
    dynamic formula,
  ) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(top: 8, bottom: 16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[400]!),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.yellow[100],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Text(
              'DETAIL FORMULA',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          IntrinsicWidth(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  _buildFormulaHeaderCell('Detail No'),
                  _buildFormulaHeaderCell('Parameter'),
                  // _buildFormulaHeaderCell('Type'), // Hidden
                  // _buildFormulaHeaderCell('Compare Specification'), // Hidden
                  _buildFormulaHeaderCell('Result', width: 150),
                  // _buildFormulaHeaderCell('Description', width: 200), // Hidden
                ],
              ),
            ),
          ),
          ...(() {
            // Sort detail berdasarkan detailno ascending
            final originalDetails = formula.formula_detail;
            final indexedDetails = originalDetails.asMap().entries.toList();
            indexedDetails.sort((MapEntry<int, FormulaDetail> a, MapEntry<int, FormulaDetail> b) => a.value.detailno.compareTo(b.value.detailno));
            
            // Return dengan original index untuk tracking
            return indexedDetails.map((entry) => {
              'detail': entry.value,
              'originalDetailIndex': entry.key,
            }).toList();
          })().map((data) {
            final detail = data['detail'] as FormulaDetail;
            final originalDetailIndex = data['originalDetailIndex'] as int;
            return IntrinsicWidth(
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: [
                    _buildFormulaCell('${detail.detailno}'),
                    _buildFormulaCell(detail.parameter),
                    // _buildFormulaCell(detail.fortype), // Hidden
                    // _buildFormulaCell(detail.comparespec ? 'Yes' : 'No'), // Hidden
                    SizedBox(
                      width: 150,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: EditableSimResultCell(
                          value: detail.simresult ?? '',
                          isEditable: detail.parameter.startsWith('@'),
                          onChanged: (newValue) {
                            widget.vm?.updateSimResult(index, originalDetailIndex, newValue);
                          },
                        ),
                      ),
                    ),
                    // _buildFormulaCell(detail.description ?? '-', width: MediaQuery.of(context).size.width * 0.15), // Hidden
                  ],
                ),
              ),
            );
          }),
        ],
        ),
      ),
    );
  }

}

// ============================================================================
// EDITABLE SIM RESULT CELL WIDGET
// ============================================================================

class EditableSimResultCell extends StatefulWidget {
  final String value;
  final bool isEditable;
  final Function(String) onChanged;

  const EditableSimResultCell({
    super.key,
    required this.value,
    this.isEditable = true,
    required this.onChanged,
  });

  @override
  State<EditableSimResultCell> createState() => _EditableSimResultCellState();
}

class _EditableSimResultCellState extends State<EditableSimResultCell> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(EditableSimResultCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isEditable) {
      return Text(
        widget.value.isEmpty ? '-' : widget.value,
        style: GoogleFonts.poppins(
          fontSize: 12,
        ),
        overflow: TextOverflow.ellipsis,
      );
    }

    if (_isEditing) {
      return TextField(
        controller: _controller,
        style: GoogleFonts.poppins(fontSize: 12),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 4,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        onSubmitted: (value) {
          widget.onChanged(value);
          setState(() {
            _isEditing = false;
          });
        },
        onEditingComplete: () {
          widget.onChanged(_controller.text);
          setState(() {
            _isEditing = false;
          });
        },
      );
    }

    return InkWell(
      onTap: () {
        setState(() {
          _isEditing = true;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.blue[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                widget.value.isEmpty ? '-' : widget.value,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.blue[900],
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.edit,
              size: 14,
              color: Colors.blue[700],
            ),
          ],
        ),
      ),
    );
  }
}
