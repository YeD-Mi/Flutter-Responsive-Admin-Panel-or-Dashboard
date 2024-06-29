import 'package:admin/models/TablesModel.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/tables/tables_model_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';

class TablesInfo extends StatefulWidget {
  const TablesInfo({Key? key}) : super(key: key);

  @override
  _TablesInfoState createState() => _TablesInfoState();
}

class _TablesInfoState extends State<TablesInfo> {
  late Future<void> _fetchTablesFuture;

  @override
  void initState() {
    super.initState();
    _fetchTablesFuture =
        Provider.of<TablesPageViewModel>(context, listen: false).fetchTables();
  }

  @override
  Widget build(BuildContext context) {
    final myTables = Provider.of<TablesPageViewModel>(context);

    return FutureBuilder(
      future: _fetchTablesFuture,
      builder: (context, snapshot) {
        if (myTables.state == TablesPageState.busy) {
          return Center(child: CircularProgressIndicator());
        } else if (myTables.state == TablesPageState.error) {
          return Center(child: Text('Error loading tables'));
        } else {
          return Container(
            padding: EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Masalar",
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    ElevatedButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: defaultPadding * 1.5,
                          vertical: defaultPadding /
                              (Responsive.isMobile(context) ? 2 : 1),
                        ),
                      ),
                      onPressed: () {
                        _showAddTableDialog(context);
                      },
                      icon: Icon(Icons.add),
                      label: Text("Yeni Masa"),
                    ),
                  ],
                ),
                SizedBox(
                  width: double.infinity,
                  child: DataTable(
                    columnSpacing: defaultPadding,
                    // minWidth: 600,
                    columns: [
                      DataColumn(
                        label: Text("Masa No"),
                      ),
                      DataColumn(
                        label: Text("QR"),
                      ),
                      DataColumn(
                        label: Text("Oluşturan"),
                      ),
                      DataColumn(
                        label: Text("Oluşturma Tarihi"),
                      ),
                    ],
                    rows: List.generate(
                      myTables.tables.length,
                      (index) => tableInfoDataRow(myTables.tables[index]),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

void _showAddTableDialog(BuildContext context) {
  final _tableIDController = TextEditingController();
  final _qrURLController = TextEditingController();
  final _creativeController = TextEditingController();
  final _titleController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Yeni Masa Ekle'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _tableIDController,
                decoration: InputDecoration(labelText: 'Masa No'),
              ),
              TextField(
                controller: _qrURLController,
                decoration: InputDecoration(labelText: 'QR URL'),
              ),
              TextField(
                controller: _creativeController,
                decoration: InputDecoration(labelText: 'Oluşturan'),
              ),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Masa Adı'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              final newTable = TablesModel(
                Timestamp.fromDate(DateTime.now()),
                _creativeController.text,
                _tableIDController.text,
                _qrURLController.text,
                _titleController.text,
              );
              Provider.of<TablesPageViewModel>(context, listen: false)
                  .addTable(newTable);
              Navigator.of(context).pop();
            },
            child: Text('Ekle'),
          ),
        ],
      );
    },
  );
}

DataRow tableInfoDataRow(TablesModel tableInfo) {
  return DataRow(
    cells: [
      DataCell(Text(tableInfo.tableID!)),
      DataCell(Text(tableInfo.qrURL!)),
      DataCell(Text(tableInfo.creative!)),
      DataCell(Text(tableInfo.creationDate!.toDate().toString())),
    ],
  );
}
