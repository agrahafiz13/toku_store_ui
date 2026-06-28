import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';

// ── Log helper ────────────────────────────────────────────────
void _log(String tag, String message) {
 debugPrint('[TokuStore/$tag] $message');
}

// ── Model callback ────────────────────────────────────────────

class PaymentCallbackData {
 final String status;
 final String? reference;
 final String? transactionId;

 const PaymentCallbackData({required this.status, this.reference, this.transactionId});

 bool get isSuccess => status == 'success';

 @override
 String toString() =>
 'PaymentCallbackData(status=$status, reference=$reference, transactionId=$transactionId)';
}

// ── Service ───────────────────────────────────────────────────

/// Mengelola deeplink keluar ke Dompet Kampus Global
class DompetPayService {
 static final DompetPayService _instance = DompetPayService._();
 factory DompetPayService() => _instance;
 DompetPayService._();

 static const _tag = 'DompetPay';

 final _callbackController = StreamController<PaymentCallbackData>.broadcast();
 Stream<PaymentCallbackData> get onCallback => _callbackController.stream;

 PaymentCallbackData? _pendingCallback;

 /// Ambil callback cold-start, dikosongkan setelah dibaca (consume-once).
 PaymentCallbackData? consumePendingCallback() {
 final data = _pendingCallback;
 _pendingCallback = null;
 if (data != null) {
 _log(_tag, ' Mengonsumsi pending cold-start callback: $data');
 }
 return data;
 }

 // ── Init ────────────────────────────────────────────────────

 Future<void> init() async {
 _log(_tag, ' Inisialisasi DompetPayService...');

 final appLinks = AppLinks();

 // Kasus 1: cold start — app dibuka oleh deeplink
 try {
 _log(_tag, ' Mengambil initial link (cold start)...');
 final uri = await appLinks.getInitialLink();
 if (uri != null) {
 _log(_tag, ' Initial link ditemukan: $uri');
 _handleUri(uri, isColdStart: true);
 } else {
 _log(_tag, 'ℹ Tidak ada initial link (app dibuka normal)');
 }
 } catch (e) {
 _log(_tag, 'Error saat getInitialLink: $e');
 }

 // Kasus 2: app sudah berjalan — deeplink masuk via stream
 _log(_tag, ' Memulai listener uriLinkStream...');
 appLinks.uriLinkStream.listen(
 (uri) {
 _log(_tag, ' URI masuk via stream: $uri');
 _handleUri(uri);
 },
 onError: (Object e) {
 _log(_tag, 'Error pada uriLinkStream: $e');
 },
 );

 _log(_tag, ' Inisialisasi selesai.');
 }

 // ── Handle URI masuk ─────────────────────────────────────────

 void _handleUri(Uri uri, {bool isColdStart = false}) {
 _log(
 _tag,
 ' Handle URI | scheme=${uri.scheme} host=${uri.host} '
 'path=${uri.path} params=${uri.queryParameters} | coldStart=$isColdStart',
 );

 if (uri.scheme != 'tokustore') {
 _log(_tag, '⏩ Diabaikan — bukan skema tokustore (scheme=${uri.scheme})');
 return;
 }

 final isCallbackHost = uri.host == 'payment-callback';
 final isCallbackPath = uri.path == '/payment-callback';
 final isReturnUrl = uri.host.isEmpty && uri.path.isEmpty && uri.queryParameters.containsKey('status');

 if (!isCallbackHost && !isCallbackPath && !isReturnUrl) {
 _log(_tag, '⏩ Diabaikan — bukan callback yang dikenali');
 return;
 }

 final data = PaymentCallbackData(
 status: uri.queryParameters['status'] ?? 'unknown',
 reference: uri.queryParameters['reference'],
 transactionId: uri.queryParameters['transaction_id'],
 );

 _log(_tag, ' Callback diterima: $data');

 if (isColdStart) {
 _pendingCallback = data;
 _log(_tag, ' Disimpan sebagai pending cold-start callback');
 }

 _callbackController.add(data);
 _log(_tag, ' Event dikirim ke stream (subscriber aktif)');
 }

 // ── Build URL keluar ─────────────────────────────────────────

 /// Membangun URL deeplink ke Dompet Kampus Global sesuai spesifikasi.
 static String buildDeeplinkUrl({
 required int orderId,
 required double amount,
 String? description,
 }) {
 const scheme = 'dompettoku';
 const host = 'pay';
 final desc = (description != null && description.isNotEmpty) ? description : 'Order #$orderId';
 const callbackUrl = 'tokustore://payment-callback';

 _log(_tag, ' Membangun deeplink URL:');
 _log(_tag, 'merchant_id : MCH_TOKU_STORE');
 _log(_tag, 'merchant_name: Toku Store');
 _log(_tag, 'amount : ${amount.toInt()}');
 _log(_tag, 'description : $desc');
 _log(_tag, 'reference : INV-$orderId');
 _log(_tag, 'callback : $callbackUrl');

 final uri = Uri(
 scheme: scheme,
 host: host,
 queryParameters: {
 'merchant_id': 'MCH_TOKU_STORE',
 'merchant_name': 'Toku Store',
 'amount': amount.toInt().toString(),
 'description': desc,
 'reference': 'INV-$orderId',
 'callback': callbackUrl,
 },
 );

 final result = uri.toString();
 _log(_tag, ' URL lengkap (sebelum launch): $result');
 return result;
 }
}
