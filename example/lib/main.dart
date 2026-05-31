import 'package:flutter/material.dart';
import 'package:smart_bottom_sheet/smart_bottom_sheet.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return SheetTheme(
      config: const SheetConfig(
        handleStyle: HandleStyle.pill,
        backdrop: SheetBackdrop(
          style: BackdropStyle.frosted,
          blurStrength: 10,
          opacity: 0.2,
        ),
      ),
      child: MaterialApp(
        title: 'Smart Bottom Sheet Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _lastEvent = 'No event yet';

  void _updateEvent(String event) {
    setState(() => _lastEvent = event);
  }

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
          // event log card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.event_note_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _lastEvent,
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          _SectionTitle('Sheet Types'),
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

          _SectionTitle('Advanced'),
          _DemoTile(
            icon: Icons.table_rows_rounded,
            title: 'Side Sheet — Right',
            subtitle: 'Slides in from right',
            color: Colors.indigo,
            onTap: () => _showSideSheet(context, SideSheetDirection.right),
          ),
          _DemoTile(
            icon: Icons.table_rows_rounded,
            title: 'Side Sheet — Left',
            subtitle: 'Slides in from left',
            color: Colors.deepPurple,
            onTap: () => _showSideSheet(context, SideSheetDirection.left),
          ),
          _DemoTile(
            icon: Icons.stacked_bar_chart_rounded,
            title: 'Stacked Sheets',
            subtitle: 'Sheet on top of sheet',
            color: Colors.cyan,
            onTap: () => _showStackedSheet(context),
          ),

          _SectionTitle('Handle Styles'),
          _DemoTile(
            icon: Icons.drag_handle_rounded,
            title: 'Pill Handle',
            subtitle: 'Wider pill-shaped handle',
            color: Colors.green,
            onTap: () => _showWithHandle(context, HandleStyle.pill),
          ),
          _DemoTile(
            icon: Icons.drag_handle_rounded,
            title: 'Pulse Handle',
            subtitle: 'Animated pulsing handle',
            color: Colors.pink,
            onTap: () => _showWithHandle(context, HandleStyle.pulse),
          ),
          _DemoTile(
            icon: Icons.drag_handle_rounded,
            title: 'Arrow Handle',
            subtitle: 'Arrow indicator handle',
            color: Colors.brown,
            onTap: () => _showWithHandle(context, HandleStyle.arrow),
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
          onTap: () => _updateEvent('Action: Share tapped'),
        ),
        SheetAction(
          icon: Icons.edit_rounded,
          label: 'Rename',
          onTap: () => _updateEvent('Action: Rename tapped'),
        ),
        SheetAction(
          icon: Icons.copy_rounded,
          label: 'Duplicate',
          onTap: () => _updateEvent('Action: Duplicate tapped'),
        ),
        SheetAction(
          icon: Icons.delete_rounded,
          label: 'Delete',
          isDestructive: true,
          onTap: () => _updateEvent('Action: Delete tapped'),
        ),
      ],
    );
  }

  void _showSnapSheet(BuildContext context) {
    final controller = SheetController(
      onSnap: (snap) => _updateEvent('Snap: $snap'),
      onOpen: () => _updateEvent('Snap Sheet: Opened to full'),
      onClose: () => _updateEvent('Snap Sheet: Closed'),
    );

    SnapSheet.show(
      context,
      initialSnap: SnapPoint.half,
      controller: controller,
      onDismiss: () => _updateEvent('Snap Sheet: Dismissed'),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 10,
        itemBuilder: (_, i) => ListTile(
          leading: CircleAvatar(child: Text('${i + 1}')),
          title: Text('Place ${i + 1}'),
          subtitle: Text('${((i + 1) * 0.3).toStringAsFixed(1)} km away'),
          trailing: Text('${(4.0 + (i % 5) * 0.1).toStringAsFixed(1)} ★'),
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
        SheetField.multiline('Delivery Notes',
            hint: 'Any special instructions?'),
      ],
      onSubmit: (data) =>
          _updateEvent('Form: Saved — ${data['Full Name']}'),
    );
  }

  void _showConfirmSheet(BuildContext context) {
    ConfirmSheet.show(
      context,
      icon: Icons.delete_rounded,
      iconColor: SheetColor.danger,
      title: 'Delete this item?',
      message:
      'This action cannot be undone. The file will be permanently removed.',
      confirmLabel: 'Yes, Delete',
      cancelLabel: 'Keep it',
      isDangerous: true,
      onConfirm: () => _updateEvent('Confirm: Item deleted!'),
      onCancel: () => _updateEvent('Confirm: Cancelled'),
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
      onComplete: () => _updateEvent('Stepper: Order placed! 🎉'),
      onCancel: () => _updateEvent('Stepper: Order cancelled'),
    );
  }

  void _showRatingSheet(BuildContext context) {
    RatingSheet.show(
      context,
      title: 'How was your order?',
      subtitle: 'Burger King · Zomato Gold',
      showComment: true,
      onSubmit: (stars, comment) => _updateEvent(
        'Rating: $stars stars${comment != null ? ' — "$comment"' : ''}',
      ),
    );
  }

  void _showSideSheet(BuildContext context, SideSheetDirection direction) {
    SideSheet.show(
      context,
      title: 'Filters',
      subtitle: 'Refine your search',
      direction: direction,
      onClose: () => _updateEvent('Side Sheet: Closed'),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _FilterSection('Category', ['All', 'Food', 'Cafés', 'Parks']),
          _FilterSection('Distance', ['500m', '1km', '5km', '10km']),
          _FilterSection('Rating', ['4.5+', '4.0+', '3.5+']),
        ],
      ),
    );
  }

  void _showStackedSheet(BuildContext context) {
    SnapSheet.show(
      context,
      initialSnap: SnapPoint.half,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 5,
        itemBuilder: (ctx, i) => ListTile(
          leading: const Icon(Icons.place_rounded),
          title: Text('Place ${i + 1}'),
          subtitle: Text('Tap to see details'),
          onTap: () {
            SheetStackManager.push(
              ctx,
              title: 'Place ${i + 1} Details',
              subtitle: '0.${i + 1} km away · 4.${i + 1} ★',
              onClose: () => _updateEvent('Stack: Detail sheet closed'),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('About Place ${i + 1}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    const SizedBox(height: 8),
                    Text(
                      'This is a detailed view of Place ${i + 1}. '
                          'Stacked sheets allow you to open a new sheet '
                          'on top of an existing one.',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            );
            _updateEvent('Stack: Detail sheet opened');
          },
        ),
      ),
    );
  }

  void _showWithHandle(BuildContext context, HandleStyle style) {
    ActionMenuSheet.show(
      context,
      title: '${style.name} handle',
      config: SheetConfig(
        handleStyle: style,
        handleColor: Theme.of(context).colorScheme.primary,
      ),
      actions: [
        SheetAction(
          icon: Icons.check_circle_rounded,
          label: 'Looks great!',
          onTap: () => _updateEvent('Handle: ${style.name} selected'),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
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
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 15),
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
              child: Text(name,
                  style: const TextStyle(fontSize: 14))),
          Text(price,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 14)),
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
      leading: Icon(icon,
          color: Theme.of(context).colorScheme.primary),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 18),
    );
  }
}

class _FilterSection extends StatefulWidget {
  final String title;
  final List<String> options;
  const _FilterSection(this.title, this.options);

  @override
  State<_FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<_FilterSection> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.title,
          style: const TextStyle(
              fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: List.generate(widget.options.length, (i) {
            return ChoiceChip(
              label: Text(widget.options[i]),
              selected: _selected == i,
              onSelected: (_) => setState(() => _selected = i),
            );
          }),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}