import 'package:flutter/material.dart';
import 'package:babysitterapp/core/constants.dart';

class ServiceHistoryUpload extends StatefulWidget {
  const ServiceHistoryUpload({super.key});

  @override
  State<ServiceHistoryUpload> createState() => _ServiceHistoryUploadState();
}

class _ServiceHistoryUploadState extends State<ServiceHistoryUpload> {
  bool _isImageListVisible = false;

  final List<String> _images = <String>[avatar1, avatar2];

  void _toggleImageList() {
    setState(() {
      _isImageListVisible = !_isImageListVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        GestureDetector(
          onTap: _toggleImageList,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Icon(
                      Icons.history,
                      color: GlobalStyles.primaryButtonColor,
                      size: 35,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Service History',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          'Uploaded images for proof',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: _isImageListVisible ? 100 : 0,
          child: _isImageListVisible
              ? ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _images.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      margin: const EdgeInsets.all(8.0),
                      child: Image.asset(
                        _images[index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                )
              : null, // Empty child when not visible
        ),
      ],
    );
  }
}
