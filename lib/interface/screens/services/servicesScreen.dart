import 'package:flutter/material.dart';
import 'package:ridlers/index.dart';

/// Landing page listing all banking services.
class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
          children: [
            const ServiceHeader(
              title: 'Services',
              subtitle: 'Do more with your bank accounts.',
              icon: Icons.widgets_rounded,
              color: AppTheme.primary,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.45,
                children: [
                  _ServiceTile(
                    icon: Icons.call_split_rounded,
                    label: 'Split payment',
                    caption: 'Split a bill',
                    color: AppTheme.periwinkle,
                    onTap: () => _open(context, const SplitPaymentScreen()),
                  ),
                  _ServiceTile(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Transfer',
                    caption: 'To bank or MoMo',
                    color: AppTheme.mint,
                    onTap: () => _open(context, const TransferScreen()),
                  ),
                  _ServiceTile(
                    icon: Icons.smartphone_rounded,
                    label: 'Buy airtime',
                    caption: 'Top up any number',
                    color: AppTheme.pink,
                    onTap: () => _open(context, const AirtimeScreen()),
                  ),
                  _ServiceTile(
                    icon: Icons.wifi_rounded,
                    label: 'Data bundle',
                    caption: 'Pick a bundle',
                    color: AppTheme.sky,
                    onTap: () => _open(context, const DataScreen()),
                  ),
                  _ServiceTile(
                    icon: Icons.request_page_rounded,
                    label: 'Request money',
                    caption: 'Ask & pay back',
                    color: AppTheme.coral,
                    onTap: () => _open(context, const RequestMoneyScreen()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Sticker(
                color: AppTheme.lemon,
                radius: 18,
                dy: 3,
                padding: EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: AppTheme.ink, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'More services are on the way. Suggestions? Tap here.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.ink),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String caption;
  final Color color;
  final VoidCallback onTap;

  const _ServiceTile({
    required this.icon,
    required this.label,
    required this.caption,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return StickerButton(
      onTap: onTap,
      color: color,
      radius: 22,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: AppTheme.outline, width: 2.5),
            ),
            child: Icon(icon, color: AppTheme.ink, size: 22),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.ink),
              ),
              const SizedBox(height: 1),
              Text(
                caption,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.inkSoft),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
