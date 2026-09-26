import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class OtpScreen extends StatefulWidget {
  final String verificationId;
  final String phone;
  const OtpScreen({super.key, required this.verificationId, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  void _verify() async {
    final otp = _otpController.text.trim();
    if (otp.length != 6) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('6 hindson ka OTP likhein')));
      return;
    }
    setState(() => _loading = true);
    final ok = await _auth.verifyOtp(verificationId: widget.verificationId, otp: otp);
    setState(() => _loading = false);
    if (ok && mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } else if (mounted) {
      final err = AuthService.lastError;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err ?? 'OTP ghalat hai, dobara koshish karein'),
          duration: const Duration(seconds: 8),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP verify karein')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('${widget.phone} pe bheje gaye code ko likhein',
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'OTP code',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _verify,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Verify', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
