import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:path_provider/path_provider.dart';

// Configure caching options
final cacheOptions = CacheOptions(
  store: MemCacheStore(), // Folder where cache will be stored
  policy: CachePolicy.forceCache, // Use cache if server allows
  hitCacheOnErrorCodes: [500], // Return cache on error except auth errors
  priority: CachePriority.normal,
  maxStale: const Duration(days: 7), // Cache duration
);

// Attach the cache interceptor to Dio
final dio = Dio(BaseOptions(baseUrl: "https://api.exactonline.co.tz"))
  ..interceptors.add(DioCacheInterceptor(options: cacheOptions));
