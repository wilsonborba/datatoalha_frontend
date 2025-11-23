import 'package:dio/dio.dart';
import '../../core/settings.dart';
import '../../core/logs.dart'; // Assume simple print wrapper
import '../local/storage_adapter.dart';

class ApiClient {
  final Dio _dio = Dio(BaseOptions(baseUrl: AppSettings.apiUrl));
  final StorageAdapter _storage = StorageAdapter();

  ApiClient() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Inject Admin Token if available
          final token = await _storage.getAdminToken();
          if (token != null && token.isNotEmpty) {
            options.headers['X-Admin-Token'] = token;
          }
          debug("Request: ${options.method} ${options.path}");
          return handler.next(options);
        },
      ),
    );
  }

  Future<Response> get(String path) => _dio.get(path);
  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);
  Future<Response> delete(String path) => _dio.delete(path);
}
