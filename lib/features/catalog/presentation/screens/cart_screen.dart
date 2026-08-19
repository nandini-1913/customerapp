import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/state/cart_controller.dart';
import '../../../../core/state/quotation_controller.dart';
import '../../../../core/state/session_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_icons.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Cart'),
        actions: [
          if (!cart.isEmpty)
            TextButton(
              onPressed: cart.clear,
              child: const Text('Clear'),
            ),
        ],
      ),
      body: cart.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.space6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      size: 48,
                      color: AppColors.outline,
                    ),
                    const SizedBox(height: AppSpacing.space4),
                    Text('Your cart is empty', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.space2),
                    Text(
                      'Add construction materials to generate a quotation.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.space4),
              itemCount: cart.items.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.space3),
              itemBuilder: (context, index) {
                final item = cart.items[index];
                final variant = item.variant;
                return Material(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.space3),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: AppSpacing.space12,
                          height: AppSpacing.space12,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            appIcon(variant.icon),
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.space3),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                variant.brandName,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                variant.productName,
                                style: theme.textTheme.titleSmall,
                              ),
                              Text(
                                variant.priceWithUnit,
                                style: theme.textTheme.bodySmall,
                              ),
                              const SizedBox(height: AppSpacing.space2),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () =>
                                        cart.decrease(variant.id),
                                    icon: const Icon(Icons.remove_circle_outline),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: theme.textTheme.titleSmall,
                                  ),
                                  IconButton(
                                    onPressed: () =>
                                        cart.increase(variant.id),
                                    icon: const Icon(Icons.add_circle_outline),
                                    visualDensity: VisualDensity.compact,
                                  ),
                                  const Spacer(),
                                  Text(
                                    '₹${item.totalPrice.toStringAsFixed(0)}',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => cart.remove(variant.id),
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.space4),
                color: AppColors.surface,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Text('Subtotal', style: theme.textTheme.bodyMedium),
                        const Spacer(),
                        Text(
                          '₹${cart.subtotal.toStringAsFixed(0)}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space1),
                    Row(
                      children: [
                        Text('Items', style: theme.textTheme.bodySmall),
                        const Spacer(),
                        Text(
                          '${cart.totalQuantity}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.space3),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pushNamed(AppRoutes.quotationReview);
                        },
                        child: const Text('Generate Quotation'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class QuotationReviewScreen extends StatefulWidget {
  const QuotationReviewScreen({super.key});

  @override
  State<QuotationReviewScreen> createState() => _QuotationReviewScreenState();
}

class _QuotationReviewScreenState extends State<QuotationReviewScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _notes = TextEditingController();
  var _seeded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_seeded) return;
    final user = context.read<SessionController>().user;
    _name.text = user.name;
    _phone.text = user.phone ?? '';
    _seeded = true;
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text('Quotation Review'),
      ),
      body: cart.isEmpty
          ? const Center(child: Text('Add materials to cart first.'))
          : ListView(
              padding: const EdgeInsets.all(AppSpacing.space4),
              children: [
                Text('Materials', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.space3),
                ...cart.items.map(
                  (item) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(item.variant.productName),
                    subtitle: Text(
                      '${item.variant.brandName} · ${item.quantity} ${item.variant.unit}',
                    ),
                    trailing: Text(
                      '₹${item.totalPrice.toStringAsFixed(0)}',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const Divider(),
                Row(
                  children: [
                    Text('Estimated Total', style: theme.textTheme.titleSmall),
                    const Spacer(),
                    Text(
                      '₹${cart.estimatedTotal.toStringAsFixed(0)}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.space5),
                Text('Customer information', style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.space3),
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: AppSpacing.space3),
                TextField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: AppSpacing.space3),
                TextField(
                  controller: _notes,
                  decoration:
                      const InputDecoration(labelText: 'Notes (optional)'),
                  maxLines: 3,
                ),
                const SizedBox(height: AppSpacing.space6),
                FilledButton(
                  onPressed: () {
                    final user = context.read<SessionController>().user;
                    context.read<QuotationController>().createFromCart(
                          items: cart.items,
                          requesterId: user.id,
                          customerName: _name.text.trim().isEmpty
                              ? user.name
                              : _name.text.trim(),
                          customerPhone: _phone.text.trim(),
                          notes: _notes.text.trim(),
                        );
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Quotation enquiry saved locally (pending — no rewards yet)',
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Submit Enquiry'),
                ),
              ],
            ),
    );
  }
}
