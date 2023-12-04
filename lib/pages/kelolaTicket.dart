import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:utswisata/pages/updateTicket.dart';
import 'package:utswisata/services/databasehelper.dart';
import 'package:utswisata/models/ticket.dart';
import 'package:utswisata/pages/addTicket.dart';
import 'package:utswisata/theme.dart';
import 'package:pdf/widgets.dart' as pw;
import 'dart:typed_data';
import 'package:open_filex/open_filex.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:intl/intl.dart';

// import 'package:flowder/flowder.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({super.key});

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  late Future<List<Ticket>> _ticketListFuture;
  Key myKey = UniqueKey();
  TextEditingController _searchController = TextEditingController();
  late List<Ticket> _searchResult = [];
  late List<Ticket> _ticketList = [];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initializeNotification() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('mipmap/ic_launcher');
    const DarwinInitializationSettings darwinInitializationSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: darwinInitializationSettings,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> showNotification(
    int id,
    String title,
    String body,
  ) async {
    const AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails('1', 'TTE',
            channelDescription: 'Khusus notif TTE',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker');
    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);
    await flutterLocalNotificationsPlugin.show(
      1,
      title,
      body,
      notificationDetails,
      payload: 'item x',
    );
  }

  // awd
  Future<List<Ticket>> getTicketList() async {
    final List<Map<String, dynamic>> ticketMapList =
        await DatabaseHelper.instance.getTicketMapList();
    final List<Ticket> ticketList = [];
    ticketMapList.forEach((ticketMap) {
      ticketList.add(Ticket.fromMap(ticketMap));
    });
    _ticketList = ticketList;
    return ticketList;
  }

  void _searchTickets(String query) {
    setState(() {
      _searchResult = _ticketList
          .where((ticket) =>
              ticket.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _ticketListFuture = getTicketList();
    initializeNotification();
    showNotification(1, 'Halo', 'Selamat Datang');
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: palmGreen,
        title: Text(
          'Kelola Ticket',
          style: headLandBold.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              width: width,
              child: TextFormField(
                controller: _searchController,
                onChanged: (query) {
                  _searchTickets(query);
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: palmGreen, width: 5)),
                  prefixIcon: Icon(Icons.search, color: palmGreen),
                  hintText: "cari tiket...",
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: palmGreen, width: 2)),
                ),
              ),
            ),
            Container(
              width: width,
              height: height - 100,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: FutureBuilder<List<Ticket>>(
                key: UniqueKey(),
                future: _ticketListFuture,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return Center(child: CircularProgressIndicator());
                  }

                  List<Ticket> displayedTickets =
                      _searchController.text.isNotEmpty
                          ? _searchResult
                          : snapshot.data!;

                  if (displayedTickets.isEmpty) {
                    return Center(child: Text('Tidak ada data'));
                  }

                  return ListView.builder(
                    itemCount: displayedTickets.length,
                    itemBuilder: (BuildContext context, int index) {
                      Ticket ticket = displayedTickets[index];

                      File imageFile = File(ticket.image);

                      return Container(
                        width: width,
                        height: 65,
                        margin: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Container(
                            padding: const EdgeInsets.only(top: 10),
                            width: 80,
                            height: 160,
                            child: Image.file(imageFile, fit: BoxFit.cover),
                          ),
                          title: Container(
                            margin: const EdgeInsets.only(top: 6),
                            child: Text(ticket.title,
                                style: headLandBold.copyWith(fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                          ),
                          trailing: Container(
                            width: 100,
                            child: Wrap(
                              children: [
                                IconButton(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return UpdateTicket(
                                              ticketId: ticket.id!);
                                        },
                                      ),
                                    );
                                  },
                                  icon: Icon(Icons.edit, color: palmGreen),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    try {
                                      await DatabaseHelper.instance
                                          .deleteTicket(ticket.id!);
                                      setState(() {
                                        getTicketList();
                                      });
                                    } catch (e) {
                                      print(e.toString());
                                      rethrow;
                                    }
                                  },
                                  icon: Icon(Icons.delete, color: Colors.pink),
                                ),
                              ],
                            ),
                          ),
                          onTap: () {
                            getPdf(ticket);
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: palmGreen,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) {
                return const TicketAdd();
              },
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

// Get PDF
Future<void> getPdf(Ticket ticket) async {
  final pdf = pw.Document();

  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Center(
          child: pw.Column(
            mainAxisAlignment: pw.MainAxisAlignment.center,
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Container(
                width: 500,
                height: 200,
                child:  pw.Image(pw.MemoryImage(Uint8List.fromList(File(ticket.image).readAsBytesSync()))),
              ),
              pw.SizedBox(height: 10),
              pw.Text(ticket.title, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Text(ticket.category, style: pw.TextStyle(fontSize: 12)),
              pw.SizedBox(height: 10),
              pw.Text(
                '${NumberFormat.currency(locale: 'id', symbol: 'Rp', decimalDigits: 0).format(ticket.price)}',
                style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
              ),
            ],
          ),
        );
      },
    ),
  );

  Uint8List bytes = await pdf.save();

  final dir = await getApplicationDocumentsDirectory();
  final name_file = File("${dir.path}/document.pdf");

  await name_file.writeAsBytes(bytes);

  await OpenFilex.open(name_file.path);
}


class PdfRun extends StatefulWidget {
  final String filePath;
  const PdfRun({super.key, required this.filePath});

  @override
  State<PdfRun> createState() => _PdfRunState();
}

class _PdfRunState extends State<PdfRun> {
  final Completer<PDFViewController> _controller =
      Completer<PDFViewController>();
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';

  @override
  Widget build(BuildContext context) {
    print(widget.filePath);
    return Scaffold(
        body: PDFView(
      filePath: widget.filePath,
      enableSwipe: true,
      swipeHorizontal: true,
      autoSpacing: false,
      pageFling: false,
      onRender: (_pages) {
        setState(() {
          pages = _pages;
          isReady = true;
        });
      },
      onError: (error) {
        print(error.toString());
      },
      onPageError: (page, error) {
        print('$page: ${error.toString()}');
      },
      onViewCreated: (PDFViewController pdfViewController) {
        _controller.complete(pdfViewController);
      },
    ));
  }
}
