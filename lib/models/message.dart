import 'package:uuid/uuid.dart';

enum MessageState { none, error, typed, predicting, predicted }

enum MessageSender { user, userRag, system }

class Message {
  final String id;
  final MessageSender sender;
  MessageState state;
  String text;
  double tokSec;
  String header;
  String? attachment;
  String? attachmentType;
  bool isMarkdown;
  int tokensCount;
  double? totalSeconds;

  Message({
    String? id,
    required this.sender,
    this.state = MessageState.none,
    required this.text,
    this.tokSec = 0.0,
    this.header = "",
    this.attachment,
    this.attachmentType,
    this.isMarkdown = false,
    this.tokensCount = 0,
    this.totalSeconds,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.toString(),
      'state': state.toString(),
      'text': text,
      'tok_sec': tokSec.toString(),
      'header': header,
      'attachment': attachment,
      'attachment_type': attachmentType,
      'is_markdown': isMarkdown,
      'tokens_count': tokensCount,
      'total_seconds': totalSeconds,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'],
      sender: MessageSender.values.firstWhere(
        (e) => e.toString() == json['sender'],
        orElse: () => MessageSender.system,
      ),
      state: MessageState.values.firstWhere(
        (e) => e.toString() == json['state'],
        orElse: () => MessageState.none,
      ),
      text: json['text'] ?? '',
      tokSec: double.tryParse(json['tok_sec'] ?? '0') ?? 0.0,
      header: json['header'] ?? '',
      attachment: json['attachment'],
      attachmentType: json['attachment_type'],
      isMarkdown: json['is_markdown'] ?? false,
      tokensCount: json['tokens_count'] ?? 0,
      totalSeconds: json['total_seconds'],
    );
  }
}
