import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sistem_presensi_karyawan/app/theme/app_colors.dart';
import 'package:sistem_presensi_karyawan/core/di/injection.dart';
import 'package:sistem_presensi_karyawan/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:sistem_presensi_karyawan/features/auth/presentation/bloc/auth_event.dart';
import 'package:sistem_presensi_karyawan/features/auth/presentation/bloc/auth_state.dart';

// Wrapper untuk menyediakan AuthBloc dari Gudang (Injection) ke UI
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthBloc>(),
      child: const LoginView(),
    );
  }
}

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordObscured = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      // BlocConsumer bertugas mendengar perubahan State (Loading/Sukses/Error)
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            _showSnackBar('Selamat datang, ${state.user['nama']}!', Colors.green);
            context.go('/beranda');
          } else if (state is AuthError) {
            _showSnackBar(state.message, AppColors.error);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  height: size.height * 0.55,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.vertical(bottom: Radius.circular(40)),
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.04),
                        Container(
                          height: 72,
                          width: 72,
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                          child: const Icon(Icons.filter_center_focus, size: 36, color: AppColors.primary),
                        ),
                        const SizedBox(height: 24),
                        const Text('Selamat Datang', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                        const SizedBox(height: 8),
                        const Text('Silakan masuk ke akun yang sudah didaftarkan\noleh Admin', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: Colors.white, height: 1.4)),
                        const SizedBox(height: 32),
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8))],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Email', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF333333))),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _emailController,
                                enabled: !isLoading,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  hintText: 'Masukkan email',
                                  hintStyle: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
                                  prefixIcon: const Icon(Icons.person_outline_rounded, color: Color(0xFFA0AEC0), size: 22),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                                ),
                              ),
                              const SizedBox(height: 20),
                              const Text('Kata Sandi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF333333))),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _passwordController,
                                enabled: !isLoading,
                                obscureText: _isPasswordObscured,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) {
                                  if (!isLoading) {
                                    context.read<AuthBloc>().add(LoginRequested(email: _emailController.text.trim(), password: _passwordController.text));
                                  }
                                },
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                decoration: InputDecoration(
                                  hintText: 'Masukkan kata sandi',
                                  hintStyle: const TextStyle(color: Color(0xFFA0AEC0), fontSize: 14),
                                  prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFFA0AEC0), size: 22),
                                  suffixIcon: IconButton(
                                    icon: Icon(_isPasswordObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined, color: const Color(0xFFA0AEC0), size: 22),
                                    onPressed: () => setState(() => _isPasswordObscured = !_isPasswordObscured),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5)),
                                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Container(
                                width: double.infinity,
                                height: 52,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 6))],
                                ),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  ),
                                  onPressed: isLoading ? null : () {
                                    final email = _emailController.text.trim();
                                    final password = _passwordController.text;
                                    if (email.isEmpty || password.isEmpty) {
                                      _showSnackBar('Email dan Kata Sandi tidak boleh kosong!', AppColors.warning);
                                      return;
                                    }
                                    // Melempar Event (Tugas) ke BLoC
                                    context.read<AuthBloc>().add(LoginRequested(email: email, password: password));
                                  },
                                  child: isLoading
                                      ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                      : const Text('Masuk', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}