import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'otp_screen.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  final _phoneController = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  void _sendOtp() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty || phone.length < 10) {
      _showMsg('Sahi phone number likhein (e.g. 03001234567)');
      return;
    }
    // Pakistan code lagayein agar na ho
    final fullPhone = phone.startsWith('+') ? phone : '+92${phone.startsWith('0') ? phone.substring(1) : phone}';

    setState(() => _loading = true);
    await _auth.sendOtp(
      phoneNumber: fullPhone,
      onCodeSent: (verificationId) {
        setState(() => _loading = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OtpScreen(verificationId: verificationId, phone: fullPhone),
          ),
        );
      },
      onError: (error) {
        setState(() => _loading = false);
        _showMsg(error);
      },
    );
  }

  void _showMsg(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GapShap mein khush aamdeed')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Apna phone number likhein',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('OTP code SMS se aayega', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 24),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone number',
                hintText: '03001234567',
                prefixText: '+92 ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _sendOtp,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('OTP Bhejein', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
