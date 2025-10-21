import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/auth_service.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Handle settings
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(context, user),
            
            const SizedBox(height: 24),
            
            // Profile Options
            _buildProfileOptions(context),
            
            const SizedBox(height: 24),
            
            // Account Actions
            _buildAccountActions(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar
            CircleAvatar(
              radius: 50,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user?.name?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // User Info
            Text(
              user?.name ?? 'Usuário',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              user?.email ?? 'email@example.com',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            
            if (user?.phone != null) ...[
              const SizedBox(height: 4),
              Text(
                user!.phone!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOptions(BuildContext context) {
    return Card(
      child: Column(
        children: [
          _buildOptionTile(
            context,
            icon: Icons.person_outline,
            title: 'Editar Perfil',
            subtitle: 'Atualizar suas informações',
            onTap: () {
              // Handle edit profile
            },
          ),
          _buildOptionTile(
            context,
            icon: Icons.location_on_outlined,
            title: 'Endereços',
            subtitle: 'Gerenciar endereços de entrega',
            onTap: () {
              // Handle addresses
            },
          ),
          _buildOptionTile(
            context,
            icon: Icons.payment_outlined,
            title: 'Formas de Pagamento',
            subtitle: 'Cartões e métodos de pagamento',
            onTap: () {
              // Handle payment methods
            },
          ),
          _buildOptionTile(
            context,
            icon: Icons.favorite_outline,
            title: 'Favoritos',
            subtitle: 'Produtos que você curtiu',
            onTap: () {
              // Handle favorites
            },
          ),
          _buildOptionTile(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notificações',
            subtitle: 'Configurar notificações',
            onTap: () {
              // Handle notifications
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildAccountActions(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(
        children: [
          _buildActionTile(
            context,
            icon: Icons.help_outline,
            title: 'Ajuda e Suporte',
            onTap: () {
              // Handle help
            },
          ),
          _buildActionTile(
            context,
            icon: Icons.info_outline,
            title: 'Sobre o App',
            onTap: () {
              _showAboutDialog(context);
            },
          ),
          _buildActionTile(
            context,
            icon: Icons.logout,
            title: 'Sair',
            onTap: () => _handleLogout(context, ref),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  Widget _buildActionTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Theme.of(context).colorScheme.error : null,
      ),
      title: Text(
        title,
        style: isDestructive
            ? TextStyle(color: Theme.of(context).colorScheme.error)
            : null,
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Escribo E-commerce',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.shopping_cart),
      children: [
        const Text('Um aplicativo de e-commerce moderno e intuitivo.'),
        const SizedBox(height: 16),
        const Text('Desenvolvido com Flutter e Supabase.'),
      ],
    );
  }

  void _handleLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Tem certeza que deseja sair da sua conta?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final authService = ref.read(authServiceProvider);
                await authService.logout();
                if (context.mounted) {
                  context.go('/auth/login');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao sair: ${e.toString()}'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Sair'),
          ),
        ],
      ),
    );
  }
}

