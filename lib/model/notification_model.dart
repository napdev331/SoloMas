class NotificationClick {
  String? body, title;

  NotificationClick({this.body, this.title});

  NotificationClick.fromJson(Map<String, dynamic> json) {
    body = json['body'];

    title = json['title'];
  }
}

class NotificationData {
  String? type, id;

  NotificationData({this.type, this.id});

  NotificationData.fromJson(Map<String, dynamic> json) {
    id = json['id'];

    type = json['type'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();

    data['id'] = this.id ?? "";

    data['type'] = this.type;

    return data;
  }
}
