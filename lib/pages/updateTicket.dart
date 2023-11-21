import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utswisata/models/ticket.dart';
import 'package:utswisata/services/databasehelper.dart';
import 'package:utswisata/theme.dart';
import 'package:image_picker/image_picker.dart';

class UpdateTicket extends StatefulWidget {
  final int ticketId;
  const UpdateTicket({Key? key, required this.ticketId}) : super(key: key);

  @override
  State<UpdateTicket> createState() => _UpdateTicketState();
}

class _UpdateTicketState extends State<UpdateTicket> {
  final _formKey = GlobalKey<FormState>();
  final titleController = TextEditingController();
  final categoryController = TextEditingController();
  final imageController = TextEditingController();
  final priceController = TextEditingController();

   late File? _getImage;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(source: source);

    setState(() {
      _getImage = File(pickedFile!.path);
    });

    imageController.text = _getImage!.path;
  }

  @override
  void initState() {
    super.initState();
    getTicketData();
  }

  void getTicketData() async {
    Ticket ticket = await DatabaseHelper.instance.getTicketById(widget.ticketId);


    titleController.text = ticket.title;
    categoryController.text = ticket.category;
    imageController.text = ticket.image;
    priceController.text = ticket.price.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: palmGreen,
        title: Text(
          'Create Data',
          style: headLandBold.copyWith(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter ticket name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: categoryController,
                  decoration: InputDecoration(labelText: 'Category'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter category.';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: imageController,
                        decoration: InputDecoration(labelText: 'Image URL'),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter ticket image URL.';
                          }
                          return null;
                        },
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context){
                            return Container(
                                height: 150.0,
                                child: Column(
                                children: [
                                  ListTile(
                                    leading: Icon(Icons.camera_alt),
                                    title: Text('Camera'),
                                    onTap: () {
                                    _pickImage(ImageSource.camera);
                                    Navigator.pop(context);
                                  },
                                ),
                                ListTile(
                                  leading: Icon(Icons.photo_library),
                                  title: Text('Gallery'),
                                  onTap: () {
                                    _pickImage(ImageSource.gallery);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    icon: Icon(Icons.add_a_photo),
                    tooltip: 'Add Image',
                    ),
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                TextFormField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
                  ],
                  decoration: InputDecoration(
                      labelText: 'Price',
                      prefixText: '\Rp ',
                      ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter ticket price.';
                    }
                    return null;
                  },
                ),
                const SizedBox(
                  height: 8,
                ),
                FilledButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        String title = titleController.text;
                        String category= categoryController.text;
                        String image = imageController.text;
                        double price = double.parse(priceController.text);

                        Ticket data = Ticket(
                          id: widget.ticketId, // tambahkan id produk yang akan diupdate
                          title: title,
                          category: category,
                          image: image,
                          price: price
                        );

                        await DatabaseHelper.instance.updateTicket(data); // panggil fungsi updateProduct

                        Navigator.pop(context);
                      }
                    }
, child: Text('Submit'))
              ],
            ),
          )
        )
      ),
    );
  }
}