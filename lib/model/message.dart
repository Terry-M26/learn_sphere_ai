class Message {
  String msg;
  final MessageType msgType;

  Message({required this.msg, required this.msgType});

  Map<String, dynamic> toMap() {
    return {'msg': msg, 'msgType': msgType.name};
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      msg: map['msg'] ?? '',
      msgType: map['msgType'] == 'user' ? MessageType.user : MessageType.bot,
    );
  }
}

enum MessageType { user, bot }
