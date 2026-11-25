import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location_model.dart';
import '../theme/app_theme.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/location_tile.dart';
import '../widgets/state_message.dart';

/// Search / Location Screen.
/// StatefulWidget karena memiliki TextEditingController dan Timer (debounce).
/// Fitur: input cari kota, daftar hasil dari API, pilih lokasi, favorit.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Mulai dari kondisi bersih setiap kali screen dibuka.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<SearchViewModel>().reset();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Menunggu pengguna berhenti mengetik 500 ms sebelum request ke API.
  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) context.read<SearchViewModel>().search(value);
    });
  }

  void _onSubmitted(String value) {
    _debounce?.cancel();
    context.read<SearchViewModel>().search(value);
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    context.read<SearchViewModel>().reset();
  }

  /// Memilih lokasi: tampilkan cuacanya di Home, catat ke riwayat, kembali.
  void _select(LocationModel location) {
    final navigator = Navigator.of(context);
    context.read<SearchViewModel>().addToHistory(location);
    context.read<WeatherViewModel>().loadWeather(location);
    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Column(
        children: [
          // Header biru lembut dengan tombol back bulat putih & input pill.
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(32)),
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: isDark
                    ? const [
                        Color(0xFF1F3B73),
                        Color(0xFF162444),
                        Color(0xFF121C33),
                      ]
                    : const [
                        Color(0xFF9AC3FF),
                        Color(0xFFD8E8FF),
                        Color(0xFFEDF4FF),
                      ],
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Material(
                              color:
                                  isDark ? AppPalette.cardDark : Colors.white,
                              shape: const CircleBorder(),
                              elevation: isDark ? 0 : 2,
                              shadowColor:
                                  AppPalette.primaryBlue.withValues(alpha: 0.16),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => Navigator.of(context).pop(),
                                child: SizedBox(
                                  width: 44,
                                  height: 44,
                                  child: Icon(
                                    Icons.arrow_back_rounded,
                                    size: 22,
                                    color: isDark
                                        ? Colors.white
                                        : AppPalette.textDark,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                'Cari Lokasi',
                                style: theme.textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(width: 44),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          decoration: BoxDecoration(
                            color: isDark ? AppPalette.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              if (!isDark)
                                BoxShadow(
                                  color: AppPalette.primaryBlue
                                      .withValues(alpha: 0.1),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                            ],
                          ),
                          child: TextField(
                            controller: _controller,
                            autofocus: true,
                            textInputAction: TextInputAction.search,
                            onChanged: _onChanged,
                            onSubmitted: _onSubmitted,
                            decoration: InputDecoration(
                              hintText: 'Cari nama kota...',
                              hintStyle: theme.textTheme.bodyMedium,
                              prefixIcon: const Icon(Icons.search_rounded),
                              suffixIcon:
                                  ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _controller,
                                builder: (context, value, _) {
                                  if (value.text.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return IconButton(
                                    tooltip: 'Hapus',
                                    icon: const Icon(Icons.close_rounded),
                                    onPressed: _clear,
                                  );
                                },
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Consumer<SearchViewModel>(
                  builder: (context, vm, _) => _buildBody(context, vm),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, SearchViewModel vm) {
    switch (vm.status) {
      case SearchStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppPalette.primaryBlue),
        );

      case SearchStatus.error:
        return StateMessage(
          icon: Icons.cloud_off_rounded,
          title: 'Gagal mencari lokasi',
          message: vm.errorMessage,
          actionLabel: 'Coba Lagi',
          onAction: () => vm.search(_controller.text),
        );

      case SearchStatus.empty:
        return const StateMessage(
          icon: Icons.search_off_rounded,
          title: 'Kota tidak ditemukan',
          message: 'Coba gunakan nama kota lain atau periksa ejaannya.',
        );

      case SearchStatus.success:
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 12),
          itemCount: vm.results.length,
          itemBuilder: (context, index) {
            final location = vm.results[index];
            return LocationTile(
              location: location,
              isFavorite: vm.isFavorite(location),
              onTap: () => _select(location),
              onFavoriteTap: () => vm.toggleFavorite(location),
            );
          },
        );

      case SearchStatus.idle:
        return _buildSaved(context, vm);
    }
  }

  /// Kondisi awal: tampilkan lokasi favorit dan riwayat pencarian
  /// yang dibaca dari local storage.
  Widget _buildSaved(BuildContext context, SearchViewModel vm) {
    if (vm.favorites.isEmpty && vm.history.isEmpty) {
      return const StateMessage(
        icon: Icons.travel_explore_rounded,
        title: 'Cari kota',
        message: 'Ketik nama kota (minimal 2 huruf) untuk mulai mencari.',
      );
    }

    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: [
        if (vm.favorites.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
            child: Text('Lokasi Favorit', style: theme.textTheme.titleMedium),
          ),
          for (final location in vm.favorites)
            LocationTile(
              location: location,
              leadingIcon: Icons.star_rounded,
              badgeBg: AppPalette.amberSoft,
              badgeIconColor: AppPalette.amberIcon,
              isFavorite: true,
              onTap: () => _select(location),
              onFavoriteTap: () => vm.toggleFavorite(location),
            ),
        ],
        if (vm.history.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 10, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Riwayat Pencarian',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                TextButton(
                  onPressed: vm.clearHistory,
                  child: const Text('Hapus semua'),
                ),
              ],
            ),
          ),
          for (final location in vm.history)
            LocationTile(
              location: location,
              leadingIcon: Icons.history_rounded,
              badgeBg: AppPalette.purpleSoft,
              badgeIconColor: AppPalette.purpleIcon,
              isFavorite: vm.isFavorite(location),
              onTap: () => _select(location),
              onFavoriteTap: () => vm.toggleFavorite(location),
            ),
        ],
      ],
    );
  }
}
