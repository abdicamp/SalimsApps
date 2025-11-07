import 'package:flutter/material.dart';
import 'package:salims_apps_new/core/models/sample_models.dart';
import 'package:salims_apps_new/ui/views/detail_task/detail_task_viewmodel.dart';

class DataTableCIView extends StatelessWidget {
  DetailTaskViewmodel? vm;
  List<TakingSampleCI>? listTakingSample = [];
  DataTableCIView({super.key, this.listTakingSample, this.vm});

  @override
  Widget build(BuildContext context) {
    final dataSource = DataTableCi(listTakingSample!, vm);

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
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Con Qty')),
          DataColumn(label: Text('Con Uom')),
          DataColumn(label: Text('Vol Qty')),
          DataColumn(label: Text('Vol Uom')),
          DataColumn(label: Text('Description')),
          DataColumn(label: Text('')),
        ],
        source: dataSource,
        rowsPerPage: listTakingSample!.length,
      ),
    );
  }
}

class DataTableCi extends DataTableSource {
  DetailTaskViewmodel? vm;
  final List<TakingSampleCI> takingSampleCI;

  DataTableCi(this.takingSampleCI, this.vm);

  @override
  DataRow? getRow(int index) {
    if (index >= takingSampleCI.length) return null;
    final eq = takingSampleCI[index];
    return DataRow(
      color: MaterialStateProperty.all(Colors.grey[100]),
      cells: [
        DataCell(Text('${eq.equipmentname}')),
        DataCell(Text('${eq.conqty}')),
        DataCell(Text('${eq.conuom}')),
        DataCell(Text('${eq.volqty}')),
        DataCell(Text('${eq.voluom}')),
        DataCell(Text(eq.description)),
        DataCell(Row(
          children: [
            TextButton(
                onPressed: () {
      
                  vm?.removeListCi(index);
    
                  notifyListeners();
                },
                child: Text("Hapus")),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => takingSampleCI.length;

  @override
  int get selectedRowCount => 0;
}
