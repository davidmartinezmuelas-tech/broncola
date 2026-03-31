import 'package:flutter/material.dart';
import '../models/active_rule.dart';

class ActiveRulesWidget extends StatelessWidget {
  final List<ActiveRule> rules;

  const ActiveRulesWidget({super.key, required this.rules});

  void _showRuleDetail(BuildContext context, ActiveRule rule) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Text('📜 ', style: TextStyle(fontSize: 18)),
            Text('Regla activa',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              rule.text,
              style: const TextStyle(
                  color: Colors.white, fontSize: 16, height: 1.4),
            ),
            const SizedBox(height: 10),
            Text(
              'Creada por ${rule.createdBy}',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar',
                style: TextStyle(color: Color(0xFFF57C00))),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text('📜', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 6),
              const Text(
                'REGLAS ACTIVAS',
                style: TextStyle(
                  color: Color(0xFFF57C00),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF57C00),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${rules.length}/4',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 34,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: rules.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final rule = rules[i];
              return GestureDetector(
                onTap: () => _showRuleDetail(context, rule),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A1500),
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: const Color(0xFFF57C00), width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        rule.text.length > 22
                            ? '${rule.text.substring(0, 22)}…'
                            : rule.text,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        rule.createdBy.split(' ').first,
                        style: const TextStyle(
                            color: Color(0xFFF57C00),
                            fontSize: 11,
                            fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
