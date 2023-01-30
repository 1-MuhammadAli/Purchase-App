import 'dart:async';

import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;

  @override
  void initState() {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList);
     }, onDone: (){
      _subscription.cancel();
     } , onError: (error){

     });
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
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}