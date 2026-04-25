import 'package:flutter/material.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_entity.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/addon_entity.dart';
import 'package:ahgzly_pos/features/menu/domain/entities/item_variant_entity.dart';
import 'package:ahgzly_pos/core/utils/money_formatter.dart';
import 'package:ahgzly_pos/core/common/widgets/pos_dialog_components.dart';

class ModifiersDialog extends StatefulWidget {
  final ItemEntity item;
  const ModifiersDialog({super.key, required this.item});

  @override
  State<ModifiersDialog> createState() => _ModifiersDialogState();
}

class _ModifiersDialogState extends State<ModifiersDialog> {
  ItemVariantEntity? _selectedVariant;
  final List<AddonEntity> _selectedAddons = [];

  @override
  void initState() {
    super.initState();
    if (widget.item.variants.isNotEmpty) {
      _selectedVariant = widget.item.variants.first;
    }
  }

  void _submit() {
    Navigator.pop(context, {
      'variant': _selectedVariant,
      'addons': _selectedAddons,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        titlePadding: EdgeInsets.zero,
        // 🚀 DRY Applied
        title: PosDialogHeader(title: 'تخصيص: ${widget.item.name}', icon: Icons.room_preferences_rounded),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.item.variants.isNotEmpty) ...[
                  const Text('اختر المقاس:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...widget.item.variants.map((variant) => RadioListTile<ItemVariantEntity>(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(variant.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text('${variant.price.toFormattedMoney()} ج.م', style: const TextStyle(color: Colors.teal, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    value: variant,
                    groupValue: _selectedVariant,
                    activeColor: Colors.teal,
                    onChanged: (val) => setState(() => _selectedVariant = val),
                  )),
                  const Divider(height: 32),
                ],

                if (widget.item.availableAddons.isNotEmpty) ...[
                  const Text('إضافات إضافية:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...widget.item.availableAddons.map((addon) {
                    final isSelected = _selectedAddons.contains(addon);
                    return CheckboxListTile(
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(addon.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text('+ ${addon.price.toFormattedMoney()} ج.م', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      value: isSelected,
                      activeColor: Colors.teal,
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            _selectedAddons.add(addon);
                          } else {
                            _selectedAddons.remove(addon);
                          }
                        });
                      },
                    );
                  }),
                ],
              ],
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.all(24),
        actions: [
          // 🚀 DRY Applied
          PosDialogActions(
            onCancel: () => Navigator.pop(context), 
            onSubmit: _submit,
            submitText: 'إضافة للسلة',
          ),
        ],
      ),
    );
  }
}