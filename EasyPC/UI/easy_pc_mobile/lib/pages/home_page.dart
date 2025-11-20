import 'package:easy_pc/models/pc.dart';
import 'package:easy_pc/models/user.dart';
import 'package:easy_pc/pages/order_history_page.dart';
import 'package:easy_pc/pages/support_page.dart';
import 'package:easy_pc/providers/user_provider.dart';
import 'package:easy_pc/services/pc_service.dart';
import 'package:easy_pc/widgets/dialog/filter_dialog.dart';
import 'package:easy_pc/widgets/pc_card.dart';
import 'package:easy_pc/widgets/hero_header.dart';
import 'package:easy_pc/pages/edit_profile_page.dart';
import 'package:easy_pc/widgets/dialog/pc_details_dialog.dart';
import 'package:easy_pc/pages/login_page.dart';
import 'package:easy_pc/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_pc/providers/cart_provider.dart';
import 'package:easy_pc/pages/cart_page.dart';

enum _MenuAction { editProfile, orderHistory, support, logout }

const yellow = Color(0xFFDDC03D);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentPage = 1;
  int _totalPages = 1;
  final int _pageSize = 4;
  List<PC> _pcs = [];
  bool _loading = false;
  Map<String, dynamic>? _currentFilters;
  final _pageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPcs();
    _loadUserPassword();
  }

  Future<void> _loadUserPassword() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.user != null && userProvider.password == null) {
        await userProvider.loadPassword();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      appBar: _buildAppBar(user),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButton: user != null ? _buildSupportFab() : null,
    );
  }

  Widget _buildSupportFab() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SupportPage()),
        );
      },
      backgroundColor: yellow,
      child: const Icon(
        Icons.support_agent,
        color: Colors.black,
        size: 28,
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(User? user) {
    return AppBar(
      backgroundColor: const Color(0xFF262626),
      elevation: 0,
      titleSpacing: 0,
      title: Row(
        children: const [
          SizedBox(width: 12),
          Icon(Icons.computer, color: yellow),
          SizedBox(width: 8),
          Text(
            'EasyPC',
            style: TextStyle(color: yellow, fontWeight: FontWeight.w700),
          ),
        ],
      ),
      actions: [
        if (user == null)
          ..._guestActions()
        else ...[
          ..._userActions(user),
          _cartButton(),
        ],
      ],
    );
  }

  List<Widget> _guestActions() {
    return [
      TextButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LoginPage()),
        ),
        icon: const Icon(Icons.login, color: yellow),
        label: const Text('Login', style: TextStyle(color: yellow)),
      ),
      TextButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RegisterPage()),
        ),
        icon: const Icon(Icons.person_add, color: yellow),
        label: const Text('Register', style: TextStyle(color: yellow)),
      ),
    ];
  }

  Widget _cartButton() {
    final cartProvider = Provider.of<CartProvider>(context);
    final itemCount = cartProvider.itemCount;

    return Stack(
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => CartPage()),
            );
          },
          icon: const Icon(Icons.shopping_cart, color: yellow),
        ),
        if (itemCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                child: Text(
                  '$itemCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }

  List<Widget> _userActions(User? user) {
    return [
      PopupMenuButton<_MenuAction>(
        icon: const Icon(Icons.menu, color: yellow),
        onSelected: _handleMenuAction,
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: _MenuAction.editProfile,
            child: Text('Profile'),
          ),
          const PopupMenuItem(
            value: _MenuAction.orderHistory,
            child: Text('Order History'),
          ),
          const PopupMenuItem(
            value: _MenuAction.support,
            child: Text('Support'),
          ),
          const PopupMenuItem(value: _MenuAction.logout, child: Text('Logout')),
        ],
      ),
      const SizedBox(width: 8),
    ];
  }

  Future<void> _handleMenuAction(_MenuAction action) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    switch (action) {
      case _MenuAction.editProfile:
        if (userProvider.user == null) return;
        final updated = await Navigator.push<User>(
          context,
          MaterialPageRoute(
            builder: (_) => EditProfilePage(user: userProvider.user!),
          ),
        );
        if (!mounted) return;
        if (updated != null) {
          _snack('Profile updated');
        }
        break;
      case _MenuAction.logout:
        await userProvider.clearUser();
        if (!mounted) return;
        _snack('Logged out');
        break;
      case _MenuAction.orderHistory:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OrderHistoryPage()),
        ).then((_) {
          _loadPcs();
        });
        break;
      case _MenuAction.support:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SupportPage()),
        );
        break;
    }
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const HeroHeader(),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              'Catalog:',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator(color: yellow)),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _pcs.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.625,
              ),
              itemBuilder: (_, i) => PcCard(
                pc: _pcs[i],
                onAddToCart: () => _addToCart(_pcs[i]),
                onSeeDetails: () => PcDetailsDialog.show(context, _pcs[i]),
              ),
            ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  void _addToCart(PC pc) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (userProvider.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 12),
              Expanded(
                child: Text('Please login or register to add items to cart'),
              ),
            ],
          ),
          backgroundColor: Colors.grey[850],
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          action: SnackBarAction(
            label: 'LOGIN',
            textColor: yellow,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
          ),
        ),
      );
      return;
    }

    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    cartProvider.addItem(
      pc.id!,
      pc.name ?? 'Unknown PC',
      pc.price ?? 0,
      pc.picture,
    );

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text('${pc.name} added to cart')),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartPage()),
                );
              },
              child: const Text(
                'VIEW CART',
                style: TextStyle(color: yellow, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[850],
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildBottomNav() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          border: const Border(top: BorderSide(color: Colors.black26)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: _currentPage > 1
                  ? () => _changePage(_currentPage - 1)
                  : null,
              icon: const Icon(Icons.chevron_left),
              color: _currentPage > 1 ? yellow : Colors.grey,
            ),

            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageNumbers(),
                ),
              ),
            ),
            
            IconButton(
              onPressed: _currentPage < _totalPages
                  ? () => _changePage(_currentPage + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
              color: _currentPage < _totalPages ? yellow : Colors.grey,
            ),

            const SizedBox(width: 8),
            _filterButton(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pages = [];
    
    if (_totalPages <= 7) {
      for (int i = 1; i <= _totalPages; i++) {
        pages.add(_pageNumberButton(i));
      }
    } else {
      pages.add(_pageNumberButton(1));
      
      if (_currentPage > 3) {
        pages.add(_dotsIndicator());
      }
      
      int start = _currentPage - 1;
      int end = _currentPage + 1;
      
      if (_currentPage <= 3) {
        start = 2;
        end = 4;
      } else if (_currentPage >= _totalPages - 2) {
        start = _totalPages - 3;
        end = _totalPages - 1;
      }
      
      for (int i = start; i <= end; i++) {
        if (i > 1 && i < _totalPages) {
          pages.add(_pageNumberButton(i));
        }
      }
      
      if (_currentPage < _totalPages - 2) {
        pages.add(_dotsIndicator());
      }
      
      pages.add(_pageNumberButton(_totalPages));
    }
    
    return pages;
  }

  Widget _dotsIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Text(
        '...',
        style: TextStyle(
          color: Colors.white70,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _pageNumberButton(int pageNum) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton(
        onPressed: () => _changePage(pageNum),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: pageNum == _currentPage ? yellow : Colors.white24,
          ),
          foregroundColor: pageNum == _currentPage ? yellow : Colors.white70,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          minimumSize: const Size(36, 36),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text('$pageNum'),
      ),
    );
  }

 Widget _filterButton() {
  return ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 150),
    child: ElevatedButton.icon(
      onPressed: _showFilterDialog,
      icon: const Icon(Icons.tune, color: Colors.black),
      label: const Text(
        'FILTER PCS',
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: yellow,
        foregroundColor: Colors.black,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: const StadiumBorder(),
        minimumSize: const Size(0, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    ),
  );
}

  Future<void> _showFilterDialog() async {
    final filters = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => FilterDialog(initialFilters: _currentFilters),
    );

    if (filters != null) {
      setState(() {
        _currentFilters = filters;
        _currentPage = 1;
      });
      _loadPcs();
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _loadPcs() async {
    setState(() => _loading = true);
    try {
      final result = await PcService().getAll(
        page: _currentPage,
        pageSize: _pageSize,
        filters: _currentFilters,
      );
      setState(() {
        _pcs = result.items;
        _totalPages = result.totalPages;
      });
    } catch (e) {
      _snack('Error fetching PCs: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _changePage(int newPage) {
    if (newPage < 1 || newPage > _totalPages) return;
    setState(() {
      _currentPage = newPage;
    });
    _loadPcs();
  }
}
