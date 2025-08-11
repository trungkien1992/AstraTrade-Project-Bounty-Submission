import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;

/// Enhanced gamified trade widget with TikTok-generation appeal
/// Features: Haptic feedback, animations, streak bonuses, quick actions
class GamifiedTradeWidget extends StatefulWidget {
  final Function(double amount, String direction, String symbol) onTradeExecute;
  final List<String> availableSymbols;
  final List<double> availableAmounts;
  final bool isDemo;

  const GamifiedTradeWidget({
    super.key,
    required this.onTradeExecute,
    required this.availableSymbols,
    required this.availableAmounts,
    this.isDemo = false,
  });

  @override
  State<GamifiedTradeWidget> createState() => _GamifiedTradeWidgetState();
}

class _GamifiedTradeWidgetState extends State<GamifiedTradeWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _sparkleController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _sparkleAnimation;

  String _selectedSymbol = 'ETH-USD';
  double _selectedAmount = 25.0;
  String _selectedDirection = 'long';
  bool _isExecuting = false;

  @override
  void initState() {
    super.initState();
    
    if (widget.availableSymbols.isNotEmpty) {
      _selectedSymbol = widget.availableSymbols.first;
    }
    if (widget.availableAmounts.isNotEmpty) {
      _selectedAmount = widget.availableAmounts.first;
    }

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeOutBack),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  void _triggerHaptic() {
    HapticFeedback.mediumImpact();
  }

  void _executeTradeWithAnimation() async {
    if (_isExecuting) return;

    setState(() => _isExecuting = true);
    _sparkleController.forward();
    HapticFeedback.heavyImpact();

    // Add dramatic pause for suspense
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      await widget.onTradeExecute(_selectedAmount, _selectedDirection, _selectedSymbol);
      
      // Success celebration
      HapticFeedback.heavyImpact();
      _sparkleController.reset();
      _sparkleController.forward();
    } catch (e) {
      // Handle error
      HapticFeedback.lightImpact();
    } finally {
      setState(() => _isExecuting = false);
      _sparkleController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1F3A),
            const Color(0xFF2D1B69),
            const Color(0xFF0A0E27),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.cyan.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildQuickActions(),
          const SizedBox(height: 20),
          _buildSymbolSelector(),
          const SizedBox(height: 16),
          _buildAmountSelector(),
          const SizedBox(height: 20),
          _buildDirectionSelector(),
          const SizedBox(height: 24),
          _buildExecuteButton(),
          if (widget.isDemo) _buildDemoIndicator(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.cyan, Colors.blue]),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.rocket_launch, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🚀 Quick Trade',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Fast • Fun • Profitable',
                style: TextStyle(
                  color: Colors.cyan,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        if (!widget.isDemo)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.5)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, color: Colors.green, size: 16),
                SizedBox(width: 4),
                Text(
                  'REAL',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionButton(
            '⚡ Quick Long',
            Colors.green,
            () {
              _selectedDirection = 'long';
              _selectedAmount = 25.0;
              _triggerHaptic();
              _executeTradeWithAnimation();
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickActionButton(
            '🔥 Quick Short',
            Colors.red,
            () {
              _selectedDirection = 'short';
              _selectedAmount = 25.0;
              _triggerHaptic();
              _executeTradeWithAnimation();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(String text, Color color, VoidCallback onPressed) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _isExecuting ? 0.95 : 1.0,
          child: ElevatedButton(
            onPressed: _isExecuting ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color.withOpacity(0.2),
              foregroundColor: color,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: color.withOpacity(0.5)),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSymbolSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💎 Asset',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.availableSymbols.length,
            itemBuilder: (context, index) {
              final symbol = widget.availableSymbols[index];
              final isSelected = symbol == _selectedSymbol;
              
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedSymbol = symbol);
                  _triggerHaptic();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(colors: [Colors.cyan, Colors.blue])
                        : null,
                    color: isSelected ? null : Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? Colors.cyan : Colors.white24,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      symbol.replaceAll('-USD', ''),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAmountSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '💰 Amount (\$)',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.availableAmounts.map((amount) {
            final isSelected = amount == _selectedAmount;
            
            return GestureDetector(
              onTap: () {
                setState(() => _selectedAmount = amount);
                _triggerHaptic();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(colors: [Colors.purple, Colors.pink])
                      : null,
                  color: isSelected ? null : Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.purple : Colors.white24,
                    width: 2,
                  ),
                ),
                child: Text(
                  '\$${amount.toInt()}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDirectionSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedDirection = 'long');
              _triggerHaptic();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: _selectedDirection == 'long'
                    ? const LinearGradient(colors: [Colors.green, Colors.lightGreen])
                    : null,
                color: _selectedDirection == 'long' ? null : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedDirection == 'long' ? Colors.green : Colors.white24,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_up,
                    color: _selectedDirection == 'long' ? Colors.white : Colors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LONG 📈',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: _selectedDirection == 'long' ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedDirection = 'short');
              _triggerHaptic();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                gradient: _selectedDirection == 'short'
                    ? const LinearGradient(colors: [Colors.red, Colors.orange])
                    : null,
                color: _selectedDirection == 'short' ? null : Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedDirection == 'short' ? Colors.red : Colors.white24,
                  width: 2,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_down,
                    color: _selectedDirection == 'short' ? Colors.white : Colors.red,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'SHORT 📉',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: _selectedDirection == 'short' ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExecuteButton() {
    return AnimatedBuilder(
      animation: _sparkleAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Sparkle effects
            if (_sparkleAnimation.value > 0)
              ...List.generate(8, (index) {
                final angle = (index * 45) * math.pi / 180;
                final distance = 60 * _sparkleAnimation.value;
                return Positioned(
                  left: math.cos(angle) * distance,
                  top: math.sin(angle) * distance,
                  child: Opacity(
                    opacity: 1.0 - _sparkleAnimation.value,
                    child: Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ),
                );
              }),
            
            // Main button
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isExecuting ? 0.95 : _pulseAnimation.value,
                  child: Container(
                    width: double.infinity,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _isExecuting
                            ? [Colors.grey, Colors.grey.shade700]
                            : [Colors.amber, Colors.orange],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _isExecuting ? null : _executeTradeWithAnimation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isExecuting
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Executing Trade...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.flash_on, color: Colors.white, size: 24),
                                const SizedBox(width: 8),
                                Text(
                                  'EXECUTE TRADE',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.flash_on, color: Colors.white, size: 24),
                              ],
                            ),
                    ),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildDemoIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.science, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          Text(
            'Demo Mode - Practice Trading',
            style: TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}