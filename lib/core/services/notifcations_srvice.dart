import 'dart:async';

import 'package:fluter_template/core/data/enums/app_status.dart';
import 'package:fluter_template/core/data/enums/notification_type.dart';


import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fluter_template/core/data/models/notifacations_model.dart';
import 'package:get/get.dart';

class NotificationService {
  StreamController<NotifictionModel> notifcationStream =
      StreamController<NotifictionModel>.broadcast();

  NotificationService() {
    onInit();
  }

  void onInit() async {
    if (GetPlatform.isIOS) {
      FirebaseMessaging messaging = FirebaseMessaging.instance;

      NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        await registerdFCMToken();
      } else {
        return;
      }
    } else {
      await registerdFCMToken();
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      NotifictionModel model = NotifictionModel.fromJson(message.data);
      handelNotification(model: model, appState: AppState.FOREGROUND);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      NotifictionModel model = NotifictionModel.fromJson(message.data);
      handelNotification(model: model, appState: AppState.BACKGROUND);
    });
  }

  Future<void> registerdFCMToken() async {
    final fcmToken = await FirebaseMessaging.instance.getToken();
    //! -- Call api that register fcm token ---

    FirebaseMessaging.instance.onTokenRefresh.listen((fcmToken) {
      //! -- Call api that register fcm token ---
      // TODO: If necessary send token to application server.

      // Note: This callback is fired at each app startup and whenever a new
      // token is generated.
    }).onError((err) {
      // Error getting token.
    });
  }

  void handelNotification(
      {required NotifictionModel model, required AppState appState}) {
    notifcationStream.add(model);
    if (model.notifctionType == NotificationType.SUBSCRIPTION.name) {
      //   storage.setSubStatus(model.subStatus == "1" ? true : false);
    }
  }
}
