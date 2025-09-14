import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

// Configure default caching options with smarter policy
final defaultCacheOptions = CacheOptions(
  store: MemCacheStore(), // Memory cache for better performance
  policy: CachePolicy.request, // Respect cache headers but allow fresh requests
  hitCacheOnErrorCodes: [500, 502, 503, 504], // Use cache on server errors
  priority: CachePriority.normal,
  maxStale:
      const Duration(minutes: 30), // Shorter cache duration for fresher data
);

// Cache options for static data that rarely changes
final staticCacheOptions = CacheOptions(
  store: MemCacheStore(),
  policy: CachePolicy.forceCache, // Use cache aggressively for static data
  hitCacheOnErrorCodes: [500, 502, 503, 504],
  priority: CachePriority.normal,
  maxStale: const Duration(hours: 6), // Longer cache for static data
);

// Cache options for dynamic data that changes frequently
final noCacheOptions = CacheOptions(
  store: MemCacheStore(),
  policy: CachePolicy.noCache, // Always fetch fresh data
);

// Custom interceptor to handle different caching strategies
class SmartCacheInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Determine caching strategy based on endpoint and method
    CacheOptions cacheToUse =
        _getCacheOptionsForRequest(options.path, options.method);

    // Apply the cache options to this specific request
    options.extra.addAll(cacheToUse.toExtra());

    super.onRequest(options, handler);
  }

  CacheOptions _getCacheOptionsForRequest(String path, String method) {
    // For non-GET requests, don't cache
    if (method.toUpperCase() != 'GET') {
      return noCacheOptions;
    }

    // Define endpoints that change frequently and need fresh data
    List<String> dynamicEndpoints = [
      '/products', // Product listings change frequently
      '/shops', // Shop data changes when users update
      '/reels', // Reels are dynamic content
      '/orders', // Orders change frequently
      '/favorites', // Favorites change when users like/unlike
      '/following', // Following status changes
      '/categories',
      '/shop-calendar', // Calendar data changes
    ];

    // Define endpoints that can be cached longer (static data)
    List<String> staticEndpoints = [
      '/categories', // Categories rarely change
      '/locations', // Locations are mostly static
      '/product-specifications', // Specs don't change often
    ];

    // Check if this is a dynamic endpoint that needs fresh data
    if (dynamicEndpoints.any((endpoint) => path.contains(endpoint))) {
      return noCacheOptions; // Always fetch fresh data
    }

    // Check if this is a static endpoint that can be cached longer
    if (staticEndpoints.any((endpoint) => path.contains(endpoint))) {
      return staticCacheOptions; // Cache for longer duration
    }

    // Default to short-term caching
    return defaultCacheOptions;
  }
}

// Create Dio instance with smart caching
final dio = Dio(BaseOptions(
  baseUrl: "https://api.exactonline.co.tz",
  connectTimeout: const Duration(seconds: 30),
  receiveTimeout: const Duration(seconds: 30),
))
  ..interceptors.add(SmartCacheInterceptor())
  ..interceptors.add(DioCacheInterceptor(options: defaultCacheOptions));
