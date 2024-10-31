import 'package:flutter/material.dart';
import 'package:foodly_user/models/environment.dart';
import 'package:foodly_user/models/user_driver.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:get_storage/get_storage.dart';

class ChatDriver extends StatefulWidget {
  const ChatDriver({super.key, required this.driver});
  final UserDriver driver;

  @override
  State<ChatDriver> createState() => _ChatDriverState();
}

class _ChatDriverState extends State<ChatDriver> {
  final TextEditingController _messageController = TextEditingController();
  final box = GetStorage();
  late final String uid;
  late IO.Socket socket;
  List<Map<String, dynamic>> messages = [];
  List<Map<String, dynamic>> filteredMessages = [];

  @override
  void initState() {
    super.initState();
    uid = box.read("userId").replaceAll('"', '');
    _connectToServer();
    _loadChatHistory();
  }

  void _markMessagesAsRead() {
    // Chỉ đánh dấu tin nhắn là đã đọc nếu uid khác với id của người gửi
    if (uid != widget.driver.id && uid != socket.id) {
      socket.emit('mark_as_read_driver', {
        'driverId': widget.driver.id,
        'customerId': uid,
      });
    }
  }

  void _connectToServer() {
    socket = IO.io(
      'http://192.168.137.1:5000',
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .build(),
    );

    socket.connect();
    socket.onConnect((_) {
      // Get.snackbar('Connection', widget.driver.id);
      socket.emit('join_room_driver', {
        'driverId': widget.driver.id,
        'customerId': uid,
      });
      _markMessagesAsRead();
    });

    socket.on('receive_message_driver', (data) {
      setState(() {
        messages.add({
          'message': data['message'],
          'sender': data['sender'],
          'id': data['_id'],
          'isRead': data['isRead'] ?? 'unread',
        });
        filteredMessages.add({
          'message': data['message'],
          'sender': data['sender'],
          'id': data['_id'],
          'isRead': data['isRead'] ?? 'unread',
        });
      });
      if (data['sender'] != uid) {
        _markMessagesAsRead();
      }
    });

    socket.on('message_deleted', (data) {
      setState(() {
        messages.removeWhere((msg) => msg['_id'] == data['messageId']);
        filteredMessages.removeWhere((msg) => msg['_id'] == data['messageId']);
      });
      Get.snackbar("Success", "Message deleted successfully");
    });
  }

  Future<void> _loadChatHistory() async {
    final url = Uri.parse(
        '${Environment.appBaseUrl}/api/chats/messages-driver/${widget.driver.id}/$uid');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> chatHistory = json.decode(response.body);
        setState(() {
          messages = chatHistory.map((msg) {
            return {
              'message': msg['message'],
              'sender': msg['sender'],
              'id': msg['_id'] ?? '',
            };
          }).toList();
          filteredMessages = List.from(messages);
        });
        // _markMessagesAsRead(messages.length);
      } else {
        Get.snackbar("Error", "Failed to load chat history");
      }
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void _sendMessage() {
    if (_messageController.text.isNotEmpty) {
      final message = _messageController.text;
      socket.emit('send_message_driver', {
        'driverId': widget.driver.id,
        'customerId': uid,
        'message': message,
        'sender': uid,
      });
      setState(() {
        messages.add({
          'message': message,
          'sender': uid,
          'id': '', // Thêm trình giữ chỗ cho các tin nhắn mới
        });
        filteredMessages.add({
          'message': message,
          'sender': uid,
          'id': '', // Add a placeholder for new messages
        });
        _messageController.clear();
      });
    }
  }

  void _editMessage(int index) {
    final editedMessage = messages[index]['message'];
    _messageController.text = editedMessage;

    // Use a dialog for editing
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Message"),
          content: TextField(
            controller: _messageController,
            decoration: const InputDecoration(hintText: 'Edit your message...'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                final updatedMessage = _messageController.text;
                if (updatedMessage.isNotEmpty) {
                  socket.emit('edit_message_driver', {
                    'driverId': widget.driver.id,
                    'customerId': uid,
                    'messageId': messages[index]['id'],
                    'message': updatedMessage,
                  });
                  setState(() {
                    messages[index]['message'] = updatedMessage;
                    filteredMessages[index]['message'] =
                        updatedMessage; // Update filteredMessages too
                    _messageController.clear();
                    Navigator.of(context).pop(); // Close the dialog
                  });
                }
              },
              child: const Text("Update"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  void _deleteMessage(int index) {
    final message = messages[index];

    // Show confirmation dialog before deletion
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete Message"),
          content: const Text("Are you sure you want to delete this message?"),
          actions: [
            TextButton(
              onPressed: () {
                socket.emit('delete_message_driver', {
                  'driverId': widget.driver.id,
                  'customerId': uid,
                  'messageId': message['id'],
                });

                // Remove message locally
                setState(() {
                  messages.removeAt(index);
                  filteredMessages.removeAt(index);
                });

                Get.snackbar("Success", "Message deleted successfully");
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("Yes"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("No"),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    socket.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          widget.driver.username,
          style: const TextStyle(color: Colors.black),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Search function
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: filteredMessages.length,
              itemBuilder: (context, index) {
                final message = filteredMessages[index];
                final isCustomer = message['sender'] == uid;
                final messageStatus = message['status'];
                return Align(
                  alignment:
                      isCustomer ? Alignment.centerRight : Alignment.centerLeft,
                  child: Row(
                    mainAxisAlignment: isCustomer
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      PopupMenuButton<int>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 1) {
                            _editMessage(index);
                          } else if (value == 2) {
                            _deleteMessage(index);
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 1,
                            child: Text("Edit"),
                          ),
                          const PopupMenuItem(
                            value: 2,
                            child: Text("Delete"),
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        padding: const EdgeInsets.all(12.0),
                        decoration: BoxDecoration(
                          color:
                              isCustomer ? Colors.blue[100] : Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message['message'],
                              softWrap: true,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              messageStatus == 'read' ? 'Read' : 'Unread',
                              style: TextStyle(
                                fontSize: 10,
                                color: messageStatus == 'read'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            color: Colors.grey[200],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
