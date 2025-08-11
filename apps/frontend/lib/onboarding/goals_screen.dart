
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';
import 'notification_permission.dart';

class GoalsScreen extends ConsumerStatefulWidget {
  const GoalsScreen({super.key});

  @override
  ConsumerState<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends ConsumerState<GoalsScreen> {
  List<String> _selectedGoals = [];

  final List<Map<String, dynamic>> _goals = [
    {
      'title': 'Learn trading fundamentals',
      'subtitle': 'Master the basics',
      'icon': Icons.school,
      'color': Colors.green,
      'value': 'learn_fundamentals',
    },
    {
      'title': 'Build trading strategies',
      'subtitle': 'Develop winning approaches',
      'icon': Icons.psychology,
      'color': Colors.purple,
      'value': 'build_strategies',
    },
    {
      'title': 'Test new strategies',
      'subtitle': 'Validate ideas safely',
      'icon': Icons.science,
      'color': Colors.blue,
      'value': 'test_strategies',
    },
    {
      'title': 'Improve risk management',
      'subtitle': 'Protect your capital',
      'icon': Icons.security,
      'color': Colors.orange,
      'value': 'risk_management',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Your Goals'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress indicator
              LinearProgressIndicator(
                value: 0.75,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              ),
              const SizedBox(height: 20),

              const Text(
                'What do you want to achieve?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select up to 3 goals that best describe your trading objectives.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),

              // Goals Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _goals.length,
                  itemBuilder: (context, index) {
                  final goal = _goals[index];
                  final isSelected = _selectedGoals.contains(goal['value']);
                  
                  return GestureDetector(
                    onTap: () => _toggleGoal(goal['value']),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? Colors.blue[600]! : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected 
                                ? Colors.blue.withOpacity(0.1) 
                                : Colors.grey.withOpacity(0.05),
                            blurRadius: isSelected ? 6 : 3,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? goal['color'].withOpacity(0.15)
                                  : goal['color'].withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              goal['icon'],
                              color: goal['color'],
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            goal['title'],
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.blue[700] : Colors.black87,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            goal['subtitle'],
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (isSelected) ...[
                            const SizedBox(height: 6),
                            Icon(
                              Icons.check_circle,
                              color: Colors.blue[600],
                              size: 18,
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Selection Counter and Continue Button
            Column(
              children: [
                if (_selectedGoals.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Text(
                      '${_selectedGoals.length}/3 goals selected',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),

                // Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _selectedGoals.isNotEmpty ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[600],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
        ),
      ),
    );
  }

  void _toggleGoal(String goalValue) {
    setState(() {
      if (_selectedGoals.contains(goalValue)) {
        _selectedGoals.remove(goalValue);
      } else if (_selectedGoals.length < 3) {
        _selectedGoals.add(goalValue);
      }
    });
  }

  void _handleNext() {
    ref.read(onboardingProvider.notifier).setGoals(_selectedGoals);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NotificationPermissionScreen(),
      ),
    );
  }
}
