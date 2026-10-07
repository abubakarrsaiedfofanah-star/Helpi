import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_state.dart';
import '../core/theme.dart';
import '../widgets.dart';
import 'voice_call_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  List<dynamic> threads = [];
  bool busy = true;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final state = context.read<AppState>();
      final result = state.demoMode
          ? [
              {
                'id': 'thread-1',
                'case': {'title': 'School medical support'},
                'participants': [
                  {'id': 'demo-helper-1', 'name': 'Sarah Johnson'},
                  {'id': 'demo-user', 'name': 'Helpi Demo User'}
                ],
                'lastMessage': 'I can help with the school supplies.',
              },
              {
                'id': 'thread-2',
                'case': {'title': 'Emergency food support'},
                'participants': [
                  {'id': 'demo-helper-2', 'name': 'James Otieno'},
                  {'id': 'demo-user', 'name': 'Helpi Demo User'}
                ],
                'lastMessage': 'Thank you for reaching out.',
              },
            ]
          : await state.api.threads();
      if (mounted) setState(() => threads = result);
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext c) {
    final currentUserId = context.watch<AppState>().user?['id']?.toString();
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      body: RefreshIndicator(
        onRefresh: load,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [orange, orangeDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.forum_outlined, color: Colors.white, size: 26),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Talk about the help request',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900)),
                            SizedBox(height: 5),
                            Text(
                                'Keep your conversation in Helpi. Never share passwords, card details or one-time codes.',
                                style: TextStyle(
                                    color: Colors.white70, height: 1.35)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                const Text('Your conversations',
                    style:
                        TextStyle(fontSize: 21, fontWeight: FontWeight.w900)),
                const SizedBox(height: 10),
                if (busy)
                  const Padding(
                    padding: EdgeInsets.all(30),
                    child:
                        Center(child: CircularProgressIndicator(color: orange)),
                  )
                else if (error != null)
                  HelpiErrorState(message: error!, onRetry: load)
                else if (threads.isEmpty)
                  const HelpiEmptyState(
                    icon: Icons.chat_bubble_outline,
                    title: 'No conversations yet',
                    message:
                        'Conversations about financial help requests will appear here.',
                  )
                else
                  ...threads.map((thread) {
                    final threadCase = thread['case'];
                    final title = threadCase is Map
                        ? (threadCase['title']?.toString() ??
                            'Financial help request')
                        : 'Financial help request';
                    final participants = thread['participants'];
                    final peerName = _peerName(participants, currentUserId);
                    final latest = thread['lastMessage'] ??
                        _lastMessage(thread['messages']);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Card(
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () => Navigator.push(
                            c,
                            MaterialPageRoute(
                              builder: (_) => ThreadScreen(
                                id: thread['id'].toString(),
                                title: title,
                                peerName: peerName,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: orange.withValues(alpha: .12),
                                foregroundColor: orange,
                                child: Text(_initials(peerName),
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w900)),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(peerName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w900,
                                            fontSize: 16)),
                                    const SizedBox(height: 3),
                                    Text(title,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: navy,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13)),
                                    const SizedBox(height: 5),
                                    Text(
                                      latest?.toString() ??
                                          'Open your conversation',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: Colors.black54, fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.chevron_right,
                                  color: Colors.black45),
                            ]),
                          ),
                        ),
                      ),
                    );
                  }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _peerName(dynamic participants, String? currentUserId) {
    if (participants is List) {
      for (final participant in participants) {
        if (participant is Map &&
            participant['id']?.toString() != currentUserId &&
            participant['name'] != null) {
          return participant['name'].toString();
        }
      }
    }
    return 'Helpi member';
  }

  String? _lastMessage(dynamic value) {
    if (value is List && value.isNotEmpty && value.first is Map) {
      return value.first['body']?.toString();
    }
    return null;
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    return parts.length > 1
        ? '${parts.first[0]}${parts.last[0]}'.toUpperCase()
        : (name.isNotEmpty ? name[0].toUpperCase() : 'H');
  }
}

class ThreadScreen extends StatefulWidget {
  final String id;
  final String title;
  final String peerName;

  const ThreadScreen({
    super.key,
    required this.id,
    required this.title,
    required this.peerName,
  });

  @override
  State<ThreadScreen> createState() => _ThreadScreenState();
}

class _ThreadScreenState extends State<ThreadScreen> {
  final List<dynamic> messages = [];
  final body = TextEditingController();
  final scroll = ScrollController();
  bool busy = true;
  bool sending = false;
  String? error;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final state = context.read<AppState>();
      final result = state.demoMode
          ? _demoMessages()
          : await state.api.threadMessages(widget.id);
      if (mounted) {
        setState(() {
          messages
            ..clear()
            ..addAll(result);
        });
        _scrollToLatest();
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  List<Map<String, dynamic>> _demoMessages() => [
        {
          'senderId': 'demo-helper',
          'senderName': widget.peerName,
          'body': 'Hello, I saw your financial help request. How can I help?',
        },
        {
          'senderId': 'demo-user',
          'senderName': 'You',
          'body': 'Thank you for reaching out. I appreciate your support.',
        },
      ];

  Future<void> send() async {
    final message = body.text.trim();
    if (message.isEmpty || sending) return;
    final state = context.read<AppState>();
    if (state.demoMode) {
      setState(() {
        messages.add({
          'senderId': state.user?['id'] ?? 'demo-user',
          'senderName': 'You',
          'body': message,
        });
        body.clear();
      });
      _scrollToLatest();
      return;
    }

    setState(() {
      sending = true;
      error = null;
    });
    try {
      final sent = await state.api.sendMessage(widget.id, message);
      if (mounted) {
        setState(() {
          messages.add(sent);
          body.clear();
        });
        _scrollToLatest();
      }
    } catch (e) {
      if (mounted) {
        setState(() => error = e.toString().replaceFirst('Exception: ', ''));
      }
    } finally {
      if (mounted) setState(() => sending = false);
    }
  }

  void _scrollToLatest() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scroll.hasClients) {
        scroll.animateTo(
          scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    body.dispose();
    scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext c) {
    final userId = context.watch<AppState>().user?['id']?.toString();
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.peerName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          Text(widget.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: Colors.white70)),
        ]),
        actions: [
          IconButton(
            tooltip: 'Voice call',
            icon: const Icon(Icons.phone_outlined),
            onPressed: () => Navigator.push(
                c,
                MaterialPageRoute(
                    builder: (_) =>
                        VoiceCallScreen(peerName: widget.peerName))),
          ),
          IconButton(
            tooltip: 'Video call',
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () => Navigator.push(
                c,
                MaterialPageRoute(
                    builder: (_) =>
                        VoiceCallScreen(peerName: widget.peerName))),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(children: [
          Expanded(
            child: busy
                ? const Center(child: CircularProgressIndicator(color: orange))
                : error != null && messages.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child:
                              HelpiErrorState(message: error!, onRetry: load),
                        ),
                      )
                    : messages.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Say hello and talk about how you can help.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.black54, fontSize: 15),
                              ),
                            ),
                          )
                        : LayoutBuilder(builder: (context, constraints) {
                            final bubbleWidth = (constraints.maxWidth * .78)
                                .clamp(230.0, 560.0);
                            return ListView.builder(
                              controller: scroll,
                              padding:
                                  const EdgeInsets.fromLTRB(16, 20, 16, 20),
                              itemCount:
                                  messages.length + (error == null ? 0 : 1),
                              itemBuilder: (_, i) {
                                if (i == messages.length) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Text(error!,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.red, fontSize: 13)),
                                  );
                                }
                                final message = messages[i];
                                final isMe =
                                    message['senderId']?.toString() == userId ||
                                        message['senderName'] == 'You';
                                final sender = isMe
                                    ? 'You'
                                    : (message['senderName']?.toString() ??
                                        widget.peerName);
                                final text = message['body']?.toString() ?? '';
                                return Align(
                                  alignment: isMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    constraints:
                                        BoxConstraints(maxWidth: bubbleWidth),
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15, vertical: 12),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? orange
                                          : Theme.of(c).colorScheme.surface,
                                      borderRadius: BorderRadius.only(
                                        topLeft: const Radius.circular(18),
                                        topRight: const Radius.circular(18),
                                        bottomLeft:
                                            Radius.circular(isMe ? 18 : 5),
                                        bottomRight:
                                            Radius.circular(isMe ? 5 : 18),
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: .045),
                                            blurRadius: 8,
                                            offset: const Offset(0, 2)),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(sender,
                                            style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w800,
                                                color: isMe
                                                    ? Colors.white70
                                                    : orange)),
                                        const SizedBox(height: 4),
                                        Text(text,
                                            style: TextStyle(
                                                color: isMe
                                                    ? Colors.white
                                                    : Theme.of(c)
                                                        .colorScheme
                                                        .onSurface,
                                                height: 1.4)),
                                        if (message['createdAt'] != null) ...[
                                          const SizedBox(height: 5),
                                          Align(
                                            alignment: Alignment.centerRight,
                                            child: Text(
                                                _messageTime(
                                                    message['createdAt']),
                                                style: TextStyle(
                                                    fontSize: 10,
                                                    color: isMe
                                                        ? Colors.white70
                                                        : Theme.of(c)
                                                            .colorScheme
                                                            .onSurfaceVariant)),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(c).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: .05),
                    blurRadius: 10,
                    offset: const Offset(0, -3)),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child:
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Expanded(
                    child: TextField(
                      controller: body,
                      enabled: !sending,
                      minLines: 1,
                      maxLines: 4,
                      maxLength: 4000,
                      textCapitalization: TextCapitalization.sentences,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        hintText: 'Write a message',
                        counterText: '',
                        prefixIcon: Icon(Icons.chat_bubble_outline, size: 19),
                      ),
                      onSubmitted: (_) => send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: IconButton.filled(
                      tooltip: 'Send message',
                      onPressed: sending ? null : send,
                      style: IconButton.styleFrom(
                          backgroundColor: orange,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(48, 48)),
                      icon: sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.send_rounded, size: 20),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  String _messageTime(dynamic value) {
    final date = DateTime.tryParse(value?.toString() ?? '')?.toLocal();
    if (date == null) return '';
    return TimeOfDay.fromDateTime(date).format(context);
  }
}
