import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const List<_FaqItem> _faqItems = [
    _FaqItem(
      question: 'How do I book a matatu?',
      answer: 'To book a matatu, go to the home screen and search for your route. '
          'Select a SACCO operating on that route, view available vehicles in the queue, '
          'and tap "Book" to reserve your seat. You can pay using M-Pesa or your wallet balance.',
    ),
    _FaqItem(
      question: 'How does the queue system work?',
      answer: 'The queue system shows you the order of vehicles waiting to depart. '
          'Each vehicle fills up with passengers before departing. You can see the position '
          'of your vehicle, estimated wait time, and available seats in real-time.',
    ),
    _FaqItem(
      question: 'What payment methods are accepted?',
      answer: 'We accept M-Pesa, wallet balance, and cash (at selected routes). '
          'M-Pesa is the recommended payment method for a seamless cashless experience. '
          'You can also top up your Komiut wallet for faster checkout.',
    ),
    _FaqItem(
      question: 'How do I top up my wallet?',
      answer: 'Go to your wallet section from the home screen and tap "Top Up". '
          'Enter the amount you want to add and select M-Pesa as the payment method. '
          'You\'ll receive an STK push to complete the payment.',
    ),
    _FaqItem(
      question: 'Can I cancel my booking?',
      answer: 'Yes, you can cancel your booking before the vehicle departs. '
          'Go to your active tickets, select the booking you want to cancel, and tap "Cancel". '
          'Refunds are processed to your wallet within 24 hours.',
    ),
    _FaqItem(
      question: 'How do I earn loyalty points?',
      answer: 'You earn loyalty points on every trip you take with Komiut. '
          'Points are awarded based on the fare amount. You can redeem points for free trips, '
          'discounts, or other rewards in the Rewards section.',
    ),
    _FaqItem(
      question: 'What if my vehicle is delayed?',
      answer: 'We provide real-time updates on vehicle status. If there\'s a significant delay, '
          'you\'ll receive a notification. You can choose to wait or cancel your booking for a full refund.',
    ),
    _FaqItem(
      question: 'How do I report an issue during my trip?',
      answer: 'During an active trip, you can tap the "Report Issue" button. '
          'This allows you to report problems like safety concerns, driver behavior, or vehicle conditions. '
          'Our support team will follow up within 24 hours.',
    ),
    _FaqItem(
      question: 'Is my payment information secure?',
      answer: 'Yes, we use industry-standard encryption to protect your payment information. '
          'We don\'t store your M-Pesa PIN or sensitive financial data on our servers. '
          'All transactions are processed through secure payment gateways.',
    ),
    _FaqItem(
      question: 'How do I contact support?',
      answer: 'You can reach our support team through the Help & Support section in Settings. '
          'We offer live chat, email support (support@komiut.com), and phone support (+254 700 000 000). '
          'Our team is available 24/7.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FAQs'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _faqItems.length,
        itemBuilder: (context, index) {
          return _FaqTile(item: _faqItems[index]);
        },
      ),
    );
  }
}

class _FaqItem {
  const _FaqItem({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;
}

class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.item});

  final _FaqItem item;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.item.question,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  AnimatedRotation(
                    turns: _isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: isDark ? Colors.grey[500] : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                widget.item.answer,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.6,
                  color: isDark ? Colors.grey[400] : AppColors.textSecondary,
                ),
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }
}
