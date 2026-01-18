import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:salims_apps_new/core/models/sample_models.dart';
import 'package:salims_apps_new/ui/views/detail_task/detail_task_viewmodel.dart';
import 'package:salims_apps_new/core/models/formula_exec_models.dart';

class DataTableParView extends StatelessWidget {
  final DetailTaskViewmodel? vm;
  final List<TakingSampleParameter>? listTakingSampleParameter;
  DataTableParView({super.key, this.listTakingSampleParameter, this.vm});

  @override
  Widget build(BuildContext context) {
    if (listTakingSampleParameter == null ||
        listTakingSampleParameter!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'No parameter information available',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTableHeader(),
            SizedBox(height: 3),
            ...listTakingSampleParameter!.asMap().entries.map((entry) {
              final index = entry.key;
              final param = entry.value;
              final isExpanded = vm?.isExpanded(index) ?? false;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildParameterRow(
                    context,
                    index,
                    param,
                    isExpanded,
                    () => vm?.toggleExpand(index),
                  ),
                  if (isExpanded && param.ls_t_ts_fo != null && param.ls_t_ts_fo!.isNotEmpty)
                    _buildFormulaTable(context, param),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return IntrinsicWidth(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.indigo[100],
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: Row(
          children: [
            _buildHeaderCell('', width: 60),
            _buildHeaderCell('No', width: 60),
            _buildHeaderCell('Parameter', width: 150),
            _buildHeaderCell('Parameter Equipment', width: 200),
            _buildHeaderCell('Description', width: 200),
            _buildHeaderCell('Action', width: 150),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, {double? width}) {
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

  Widget _buildParameterRow(
    BuildContext context,
    int index,
    TakingSampleParameter param,
    bool isExpanded,
    VoidCallback onToggle,
  ) {
    return IntrinsicWidth(
      child: Container(
        margin: EdgeInsets.only(bottom: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          color: Colors.grey[100],
          border: Border(
            bottom: BorderSide(color: Colors.grey[300]!),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 60,
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
            _buildCell('${index + 1}', width: 60),
            _buildCell(param.parname, width: 150),
            _buildCell(param.equipmentname, width: 200),
            _buildCell(param.description, width: 200),
            SizedBox(
              width: 150,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: vm?.isDetailhistory == true
                    ? SizedBox.shrink()
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                vm?.editParameter(index, param);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size(0, 32),
                              ),
                              child: Text(
                                "Edit",
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              onPressed: () {
                                vm?.removeListPar(index, param);
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size(0, 32),
                              ),
                              child: Text(
                                "Hapus",
                                style: GoogleFonts.poppins(
                                  fontSize: 11,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCell(String text, {double? width}) {
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

  /// Build formula table dari ls_t_ts_fo
  Widget _buildFormulaTable(BuildContext context, TakingSampleParameter param) {
    // Parse ls_t_ts_fo ke List<FormulaExec>
    List<FormulaExec> formulaList = [];
    if (param.ls_t_ts_fo != null && param.ls_t_ts_fo!.isNotEmpty) {
      try {
        formulaList = param.ls_t_ts_fo!.map((e) {
          if (e is Map<String, dynamic>) {
            // Konversi dari format baru ke FormulaExec
            final detailList = (e['formula_detail'] as List<dynamic>?)
                ?.map((detailJson) {
                  if (detailJson is Map<String, dynamic>) {
                    return FormulaDetail(
                      samplecode: '',
                      parcode: '',
                      formulacode: detailJson['formulacode']?.toString() ?? '',
                      formulaversion: int.tryParse(detailJson['formulaversion']?.toString() ?? '0') ?? 0,
                      description: detailJson['description']?.toString(),
                      lspec: detailJson['lspec']?.toString(),
                      uspec: detailJson['uspec']?.toString(),
                      version: 0,
                      parameter: detailJson['parameter']?.toString() ?? '',
                      simvalue: null,
                      detailno: int.tryParse(detailJson['detailno']?.toString() ?? '0') ?? 0,
                      fortype: '',
                      comparespec: detailJson['comparespec']?.toString().toLowerCase() == 'true',
                      formula: detailJson['formula']?.toString(),
                      simformula: null,
                      simresult: detailJson['parameterresult']?.toString(),
                    );
                  }
                  return null;
                })
                .whereType<FormulaDetail>()
                .toList() ?? [];
            
            return FormulaExec(
              formulacode: e['formulacode']?.toString() ?? '',
              formulaname: e['formulaname']?.toString() ?? '',
              refcode: '',
              formulaversion: int.tryParse(e['formulaversion']?.toString() ?? '0') ?? 0,
              formulalevel: int.tryParse(e['formulalevel']?.toString() ?? '0') ?? 0,
              description: e['description']?.toString(),
              samplecode: '',
              version: 0,
              formula_detail: detailList,
              formulano: int.tryParse(e['formulano']?.toString() ?? '1') ?? 1,
            );
          }
          return null;
        }).whereType<FormulaExec>().toList();
        
        // Sort formula berdasarkan formulalevel ascending, lalu formulano ascending
        formulaList.sort((a, b) {
          if (a.formulalevel != b.formulalevel) {
            return a.formulalevel.compareTo(b.formulalevel);
          }
          return a.formulano.compareTo(b.formulano);
        });
        
        // Sort formula_detail berdasarkan detailno ascending untuk setiap formula
        for (var formula in formulaList) {
          final sortedDetails = List<FormulaDetail>.from(formula.formula_detail);
          sortedDetails.sort((a, b) => a.detailno.compareTo(b.detailno));
          // Karena formula_detail adalah final, kita perlu membuat FormulaExec baru dengan detail yang sudah di-sort
          final index = formulaList.indexOf(formula);
          formulaList[index] = FormulaExec(
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
        }
      } catch (e) {
        print('Error parsing ls_t_ts_fo: $e');
      }
    }

    if (formulaList.isEmpty) {
      return SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.only(left: 15,top: 8, bottom: 16),
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
              'FORMULA',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormulaTableHeader(),
                ...formulaList.asMap().entries.map((entry) {
                  final formulaIndex = entry.key;
                  final formula = entry.value;
                  // Cari index parameter dari listTakingSampleParameter
                  final paramIndex = listTakingSampleParameter!.indexOf(param);
                  final isFormulaExpanded = vm?.isFormulaExpanded(paramIndex, formulaIndex) ?? false;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormulaRow(
                        context,
                        paramIndex,
                        formulaIndex,
                        formula,
                        isFormulaExpanded,
                        () => vm?.toggleFormulaExpand(paramIndex, formulaIndex),
                      ),
                      if (isFormulaExpanded)
                        _buildFormulaDetailTable(context, paramIndex, formulaIndex, formula),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
            _buildHeaderCell('', width: 50),
            _buildHeaderCell('No', width: 80),
            _buildHeaderCell('Formula Code', width: 150),
            _buildHeaderCell('Formula Name', width: 200),
            // _buildHeaderCell('Version', width: 100), // Hidden
            // _buildHeaderCell('Reference Code', width: 150), // Hidden
            _buildHeaderCell('Formula Level', width: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaRow(
    BuildContext context,
    int paramIndex,
    int formulaIndex,
    FormulaExec formula,
    bool isExpanded,
    VoidCallback onToggle,
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
              width: 50,
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
            _buildCell('${formulaIndex + 1}', width: 80),
            _buildCell(formula.formulacode, width: 150),
            _buildCell(formula.formulaname, width: 200),
            // _buildCell('${formula.formulaversion}', width: 100), // Hidden
            // _buildCell(formula.refcode, width: 150), // Hidden
            _buildCell('${formula.formulalevel}', width: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildFormulaDetailTable(
    BuildContext context,
    int paramIndex,
    int formulaIndex,
    FormulaExec formula,
  ) {
    return Container(
      margin: EdgeInsets.only(left: 50, top: 8, bottom: 16),
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
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  _buildHeaderCell('Detail No'),
                  _buildHeaderCell('Parameter'),
                  // _buildHeaderCell('Type'), // Hidden
                  // _buildHeaderCell('Compare Specification'), // Hidden
                  _buildHeaderCell('Result', width: 150),
                  // _buildHeaderCell('Description', width: 200), // Hidden
                ],
              ),
            ),
          ),
          ...(() {
            // Sort detail berdasarkan detailno ascending
            final sortedDetails = List<FormulaDetail>.from(formula.formula_detail);
            sortedDetails.sort((a, b) => a.detailno.compareTo(b.detailno));
            return sortedDetails;
          })().map((detail) {
            return IntrinsicWidth(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[300]!),
                  ),
                ),
                child: Row(
                  children: [
                    _buildCell('${detail.detailno}'),
                    _buildCell(detail.parameter),
                    // _buildCell(detail.fortype), // Hidden
                    // _buildCell(detail.comparespec ? 'Yes' : 'No'), // Hidden
                    SizedBox(
                      width: 150,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Text(
                          detail.simresult ?? '-',
                          style: GoogleFonts.poppins(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    // _buildCell(detail.description ?? '-', width: MediaQuery.of(context).size.width * 0.15), // Hidden
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
