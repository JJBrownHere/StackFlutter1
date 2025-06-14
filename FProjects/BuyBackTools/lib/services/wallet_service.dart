import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalletService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Get wallet balance - returns null on mobile platforms
  Future<double?> getWalletBalance() async {
    if (!kIsWeb) return null; // Return null on mobile platforms
    
    try {
      final response = await _supabase
          .from('wallets')
          .select('balance')
          .single();
      return (response['balance'] as num).toDouble();
    } catch (e) {
      debugPrint('Error fetching wallet balance: $e');
      return null;
    }
  }

  // Check if user has sufficient balance - returns true on mobile platforms
  Future<bool> hasSufficientBalance(double requiredAmount) async {
    if (!kIsWeb) return true; // Always return true on mobile platforms
    
    final balance = await getWalletBalance();
    return balance != null && balance >= requiredAmount;
  }

  // Get transaction history - returns empty list on mobile platforms
  Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    if (!kIsWeb) return []; // Return empty list on mobile platforms
    
    try {
      final response = await _supabase
          .from('wallet_transactions')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching transaction history: $e');
      return [];
    }
  }

  // Create Stripe checkout session - only available on web
  Future<String?> createCheckoutSession(double amount) async {
    if (!kIsWeb) return null;
    
    try {
      final response = await _supabase.functions.invoke(
        'create-checkout-session',
        body: {'amount': amount},
      );
      return response.data['url'];
    } catch (e) {
      debugPrint('Error creating checkout session: $e');
      return null;
    }
  }
} 