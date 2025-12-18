import 'package:flutter/material.dart';
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
  // Static catalog so we can group skins per character and keep the UI simple for now.
  final Map<String, List<_ShopItem>> _catalog = {
    'Character 1': const [
      _ShopItem(
        name: 'Obsidian Outfit 5',
        tone: 'Black variant',
        price: 450,
        assetPath: 'assets/Shop_temp/character1-black-outfit5.webp',
      ),
      _ShopItem(
        name: 'Obsidian Outfit 6',
        tone: 'Black variant',
        price: 520,
        assetPath: 'assets/Shop_temp/character1-black-outfit6.webp',
      ),
      _ShopItem(
        name: 'Ivory Outfit 5',
        tone: 'White variant',
        price: 460,
        assetPath: 'assets/Shop_temp/character1-white-outfit5.webp',
      ),
      _ShopItem(
        name: 'Ivory Outfit 6',
        tone: 'White variant',
        price: 540,
        assetPath: 'assets/Shop_temp/character1-white-outfit6.webp',
      ),
    ],
    'Character 2': const [
      _ShopItem(
        name: 'Crimson Outfit 5',
        tone: 'Black variant',
        price: 470,
        assetPath: 'assets/Shop_temp/character2-black-outfit5.webp',
      ),
      _ShopItem(
        name: 'Crimson Outfit 6',
        tone: 'Black variant',
        price: 540,
        assetPath: 'assets/Shop_temp/character2-black-outfit6.webp',
      ),
      _ShopItem(
        name: 'Pearl Outfit 5',
        tone: 'White variant',
        price: 480,
        assetPath: 'assets/Shop_temp/character2-white-outfit5.webp',
      ),
      _ShopItem(
        name: 'Pearl Outfit 6',
        tone: 'White variant',
        price: 550,
        assetPath: 'assets/Shop_temp/character2-white-outfit6.webp',
      ),
    ],
    'Character 3': const [
      _ShopItem(
        name: 'Slate Outfit 5',
        tone: 'Black variant',
        price: 430,
        assetPath: 'assets/Shop_temp/character3-black-outfit5.webp',
      ),
      _ShopItem(
        name: 'Slate Outfit 6',
        tone: 'Black variant',
        price: 510,
        assetPath: 'assets/Shop_temp/character3-black-outfit6.webp',
      ),
      _ShopItem(
        name: 'Frost Outfit 5',
        tone: 'White variant',
        price: 440,
        assetPath: 'assets/Shop_temp/character3-white-outfit5.webp',
      ),
      _ShopItem(
        name: 'Frost Outfit 6',
        tone: 'White variant',
        price: 520,
        assetPath: 'assets/Shop_temp/character3-white-outfit6.webp',
      ),
    ],
    'Character 4': const [
      _ShopItem(
        name: 'Shadow Outfit 5',
        tone: 'Black variant',
        price: 490,
        assetPath: 'assets/Shop_temp/character4-black-outfit5.webp',
      ),
      _ShopItem(
        name: 'Shadow Outfit 6',
        tone: 'Black variant',
        price: 560,
        assetPath: 'assets/Shop_temp/character4-black-outfit6.webp',
      ),
      _ShopItem(
        name: 'Light Outfit 5',
        tone: 'White variant',
        price: 500,
        assetPath: 'assets/Shop_temp/character4-white-outfit5.webp',
      ),
      _ShopItem(
        name: 'Light Outfit 6',
        tone: 'White variant',
        price: 570,
        assetPath: 'assets/Shop_temp/character4-white-outfit6.webp',
      ),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor,
      body: SafeArea(
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
                      style: AppStyles.titleBold.copyWith(fontSize: 30),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Skins curated per character so you can swap looks in the profile page.',
                      style: AppStyles.bodyRegular.copyWith(
                        fontSize: 16,
                        color: AppStyles.grey.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ..._catalog.entries.map(
              (entry) => SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                sliver: SliverToBoxAdapter(
                  child: _buildCharacterSection(entry.key, entry.value),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: 24),
            ),
          ],
        ),
      ),
    );
  }

  // Builds one section per character with a grid of purchasable skins.
  Widget _buildCharacterSection(String title, List<_ShopItem> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: AppStyles.titleBold.copyWith(fontSize: 24),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppStyles.grey.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${items.length} skins',
                style: AppStyles.bodyRegular.copyWith(
                  fontSize: 12,
                  color: AppStyles.grey.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) => _ShopCard(
            item: items[index],
            coins: widget.coins,
            onBuy: _handlePurchase,
          ),
        ),
      ],
    );
  }

  void _handlePurchase(
    _ShopItem item,
    BuildContext viewContext, {
    BuildContext? sheetContext,
  }) {
    if (widget.coins < item.price) {
      _showTimedDialog(
        viewContext,
        'Not enough coins to buy ${item.name}.',
      );
      return;
    }

    widget.onCoinsChange(widget.coins - item.price);
    ScaffoldMessenger.of(viewContext).showSnackBar(
      SnackBar(
        content: Text('${item.name} purchased!'),
        backgroundColor: Colors.green,
      ),
    );

    if (sheetContext != null) {
      Navigator.of(sheetContext).pop();
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
                    child: Image.asset(
                      item.assetPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                item.name,
                style: AppStyles.bodyBold.copyWith(fontSize: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                item.tone,
                style: AppStyles.bodyRegular.copyWith(
                  fontSize: 14,
                  color: AppStyles.grey.withOpacity(0.7),
                ),
              ),
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
                  onPressed: () => onBuy(item, outerContext),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyles.red,
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
                    child: const Text('Buy'),
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
                        child: Image.asset(
                          item.assetPath,
                          fit: BoxFit.contain,
                        ),
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
                        onPressed: () => onBuy(
                          item,
                          outerContext,
                          sheetContext: sheetContext,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppStyles.red,
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
                        child: const Text('Buy now'),
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
    required this.name,
    required this.tone,
    required this.price,
    required this.assetPath,
  });

  final String name;
  final String tone;
  final int price;
  final String assetPath;
}
