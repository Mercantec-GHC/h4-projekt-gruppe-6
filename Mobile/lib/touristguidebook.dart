import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:mobile/base/sidemenu.dart';
import 'package:mobile/models.dart' as models;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import 'services/openaiservice.dart' as api;
import 'base/variables.dart';

class TouristGuideBookPage extends StatefulWidget {
  const TouristGuideBookPage({super.key});

  @override
  State<TouristGuideBookPage> createState() => _TouristGuideBookPageState();
}

class _TouristGuideBookPageState extends State<TouristGuideBookPage> {
  String? _selectedCountry;
  final List<String> countries = [
    "Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Argentina", 
    // Add more countries
  ];

  Future<void> getBook() async {
    if (_selectedCountry != null) {
      final response = await api.OpenAIService.getGuideBook(_selectedCountry!);
      print(response);  // For debugging to check the response
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choose a country')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SideMenu(
      selectedIndex: 5,
      body: Scaffold(
        appBar: AppBar(
          title: Text('Select Country'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                DropdownSearch<String>(
                  items: countries,
                  popupProps: const PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        labelText: "Search a country",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Select a country",
                      hintText: "Search a country",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  onChanged: (String? country) {
                    setState(() {
                      _selectedCountry = country;
                    });
                  },
                  selectedItem: "Select a country you want a touristbook for",
                ),
                ElevatedButton(
                  onPressed: getBook,
                  child: Text('Get Guidebook'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

