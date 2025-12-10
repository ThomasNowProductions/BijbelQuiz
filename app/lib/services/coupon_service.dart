import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../services/logger.dart';
import '../utils/automatic_error_reporter.dart';

class CouponReward {
  final String type; // 'stars', 'theme'
  final dynamic value; // int for stars, String for others

  CouponReward({required this.type, required this.value});
}

class CouponService {
  final SupabaseClient _client;

  CouponService() : _client = SupabaseConfig.getClient();

  Future<CouponReward> redeemCoupon(String code) async {
    final normalizedCode = code.trim().toUpperCase();
    try {
      AppLogger.info('Attempting to redeem coupon: $normalizedCode');

      // 1. Fetch coupon details
      final response = await _client
          .from('coupons')
          .select()
          .eq('code', normalizedCode)
          .maybeSingle();

      if (response == null) {
        throw Exception('Invalid coupon code');
      }

      final coupon = response;
      final expirationDate = DateTime.parse(coupon['expiration_date']);
      final maxUses = coupon['max_uses'] as int;
      final currentUses = coupon['current_uses'] as int;

      // 2. Validate expiration
      if (DateTime.now().isAfter(expirationDate)) {
        throw Exception('This coupon has expired');
      }

      // 3. Validate usage limit
      if (currentUses >= maxUses) {
        throw Exception('This coupon is no longer valid (maximum uses reached)');
      }

      // 4. Increment usage count
      await _client.from('coupons').update({
        'current_uses': currentUses + 1,
      }).eq('code', normalizedCode);

      // 5. Return reward
      dynamic value = coupon['reward_value'];
      if (coupon['reward_type'] == 'stars') {
        value = int.tryParse(value.toString()) ?? 0;
      }

      return CouponReward(
        type: coupon['reward_type'],
        value: value,
      );
    } catch (e) {
      // Report error to automatic error tracking system
      await AutomaticErrorReporter.reportNetworkError(
        message: 'Failed to redeem coupon: ${e.toString()}',
        additionalInfo: {'coupon_code': normalizedCode, 'operation': 'redeem_coupon'},
      );
      AppLogger.error('Error redeeming coupon: $e');
      rethrow;
    }
  }
}
