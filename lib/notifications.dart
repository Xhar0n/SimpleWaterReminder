import 'package:awesome_notifications/awesome_notifications.dart';

int createUniqueId() {
  return DateTime.now().millisecondsSinceEpoch.remainder(10000);
}

Future<void> createPlantFoodNotification() async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
    id: createUniqueId(),
    channelKey: 'basic_channel',
    title: '${Emojis.wheater_droplet} Pi more!!!',
    body: 'Dyk ale hned',
  ));
}

Future<void> createNotification(int hours, int minutes) async {
  await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: createUniqueId(),
        channelKey: 'scheduled_channel',
        title: '${Emojis.wheater_droplet} Sak ale uz sa napi!',
        body: 'man uz toho dost, normalne ma to uz nebavi',
      ),
      schedule: NotificationCalendar(
        hour: hours,
        minute: minutes,
        second: 0,
        millisecond: 0,
        repeats: true,
      ));
}

void createWaterReminderNotification(List<String> drinkingtimes) {
  for (var i = 0; i < drinkingtimes.length; i++) {
    var times = drinkingtimes[i].split(' ');
    createNotification(int.parse(times[0]), int.parse(times[1]));
  }
}

Future<void> cancelScheduledNotifications() async {
  await AwesomeNotifications().cancelAllSchedules();
}
