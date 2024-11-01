import 'package:babysitterapp/core/constants/styles.dart';
import 'package:flutter/material.dart';

class SaveChangesButton extends StatelessWidget with GlobalStyles {
  SaveChangesButton({super.key});

  @override
  Widget build(BuildContext context) {
    return  SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black, // Set button background color
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                                vertical:
                                    10), // Reduced padding for smaller size
                          ),
                          child: const Text(
                            'Save Changes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // Set text color to white
                            ),
                          ),
                        ),
                      );
  }
}
