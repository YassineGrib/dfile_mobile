import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/theme.dart';
import 'blobatar.dart';

/// Circular character avatar generated from a name, the same one the web app
/// shows for clients and friends.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.name, this.size = 36});

  final String name;
  final double size;

  static final Map<String, String> _cache = <String, String>{};

  static String _svgFor(String name) =>
      _cache.putIfAbsent(name, () => blobatarSvg(name, background: 'circle'));

  @override
  Widget build(BuildContext context) {
    final String clean = name.trim().isEmpty ? 'User' : name.trim();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.card, width: 1.5),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: SvgPicture.string(
          _svgFor(clean),
          width: size,
          height: size,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
