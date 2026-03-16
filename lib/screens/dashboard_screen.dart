import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/category_pie_chart.dart';
import 'expense_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExpenseProvider>(
      builder: (context, provider, child) {
        final categoryColorMap = <String, Color>{};
        for (final cat in provider.categories) {
          categoryColorMap[cat.name] = Color(cat.color);
        }

        final recentExpenses = provider.expenses.take(5).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary Cards
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 1.1,
                children: [
                  SummaryCard(
                    title: 'Total Items',
                    value: '${provider.totalItems}',
                    icon: Icons.receipt_long,
                    color: const Color(0xFF6C63FF),
                  ),
                  SummaryCard(
                    title: 'Total Expenses',
                    value: '฿${NumberFormat('#,##0').format(provider.totalExpenses)}',
                    icon: Icons.account_balance_wallet,
                    color: const Color(0xFFFF6B6B),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              SummaryCard(
                title: 'Most Expensive Category',
                value: provider.mostExpensiveCategory,
                icon: Icons.trending_up,
                color: const Color(0xFF4ECDC4),
              ),

              const SizedBox(height: 28),

              // Pie Chart Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Expenses by Category',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    CategoryPieChart(
                      data: provider.expensesByCategory,
                      colorMap: categoryColorMap,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Recent Expenses
              const Text(
                'Recent Expenses',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (recentExpenses.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade300),
                        const SizedBox(height: 12),
                        Text(
                          'No expenses yet',
                          style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...recentExpenses.map((expense) {
                  final cat = provider.categoryMap[expense.categoryId];
                  final catColor = Color(cat?.color ?? 0xFF9E9E9E);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: catColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          IconData(cat?.iconCodePoint ?? Icons.category.codePoint, fontFamily: 'MaterialIcons'),
                          color: catColor,
                          size: 22,
                        ),
                      ),
                      title: Text(expense.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(
                        DateFormat('dd MMM yyyy').format(expense.date),
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                      trailing: Text(
                        '฿${NumberFormat('#,##0.00').format(expense.amount)}',
                        style: TextStyle(fontWeight: FontWeight.bold, color: catColor, fontSize: 14),
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ExpenseDetailScreen(expense: expense),
                          ),
                        );
                      },
                    ),
                  );
                }),
            ],
          ),
        );
      },
    );
  }
}
