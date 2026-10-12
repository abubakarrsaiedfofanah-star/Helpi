import 'package:flutter/material.dart';
import 'core/theme.dart';

class HelpiPage extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  const HelpiPage(
      {super.key,
      required this.child,
      this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 24)});
  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1240),
          child: Padding(padding: padding, child: child),
        ),
      );
}

class HelpiResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final int mobileColumns;
  final int tabletColumns;
  final int desktopColumns;
  const HelpiResponsiveGrid(
      {super.key,
      required this.children,
      this.mobileColumns = 1,
      this.tabletColumns = 2,
      this.desktopColumns = 3});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final cols = width >= 1100
          ? desktopColumns
          : (width >= 720 ? tabletColumns : mobileColumns);
      if (cols == 1) {
        return Column(
            children: children
                .map((c) => Padding(
                    padding: const EdgeInsets.only(bottom: 12), child: c))
                .toList());
      }
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.35,
        ),
        itemCount: children.length,
        itemBuilder: (_, i) => children[i],
      );
    });
  }
}

class HelpiLoadingButton extends StatelessWidget {
  final bool loading;
  final String label;
  final VoidCallback? onPressed;
  const HelpiLoadingButton(
      {super.key,
      required this.loading,
      required this.label,
      required this.onPressed});
  @override
  Widget build(BuildContext context) => FilledButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(label),
      );
}

class CaseCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onTap;
  const CaseCard({super.key, required this.item, this.onTap});
  @override
  Widget build(BuildContext c) {
    final goalMinor = item['goalMinor'];
    final raisedMinor = item['raisedMinor'];
    final goal = (goalMinor is num
            ? goalMinor.toDouble()
            : double.tryParse(goalMinor?.toString() ?? '') ?? 0) /
        100;
    final raised = (raisedMinor is num
            ? raisedMinor.toDouble()
            : double.tryParse(raisedMinor?.toString() ?? '') ?? 0) /
        100;
    final double p =
        goal > 0 ? (raised / goal).clamp(0.0, 1.0).toDouble() : 0.0;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: orange.withValues(alpha: .1), borderRadius: BorderRadius.circular(30)),
                child: Text((item['category'] ?? 'FINANCIAL HELP').toString().replaceAll('_', ' '), style: const TextStyle(color: orange, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
              const Spacer(),
            ]),
            const SizedBox(height: 10),
            Text(item['title'] ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(item['description'] ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.black54)),
            if (goal > 0) ...[
              const SizedBox(height: 10),
              ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                      value: p,
                      minHeight: 7.0,
                      color: orange,
                      backgroundColor: orange.withValues(alpha: .10))),
              const SizedBox(height: 6),
              Text(
                  '${item['currency'] ?? ''} ${raised.toStringAsFixed(0)} raised of ${goal.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w700)),
            ],
            const SizedBox(height: 10),
            Row(children: [
              const Icon(Icons.public, size: 16, color: orange),
              const SizedBox(width: 5),
              Expanded(
                  child: Text(
                      '${item['countryCode'] ?? ''}${item['city'] == null ? '' : ' • ${item['city']}'}',
                      overflow: TextOverflow.ellipsis)),
              const Icon(Icons.chevron_right),
            ]),
          ]),
        ),
      ),
    );
  }
}

class ActionTile extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final VoidCallback onTap;
  const ActionTile(
      {super.key,
      required this.icon,
      required this.title,
      required this.subtitle,
      required this.onTap});
  @override
  Widget build(BuildContext c) => Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              CircleAvatar(
                  backgroundColor: orange.withValues(alpha: .12),
                  foregroundColor: orange,
                  child: Icon(icon)),
              const SizedBox(width: 12),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(title,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 3),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.black54)),
                  ])),
              const Icon(Icons.chevron_right),
            ]),
          ),
        ),
      );
}

class HelpiErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const HelpiErrorState(
      {super.key, required this.message, required this.onRetry});
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.wifi_off_rounded, color: orange, size: 30),
            const SizedBox(height: 10),
            const Text('Something went wrong',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17)),
            const SizedBox(height: 5),
            Text(message, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
            OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'))
          ])));
}

class HelpiEmptyState extends StatelessWidget {
  final IconData icon;
  final String title, message;
  final VoidCallback? onAction;
  final String actionLabel;
  const HelpiEmptyState(
      {super.key,
      required this.icon,
      required this.title,
      required this.message,
      this.onAction,
      this.actionLabel = 'Get started'});
  @override
  Widget build(BuildContext context) => Card(
      child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(children: [
            CircleAvatar(
                radius: 25,
                backgroundColor: orange.withValues(alpha: .10),
                foregroundColor: orange,
                child: Icon(icon)),
            const SizedBox(height: 12),
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                textAlign: TextAlign.center),
            const SizedBox(height: 5),
            Text(message,
                style: const TextStyle(color: Colors.black54),
                textAlign: TextAlign.center),
            if (onAction != null) ...[
              const SizedBox(height: 12),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel))
            ]
          ])));
}
