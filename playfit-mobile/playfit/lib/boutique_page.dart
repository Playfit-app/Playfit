import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:playfit/i18n/strings.g.dart';
import 'package:playfit/styles/styles.dart';

class BoutiquePage extends StatefulWidget {
  const BoutiquePage({
    super.key,
    required this.coins,
    required this.onCoinsChange,
  });

  final int coins;
  final ValueChanged<int> onCoinsChange;

  @override
  State<BoutiquePage> createState() => _BoutiquePage();
}

class _BoutiquePage extends State<BoutiquePage> {
  final _storage = const FlutterSecureStorage();
  List<_ShopItem> _items = [];
  bool _loading = true;
  String? _error;
  late int _coins;

  @override
  void initState() {
    super.initState();
    _coins = widget.coins;
    _loadShop();
  }

  @override
  void didUpdateWidget(covariant BoutiquePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coins != widget.coins) {
      setState(() {
        _coins = widget.coins;
      });
    }
  }

  Future<void> _loadShop() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final token = await _storage.read(key: 'token');
      final url = '${dotenv.env['SERVER_BASE_URL']}/api/social/shop/items/';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Token $token'},
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load shop (${response.statusCode})');
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final coins = data['coins'] ?? _coins;
      final itemsData = (data['items'] as List<dynamic>? ?? []);
      final items = itemsData.map((raw) {
        final baseCharacter = raw['base_character'] as Map<String, dynamic>?;
        final rawImage =
            raw['preview_image'] ?? raw['image'] ?? baseCharacter?['image'];
        return _ShopItem(
          id: raw['id'] as int,
          name: raw['name'] ?? '',
          tone: baseCharacter != null ? baseCharacter['name'] ?? '' : '',
          price: raw['price'] ?? 0,
          imageUrl: _resolveImageUrl(rawImage?.toString()),
          purchased: raw['purchased'] ?? false,
          baseCharacterName: baseCharacter?['name'],
        );
      }).toList();

      setState(() {
        _items = items;
        _coins = coins;
      });
      widget.onCoinsChange(coins);
    } catch (e) {
      setState(() {
        _error = 'Unable to load shop. Pull to retry.';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final body = _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, style: AppStyles.bodyRegular),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _loadShop,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadShop,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.shop.title,
                              style:
                                  AppStyles.titleBold.copyWith(fontSize: 30),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Buy outfits with your coins. Purchases are locked to your account.',
                              style: AppStyles.bodyRegular.copyWith(
                                fontSize: 16,
                                color: AppStyles.grey.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                      sliver: SliverGrid(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.78,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _ShopCard(
                              item: _items[index],
                              coins: _coins,
                              onBuy: _handlePurchase,
                            );
                          },
                          childCount: _items.length,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 24),
                    ),
                  ],
                ),
              );

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: SafeArea(child: body),
    );
  }

  void _handlePurchase(
    _ShopItem item,
    BuildContext viewContext, {
    BuildContext? sheetContext,
  }) {
    _purchase(item, viewContext, sheetContext: sheetContext);
  }

  Future<void> _purchase(
    _ShopItem item,
    BuildContext viewContext, {
    BuildContext? sheetContext,
  }) async {
    if (item.purchased) {
      _showTimedDialog(viewContext, '${item.name} is already owned.');
      return;
    }

    if (_coins < item.price) {
      _showTimedDialog(viewContext, 'Not enough coins to buy ${item.name}.');
      return;
    }

    try {
      final token = await _storage.read(key: 'token');
      final url =
          '${dotenv.env['SERVER_BASE_URL']}/api/social/shop/purchase/';
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Token $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'item_id': item.id}),
      );

      if (response.statusCode != 200) {
        final detail = jsonDecode(response.body)['detail'] ??
            'Purchase failed (${response.statusCode})';
        _showTimedDialog(viewContext, detail.toString());
        return;
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final updatedCoins = data['coins'] ?? _coins;

      setState(() {
        _coins = updatedCoins;
        _items = _items
            .map((it) =>
                it.id == item.id ? it.copyWith(purchased: true) : it)
            .toList();
      });
      widget.onCoinsChange(updatedCoins);

      ScaffoldMessenger.of(viewContext).showSnackBar(
        SnackBar(
          content: Text('${item.name} purchased!'),
          backgroundColor: Colors.green,
        ),
      );

      if (sheetContext != null) {
        Navigator.of(sheetContext).pop();
      }
    } catch (e) {
      _showTimedDialog(viewContext, 'Purchase failed. Please try again.');
    }
  }

  void _showTimedDialog(BuildContext context, String message) {
    // Lightweight modal that auto-closes after a short delay.
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: AppStyles.bodyRegular.copyWith(fontSize: 15),
              ),
            ),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final navigator = Navigator.of(context, rootNavigator: true);
      if (navigator.canPop()) {
        navigator.pop();
      }
    });
  }

  String? _resolveImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) {
      return null;
    }
    final baseUrl = dotenv.env['SERVER_BASE_URL'] ?? '';
    if (rawUrl.startsWith('http')) {
      return rawUrl;
    }
    if (rawUrl.startsWith('/')) {
      return '$baseUrl$rawUrl';
    }
    return '$baseUrl/$rawUrl';
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({
    required this.item,
    required this.coins,
    required this.onBuy,
  });

  final _ShopItem item;
  final int coins;
  final void Function(
    _ShopItem item,
    BuildContext context, {
    BuildContext? sheetContext,
  }) onBuy;

  @override
  Widget build(BuildContext context) {
    final outerContext = context;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => _showSkinSheet(outerContext),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppStyles.grey.withOpacity(0.08),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 14,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppStyles.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: item.imageUrl != null
                              ? Image.network(
                                  item.imageUrl!,
                                  fit: BoxFit.contain,
                                )
                              : const Icon(Icons.image_not_supported),
                        ),
                        if (item.purchased)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.green.shade600,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Owned',
                                style: AppStyles.bodyBold
                                    .copyWith(color: Colors.white, fontSize: 10),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 255, 248, 225),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color.fromARGB(255, 249, 200, 99),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.monetization_on,
                          size: 16,
                          color: Color.fromARGB(255, 219, 176, 34),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${item.price}',
                          style: AppStyles.bodyBold.copyWith(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 113, 93, 52),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: item.purchased
                        ? null
                        : () => onBuy(item, outerContext),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: item.purchased
                          ? Colors.grey.shade400
                          : AppStyles.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(item.purchased ? 'Owned' : 'Buy'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSkinSheet(BuildContext outerContext) {
    // Shows a modal with a larger preview and a single buy action.
    showModalBottomSheet(
      context: outerContext,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: 18 + MediaQuery.of(outerContext).padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: AppStyles.titleBold.copyWith(fontSize: 24),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(sheetContext).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.tone,
                    style: AppStyles.bodyRegular.copyWith(
                      fontSize: 15,
                      color: AppStyles.grey.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      color: AppStyles.grey.withOpacity(0.05),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: item.imageUrl != null
                            ? Image.network(
                                item.imageUrl!,
                                fit: BoxFit.contain,
                              )
                            : const Icon(Icons.image_not_supported),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 248, 225),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color.fromARGB(255, 249, 200, 99),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.monetization_on,
                              size: 18,
                              color: Color.fromARGB(255, 219, 176, 34),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${item.price}',
                              style: AppStyles.bodyBold.copyWith(
                                fontSize: 16,
                                color: const Color.fromARGB(255, 113, 93, 52),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        // Replace with purchase flow once available.
                        onPressed: item.purchased
                            ? null
                            : () => onBuy(
                                  item,
                                  outerContext,
                                  sheetContext: sheetContext,
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: item.purchased
                              ? Colors.grey.shade400
                              : AppStyles.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(item.purchased ? 'Owned' : 'Buy now'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ShopItem {
  const _ShopItem({
    required this.id,
    required this.name,
    required this.tone,
    required this.price,
    required this.imageUrl,
    required this.purchased,
    this.baseCharacterName,
  });

  final int id;
  final String name;
  final String tone;
  final int price;
  final String? imageUrl;
  final bool purchased;
  final String? baseCharacterName;

  _ShopItem copyWith({
    bool? purchased,
  }) {
    return _ShopItem(
      id: id,
      name: name,
      tone: tone,
      price: price,
      imageUrl: imageUrl,
      purchased: purchased ?? this.purchased,
      baseCharacterName: baseCharacterName,
    );
  }
}
