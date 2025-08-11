import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math' as math;
import '../models/simple_trade.dart';

/// TikTok-style feed for trade results and social sharing
/// Features vertical scrolling, quick reactions, share buttons
class TikTokStyleFeed extends StatefulWidget {
  final List<SimpleTrade> trades;
  final Function(SimpleTrade)? onLike;
  final Function(SimpleTrade)? onShare;
  final Function(SimpleTrade)? onComment;

  const TikTokStyleFeed({
    super.key,
    required this.trades,
    this.onLike,
    this.onShare,
    this.onComment,
  });

  @override
  State<TikTokStyleFeed> createState() => _TikTokStyleFeedState();
}

class _TikTokStyleFeedState extends State<TikTokStyleFeed>
    with TickerProviderStateMixin {
  PageController _pageController = PageController();
  int _currentIndex = 0;
  final Map<String, AnimationController> _heartControllers = {};
  final Map<String, AnimationController> _moneyControllers = {};

  @override
  void initState() {
    super.initState();
    // Initialize animation controllers for each trade
    for (final trade in widget.trades) {
      _heartControllers[trade.id] = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
      );
      _moneyControllers[trade.id] = AnimationController(
        duration: const Duration(milliseconds: 800),
        vsync: this,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (final controller in _heartControllers.values) {
      controller.dispose();
    }
    for (final controller in _moneyControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() => _currentIndex = index);
    HapticFeedback.selectionClick();
  }

  void _handleLike(SimpleTrade trade) {
    HapticFeedback.heavyImpact();
    _heartControllers[trade.id]?.forward().then((_) {
      _heartControllers[trade.id]?.reverse();
    });
    widget.onLike?.call(trade);
  }

  void _handleShare(SimpleTrade trade) {
    HapticFeedback.mediumImpact();
    _moneyControllers[trade.id]?.forward().then((_) {
      _moneyControllers[trade.id]?.reverse();
    });
    widget.onShare?.call(trade);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trades.isEmpty) {
      return _buildEmptyState();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main feed
          PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            onPageChanged: _onPageChanged,
            itemCount: widget.trades.length,
            itemBuilder: (context, index) {
              return _buildTradeCard(widget.trades[index], index);
            },
          ),
          
          // Page indicators
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.3,
            child: Column(
              children: List.generate(
                widget.trades.length.clamp(0, 5), // Max 5 indicators
                (index) => _buildPageIndicator(index),
              ),
            ),
          ),
          
          // Top gradient overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // Bottom gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.8),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeCard(SimpleTrade trade, int index) {
    final isProfit = trade.pnl != null && trade.pnl! > 0;
    final backgroundColor = isProfit
        ? Colors.green.withOpacity(0.1)
        : Colors.red.withOpacity(0.1);
    
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            backgroundColor,
            Colors.black.withOpacity(0.8),
            Colors.black,
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern
          _buildBackgroundPattern(isProfit),
          
          // Main content
          Positioned(
            left: 20,
            right: 100,
            top: MediaQuery.of(context).size.height * 0.2,
            bottom: 120,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTradeHeader(trade),
                const SizedBox(height: 20),
                _buildTradeStats(trade),
                const Spacer(),
                _buildTradeFooter(trade),
              ],
            ),
          ),
          
          // Right action panel
          Positioned(
            right: 16,
            bottom: 120,
            child: _buildActionPanel(trade),
          ),
          
          // Top info
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 20,
            right: 20,
            child: _buildTopInfo(trade, index),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundPattern(bool isProfit) {
    return Positioned.fill(
      child: CustomPaint(
        painter: TradingPatternPainter(isProfit: isProfit),
      ),
    );
  }

  Widget _buildTradeHeader(SimpleTrade trade) {
    final isProfit = trade.pnl != null && trade.pnl! > 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${trade.direction.toUpperCase()} ${trade.symbol}',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isProfit ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                isProfit ? '📈 PROFIT' : '📉 LOSS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '\$${trade.amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTradeStats(SimpleTrade trade) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          if (trade.pnl != null) _buildStatRow('P&L', '\$${trade.pnl!.toStringAsFixed(2)}'),
          if (trade.fillPrice != null) _buildStatRow('Fill Price', '\$${trade.fillPrice!.toStringAsFixed(2)}'),
          _buildStatRow('Time', _formatTimestamp(trade.timestamp)),
          if (trade.extendedOrderId != null && !trade.extendedOrderId!.startsWith('ERROR'))
            _buildStatRow('Order ID', trade.extendedOrderId!.substring(0, 10) + '...'),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeFooter(SimpleTrade trade) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '🚀 AstraTrade • Making DeFi accessible',
          style: TextStyle(
            color: Colors.white60,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            _buildHashTag('#DeFi'),
            _buildHashTag('#Trading'),
            _buildHashTag('#${trade.symbol.split('-')[0]}'),
            _buildHashTag('#ExtendedExchange'),
          ],
        ),
      ],
    );
  }

  Widget _buildHashTag(String tag) {
    return Text(
      tag,
      style: TextStyle(
        color: Colors.cyan,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildActionPanel(SimpleTrade trade) {
    return Column(
      children: [
        _buildActionButton(
          Icons.favorite,
          Colors.red,
          trade.id,
          _heartControllers[trade.id]!,
          () => _handleLike(trade),
          '${(math.Random().nextInt(50) + 10)}', // Mock likes
        ),
        const SizedBox(height: 24),
        _buildActionButton(
          Icons.chat_bubble,
          Colors.white,
          trade.id,
          _heartControllers[trade.id]!,
          () => widget.onComment?.call(trade),
          '${math.Random().nextInt(20) + 1}', // Mock comments
        ),
        const SizedBox(height: 24),
        _buildActionButton(
          Icons.share,
          Colors.yellow,
          trade.id,
          _moneyControllers[trade.id]!,
          () => _handleShare(trade),
          'Share',
        ),
        const SizedBox(height: 24),
        _buildActionButton(
          Icons.bookmark,
          Colors.white,
          trade.id,
          _heartControllers[trade.id]!,
          () {},
          '',
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    Color color,
    String tradeId,
    AnimationController controller,
    VoidCallback onPressed,
    String label,
  ) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (controller.value * 0.3),
          child: Column(
            children: [
              GestureDetector(
                onTap: onPressed,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
              ),
              if (label.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopInfo(SimpleTrade trade, int index) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.cyan, Colors.purple]),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.person, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AstraTrader${(index + 1).toString().padLeft(3, '0')}',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatTimestamp(trade.timestamp),
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.close, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = index == _currentIndex;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 4,
      height: isActive ? 24 : 8,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.trending_up,
              color: Colors.white.withOpacity(0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No trades yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start trading to see your feed',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

class TradingPatternPainter extends CustomPainter {
  final bool isProfit;

  TradingPatternPainter({required this.isProfit});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (isProfit ? Colors.green : Colors.red).withOpacity(0.1)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    
    // Create a random-looking but consistent trading pattern
    final points = <Offset>[];
    final random = math.Random(42); // Fixed seed for consistency
    
    for (int i = 0; i <= 50; i++) {
      final x = (size.width / 50) * i;
      final baseY = size.height * 0.5;
      final variation = random.nextDouble() * 200 - 100;
      final y = baseY + variation * (isProfit ? -0.5 : 0.5); // Trend direction
      points.add(Offset(x, y));
    }

    if (points.isNotEmpty) {
      path.moveTo(points[0].dx, points[0].dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}