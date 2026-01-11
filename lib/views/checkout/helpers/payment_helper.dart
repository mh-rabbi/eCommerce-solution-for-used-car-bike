import 'dart:convert';

import 'package:flutter_sslcommerz/model/SSLCSdkType.dart';
import 'package:flutter_sslcommerz/model/SSLCommerzInitialization.dart';
import 'package:flutter_sslcommerz/model/SSLCurrencyType.dart';
import 'package:flutter_sslcommerz/sslcommerz.dart';

void onButtonTap(String selected) async {
  switch (selected) {
    case 'bkash':
      //bkashPayment();
      break;

    case 'sslcommerz':
      sslcommerz();
      break;

    default:
      print('No gateway selected');
  }
}

double totalPrice = 1.00;

// /// bKash
// bkashPayment() async {
//   final bkash = Bkash(
//     logResponse: true,
//   );
//
//   try {
//     final response = await bkash.pay(
//       context: Get.context!,
//       amount: totalPrice,
//       merchantInvoiceNumber: 'Test0123456',
//     );
//
//     print(response.trxId);
//     print(response.paymentId);
//   } on BkashFailure catch (e) {
//     print(e.message);
//   }
// }


/// SslCommerz
void sslcommerz() async {
  Sslcommerz sslcommerz = Sslcommerz(
    initializer: SSLCommerzInitialization(
      multi_card_name: "visa,master,bkash",
      currency: SSLCurrencyType.BDT,
      product_category: "e-commerce",
      sdkType: SSLCSdkType.TESTBOX,
      store_id: "your store id",
      store_passwd: "your store pass @ssl",
      total_amount: totalPrice,
      tran_id: "TestTRX257",
    ),
  );

  final response = await sslcommerz.payNow();

  if (response.status == 'VALID') {
    print(jsonEncode(response));

    print('Payment completed, TRX ID: ${response.tranId}');
    print(response.tranDate);
  }

  if (response.status == 'Closed') {
    print('Payment closed');
  }

  if (response.status == 'FAILED') {
    print('Payment failed');
  }
}

