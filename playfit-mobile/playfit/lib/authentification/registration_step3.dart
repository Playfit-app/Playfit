import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:playfit/i18n/strings.g.dart';
import 'package:playfit/components/character_carousel.dart';
import 'package:playfit/components/customization/skin_tone_selection.dart';

class RegistrationStep3 extends StatefulWidget {
  final Function(String, List<String>) onPageChanged;

  const RegistrationStep3({
    super.key,
    required this.onPageChanged,
  });

  @override
  State<RegistrationStep3> createState() => _RegistrationStep3State();
}

class _RegistrationStep3State extends State<RegistrationStep3> {
  final FlutterSecureStorage storage = const FlutterSecureStorage();
  int _currentStep = 0;
  int _selectedCharacterIndex = 0;
  int _selectedSkinIndex = 0;
  int _selectedOutfitIndex = 0;
  final _totalSteps = 3;

  /// Fetches character images from the server for the registration process.
  Future<Map<String, dynamic>> fetchImages() async {
    final String url =
        '${dotenv.env['SERVER_BASE_URL']}/api/social/get-character-images/?registration=true';
    final response = await http.get(Uri.parse(url));

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

  List<String> _getSkinToneImages(Map<String, dynamic> data, String character) {
    final skinToneImages = <String>[];
    final characterData = data[character] as Map<String, dynamic>;

    for (final entry in characterData.entries) {
      if (entry.key == 'introduction') continue;
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

  void _getSelectedCharacter(Map<String, dynamic> data) {
    final characterImages = _getCharacterImages(data);
    final character = _getBasicCharacterFromImageUrl(
        characterImages[_selectedCharacterIndex]);
    final outfit = _getOutfitImages(
        data, character, _selectedSkinIndex)[_selectedOutfitIndex];

    final prefix = '${dotenv.env["SERVER_BASE_URL"]}/media/base_characters/';
    final baseCharacter = outfit
        .replaceAll(RegExp(RegExp.escape(prefix)), '')
        .replaceAll(RegExp(r'\.webp$'), '');

    widget.onPageChanged(baseCharacter,
        _getIntroductionImages(data, character, _selectedSkinIndex));
  }

  List<String> _getIntroductionImages(
      Map<String, dynamic> data, String character, int skinTone) {
    final introductionImages = <String>[];
    final characterData = data[character] as Map<String, dynamic>;
    final color = skinTone == 0 ? 'white' : 'black';
    final introduction = characterData['introduction'][color] as List<dynamic>;

    for (final image in introduction) {
      introductionImages.add(
        "${dotenv.env['SERVER_BASE_URL']}${image['image']}",
      );
    }

    return introductionImages;
  }

  /// Builds the widget tree for the registration step 3 screen.
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: fetchImages(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data as Map<String, dynamic>;
          double screenHeight = MediaQuery.of(context).size.height;
          double screenWidth = MediaQuery.of(context).size.width;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              children: [
                const SizedBox(height: 5),
                // Consent form as dialog
                Text(
                  t.register.avatar_choose,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                SizedBox(
                  height: screenHeight * 0.3,
                  child: _buildStepContent(data),
                ),
                SizedBox(
                  height: screenHeight * 0.06,
                ),
                if (_currentStep != _totalSteps - 1)
                  ElevatedButton(
                    onPressed: () async {
                      if (_currentStep < _totalSteps - 1) {
                        setState(() {
                          _currentStep++;
                        });
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 248, 135, 31),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100.0),
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.06, vertical: 10),
                    ),
                    child: Text(
                      _currentStep == _totalSteps - 1
                          ? t.register.create_account
                          : t.register.next,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          );
        });
  }

  /// Builds the content widget for the current registration step based on the provided [data].
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
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _getSelectedCharacter(data);
          }
        });

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(
              _getOutfitImages(
                  data,
                  _getBasicCharacterFromImageUrl(
                      basicCharacterImages[_selectedCharacterIndex]),
                  _selectedSkinIndex)[_selectedOutfitIndex],
              fit: BoxFit.fitHeight,
            ),
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
