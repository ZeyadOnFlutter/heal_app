import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/service/backend_service.dart';
import 'rating_widget.dart';

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String currentUserName;
  final String otherUserId;
  final String otherUserName;

  const ChatScreen({
    super.key,
    required this.currentUserId,
    required this.currentUserName,
    required this.otherUserId,
    required this.otherUserName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  late final String _chatId;
  late final CollectionReference _messages;

  @override
  void initState() {
    super.initState();
    final ids = [widget.currentUserId, widget.otherUserId]..sort();
    _chatId = ids.join('_');
    _messages = FirebaseFirestore.instance
        .collection('chats')
        .doc(_chatId)
        .collection('messages');
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
  final text = _controller.text.trim();
  if (text.isEmpty) return;

  _controller.clear();

  await FirebaseFirestore.instance
      .collection('chats')
      .doc(_chatId)
      .set({
    'participants': [widget.currentUserId, widget.otherUserId],
    'receiverId': widget.otherUserId,
    'names': {
      widget.currentUserId: widget.currentUserName,
      widget.otherUserId: widget.otherUserName,
    },
    'lastMessage': text,
    'lastTimestamp': FieldValue.serverTimestamp(),
  }, SetOptions(merge: true));

// Notify backend to push FCM notification to receiver.

  await BackendService.instance.sendMessageNotification(
    chatId: _chatId,
    senderId: widget.currentUserId,
    receiverId: widget.otherUserId,
    senderName: widget.currentUserName,
    message: text,
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111827),
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          ),
        ),
        title: Row(
          children: [
            CircleAvatar(
              radius: 16.r,
              backgroundColor: const Color(0xFF00E5FF).withOpacity(0.2),
              child: Text(
                widget.otherUserName.isNotEmpty
                    ? widget.otherUserName[0].toUpperCase()
                    : '?',
                style: TextStyle(
                    color: const Color(0xFF00E5FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp),
              ),
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.otherUserName,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w600)),
                RatingWidget(userId: widget.otherUserId),
              ],
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
              height: 1, color: const Color(0xFF00E5FF).withOpacity(0.3)),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _messages
                  .orderBy('timestamp', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFF00E5FF)));
                }
                final docs = snapshot.data!.docs;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  }
                });
                if (docs.isEmpty) {
                  return Center(
                    child: Text('No messages yet. Say hello! 👋',
                        style: TextStyle(
                            color: Colors.white38, fontSize: 13.sp)),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 12.h),
                  itemCount: docs.length,
                  itemBuilder: (_, i) {
                    final data =
                        docs[i].data() as Map<String, dynamic>;
                    final isMe =
                        data['senderId'] == widget.currentUserId;
                    final ts = data['timestamp'] as Timestamp?;
                    final time = ts != null
                        ? TimeOfDay.fromDateTime(ts.toDate())
                            .format(context)
                        : '';
                    return _MessageBubble(
                        text: data['text'] ?? '',
                        isMe: isMe,
                        time: time);
                  },
                );
              },
            ),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: const Color(0xFF111827),
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 16.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A2235),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: const Color(0xFF1E2D45)),
              ),
              child: TextField(
                controller: _controller,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle:
                      TextStyle(color: Colors.white30, fontSize: 13.sp),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w, vertical: 10.h),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: _send,
            child: Container(
              padding: EdgeInsets.all(10.w),
              decoration: const BoxDecoration(
                color: Color(0xFF00E5FF),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.send_rounded,
                  color: const Color(0xFF0A0E1A), size: 20.sp),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;
  final String time;

  const _MessageBubble(
      {required this.text, required this.isMe, required this.time});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        constraints: BoxConstraints(maxWidth: 0.72.sw),
        padding:
            EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isMe
              ? const Color(0xFF00E5FF).withOpacity(0.15)
              : const Color(0xFF1A2235),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: Radius.circular(isMe ? 16.r : 4.r),
            bottomRight: Radius.circular(isMe ? 4.r : 16.r),
          ),
          border: Border.all(
            color: isMe
                ? const Color(0xFF00E5FF).withOpacity(0.3)
                : const Color(0xFF1E2D45),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(text,
                style:
                    TextStyle(color: Colors.white, fontSize: 13.sp)),
            SizedBox(height: 4.h),
            Text(time,
                style: TextStyle(
                    color: Colors.white38, fontSize: 10.sp)),
          ],
        ),
      ),
    );
  }
}
