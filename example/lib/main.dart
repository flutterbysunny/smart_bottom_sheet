import 'package:flutter/material.dart';
import 'package:smart_bottom_sheet/smart_bottom_sheet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Bottom Sheet Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Bottom Sheet'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SectionTitle('Sheets'),
          _DemoTile(
            icon: Icons.list_alt_rounded,
            title: 'Action Menu Sheet',
            subtitle: 'Quick actions list with icons',
            color: Colors.blue,
            onTap: () => _showActionMenu(context),
          ),
          _DemoTile(
            icon: Icons.anchor_rounded,
            title: 'Snap Sheet',
            subtitle: '3 snap points with physics',
            color: Colors.purple,
            onTap: () => _showSnapSheet(context),
          ),
          _DemoTile(
            icon: Icons.edit_note_rounded,
            title: 'Form Sheet',
            subtitle: 'Keyboard-aware inline form',
            color: Colors.teal,
            onTap: () => _showFormSheet(context),
          ),
          _DemoTile(
            icon: Icons.warning_amber_rounded,
            title: 'Confirm Sheet',
            subtitle: 'Destructive action confirmation',
            color: Colors.red,
            onTap: () => _showConfirmSheet(context),
          ),
          _DemoTile(
            icon: Icons.stairs_rounded,
            title: 'Stepper Sheet',
            subtitle: 'Multi-step flow in one sheet',
            color: Colors.orange,
            onTap: () => _showStepperSheet(context),
          ),
          _DemoTile(
            icon: Icons.star_rounded,
            title: 'Rating Sheet',
            subtitle: 'Star rating with comment',
            color: Colors.amber,
            onTap: () => _showRatingSheet(context),
          ),
        ],
      ),
    );
  }

  void _showActionMenu(BuildContext context) {
    ActionMenuSheet.show(
      context,
      title: 'File Options',
      subtitle: 'document_final_v3.pdf',
      actions: [
        SheetAction(
          icon: Icons.share_rounded,
          label: 'Share',
          onTap: () => _snack(context, 'Shared!'),
        ),
        SheetAction(
          icon: Icons.edit_rounded,
          label: 'Rename',
          onTap: () => _snack(context, 'Rename tapped'),
        ),
        SheetAction(
          icon: Icons.copy_rounded,
          label: 'Duplicate',
          onTap: () => _snack(context, 'Duplicated!'),
        ),
        SheetAction(
          icon: Icons.delete_rounded,
          label: 'Delete',
          isDestructive: true,
          onTap: () => _snack(context, 'Deleted!'),
        ),
      ],
    );
  }

  void _showSnapSheet(BuildContext context) {
    SnapSheet.show(
      context,
      initialSnap: SnapPoint.half,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 10,
        itemBuilder: (_, i) => ListTile(
          leading: CircleAvatar(child: Text('${i + 1}')),
          title: Text('Place ${i + 1}'),
          subtitle: Text('${(i + 1) * 0.3} km away'),
          trailing: Text('${4.0 + (i % 5) * 0.1} ★'),
        ),
      ),
    );
  }

  void _showFormSheet(BuildContext context) {
    FormSheet.show(
      context,
      title: 'Add Delivery Address',
      subtitle: 'Fill in your details below',
      submitLabel: 'Save Address',
      fields: [
        SheetField.text('Full Name', isRequired: true),
        SheetField.phone('Phone Number', isRequired: true),
        SheetField.text('Street Address', isRequired: true),
        SheetField.text('City & Pincode'),
        SheetField.multiline('Delivery Notes', hint: 'Any special instructions?'),
      ],
      onSubmit: (data) => _snack(context, 'Address saved: ${data['Full Name']}'),
    );
  }

  void _showConfirmSheet(BuildContext context) {
    ConfirmSheet.show(
      context,
      icon: Icons.delete_rounded,
      iconColor: SheetColor.danger,
      title: 'Delete this item?',
      message: 'This action cannot be undone. The file will be permanently removed from your storage.',
      confirmLabel: 'Yes, Delete',
      cancelLabel: 'Keep it',
      isDangerous: true,
      onConfirm: () => _snack(context, 'Item deleted!'),
      onCancel: () => _snack(context, 'Cancelled'),
    );
  }

  void _showStepperSheet(BuildContext context) {
    StepperSheet.show(
      context,
      title: 'Place Order',
      steps: [
        SheetStep(
          title: 'Bag',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CartItem('Burger King Whopper', '₹249'),
              _CartItem('Large Fries', '₹99'),
              _CartItem('Coke Zero', '₹69'),
            ],
          ),
        ),
        SheetStep(
          title: 'Address',
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Delivery Address',
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
        SheetStep(
          title: 'Payment',
          child: Column(
            children: [
              _PaymentOption(Icons.credit_card, 'Credit / Debit Card'),
              _PaymentOption(Icons.account_balance_wallet, 'UPI'),
              _PaymentOption(Icons.money, 'Cash on Delivery'),
            ],
          ),
        ),
      ],
      onComplete: () => _snack(context, 'Order placed! 🎉'),
      onCancel: () => _snack(context, 'Order cancelled'),
    );
  }

  void _showRatingSheet(BuildContext context) {
    RatingSheet.show(
      context,
      title: 'How was your order?',
      subtitle: 'Burger King · Zomato Gold',
      showComment: true,
      onSubmit: (stars, comment) => _snack(
        context,
        'Rated $stars stars${comment != null ? ' — "$comment"' : ''}',
      ),
    );
  }

  void _snack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          color: Theme.of(context).colorScheme.outline,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _DemoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _DemoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).dividerColor),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Theme.of(context).colorScheme.outline,
        ),
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  final String name;
  final String price;
  const _CartItem(this.name, this.price);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(name, style: const TextStyle(fontSize: 14)),
          ),
          Text(
            price,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String label;
  const _PaymentOption(this.icon, this.label);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 18),
    );
  }
}