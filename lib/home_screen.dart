import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

// const String _kConsumableId = 'test_product';
// const String _kUpgradeId = 'test_product1';
// const String _kSilverSubscriptionId = 'subscriptionId';
// const String _kGoldSubscriptionId = 'subscription_gold';
// const List<String> _kProductIds = <String>[
// _kConsumableId,
// _kUpgradeId,
// _kSilverSubscriptionId,
// _kGoldSubscriptionId,
// ]; 
Set<String> product_id={'test_product','test_product1'};

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<ProductDetails> products=[];
  Set<String> subscriptionProductId=product_id;
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

   Future<void> initStoreInfo() async {
      final bool isAvailable = await _inAppPurchase.isAvailable();

      if(isAvailable) {
        final ProductDetailsResponse response = 
        await _inAppPurchase.queryProductDetails(subscriptionProductId);
        if (response.notFoundIDs.isNotEmpty) {
          // Handle the error
        }
        products = response.productDetails;
        // print products
        for (ProductDetails product in products) {
          print('product: ' + product.id);
          print('price: ' + product.price);
          print('title: ' + product.title);
          print('description: ' + product.description);
          print('rawPrice: ' + product.rawPrice.toString());
          print('currencyCode: ' + product.currencyCode);
        }
      } 
      else {
          print('IsAvailable=>$isAvailable');
          print('Unfortunately store is not available');
        }
     }

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
     }, onDone: (){
      _subscription.cancel();
     } , onError: (error){

     });
     initStoreInfo();

    // TODO: implement initState
    super.initState();
  }

  _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
  for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
    if (purchaseDetails.status == PurchaseStatus.pending) {
      print('show pending UI');
    } else if (purchaseDetails.status == PurchaseStatus.purchased ||
        purchaseDetails.status == PurchaseStatus.restored) {
      bool valid = await verifyPurchase(purchaseDetails);
      //// to-do implementation of after purchased
      if(valid){
        print('Deliver Products');
      }else{
        print('show invalid purchase UI and invalid purchases');
      }
     // verifyAndDeliverProduct(purchaseDetails);
    }else if(purchaseDetails.status == PurchaseStatus.error){
      print('show error UI & handle errors.');
    //  handleError(purchaseDetails.error);
    }
    if(purchaseDetails.pendingCompletePurchase){
      await _inAppPurchase.completePurchase(purchaseDetails);
    }
  }
}

Future<bool> verifyPurchase(PurchaseDetails){
  return Future.value(true);
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Purchase App')),
      ),
      body: Center(
        child: Column(
          children: [
            for(ProductDetails product in products)...[
                Text(
                  product.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(product.description),
                Text(
                  product.price,
                  style: TextStyle(color: Colors.blueAccent, fontSize: 40),
                ),
              ],
          ],
        ),
      ),
    );
  }
}