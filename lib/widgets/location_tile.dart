import 'package:flutter/material.dart';

import '../models/location_model.dart';
import '../theme/app_theme.dart';

/// Satu baris lokasi (hasil pencarian, favorit, atau riwayat)
/// dalam kartu putih lembut dengan tombol bintang favorit.
class LocationTile extends StatelessWidget {
  const LocationTile({
    super.key,
    required this.location,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteTap,
    this.leadingIcon = Icons.location_on_rounded,
    this.badgeBg = AppPalette.blueSoft,
    this.badgeIconColor = AppPalette.primaryBlue,
  });

  final LocationModel location;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteTap;
  final IconData leadingIcon;
  final Color badgeBg;
  final Color badgeIconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: AppTheme.cardDecoration(context, radius: 20),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: isDark
                        ? badgeIconColor.withValues(alpha: 0.18)
                        : badgeBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(leadingIcon, color: badgeIconColor, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        location.name,
                        style: theme.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (location.subtitle.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          location.subtitle,
                          style: theme.textTheme.bodyMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip:
                      isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
                  icon: Icon(
                    isFavorite
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: isFavorite
                        ? AppPalette.amberIcon
                        : theme.textTheme.bodyMedium?.color,
                  ),
                  onPressed: onFavoriteTap,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
