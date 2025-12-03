import 'package:desktop/pages/build_wizard_page.dart';
import 'package:desktop/pages/compatibility_checker_page.dart';
import 'package:desktop/pages/login_page.dart';
import 'package:desktop/pages/orders_page.dart';
import 'package:desktop/pages/product_page.dart';
import 'package:desktop/pages/role_management_page.dart';
import 'package:desktop/pages/support_page.dart';
import 'package:desktop/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DesktopAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentPage;

  const DesktopAppBar({
    super.key,
    required this.currentPage,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final username = userProvider.username ?? 'admin';
    final isSuperAdmin = userProvider.isSuperAdmin;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: const Color(0xFF2B2727),
      title: Row(
        children: [
          const Text(
            'EasyPC',
            style: TextStyle(color: Color(0xFFFFCC00), fontSize: 22),
          ),
          SizedBox(
            width: 42,
            height: 42,
            child: Image.asset(
              'assets/images/logoIcon.png',
              fit: BoxFit.contain,
            ),
          ),
          const Spacer(),
          _buildNavButton(context, 'Products', 'productsIcon.png'),
          const SizedBox(width: 36),
          _buildNavButton(context, 'Build Wizard', 'productsIcon.png'),
          const SizedBox(width: 36),
          _buildNavButton(context, 'Compatibility', 'productsIcon.png'),
          const SizedBox(width: 36),
          _buildNavButton(context, 'Support', 'supportIcon.png'),
          const SizedBox(width: 36),
          _buildNavButton(context, 'Orders', 'ordersIcon.png'),
          if (isSuperAdmin) ...[
            const SizedBox(width: 36),
            _buildNavButton(context, 'Role Management', 'userIcon.png'),
          ],
          const Spacer(),
          SizedBox(
            width: 32,
            height: 32,
            child: Image.asset(
              'assets/images/userIcon.png',
              fit: BoxFit.contain,
              color: Colors.white,
            ),
          ),
          Text(
            'User: $username',
            style: const TextStyle(color: Color(0xFFFFCC00)),
          ),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () => _handleLogout(context),
            icon: const Icon(Icons.logout, color: Color(0xFFFFCC00)),
            tooltip: 'Logout',
          ),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    context.read<UserProvider>().clearCredentials();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  Widget _buildNavButton(BuildContext context, String label, String iconPath, {Color? iconColor}) {
    return Row(
      children: [
        TextButton(
          onPressed: () {
            if (label == currentPage) return;

            Widget? route;
            switch (label) {
              case 'Products':
                route = const ProductPage();
                break;
              case 'Build Wizard':
                route = const BuildWizardPage();
                break;
              case 'Compatibility':
                route = const CompatibilityCheckerPage();
                break;
              case 'Support':
                route = const SupportPage();
                break;
              case 'Orders':
                route = const OrdersPage();
                break;
              case 'Role Management':
                route = const RoleManagementPage();
                break;
            }

            if (route != null) {
              Navigator.pushReplacement(
                context,
                PageRouteBuilder(
                  pageBuilder: (_, __, ___) => route!,
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            }
          },
          child: Text(
            label,
            style: TextStyle(
              color:Colors.white,
              fontSize: 22,
            ),
          ),
        ),
        SizedBox(
          width: 32,
          height: 32,
          child: Image.asset(
            'assets/images/$iconPath',
            fit: BoxFit.contain,
            color: iconColor ?? (label == 'Support' ? Colors.white : null),
          ),
        ),
      ],
    );
  }
}

