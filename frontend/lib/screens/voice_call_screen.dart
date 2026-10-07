import 'package:flutter/material.dart';
import '../core/theme.dart';

class VoiceCallScreen extends StatefulWidget {
  final String peerName;
  const VoiceCallScreen({super.key, this.peerName = 'Sarah Johnson'});

  @override State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> {
  bool muted = false;
  bool speaker = true;
  bool videoOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: Colors.white)),
                  const Text('Secure Encrypted Call', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  const Icon(Icons.lock, color: green, size: 16),
                ],
              ),
              Column(
                children: [
                  CircleAvatar(
                    radius: 54,
                    backgroundColor: orange,
                    child: Text(widget.peerName.isNotEmpty ? widget.peerName.substring(0, 1) : 'S', style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),
                  Text(widget.peerName, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 8),
                  const Text('Voice Call • 00:12', style: TextStyle(color: orange, fontSize: 14, fontWeight: FontWeight.w700)),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton.filled(
                    onPressed: () => setState(() => muted = !muted),
                    style: IconButton.styleFrom(backgroundColor: muted ? Colors.white : Colors.white24),
                    icon: Icon(muted ? Icons.mic_off : Icons.mic, color: muted ? navy : Colors.white),
                  ),
                  IconButton.filled(
                    onPressed: () => setState(() => speaker = !speaker),
                    style: IconButton.styleFrom(backgroundColor: speaker ? Colors.white : Colors.white24),
                    icon: Icon(speaker ? Icons.volume_up : Icons.volume_down, color: speaker ? navy : Colors.white),
                  ),
                  IconButton.filled(
                    onPressed: () => setState(() => videoOn = !videoOn),
                    style: IconButton.styleFrom(backgroundColor: videoOn ? Colors.white : Colors.white24),
                    icon: Icon(videoOn ? Icons.videocam : Icons.videocam_off, color: videoOn ? navy : Colors.white),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: FloatingActionButton.large(
                  backgroundColor: Colors.red,
                  onPressed: () => Navigator.pop(context),
                  child: const Icon(Icons.call_end, color: Colors.white, size: 32),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
