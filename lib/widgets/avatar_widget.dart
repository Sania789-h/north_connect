import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AvatarWidget extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final double size;
  final Color? backgroundColor;
  final Color? textColor;
  final Border? border;
  final List<BoxShadow>? boxShadow;

  const AvatarWidget({
    super.key,
    required this.avatarUrl,
    required this.name,
    this.size = 120,
    this.backgroundColor,
    this.textColor,
    this.border,
    this.boxShadow,
  });

  String get _initial {
    final clean = name.trim();
    if (clean.isEmpty) return 'U';
    return clean[0].toUpperCase();
  }

  Widget _buildFallback() {
    final String initial = _initial;
    return Container(
      width: size,
      height: size,
      color: backgroundColor ?? const Color(0xFF067A46),
      child: Center(
        child: Text(
          initial,
          style: GoogleFonts.outfit(
            fontSize: size * 0.42,
            fontWeight: FontWeight.bold,
            color: textColor ?? Colors.white,
          ),
        ),
      ),
    );
  }

  File? _resolveLocalFile(String rawPath) {
    try {
      String clean = rawPath.trim();
      if (clean.isEmpty) return null;

      // Handle file:// URI scheme
      if (clean.startsWith('file://')) {
        try {
          final uri = Uri.parse(clean);
          final parsedFile = File(uri.toFilePath());
          if (parsedFile.existsSync()) return parsedFile;
        } catch (_) {
          clean = clean.replaceFirst(RegExp(r'^file:///?'), '');
        }
      }

      // Decode URI percentage encodings (e.g. %20 -> space)
      try {
        clean = Uri.decodeFull(clean);
      } catch (_) {}

      if (kIsWeb) return null;

      // Fix Windows leading slash if present (e.g. /C:/ -> C:/)
      if (Platform.isWindows &&
          clean.startsWith('/') &&
          clean.length > 2 &&
          clean[2] == ':') {
        clean = clean.substring(1);
      }

      final file = File(clean);
      if (file.existsSync()) {
        return file;
      }
    } catch (e) {
      debugPrint("AvatarWidget: error resolving local file: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final String cleanUrl = avatarUrl.trim();

    Widget content;

    if (cleanUrl.isEmpty) {
      content = _buildFallback();
    } else if (cleanUrl.startsWith('data:image/') && cleanUrl.contains('base64,')) {
      try {
        final base64Str = cleanUrl.split('base64,').last;
        final bytes = base64Decode(base64Str);
        content = Image.memory(
          bytes,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      } catch (_) {
        content = _buildFallback();
      }
    } else if (cleanUrl.startsWith('http://') || cleanUrl.startsWith('https://')) {
      content = CachedNetworkImage(
        imageUrl: cleanUrl,
        fit: BoxFit.cover,
        width: size,
        height: size,
        placeholder: (_, __) => Container(
          width: size,
          height: size,
          color: const Color(0xFFF1F5F9),
          child: Center(
            child: SizedBox(
              width: size * 0.25,
              height: size * 0.25,
              child: const CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFF067A46),
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          debugPrint("AvatarWidget: CachedNetworkImage failed for $url ($error)");
          // Check if the URL might actually be a local path misidentified or fallback to initial
          final localFile = _resolveLocalFile(cleanUrl);
          if (localFile != null) {
            return Image.file(
              localFile,
              fit: BoxFit.cover,
              width: size,
              height: size,
              errorBuilder: (_, __, ___) => _buildFallback(),
            );
          }
          return _buildFallback();
        },
      );
    } else {
      final file = _resolveLocalFile(cleanUrl);
      if (file != null) {
        content = Image.file(
          file,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (_, __, ___) => _buildFallback(),
        );
      } else {
        content = _buildFallback();
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: backgroundColor ?? const Color(0xFFF1F5F9),
        border: border,
        boxShadow: boxShadow,
      ),
      child: ClipOval(child: content),
    );
  }
}
