import 'package:dio/dio.dart';
import '../../shared/constants/constants.dart';

/// Handles communication with the local FastAPI notification backend.
/// Covers: POST /send-message and POST /add-feedback
class BackendService {
  BackendService._();
  static final BackendService instance = BackendService._();

  late final Dio _dio;

  void init() {
    _dio = Dio(
      BaseOptions(
        baseUrl: Constants.notificationBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        print('╔══ [BackendService] REQUEST ══════════════════════════');
        print('║ ${options.method} ${options.baseUrl}${options.path}');
        print('║ Body: ${options.data}');
        print('╚══════════════════════════════════════════════════════');
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('╔══ [BackendService] RESPONSE ═════════════════════════');
        print('║ Status: ${response.statusCode}');
        print('║ Data: ${response.data}');
        print('╚══════════════════════════════════════════════════════');
        handler.next(response);
      },
      onError: (error, handler) {
        print('╔══ [BackendService] ERROR ════════════════════════════');
        print('║ Type: ${error.type}');
        print('║ Message: ${error.message}');
        print('║ Status: ${error.response?.statusCode}');
        print('║ URL: ${error.requestOptions.baseUrl}${error.requestOptions.path}');
        print('╚══════════════════════════════════════════════════════');
        handler.next(error);
      },
    ));
  }

  // ── POST /send-message ────────────────────────────────────────────────────

  Future<void> sendMessageNotification({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String senderName,
    required String message,
  }) async {
    try {
      final body = {
        'chat_id': chatId,
        'sender_id': senderId,
        'receiver_id': receiverId,
        'sender_name': senderName,
        'message': message,
      };
      print('[BackendService] → POST ${Constants.notificationBaseUrl}/send-message');
      print('[BackendService] → Body: $body');
      final response = await _dio.post(
        '/send-message',
        data: body,
        options: Options(headers: {'Content-Type': 'application/json'}),
      );
      print('[BackendService] ✅ Status: ${response.statusCode} | Data: ${response.data}');
    } on DioException catch (e) {
      _logError('sendMessageNotification', e);
    } catch (e) {
      print('[BackendService] ❌ Unexpected error: $e');
    }
  }

  // ── POST /add-feedback ────────────────────────────────────────────────────

  Future<void> sendFeedbackNotification({
    required String patientId,
    required String doctorId,
    required String feedback,
  }) async {
    try {
      print('[BackendService] Sending feedback notification → ${Constants.notificationBaseUrl}/add-feedback');
      await _dio.post('/add-feedback', data: {
        'patient_id': patientId,
        'doctor_id': doctorId,
        'feedback': feedback,
      });
      print('[BackendService] ✅ Feedback notification sent');
    } on DioException catch (e) {
      _logError('sendFeedbackNotification', e);
    } catch (e) {
      print('[BackendService] ❌ Unexpected error: $e');
    }
  }

  // ── Connectivity check ────────────────────────────────────────────────────

  Future<bool> isBackendReachable() async {
    try {
      print('[BackendService] Checking reachability at ${Constants.notificationBaseUrl}...');
      final response = await _dio.get('/');
      print('[BackendService] ✅ Backend reachable — status: ${response.statusCode}');
      return true;
    } catch (e) {
      print('[BackendService] ❌ Backend NOT reachable: $e');
      return false;
    }
  }

  // ── Error helper ──────────────────────────────────────────────────────────

  void _logError(String method, DioException e) {
    print('[BackendService] ❌ $method failed:');
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        print('  → Connection timeout — is the backend running?');
        break;
      case DioExceptionType.connectionError:
        print('  → Connection error — check IP and WiFi');
        print('  → baseUrl: ${Constants.notificationBaseUrl}');
        break;
      case DioExceptionType.receiveTimeout:
        print('  → Receive timeout');
        break;
      case DioExceptionType.badResponse:
        print('  → Bad response: ${e.response?.statusCode} ${e.response?.data}');
        break;
      default:
        print('  → ${e.message}');
    }
  }
}
