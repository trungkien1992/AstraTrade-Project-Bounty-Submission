/// Extended Exchange API response models
/// These models match the actual Extended Exchange API structure

class ExtendedMarket {
  final String name;
  final String uiName;
  final String category;
  final String assetName;
  final int assetPrecision;
  final String collateralAssetName;
  final int collateralAssetPrecision;
  final bool active;
  final String status;
  final ExtendedMarketStats? marketStats;
  final ExtendedTradingConfig? tradingConfig;
  final bool visibleOnUi;
  final int createdAt;

  ExtendedMarket({
    required this.name,
    required this.uiName,
    required this.category,
    required this.assetName,
    required this.assetPrecision,
    required this.collateralAssetName,
    required this.collateralAssetPrecision,
    required this.active,
    required this.status,
    this.marketStats,
    this.tradingConfig,
    required this.visibleOnUi,
    required this.createdAt,
  });

  factory ExtendedMarket.fromJson(Map<String, dynamic> json) {
    return ExtendedMarket(
      name: json['name'] ?? '',
      uiName: json['uiName'] ?? '',
      category: json['category'] ?? '',
      assetName: json['assetName'] ?? '',
      assetPrecision: json['assetPrecision'] ?? 0,
      collateralAssetName: json['collateralAssetName'] ?? '',
      collateralAssetPrecision: json['collateralAssetPrecision'] ?? 0,
      active: json['active'] ?? false,
      status: json['status'] ?? '',
      marketStats: json['marketStats'] != null ? ExtendedMarketStats.fromJson(json['marketStats']) : null,
      tradingConfig: json['tradingConfig'] != null ? ExtendedTradingConfig.fromJson(json['tradingConfig']) : null,
      visibleOnUi: json['visibleOnUi'] ?? false,
      createdAt: json['createdAt'] ?? 0,
    );
  }
}

class ExtendedMarketStats {
  final String dailyVolume;
  final String dailyVolumeBase;
  final String dailyPriceChange;
  final String dailyPriceChangePercentage;
  final String dailyLow;
  final String dailyHigh;
  final String lastPrice;
  final String askPrice;
  final String bidPrice;
  final String markPrice;
  final String indexPrice;

  ExtendedMarketStats({
    required this.dailyVolume,
    required this.dailyVolumeBase,
    required this.dailyPriceChange,
    required this.dailyPriceChangePercentage,
    required this.dailyLow,
    required this.dailyHigh,
    required this.lastPrice,
    required this.askPrice,
    required this.bidPrice,
    required this.markPrice,
    required this.indexPrice,
  });

  factory ExtendedMarketStats.fromJson(Map<String, dynamic> json) {
    return ExtendedMarketStats(
      dailyVolume: json['dailyVolume'] ?? '0',
      dailyVolumeBase: json['dailyVolumeBase'] ?? '0',
      dailyPriceChange: json['dailyPriceChange'] ?? '0',
      dailyPriceChangePercentage: json['dailyPriceChangePercentage'] ?? '0',
      dailyLow: json['dailyLow'] ?? '0',
      dailyHigh: json['dailyHigh'] ?? '0',
      lastPrice: json['lastPrice'] ?? '0',
      askPrice: json['askPrice'] ?? '0',
      bidPrice: json['bidPrice'] ?? '0',
      markPrice: json['markPrice'] ?? '0',
      indexPrice: json['indexPrice'] ?? '0',
    );
  }
}

class ExtendedTradingConfig {
  final String minOrderSize;
  final String minOrderSizeChange;
  final String minPriceChange;
  final String maxMarketOrderValue;
  final String maxLimitOrderValue;
  final String maxPositionValue;
  final String maxLeverage;

  ExtendedTradingConfig({
    required this.minOrderSize,
    required this.minOrderSizeChange,
    required this.minPriceChange,
    required this.maxMarketOrderValue,
    required this.maxLimitOrderValue,
    required this.maxPositionValue,
    required this.maxLeverage,
  });

  factory ExtendedTradingConfig.fromJson(Map<String, dynamic> json) {
    return ExtendedTradingConfig(
      minOrderSize: json['minOrderSize'] ?? '0',
      minOrderSizeChange: json['minOrderSizeChange'] ?? '0',
      minPriceChange: json['minPriceChange'] ?? '0',
      maxMarketOrderValue: json['maxMarketOrderValue'] ?? '0',
      maxLimitOrderValue: json['maxLimitOrderValue'] ?? '0',
      maxPositionValue: json['maxPositionValue'] ?? '0',
      maxLeverage: json['maxLeverage'] ?? '0',
    );
  }
}

class ExtendedOrderResponse {
  final String status;
  final String? orderId;
  final String? message;
  final Map<String, dynamic>? data;

  ExtendedOrderResponse({
    required this.status,
    this.orderId,
    this.message,
    this.data,
  });

  factory ExtendedOrderResponse.fromJson(Map<String, dynamic> json) {
    return ExtendedOrderResponse(
      status: json['status'] ?? 'unknown',
      orderId: json['orderId'] ?? json['id'],
      message: json['message'] ?? json['error'],
      data: json['data'],
    );
  }
}

class ExtendedBalanceResponse {
  final String status;
  final Map<String, dynamic>? balances;
  final String? totalBalance;

  ExtendedBalanceResponse({
    required this.status,
    this.balances,
    this.totalBalance,
  });

  factory ExtendedBalanceResponse.fromJson(Map<String, dynamic> json) {
    return ExtendedBalanceResponse(
      status: json['status'] ?? 'unknown',
      balances: json['balances'] ?? json['data'],
      totalBalance: json['totalBalance'],
    );
  }
}

class ExtendedPosition {
  final String market;
  final String side;
  final String size;
  final String? avgEntryPrice;
  final String? unrealizedPnl;

  ExtendedPosition({
    required this.market,
    required this.side,
    required this.size,
    this.avgEntryPrice,
    this.unrealizedPnl,
  });

  factory ExtendedPosition.fromJson(Map<String, dynamic> json) {
    return ExtendedPosition(
      market: json['market'] ?? '',
      side: json['side'] ?? '',
      size: json['size'] ?? '0',
      avgEntryPrice: json['avgEntryPrice'],
      unrealizedPnl: json['unrealizedPnl'],
    );
  }
}

class ExtendedOrderBook {
  final List<List<String>> bids;
  final List<List<String>> asks;

  ExtendedOrderBook({
    required this.bids,
    required this.asks,
  });

  factory ExtendedOrderBook.fromJson(Map<String, dynamic> json) {
    return ExtendedOrderBook(
      bids: (json['bids'] as List?)?.map((bid) => List<String>.from(bid)).toList() ?? [],
      asks: (json['asks'] as List?)?.map((ask) => List<String>.from(ask)).toList() ?? [],
    );
  }
}

class ExtendedExchangeException implements Exception {
  final String message;
  final int? statusCode;
  final String? details;

  ExtendedExchangeException(
    this.message, {
    this.statusCode,
    this.details,
  });

  @override
  String toString() {
    if (statusCode != null && details != null) {
      return 'ExtendedExchangeException: $message (HTTP $statusCode: $details)';
    } else if (statusCode != null) {
      return 'ExtendedExchangeException: $message (HTTP $statusCode)';
    } else {
      return 'ExtendedExchangeException: $message';
    }
  }
}