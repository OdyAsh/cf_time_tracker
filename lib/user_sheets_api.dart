import 'package:cf_tracker/cf_problem.dart';
import 'package:gsheets/gsheets.dart';
import 'package:hive/hive.dart';
import 'cf_problem.dart';

class UserSheetsApi { // source: https://www.youtube.com/watch?v=3UJ6RnWTGIY
    static var _credentials = '';
    static var _spreadsheet;
    static var _spreadSheetId = '';
    static var _workSheetName = '';
    static var _cfUsername = '';
    static var _box;
    static var _gsheets;
    static Worksheet? _workSheet; // name of worksheet (tabs at the bottom), eg: "External", "CF-A", etc
    static List<dynamic> _worksheetNames = [];

    static Future initFromLocal() async {
        try {
            _box = await Hive.openBox(
                'SECRET_INFO',
                path: './',
            );
            var info = _box.get('info');
            if (info == null || info['credentials'] == '') {
                return;
            }
            _credentials = info['credentials'];
            _spreadSheetId = info['spreadSheetId'];
            _workSheetName = info['workSheetName'];
            _cfUsername = info['cfUsername'];

            _gsheets = GSheets(_credentials); // all spreadsheets that the google service account can edit are now accessible 
            _spreadsheet = await _gsheets.spreadsheet(_spreadSheetId); // selecting a specific spreadsheet with its id
            _workSheet = await _getWorkSheet(_spreadsheet, title: _workSheetName);
            var worksheets = _spreadsheet.sheets;
            _worksheetNames.clear();
            for (int i = 0 ; i < worksheets.length ; i++)
            {
                print(worksheets[i]);
                _worksheetNames.add(worksheets[i].title);
            }
            print(_worksheetNames);
            //final firstRow = ProblemFields.getFields(); // uncomment these 2 lines if you want to add a header row 
            //_workSheet!.values.insertRow(1, firstRow);
        } catch(e) {
            print("GSheets init error: $e");
        }
    }

    static Future initFromUI(String creds, String ssID, String wsName, String cfName) async {
        await _box.delete('info');
        await _box.put('info', {'credentials':creds, 'spreadSheetId':ssID, 'workSheetName':wsName, 'cfUsername':cfName});
        initFromLocal();
    }

    static void reset() {
        _credentials = '';
        _spreadSheetId = '';
        _workSheetName = '';
        _cfUsername = '';
    }

    static Future<Worksheet> _getWorkSheet(
        Spreadsheet spreadsheet,
        {required String title}
    ) async {
        try {
            return await spreadsheet.addWorksheet(title); // if worksheet doesn't exist in spreadsheet, create it then return it
        } catch(e) { // exception means it is already created, so just return it
            return spreadsheet.worksheetByTitle(title)!;
        }
    }

    static Future insert(List<Map<String, dynamic>> rowList, {bool justAppend = false}) async {
        _workSheetName = "External";
        _workSheet = await _getWorkSheet(_spreadsheet, title: _workSheetName);
        if (_workSheet == null) {
          return;
        }
        if (justAppend) {
            _workSheet!.values.map.appendRows(rowList); // append row at the end of worksheet
            return;
        }
        bool foundEmptyRow = false;
        int i = 3;
        while (!foundEmptyRow) {
            try {
                final json = await _workSheet!.values.map.row(i);
                if (json[ProblemFields.problemName] == "") {
                    break;
                }
                i++;
            } catch(e) {
                _workSheet!.values.map.appendRows(rowList); // append row at the end of worksheet
                return;
            }
        }
         _workSheet!.values.map.insertRow(i, rowList[0]); // insert row at the first row that doesn't have any data
    }

    static Future update(List<dynamic> newRow, var rowNum, String worksheetName) async {
        if (worksheetName != _workSheetName) {
            _workSheetName = worksheetName;
            _workSheet = await _getWorkSheet(_spreadsheet, title: _workSheetName);
        }
        final oldRow = await _workSheet!.values.row(int.parse(rowNum));
        newRow[1] = oldRow[1]; // problem code
        newRow[newRow.length-1] = oldRow[oldRow.length-1]; // tutorial copied from "any comments" column to "helpful resources" column
        //^^ to-do: the tutorial copied is text only, not HYPERLINK(), so we should try to add that
        _workSheet!.values.insertRow(int.parse(rowNum), newRow, fromColumn: 1);
    }

    static get getSheetId => _spreadSheetId;
    static get getWorksheetNames => _worksheetNames;
}