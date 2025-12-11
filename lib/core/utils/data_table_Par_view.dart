import 'package:flutter/material.dart';
import 'package:salims_apps_new/core/models/sample_models.dart';
import 'package:salims_apps_new/ui/views/detail_task/detail_task_viewmodel.dart';

class DataTableParView extends StatelessWidget {
  DetailTaskViewmodel? vm;
  List<TakingSampleParameter>? listTakingSampleParameter = [];
  DataTableParView({super.key, this.listTakingSampleParameter, this.vm});

  @override
  Widget build(BuildContext context) {
    // Handle null atau empty list
    if (listTakingSampleParameter == null || listTakingSampleParameter!.isEmpty) {
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

    final dataSource = DataTablePar(listTakingSampleParameter!, vm);

    return Theme(
      data: Theme.of(context).copyWith(
        cardColor: Colors.white, // background isi tabel
        canvasColor: Colors.white, // background footer (bagian bawah)
        dividerColor: Colors.black, // garis pembatas
        dataTableTheme: DataTableThemeData(
          headingRowColor: MaterialStateProperty.all(Colors.indigo[100]),
          headingTextStyle: const TextStyle(color: Colors.black),
          dataRowColor: MaterialStateProperty.all(Colors.white),
        ),
      ),
      child: PaginatedDataTable(
        headingRowColor: MaterialStateProperty.all(Colors.white),
        columns: const [
          DataColumn(label: Text('Parameter')),
          DataColumn(label: Text('Institur Result')),
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('Is Calibration')),
          DataColumn(label: Text('')),
        ],
        source: dataSource,
        rowsPerPage: listTakingSampleParameter!.isEmpty ? 10 : listTakingSampleParameter!.length,
      ),
    );
  }
}

class DataTablePar extends DataTableSource {
  DetailTaskViewmodel? vm;
  final List<TakingSampleParameter> takingSamplePar;

  DataTablePar(this.takingSamplePar, this.vm);

  @override
  DataRow? getRow(int index) {
    if (index >= takingSamplePar.length) return null;
    final eq = takingSamplePar[index];
    return DataRow(
      color: MaterialStateProperty.all(Colors.grey[100]),
      cells: [
        DataCell(Text('${eq.parname}')),
        DataCell(Text('${eq.insituresult}')),
        DataCell(Text('${eq.description}')),
        DataCell(Text('${eq.iscalibration}')),
        DataCell(
          // Untuk history, tidak tampilkan tombol hapus
          vm?.isDetailhistory == true 
            ? SizedBox.shrink()
            : Row(
                children: [
                  TextButton(
                    onPressed: () {
                      vm?.removeListPar(index);
                      notifyListeners();
                    },
                    child: Text("Hapus")),
                ],
              ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => takingSamplePar.length;

  @override
  int get selectedRowCount => 0;
}
