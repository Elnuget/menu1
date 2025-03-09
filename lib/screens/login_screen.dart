import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _loginFormKey = GlobalKey<FormState>();
  final _registerFormKey = GlobalKey<FormState>();
  
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Controladores para registro
  final _registerUsernameController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  final _registerEmailController = TextEditingController();
  
  bool _isLoading = false;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _registerUsernameController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    _registerEmailController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_loginFormKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _usernameController.text,
        _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        if (authProvider.isAdmin) {
          Navigator.pushReplacementNamed(context, '/admin');
        } else {
          Navigator.pushReplacementNamed(context, '/menu');
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Usuario o contraseña incorrectos'),
          ),
        );
      }
    }
  }

  Future<void> _register() async {
    if (_registerFormKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      // Aquí iría la lógica para registrar al usuario
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      
      // Suponiendo que existe un método register en AuthProvider
      final success = await authProvider.register(
        _registerUsernameController.text,
        _registerPasswordController.text,
        _registerEmailController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registro exitoso. Ahora puedes iniciar sesión.'),
          ),
        );
        _tabController.animateTo(0); // Cambiar a la pestaña de login
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al registrarse. Intente nuevamente.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue[700]!,
              Colors.blue[200]!,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.restaurant,
                  size: 80,
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Mi Restaurante',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 40),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      TabBar(
                        controller: _tabController,
                        labelColor: Colors.blue[700],
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: Colors.blue[700],
                        tabs: const [
                          Tab(
                            icon: Icon(Icons.login),
                            text: 'INICIAR SESIÓN',
                          ),
                          Tab(
                            icon: Icon(Icons.person_add),
                            text: 'REGISTRARSE',
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 400,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            // Pestaña de inicio de sesión
                            SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Form(
                                  key: _loginFormKey,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: _usernameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Usuario',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.person),
                                        ),
                                        validator: (value) =>
                                            value?.isEmpty ?? true ? 'Campo requerido' : null,
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _passwordController,
                                        decoration: const InputDecoration(
                                          labelText: 'Contraseña',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.lock),
                                        ),
                                        obscureText: true,
                                        validator: (value) =>
                                            value?.isEmpty ?? true ? 'Campo requerido' : null,
                                      ),
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.login),
                                          label: _isLoading
                                              ? const CircularProgressIndicator(color: Colors.white)
                                              : const Text('Iniciar Sesión'),
                                          onPressed: _isLoading ? null : _login,
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            // Pestaña de registro
                            SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Form(
                                  key: _registerFormKey,
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        controller: _registerUsernameController,
                                        decoration: const InputDecoration(
                                          labelText: 'Usuario',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.person_outline),
                                        ),
                                        validator: (value) =>
                                            value?.isEmpty ?? true ? 'Campo requerido' : null,
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _registerEmailController,
                                        decoration: const InputDecoration(
                                          labelText: 'Email',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.email),
                                        ),
                                        keyboardType: TextInputType.emailAddress,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Campo requerido';
                                          }
                                          if (!value.contains('@') || !value.contains('.')) {
                                            return 'Email inválido';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _registerPasswordController,
                                        decoration: const InputDecoration(
                                          labelText: 'Contraseña',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.lock_outline),
                                        ),
                                        obscureText: true,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Campo requerido';
                                          }
                                          if (value.length < 6) {
                                            return 'La contraseña debe tener al menos 6 caracteres';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      TextFormField(
                                        controller: _registerConfirmPasswordController,
                                        decoration: const InputDecoration(
                                          labelText: 'Confirmar Contraseña',
                                          border: OutlineInputBorder(),
                                          prefixIcon: Icon(Icons.lock),
                                        ),
                                        obscureText: true,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Campo requerido';
                                          }
                                          if (value != _registerPasswordController.text) {
                                            return 'Las contraseñas no coinciden';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 24),
                                      SizedBox(
                                        width: double.infinity,
                                        height: 48,
                                        child: ElevatedButton.icon(
                                          icon: const Icon(Icons.person_add),
                                          label: _isLoading
                                              ? const CircularProgressIndicator(color: Colors.white)
                                              : const Text('Registrarse'),
                                          onPressed: _isLoading ? null : _register,
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 