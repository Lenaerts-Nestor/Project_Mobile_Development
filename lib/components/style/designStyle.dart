// ignore_for_file: file_names

//These are the variables assuming we're using a 400x844px screen

// font_style.dart
import 'package:flutter/material.dart';

//font sizes
const double fontSize1 = 15;
const double fontSize2 = 20;
const double fontSize3 = 30;

// font families
String fontFamilyTitle = "Intro";
String fontStyleTitle = "Medium";
String fontFamilyText = "Urbane Rounded";
String fontStyleText = "Medium";

// colors
const Color color1 = Color(0xFFFFFFFF);
const Color color2 = Color(0xFFD5EFEE);
const Color color3 = Color(0xFF8FE2DF);
const Color color4 = Color(0xFF67D1D6);
const Color color5 = Color(0xFF2D8E89);
const Color color6 = Color(0xFF0F2D2B);
const Color color7 = Color(0xFF933737);

// offsets
const double padding = 30;
const double verticalSpacing1 = 10;
const double verticalSpacing2 = 30;

//corners
const double cornerRadius = 30;

// iconsizes
const double iconSizeNav = 35;
const double negativeSizePP = 200;

final ThemeData theme = ThemeData(
    colorScheme: ColorScheme.fromSwatch().copyWith(
        background: color4,
        primary: color6,
        secondary: color4,
        tertiary: color3),
    scaffoldBackgroundColor: color4);

  /*-----------
  primary: This controls the main color used throughout your app, 
  such as for app bars and the selected item in a bottom navigation bar.
  
  onPrimary: This is the color used for text and icons that appear on top of
  the primary color.
  -------------
  secondary: This is a secondary color used for things like floating action 
  buttons and some selection controls.

  onSecondary: This is the color used for text and icons that appear on top 
  of the secondary color.
  -------------
  background: This is the color used for the background of your app.

  onBackground: This is the color used for text and icons that appear on top
  of the background color.
  -------------
  surface: This is the color used for surfaces of your app, such as cards,
  dialogs, and menus.

  onSurface: This is the color used for text and icons that appear on top of
  the surface color.
  -------------
  error: This is the color used to indicate errors, such as for text fields
  with invalid input.

  onError: This is the color used for text and icons that appear on top of 
  the error color.
  -----------*/
