import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JsrcExcelExporter {
  static Future<String?> exportAllData() async {
    final prefs = await SharedPreferences.getInstance();

    final excel = Excel.createExcel();

    // Default Sheet1 हटाएँ
    if (excel.tables.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    await _addJsonSheet(
      excel,
      prefs,
      'Students',
      const [
        'id',
        'name',
        'fatherName',
        'motherName',
        'mobile',
        'email',
        'dob',
        'gender',
        'address',
        'city',
        'state',
        'pincode',
        'course',
        'admissionNo',
        'rollNo',
        'photoPath',
        'signaturePath',
      ],
      const [
        'jsrc_students',
        'jsrc_student_records',
        'students',
      ],
    );

    await _addJsonSheet(
      excel,
      prefs,
      'Fees',
      const [
        'studentId',
        'studentName',
        'course',
        'installment',
        'amount',
        'paidAmount',
        'status',
        'receiptNo',
        'date',
      ],
      const ['jsrc_fee_records'],
    );

    await _addJsonSheet(
      excel,
      prefs,
      'Staff',
      const [],
      const ['jsrc_staff_records'],
    );

    await _addJsonSheet(
      excel,
      prefs,
      'Courses',
      const [],
      const ['jsrc_courses'],
    );

    await _addJsonSheet(
      excel,
      prefs,
      'Certificates',
      const [],
      const ['jsrc_certificates'],
    );

    await _addJsonSheet(
      excel,
      prefs,
      'Study Material',
      const [],
      const ['jsrc_study_material_records'],
    );

    await _addStringListSheet(
      excel,
      prefs,
      'Documents',
      'jsrc_documents',
    );

    await _addAttendanceSheet(excel, prefs);

    await _addAllLocalDataSheet(excel, prefs);

    // Excel bytes
    final List<int>? fileBytes = excel.save();

    if (fileBytes == null || fileBytes.isEmpty) {
      throw Exception('Excel file generate नहीं हो सकी।');
    }

    final now = DateTime.now();

    String two(int value) => value.toString().padLeft(2, '0');

    final fileName =
        'JSRC_Dashboard_${now.year}-'
        '${two(now.month)}-${two(now.day)}_'
        '${two(now.hour)}${two(now.minute)}${two(now.second)}.xlsx';

    // पहले app documents में backup
    final appDir = await getApplicationDocumentsDirectory();

    final backupDir = Directory(
      '${appDir.path}/JSRC_Excel_Backup',
    );

    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final backupFile = File(
      '${backupDir.path}/$fileName',
    );

    await backupFile.writeAsBytes(
      fileBytes,
      flush: true,
    );

    // User को Save As location चुनने दें
    final savedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'JSRC Excel Backup Save करें',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      bytes: Uint8List.fromList(fileBytes),
    );

    // अगर user ने location cancel कर दी,
    // तब भी internal backup सुरक्षित है।
    return savedPath ?? backupFile.path;
  }

  static Future<void> _addJsonSheet(
    Excel excel,
    SharedPreferences prefs,
    String sheetName,
    List<String> preferredColumns,
    List<String> possibleKeys,
  ) async {
    dynamic raw;

    String? foundKey;

    for (final key in possibleKeys) {
      final value = prefs.getString(key);

      if (value != null && value.trim().isNotEmpty) {
        raw = value;
        foundKey = key;
        break;
      }

      final listValue = prefs.getStringList(key);

      if (listValue != null && listValue.isNotEmpty) {
        raw = listValue;
        foundKey = key;
        break;
      }
    }

    if (raw == null) {
      final sheet = excel[sheetName];
      sheet.appendRow([
        TextCellValue('No records found'),
      ]);
      return;
    }

    try {
      dynamic decoded = raw;

      if (raw is String) {
        decoded = jsonDecode(raw);
      } else if (raw is List<String>) {
        decoded = raw
            .map<dynamic>((item) {
              try {
                return jsonDecode(item);
              } catch (_) {
                return item;
              }
            })
            .toList();
      }

      final List<Map<String, dynamic>> rows = [];

      if (decoded is List) {
        for (final item in decoded) {
          if (item is Map) {
            rows.add(
              Map<String, dynamic>.from(item),
            );
          }
        }
      } else if (decoded is Map) {
        rows.add(
          Map<String, dynamic>.from(decoded),
        );
      }

      if (rows.isEmpty) {
        final sheet = excel[sheetName];
        sheet.appendRow([
          TextCellValue('No structured records found'),
        ]);
        return;
      }

      final columns = <String>[];

      for (final column in preferredColumns) {
        if (!columns.contains(column)) {
          columns.add(column);
        }
      }

      for (final row in rows) {
        for (final key in row.keys) {
          final keyString = key.toString();

          if (!columns.contains(keyString)) {
            columns.add(keyString);
          }
        }
      }

      final sheet = excel[sheetName];

      sheet.appendRow(
        columns
            .map(
              (column) => TextCellValue(column),
            )
            .toList(),
      );

      for (final row in rows) {
        sheet.appendRow(
          columns.map((column) {
            return TextCellValue(
              _valueToText(row[column]),
            );
          }).toList(),
        );
      }

      sheet.appendRow([
        TextCellValue('Storage Key'),
        TextCellValue(foundKey ?? ''),
      ]);
    } catch (e) {
      final sheet = excel[sheetName];

      sheet.appendRow([
        TextCellValue('Error reading data'),
        TextCellValue(e.toString()),
      ]);
    }
  }

  static Future<void> _addStringListSheet(
    Excel excel,
    SharedPreferences prefs,
    String sheetName,
    String key,
  ) async {
    final data = prefs.getStringList(key) ?? [];

    final sheet = excel[sheetName];

    sheet.appendRow([
      TextCellValue('Record No.'),
      TextCellValue('Data'),
    ]);

    if (data.isEmpty) {
      sheet.appendRow([
        TextCellValue(''),
        TextCellValue('No records found'),
      ]);
      return;
    }

    for (int i = 0; i < data.length; i++) {
      String value = data[i];

      try {
        final decoded = jsonDecode(value);

        if (decoded is Map || decoded is List) {
          value = const JsonEncoder.withIndent('  ')
              .convert(decoded);
        }
      } catch (_) {}

      sheet.appendRow([
        TextCellValue('${i + 1}'),
        TextCellValue(value),
      ]);
    }
  }

  static Future<void> _addAttendanceSheet(
    Excel excel,
    SharedPreferences prefs,
  ) async {
    final sheet = excel['Attendance'];

    sheet.appendRow([
      TextCellValue('Name'),
      TextCellValue('Student ID'),
      TextCellValue('Course'),
      TextCellValue('Date'),
      TextCellValue('Time'),
      TextCellValue('Verification'),
      TextCellValue('Photo Path'),
      TextCellValue('Attendance Key'),
    ]);

    final keys = prefs.getKeys().toList();

    final attendanceKeys = keys
        .where(
          (key) =>
              key.startsWith('attendance_') &&
              !key.contains('_name') &&
              !key.contains('_studentId') &&
              !key.contains('_course') &&
              !key.contains('_date') &&
              !key.contains('_time') &&
              !key.contains('_verification') &&
              !key.contains('_photoPath'),
        )
        .toList();

    attendanceKeys.sort();

    if (attendanceKeys.isEmpty) {
      sheet.appendRow([
        TextCellValue('No attendance records'),
      ]);
      return;
    }

    for (final key in attendanceKeys) {
      if (prefs.getBool(key) != true) {
        continue;
      }

      final name =
          prefs.getString('${key}_name') ?? '';

      final studentId =
          prefs.getString('${key}_studentId') ?? '';

      final course =
          prefs.getString('${key}_course') ?? '';

      final date =
          prefs.getString('${key}_date') ?? '';

      final time =
          prefs.getString('${key}_time') ?? '';

      final verification =
          prefs.getString('${key}_verification') ??
              'Face + Eye Blink Verified';

      final photoPath =
          prefs.getString('${key}_photoPath') ?? '';

      sheet.appendRow([
        TextCellValue(name),
        TextCellValue(studentId),
        TextCellValue(course),
        TextCellValue(date),
        TextCellValue(time),
        TextCellValue(verification),
        TextCellValue(photoPath),
        TextCellValue(key),
      ]);
    }
  }

  static Future<void> _addAllLocalDataSheet(
    Excel excel,
    SharedPreferences prefs,
  ) async {
    final sheet = excel['All Local Data'];

    sheet.appendRow([
      TextCellValue('Key'),
      TextCellValue('Type'),
      TextCellValue('Value'),
    ]);

    final keys = prefs.getKeys().toList()..sort();

    for (final key in keys) {
      final value = prefs.get(key);

      String type = value.runtimeType.toString();
      String textValue;

      if (value is List) {
        textValue = value.join('\n');
      } else {
        textValue = value.toString();
      }

      // Security: admin password को Excel में export न करें।
      if (key == 'jsrc_admin_password') {
        textValue = 'HIDDEN';
      }

      sheet.appendRow([
        TextCellValue(key),
        TextCellValue(type),
        TextCellValue(textValue),
      ]);
    }
  }

  static String _valueToText(dynamic value) {
    if (value == null) {
      return '';
    }

    if (value is Map || value is List) {
      try {
        return jsonEncode(value);
      } catch (_) {
        return value.toString();
      }
    }

    return value.toString();
  }
}
