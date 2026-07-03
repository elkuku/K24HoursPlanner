import 'package:flutter/material.dart';

/// Google Calendar's fixed official event colors, keyed by `colorId` as
/// returned/accepted by the Calendar API (`Events.colorId`, values `'1'`
/// through `'11'`). Hex values per Google's `colors.eventColor` reference.
const Map<String, Color> googleEventColors = {
  '1': Color(0xFF7986CB), // Lavender
  '2': Color(0xFF33B679), // Sage
  '3': Color(0xFF8E24AA), // Grape
  '4': Color(0xFFE67C73), // Flamingo
  '5': Color(0xFFF6C026), // Banana
  '6': Color(0xFFF5511D), // Tangerine
  '7': Color(0xFF039BE5), // Peacock
  '8': Color(0xFF616161), // Graphite
  '9': Color(0xFF3F51B5), // Blueberry
  '10': Color(0xFF0B8043), // Basil
  '11': Color(0xFFD60000), // Tomato
};

/// Color used when an event has no `colorId` (calendar's default color).
const Color defaultEventColor = Color(0xFF039BE5);

/// Resolves a `colorId` (nullable, as stored on calendar events) to a
/// paintable [Color].
Color colorForEventColorId(String? colorId) =>
    googleEventColors[colorId] ?? defaultEventColor;
