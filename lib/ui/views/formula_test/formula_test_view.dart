import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stacked/stacked.dart';
import 'formula_test_viewmodel.dart';

class FormulaTestView extends StatelessWidget {
  const FormulaTestView({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<FormulaTestViewModel>.reactive(
      viewModelBuilder: () => FormulaTestViewModel()..loadTestData(),
      builder: (context, vm, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              'Formula Test',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.print),
                onPressed: () {
                  vm.printUpdatedData();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Data printed to console'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ],
          ),
          body: vm.formulaExecList.isEmpty
              ? Center(child: CircularProgressIndicator())
              : LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minWidth: constraints.maxWidth > 0 
                                ? constraints.maxWidth 
                                : MediaQuery.of(context).size.width,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'FORMULA',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8),
                                _buildTableHeader(),
                                ...vm.formulaExecList.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final formula = entry.value;
                                  final isExpanded = vm.isExpanded(index);

                                  return Column(
                                    children: [
                                      _buildFormulaRow(
                                        context,
                                        index,
                                        formula,
                                        isExpanded,
                                        () => vm.toggleExpand(index),
                                      ),
                                      if (isExpanded)
                                        _buildDetailTable(
                                          context,
                                          index,
                                          formula,
                                          vm,
                                        ),
                                    ],
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildTableHeader() {
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
            _buildHeaderCell('Version', width: 100),
            _buildHeaderCell('Reference Code', width: 150),
            _buildHeaderCell('Formula Level', width: 120),
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

  Widget _buildFormulaRow(
    BuildContext context,
    int index,
    dynamic formula,
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
              // width: 50,
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
            _buildCell('${index + 1}', width: 80),
            _buildCell(formula.formulacode, width: 150),
            _buildCell(formula.formulaname, width: 200),
            _buildCell('${formula.formulaversion}', width: 100),
            _buildCell(formula.refcode, width: 150),
            _buildCell('${formula.formulalevel}', width: 120),
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

  Widget _buildDetailTable(
    BuildContext context,
    int index,
    dynamic formula,
    FormulaTestViewModel vm,
  ) {
    return Container(
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
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border(
                  bottom: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                
                  _buildHeaderCell('Detail No', ),
                  _buildHeaderCell('Parameter', ),
                  _buildHeaderCell('Type', ),
                  _buildHeaderCell('Compare Specification', ),
                  _buildHeaderCell('Result',width: 150 ),
                  _buildHeaderCell('Description', width: 200),
                ],
              ),
            ),
          ),
          ...formula.formula_detail.map((detail) {
            final detailIndex = formula.formula_detail.indexOf(detail);
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
                   
                    _buildCell('${detail.detailno}', ),
                    _buildCell(detail.parameter, ),
                    _buildCell(detail.fortype, ),
                    _buildCell(detail.comparespec ? 'Yes' : 'No', ),
                    SizedBox(
                      width: 150,
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: EditableSimResultCell(
                          value: detail.simresult ?? '',
                          isEditable: detail.parameter.startsWith('@'),
                          onChanged: (newValue) {
                            vm.updateSimResult(index, detailIndex, newValue);
                          },
                        ),
                      ),
                    ),
                    _buildCell(detail.description ?? '-', width: MediaQuery.of(context).size.width * 0.15),
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
