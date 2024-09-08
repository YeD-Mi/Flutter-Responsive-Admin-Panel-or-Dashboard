import 'package:admin/models/TablesModel.dart';
import 'package:admin/screens/tables/components/add_tables_dialog.dart';
import 'package:admin/screens/tables/components/edit_tables_dialog.dart';
import 'package:admin/screens/tables/tables_model_screen.dart';
import 'package:flutter/material.dart';
import 'package:admin/responsive.dart';
import 'package:provider/provider.dart';
import '../../../constants.dart';

class Tablesinfo extends StatefulWidget {
  const Tablesinfo({Key? key}) : super(key: key);

  @override
  _TablesInfoState createState() => _TablesInfoState();
}

class _TablesInfoState extends State<Tablesinfo> {
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
          return Center(child: Text('Error loading Tables'));
        } else {
          return Container(
            padding: EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: secondaryColor,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: defaultPadding * 1.5,
                          vertical: defaultPadding /
                              (Responsive.isMobile(context) ? 2 : 1),
                        ),
                      ),
                      onPressed: () {
                        showAddTableDialog(context);
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
                        label: Text(" "),
                      ),
                    ],
                    rows: List.generate(
                      myTables.tables.length,
                      (index) =>
                          tableInfoDataRow(myTables.tables[index], context),
                    ),
                  ),
                )
              ],
            ),
          );
        }
      },
    );
  }
}

DataRow tableInfoDataRow(TablesModel tableInfo, BuildContext context) {
  return DataRow(
    cells: [
      DataCell(Text(tableInfo.title!)),
      DataCell(InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    width: SizeConstants.width * 0.5,
                    height: SizeConstants.height * 0.5,
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            tableInfo.qrURL!,
                            fit: BoxFit.contain,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('Kapat'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          child: Icon(Icons.image))),
      DataCell(Text(tableInfo.creative!)),
      DataCell(ElevatedButton(
          onPressed: () {
            showDetailTableDialog(tableInfo, context);
          },
          child: Text("İşlem")))
    ],
  );
}
