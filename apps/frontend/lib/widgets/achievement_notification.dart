import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/achievement.dart';
import 'dart:math' as math;

class AchievementNotification extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback? onDismiss;

  const AchievementNotification({
    super.key,
    required this.achievement,
    this.onDismiss,
  });

  @override
  State<AchievementNotification> createState() => _AchievementNotificationState();
}

class _AchievementNotificationState extends State<AchievementNotification>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _sparkleController;
  late AnimationController _pulseController;
  
  late Animation<Offset> _slideAnimation;
  late Animation<double> _sparkleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _sparkleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _sparkleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _sparkleController, curve: Curves.easeOut),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Start animations
    _slideController.forward();
    _sparkleController.forward();
    _pulseController.repeat(reverse: true);
    
    // Trigger haptic feedback
    HapticFeedback.heavyImpact();
    
    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _sparkleController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _slideController.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Sparkle effects
            AnimatedBuilder(
              animation: _sparkleAnimation,
              builder: (context, child) {
                return Stack(
                  alignment: Alignment.center,
                  children: List.generate(12, (index) {
                    final angle = (index * 30) * math.pi / 180;
                    final distance = 80 * _sparkleAnimation.value;
                    final delay = index * 0.1;
                    final sparkleValue = (_sparkleAnimation.value - delay).clamp(0.0, 1.0);
                    
                    return Positioned(
                      left: math.cos(angle) * distance,
                      top: math.sin(angle) * distance,
                      child: Opacity(
                        opacity: (1.0 - sparkleValue) * 0.8,
                        child: Transform.scale(
                          scale: sparkleValue * 2,
                          child: Icon(
                            Icons.auto_awesome,
                            color: widget.achievement.rarityColor,
                            size: 12,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
            
            // Main notification card
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _pulseAnimation.value,
                  child: GestureDetector(
                    onTap: _dismiss,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            widget.achievement.color.withOpacity(0.9),
                            widget.achievement.rarityColor.withOpacity(0.9),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: widget.achievement.color.withOpacity(0.6),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(
                          color: widget.achievement.rarityColor,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.emoji_events,
                                color: Colors.white,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'ACHIEVEMENT UNLOCKED!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Achievement icon with rarity glow
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.2),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.achievement.rarityColor.withOpacity(0.8),
                                  blurRadius: 20,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.achievement.icon,
                              color: Colors.white,
                              size: 48,
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Achievement details
                          Column(
                            children: [
                              Text(
                                widget.achievement.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                widget.achievement.description,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              
                              // Rarity and XP
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.achievement.rarityColor.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: widget.achievement.rarityColor,
                                      ),
                                    ),
                                    child: Text(
                                      widget.achievement.rarityName.toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.amber),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 14,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '+${widget.achievement.xpReward} XP',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // Dismiss hint
                          Text(
                            'Tap to dismiss',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            
            // Close button
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Overlay widget to show achievement notifications on top of any screen
class AchievementOverlay extends StatefulWidget {
  final Widget child;

  const AchievementOverlay({super.key, required this.child});

  @override
  State<AchievementOverlay> createState() => _AchievementOverlayState();
}

class _AchievementOverlayState extends State<AchievementOverlay> {
  final List<Achievement> _pendingAchievements = [];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        
        // Achievement notifications
        ...List.generate(_pendingAchievements.length, (index) {
          final achievement = _pendingAchievements[index];
          return Positioned(
            top: MediaQuery.of(context).padding.top + (index * 20),
            left: 0,
            right: 0,
            child: AchievementNotification(
              achievement: achievement,
              onDismiss: () {
                setState(() {
                  _pendingAchievements.removeAt(index);
                });
              },
            ),
          );
        }),
      ],
    );
  }

  void showAchievement(Achievement achievement) {
    setState(() {
      _pendingAchievements.add(achievement);
    });
  }
}

/// Global instance for showing achievements
final GlobalKey<_AchievementOverlayState> achievementOverlayKey = 
    GlobalKey<_AchievementOverlayState>();

void showAchievementNotification(Achievement achievement) {
  achievementOverlayKey.currentState?.showAchievement(achievement);
}