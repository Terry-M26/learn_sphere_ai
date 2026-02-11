// Message model - represents a single chat message in AI Tutor
// Used to store and display conversation between user and AI

class Message {
  String msg; // The actual message text content
  final MessageType msgType; // Whether message is from user or bot

  // Constructor - both fields are required
  Message({required this.msg, required this.msgType});

  // Convert Message to Map for Firestore storage
  // msgType.name converts enum to string ('user' or 'bot')
  Map<String, dynamic> toMap() {
    return {'msg': msg, 'msgType': msgType.name};
  }

  // Factory constructor - creates Message from Firestore document
  // Converts string back to MessageType enum
  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      msg: map['msg'] ?? '', // Default to empty string if null
      msgType: map['msgType'] == 'user' ? MessageType.user : MessageType.bot,
    );
  }
}

// Enum to distinguish message sender
// user = message from the student
// bot = response from AI tutor (Albert)
enum MessageType { user, bot }
