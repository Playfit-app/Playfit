import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:playfit/i18n/strings.g.dart';
import 'package:playfit/components/character_carousel.dart';
import 'package:playfit/components/customization/skin_tone_selection.dart';

class CustomizationPage extends StatefulWidget {
  final String backgroundImageUrl;
  const CustomizationPage({
    super.key,
    required this.backgroundImageUrl,
  });

  @override
  State<CustomizationPage> createState() => _CustomizationPageState();
}

class _CustomizationPageState extends State<CustomizationPage> {
  final storage = const FlutterSecureStorage();
  var _currentStep = 0;
  final _totalSteps = 3;
  String? _selectedCharacter;
  int _selectedCharacterIndex = 0;
  int _selectedSkinIndex = 0;
  int _selectedOutfitIndex = 0;

  Future<Map<String, dynamic>> fetchImages() async {
    final String url =
        '${dotenv.env['SERVER_BASE_URL']}/api/social/get-character-images/';
    final String? token = await storage.read(key: 'token');

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load images: ${response.statusCode}');
    }
  }

  List<String> _getCharacterImages(Map<String, dynamic> data) {
    final characterImages = <String>[];

    for (final entry in data.entries) {
      final variations = entry.value as Map<String, dynamic>;
      final whiteList = variations['white'] as List<dynamic>;

      if (whiteList.isNotEmpty) {
        characterImages
            .add("${dotenv.env['SERVER_BASE_URL']}${whiteList[0]['image']}");
      }
    }

    return characterImages;
  }

  Future<void> updateCustomization(String image) async {
    final String url =
        '${dotenv.env['SERVER_BASE_URL']}/api/social/update-customization/';
    final String? token = await storage.read(key: 'token');
    final response = await http.patch(
      Uri.parse(url),
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'base_character': image,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update customization: ${response.statusCode}');
    }
  }

  List<String> _getSkinToneImages(Map<String, dynamic> data, String character) {
    final skinToneImages = <String>[];
    final characterData = data[character] as Map<String, dynamic>;

    for (final entry in characterData.entries) {
      skinToneImages.add(
        "${dotenv.env['SERVER_BASE_URL']}${entry.value[0]['image']}",
      );
    }

    return skinToneImages;
  }

  List<String> _getOutfitImages(
      Map<String, dynamic> data, String character, int skinTone) {
    final outfitImages = <String>[];
    final characterData = data[character] as Map<String, dynamic>;
    final color = skinTone == 0 ? 'white' : 'black';
    final outfits = characterData[color] as List<dynamic>;

    for (final outfit in outfits) {
      outfitImages.add(
        "${dotenv.env['SERVER_BASE_URL']}${outfit['image']}",
      );
    }

    return outfitImages;
  }

  String _getBasicCharacterFromImageUrl(String imageUrl) {
    final match = RegExp(r'character(\d+)').firstMatch(imageUrl);

    if (match != null) {
      return 'character${match.group(1)}';
    }
    return '';
  }

  String _getSelectedCharacter(Map<String, dynamic> data) {
    final characterImages = _getCharacterImages(data);
    final character = _getBasicCharacterFromImageUrl(
        characterImages[_selectedCharacterIndex]);
    final outfit = _getOutfitImages(
        data, character, _selectedSkinIndex)[_selectedOutfitIndex];

    final prefix = '${dotenv.env["SERVER_BASE_URL"]}/media/base_characters/';
    final baseCharacter = outfit
        .replaceAll(RegExp(RegExp.escape(prefix)), '')
        .replaceAll(RegExp(r'\.webp$'), '');

    return baseCharacter;
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final screenHeight = screenSize.height;
    final screenWidth = screenSize.width;

    return FutureBuilder(
      future: fetchImages(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data as Map<String, dynamic>;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            actions: <Widget>[],
          ),
          body: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  height: screenHeight / 2,
                  width: screenWidth,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(widget.backgroundImageUrl),
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                top: screenHeight * 0.3,
                bottom: 0,
                child: Container(
                  width: screenWidth,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.04,
                      ),
                      Text(
                        t.customization.title,
                        style: GoogleFonts.amaranth(
                          fontSize: 26,
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.04,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.1,
                        ),
                        child: LinearProgressIndicator(
                          value: (_currentStep + 1) / _totalSteps,
                          backgroundColor: const Color(0XFF2B2D42),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0XFFF8871F),
                          ),
                          borderRadius: BorderRadius.circular(20),
                          minHeight: 8,
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.08,
                      ),
                      SizedBox(
                          height: screenHeight * 0.3,
                          child: _buildStepContent(data)),
                      SizedBox(
                        height: screenHeight * 0.06,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          if (_currentStep < _totalSteps - 1) {
                            setState(() {
                              _currentStep++;
                            });
                          } else {
                            _selectedCharacter = _getSelectedCharacter(data);
                            await updateCustomization(_selectedCharacter!);
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 248, 135, 31),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100.0),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.06, vertical: 10),
                        ),
                        child: Text(
                          _currentStep == _totalSteps - 1
                              ? t.customization.confirm_button
                              : t.customization.next_button,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStepContent(Map<String, dynamic> data) {
    final List<String> basicCharacterImages = _getCharacterImages(data);

    switch (_currentStep) {
      case 0:
        return CharacterCarousel(
          imageUrls: basicCharacterImages,
          onImageSelected: (index) {
            setState(() => _selectedCharacterIndex = index);
          },
        );
      case 1:
        return SkinToneSelection(
          imageUrls: _getSkinToneImages(
            data,
            _getBasicCharacterFromImageUrl(
                basicCharacterImages[_selectedCharacterIndex]),
          ),
          onImageSelected: (index) {
            setState(() => _selectedSkinIndex = index);
          },
        );
      case 2:
        return CharacterCarousel(
          imageUrls: _getOutfitImages(
              data,
              _getBasicCharacterFromImageUrl(
                  basicCharacterImages[_selectedCharacterIndex]),
              _selectedSkinIndex),
          onImageSelected: (index) {
            setState(() => _selectedOutfitIndex = index);
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
