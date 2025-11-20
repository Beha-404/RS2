import 'package:desktop/models/user.dart';
import 'package:desktop/providers/user_provider.dart';
import 'package:desktop/services/user_service.dart';
import 'package:desktop/widgets/desktop_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RoleManagementPage extends StatefulWidget {
  const RoleManagementPage({super.key});

  @override
  State<RoleManagementPage> createState() => _RoleManagementPageState();
}

class _RoleManagementPageState extends State<RoleManagementPage> {
  final _searchController = TextEditingController();
  final _userService = const UserService();
  List<User>? _users;
  bool _loading = false;

  static const _roleNames = {
    0: 'User',
    1: 'Admin',
    2: 'Manager',
    3: 'SuperAdmin',
  };

  static const _roleColors = {
    0: Colors.grey,
    1: Color(0xFFFFCC00),
    2: Colors.blue,
    3: Colors.red,
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const DesktopAppBar(currentPage: 'Role Management'),
      body: Align(
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Role Management',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: const Color(0xFFFFCC00),
                          fontSize: 24,
                        ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Search and manage user roles',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  const SizedBox(height: 24),
                  _buildSearchBar(),
                  const SizedBox(height: 24),
                  _buildUsersList(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFCC00), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Search by username...',
                hintStyle: TextStyle(color: Colors.white54),
                border: InputBorder.none,
                isDense: true,
              ),
              onSubmitted: (_) => _searchUsers(),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: _loading ? null : _searchUsers,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFCC00),
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: _loading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.black,
                    ),
                  )
                : const Text('Search'),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList() {
    if (_users == null) {
      return Container(
        width: double.infinity,
        height: 400,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF191919),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 12)
          ],
        ),
        child: const Center(
          child: Text(
            'Enter a username to search',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    if (_users!.isEmpty) {
      return Container(
        width: double.infinity,
        height: 400,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: const Color(0xFF191919),
          borderRadius: BorderRadius.circular(10),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 12)
          ],
        ),
        child: const Center(
          child: Text(
            'No users found',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF191919),
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12)],
      ),
      child: Column(
        children: _users!.map((user) => _buildUserCard(user)).toList(),
      ),
    );
  }

  Widget _buildUserCard(User user) {
    final roleColor = _roleColors[user.role] ?? Colors.grey;
    final roleName = _roleNames[user.role] ?? 'Unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFFCC00), width: 2),
        borderRadius: BorderRadius.circular(8),
        color: const Color(0xFF2A2A2A),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.username ?? 'N/A',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (user.email != null)
                      Text(
                        user.email!,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.2),
                  border: Border.all(color: roleColor, width: 2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  roleName,
                  style: TextStyle(
                    color: roleColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFFFCC00), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Change Role:',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Row(
                children: [
                  _buildRoleButton(user, 0, 'User'),
                  const SizedBox(width: 8),
                  _buildRoleButton(user, 1, 'Admin'),
                  const SizedBox(width: 8),
                  _buildRoleButton(user, 2, 'Manager'),
                  const SizedBox(width: 8),
                  _buildRoleButton(user, 3, 'SuperAdmin'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoleButton(User user, int roleValue, String label) {
    final isCurrentRole = user.role == roleValue;
    final roleColor = _roleColors[roleValue] ?? Colors.grey;

    return ElevatedButton(
      onPressed: isCurrentRole ? null : () => _updateUserRole(user, roleValue),
      style: ElevatedButton.styleFrom(
        backgroundColor: isCurrentRole ? roleColor : roleColor.withOpacity(0.3),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(color: roleColor, width: 1.5),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _searchUsers() async {
    final searchTerm = _searchController.text.trim();
    if (searchTerm.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a username to search'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      final users = await _userService.searchUsers(username: searchTerm);
      setState(() {
        _users = users;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Search failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateUserRole(User user, int newRole) async {
    if (user.id == null) return;

    final userProvider = context.read<UserProvider>();
    final currentUsername = userProvider.username;
    final currentPassword = userProvider.password;

    if (currentUsername == null || currentPassword == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Authentication required'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      await _userService.updateUserRole(
        userId: user.id!,
        newRole: newRole,
        username: currentUsername,
        password: currentPassword,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Role updated successfully for ${user.username} to ${_roleNames[newRole]}'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Refresh the search
      await _searchUsers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update role: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
