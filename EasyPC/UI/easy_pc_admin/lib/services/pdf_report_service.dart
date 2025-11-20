import 'dart:io';
import 'package:desktop/models/order.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfReportService {
  static String _getDownloadsDirectory() {
    if (Platform.isWindows) {
      // For Windows, use USERPROFILE environment variable
      final userProfile = Platform.environment['USERPROFILE'];
      if (userProfile != null) {
        return '$userProfile\\Downloads';
      }
      throw Exception('Could not find user profile directory');
    } else if (Platform.isMacOS) {
      // For macOS
      final home = Platform.environment['HOME'];
      if (home != null) {
        return '$home/Downloads';
      }
      throw Exception('Could not find home directory');
    } else if (Platform.isLinux) {
      // For Linux
      final home = Platform.environment['HOME'];
      if (home != null) {
        return '$home/Downloads';
      }
      throw Exception('Could not find home directory');
    }
    throw Exception('Unsupported platform');
  }

  static Future<void> _openFile(String filePath) async {
    if (Platform.isWindows) {
      // Use Windows start command
      await Process.run('cmd', ['/c', 'start', '', filePath]);
    } else if (Platform.isMacOS) {
      // Use macOS open command
      await Process.run('open', [filePath]);
    } else if (Platform.isLinux) {
      // Use Linux xdg-open command
      await Process.run('xdg-open', [filePath]);
    }
  }

  static Future<String> generateOrdersReport(List<Order> orders) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd-MM-yyyy');
    final now = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'EasyPC - Orders Report',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey800,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Generated on: ${dateFormat.format(now)} at ${DateFormat('HH:mm').format(now)}',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text(
                    'Total Orders: ${orders.length}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    'Total Revenue: \$${orders.fold<int>(0, (sum, order) => sum + order.totalPrice)}',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey400),
              columnWidths: {
                0: const pw.FlexColumnWidth(1),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(1.5),
                3: const pw.FlexColumnWidth(2),
                4: const pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                    color: PdfColors.grey300,
                  ),
                  children: [
                    _buildTableCell('Order ID', isHeader: true),
                    _buildTableCell('Order Date', isHeader: true),
                    _buildTableCell('Payment Method', isHeader: true),
                    _buildTableCell('User ID', isHeader: true),
                    _buildTableCell('Total Price', isHeader: true),
                  ],
                ),
                ...orders.map((order) {
                  return pw.TableRow(
                    children: [
                      _buildTableCell('#${order.id}'),
                      _buildTableCell(dateFormat.format(order.orderDate)),
                      _buildTableCell(order.paymentMethod ?? 'N/A'),
                      _buildTableCell('${order.userId}'),
                      _buildTableCell('\$${order.totalPrice}'),
                    ],
                  );
                }),
              ],
            ),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          );
        },
      ),
    );
    // Get Downloads directory
    final downloadsPath = _getDownloadsDirectory();

    // Create file path
    final fileName = 'Orders_Report_${dateFormat.format(now)}.pdf';
    final separator = Platform.isWindows ? '\\' : '/';
    final filePath = '$downloadsPath$separator$fileName';

    // Save PDF to file
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Open the file
    await _openFile(filePath);

    return filePath;
  }

  static Future<String> generateSingleOrderReport(Order order) async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd-MM-yyyy');
    final now = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'EasyPC - Order Invoice',
                    style: pw.TextStyle(
                      fontSize: 24,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey800,
                    ),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Generated on: ${dateFormat.format(now)} at ${DateFormat('HH:mm').format(now)}',
                    style: const pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Divider(thickness: 2),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'Order ID: #${order.id}',
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Text(
                        'User ID: ${order.userId}',
                        style: const pw.TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Order Date: ${dateFormat.format(order.orderDate)}',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'Payment Method: ${order.paymentMethod ?? 'N/A'}',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            if (order.orderDetails != null && order.orderDetails!.isNotEmpty) ...[
              pw.Text(
                'Order Items',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey400),
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(1),
                  2: const pw.FlexColumnWidth(1.5),
                  3: const pw.FlexColumnWidth(1.5),
                },
                children: [
     
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(
                      color: PdfColors.grey300,
                    ),
                    children: [
                      _buildTableCell('Product', isHeader: true),
                      _buildTableCell('Quantity', isHeader: true),
                      _buildTableCell('Unit Price', isHeader: true),
                      _buildTableCell('Total', isHeader: true),
                    ],
                  ),
          
                  ...order.orderDetails!.map((detail) {
                    final productName = detail.pc?.name ?? 'PC #${detail.pcId}';
                    return pw.TableRow(
                      children: [
                        _buildTableCell(productName),
                        _buildTableCell('${detail.quantity}'),
                        _buildTableCell('\$${detail.unitPrice}'),
                        _buildTableCell('\$${detail.totalPrice}'),
                      ],
                    );
                  }),
                ],
              ),
              pw.SizedBox(height: 20),
            ],

    
            pw.Container(
              alignment: pw.Alignment.centerRight,
              child: pw.Container(
                width: 200,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Total Amount:',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '\$${order.totalPrice}',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ];
        },
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 8),
            child: pw.Text(
              'Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey600,
              ),
            ),
          );
        },
      ),
    );


    // Get Downloads directory
    final downloadsPath = _getDownloadsDirectory();

    // Create file path
    final fileName = 'Order#${order.id}.pdf';
    final separator = Platform.isWindows ? '\\' : '/';
    final filePath = '$downloadsPath$separator$fileName';

    // Save PDF to file
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());

    // Open the file
    await _openFile(filePath);

    return filePath;
  }

  static pw.Widget _buildTableCell(String text, {bool isHeader = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: isHeader ? 12 : 11,
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }
}
