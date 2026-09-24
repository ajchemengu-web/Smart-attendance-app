import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/session_expiry.dart';
import '../services/session_store.dart';

/// Self-service facial enrollment: the student captures their own
/// live photos (not a file upload) from their own logged-in session,
/// gated server-side by the liveness/anti-spoofing check
/// (Alternative_Identifier's enroll_own_face) — no admin in the loop
/// to catch a spoofed photo the way there is for admin-run
/// enrollment. Encourages a few shots from slightly different
/// angles/positions rather than just one.
class FaceEnrollmentScreen extends StatefulWidget {
  const FaceEnrollmentScreen({super.key});

  @override
  State<FaceEnrollmentScreen> createState() => _FaceEnrollmentScreenState();
}

class _FaceEnrollmentScreenState extends State<FaceEnrollmentScreen> {
  final _apiClient = ApiClient();
  final _sessionStore = SessionStore();

  List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = 0;

  final List<Uint8List> _captures = [];

  bool _initializing = true;
  bool _submitting = false;
  String? _error;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    setState(() {
      _initializing = true;
      _error = null;
    });

    try {
      _cameras = await availableCameras();

      if (_cameras.isEmpty) {
        setState(() {
          _error = 'No camera was found on this device.';
          _initializing = false;
        });
        return;
      }

      // Prefer the front ("selfie") camera to start, if there is one.
      _cameraIndex = _cameras.indexWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
      );
      if (_cameraIndex == -1) _cameraIndex = 0;

      await _startController(_cameras[_cameraIndex]);
    } catch (_) {
      setState(() {
        _error =
            'Could not access your camera. Check that you allowed camera '
            'permission for this site, then try again.';
      });
    } finally {
      if (mounted) setState(() => _initializing = false);
    }
  }

  Future<void> _startController(CameraDescription description) async {
    await _controller?.dispose();

    final controller = CameraController(
      description,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await controller.initialize();

    if (!mounted) return;
    setState(() => _controller = controller);
  }

  Future<void> _switchCamera() async {
    if (_cameras.length < 2) return;

    setState(() => _initializing = true);

    _cameraIndex = (_cameraIndex + 1) % _cameras.length;

    try {
      await _startController(_cameras[_cameraIndex]);
    } catch (_) {
      setState(() => _error = 'Could not switch cameras.');
    } finally {
      if (mounted) setState(() => _initializing = false);
    }
  }

  Future<void> _capture() async {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      final file = await controller.takePicture();
      final bytes = await file.readAsBytes();

      setState(() {
        _captures.add(bytes);
        _error = null;
        _successMessage = null;
      });
    } catch (_) {
      setState(() => _error = 'Could not capture a photo — try again.');
    }
  }

  void _removeCapture(int index) {
    setState(() => _captures.removeAt(index));
  }

  Future<void> _submit() async {
    if (_captures.isEmpty) return;

    setState(() {
      _submitting = true;
      _error = null;
      _successMessage = null;
    });

    final token = await _sessionStore.token;

    if (token == null) {
      if (!mounted) return;
      await handleUnauthorized(context);
      return;
    }

    try {
      final result = await _apiClient.enrollMyFace(_captures, token);

      if (!mounted) return;

      setState(() {
        _successMessage =
            'Your face has been enrolled successfully — ${result.samplesUsed} '
            'of ${result.samplesUsed + result.samplesSkipped} photo(s) used.';
        _captures.clear();
      });
    } on ApiException catch (error) {
      if (error.status == 401) {
        if (!mounted) return;
        await handleUnauthorized(context);
        return;
      }

      // The backend already phrases liveness/no-face rejections as
      // actionable guidance ("try somewhere well-lit, facing the
      // camera directly...") — surface it as-is rather than a generic
      // failure message.
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enroll your face')),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_initializing) {
      return const Center(child: CircularProgressIndicator());
    }

    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return _buildMessageBody();
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Face a well-lit area, hold the phone at eye level, and capture '
          'a few photos — try slightly different angles rather than the '
          'same pose each time.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CameraPreview(controller),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _capture,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Capture'),
              ),
            ),
            if (_cameras.length > 1) ...[
              const SizedBox(width: 8),
              IconButton(
                onPressed: _switchCamera,
                icon: const Icon(Icons.cameraswitch),
                tooltip: 'Switch camera',
              ),
            ],
          ],
        ),
        const SizedBox(height: 16),
        if (_captures.isNotEmpty) ...[
          Text('${_captures.length} photo(s) captured'),
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _captures.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.memory(
                        _captures[index],
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () => _removeCapture(index),
                        child: const CircleAvatar(
                          radius: 10,
                          backgroundColor: Colors.black54,
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
        if (_error != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(_error!, style: const TextStyle(color: Colors.red)),
          ),
        if (_successMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              _successMessage!,
              style: const TextStyle(color: Colors.green),
            ),
          ),
        ElevatedButton(
          onPressed: _captures.isEmpty || _submitting ? null : _submit,
          child: Text(_submitting ? 'Enrolling…' : 'Enroll my face'),
        ),
      ],
    );
  }

  Widget _buildMessageBody() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red)),
        const SizedBox(height: 16),
        ElevatedButton(onPressed: _initCamera, child: const Text('Retry')),
      ],
    );
  }
}
