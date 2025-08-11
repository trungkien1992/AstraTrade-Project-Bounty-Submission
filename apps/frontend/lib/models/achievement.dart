import 'package:flutter/material.dart';

enum AchievementType {
  trading,
  streak,
  profit,
  milestone,
  social,
  special,
}

enum AchievementRarity {
  common,
  rare,
  epic,
  legendary,
  mythic,
}

class Achievement {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final AchievementType type;
  final AchievementRarity rarity;
  final int xpReward;
  final DateTime? unlockedAt;
  final bool isUnlocked;
  final double progress;
  final double target;
  final String? nftTokenId;
  final Map<String, dynamic>? metadata;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.type,
    required this.rarity,
    required this.xpReward,
    this.unlockedAt,
    this.isUnlocked = false,
    this.progress = 0.0,
    required this.target,
    this.nftTokenId,
    this.metadata,
  });

  Achievement copyWith({
    String? id,
    String? name,
    String? description,
    IconData? icon,
    Color? color,
    AchievementType? type,
    AchievementRarity? rarity,
    int? xpReward,
    DateTime? unlockedAt,
    bool? isUnlocked,
    double? progress,
    double? target,
    String? nftTokenId,
    Map<String, dynamic>? metadata,
  }) {
    return Achievement(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      type: type ?? this.type,
      rarity: rarity ?? this.rarity,
      xpReward: xpReward ?? this.xpReward,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      progress: progress ?? this.progress,
      target: target ?? this.target,
      nftTokenId: nftTokenId ?? this.nftTokenId,
      metadata: metadata ?? this.metadata,
    );
  }

  double get progressPercentage => (progress / target).clamp(0.0, 1.0);

  bool get canClaim => progressPercentage >= 1.0 && !isUnlocked;

  String get rarityName {
    switch (rarity) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
      case AchievementRarity.mythic:
        return 'Mythic';
    }
  }

  Color get rarityColor {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.orange;
      case AchievementRarity.mythic:
        return Colors.pink;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.toString(),
      'rarity': rarity.toString(),
      'xpReward': xpReward,
      'unlockedAt': unlockedAt?.toIso8601String(),
      'isUnlocked': isUnlocked,
      'progress': progress,
      'target': target,
      'nftTokenId': nftTokenId,
      'metadata': metadata,
    };
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: Icons.star, // Default icon, should be mapped properly
      color: Colors.blue, // Default color, should be mapped properly
      type: AchievementType.values.firstWhere(
        (e) => e.toString() == json['type'],
        orElse: () => AchievementType.trading,
      ),
      rarity: AchievementRarity.values.firstWhere(
        (e) => e.toString() == json['rarity'],
        orElse: () => AchievementRarity.common,
      ),
      xpReward: json['xpReward'],
      unlockedAt: json['unlockedAt'] != null ? DateTime.parse(json['unlockedAt']) : null,
      isUnlocked: json['isUnlocked'] ?? false,
      progress: (json['progress'] ?? 0.0).toDouble(),
      target: (json['target'] ?? 1.0).toDouble(),
      nftTokenId: json['nftTokenId'],
      metadata: json['metadata'],
    );
  }
}

class AchievementSystem {
  static List<Achievement> getDefaultAchievements() {
    return [
      // Trading Achievements
      Achievement(
        id: 'first_trade',
        name: '🚀 First Launch',
        description: 'Execute your first trade',
        icon: Icons.rocket_launch,
        color: Colors.blue,
        type: AchievementType.trading,
        rarity: AchievementRarity.common,
        xpReward: 100,
        target: 1.0,
      ),
      Achievement(
        id: 'trade_warrior',
        name: '⚔️ Trade Warrior',
        description: 'Complete 10 trades',
        icon: Icons.military_tech,
        color: Colors.orange,
        type: AchievementType.trading,
        rarity: AchievementRarity.rare,
        xpReward: 500,
        target: 10.0,
      ),
      Achievement(
        id: 'trade_master',
        name: '👑 Trade Master',
        description: 'Complete 100 trades',
        icon: Icons.crown,
        color: Colors.purple,
        type: AchievementType.trading,
        rarity: AchievementRarity.legendary,
        xpReward: 2500,
        target: 100.0,
      ),

      // Streak Achievements
      Achievement(
        id: 'hot_streak',
        name: '🔥 Hot Streak',
        description: 'Win 3 trades in a row',
        icon: Icons.local_fire_department,
        color: Colors.red,
        type: AchievementType.streak,
        rarity: AchievementRarity.rare,
        xpReward: 300,
        target: 3.0,
      ),
      Achievement(
        id: 'unstoppable',
        name: '⚡ Unstoppable',
        description: 'Win 10 trades in a row',
        icon: Icons.flash_on,
        color: Colors.amber,
        type: AchievementType.streak,
        rarity: AchievementRarity.epic,
        xpReward: 1000,
        target: 10.0,
      ),

      // Profit Achievements
      Achievement(
        id: 'profit_maker',
        name: '💰 Profit Maker',
        description: 'Earn \$100 in profits',
        icon: Icons.attach_money,
        color: Colors.green,
        type: AchievementType.profit,
        rarity: AchievementRarity.rare,
        xpReward: 400,
        target: 100.0,
      ),
      Achievement(
        id: 'whale',
        name: '🐋 Whale Status',
        description: 'Earn \$1000 in profits',
        icon: Icons.waves,
        color: Colors.cyan,
        type: AchievementType.profit,
        rarity: AchievementRarity.legendary,
        xpReward: 2000,
        target: 1000.0,
      ),

      // Milestone Achievements
      Achievement(
        id: 'week_trader',
        name: '📅 Week Trader',
        description: 'Trade for 7 consecutive days',
        icon: Icons.calendar_view_week,
        color: Colors.indigo,
        type: AchievementType.milestone,
        rarity: AchievementRarity.epic,
        xpReward: 750,
        target: 7.0,
      ),
      Achievement(
        id: 'extended_exchange_pro',
        name: '🏆 Extended Pro',
        description: 'Complete 50 trades on Extended Exchange',
        icon: Icons.public,
        color: Colors.pink,
        type: AchievementType.special,
        rarity: AchievementRarity.legendary,
        xpReward: 1500,
        target: 50.0,
      ),

      // Special Achievements
      Achievement(
        id: 'early_adopter',
        name: '🌟 Early Adopter',
        description: 'One of the first 1000 users',
        icon: Icons.star,
        color: Colors.gold,
        type: AchievementType.special,
        rarity: AchievementRarity.mythic,
        xpReward: 5000,
        target: 1.0,
      ),
      Achievement(
        id: 'bounty_winner',
        name: '🏅 Bounty Champion',
        description: 'Witnessed the birth of AstraTrade',
        icon: Icons.emoji_events,
        color: Colors.amber,
        type: AchievementType.special,
        rarity: AchievementRarity.mythic,
        xpReward: 10000,
        target: 1.0,
      ),
    ];
  }

  static Achievement? checkForNewAchievements(
    List<Achievement> currentAchievements,
    Map<String, dynamic> userStats,
  ) {
    for (var achievement in currentAchievements) {
      if (achievement.isUnlocked || achievement.progress >= achievement.target) continue;

      double newProgress = _calculateProgress(achievement, userStats);
      
      if (newProgress >= achievement.target && !achievement.isUnlocked) {
        return achievement.copyWith(
          progress: newProgress,
          isUnlocked: true,
          unlockedAt: DateTime.now(),
        );
      }
    }
    
    return null;
  }

  static double _calculateProgress(Achievement achievement, Map<String, dynamic> stats) {
    switch (achievement.id) {
      case 'first_trade':
      case 'trade_warrior':
      case 'trade_master':
        return (stats['totalTrades'] ?? 0).toDouble();
      
      case 'hot_streak':
      case 'unstoppable':
        return (stats['maxStreak'] ?? 0).toDouble();
      
      case 'profit_maker':
      case 'whale':
        return (stats['totalProfit'] ?? 0.0).toDouble();
      
      case 'week_trader':
        return (stats['consecutiveDays'] ?? 0).toDouble();
      
      case 'extended_exchange_pro':
        return (stats['extendedExchangeTrades'] ?? 0).toDouble();
      
      case 'early_adopter':
        return (stats['userRank'] ?? 999999) <= 1000 ? 1.0 : 0.0;
      
      case 'bounty_winner':
        return 1.0; // All current users get this
      
      default:
        return achievement.progress;
    }
  }
}

extension ColorExtension on Color {
  static const Color gold = Color(0xFFFFD700);
}