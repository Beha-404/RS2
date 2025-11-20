import 'package:desktop/models/order.dart';
import 'package:desktop/services/order_service.dart';
import 'package:desktop/services/pdf_report_service.dart';
import 'package:desktop/widgets/order_details_dialog.dart';
import 'package:desktop/widgets/desktop_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class OrdersPage extends StatefulWidget {
	const OrdersPage({super.key});

	@override
	State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
	final OrderService _orderService = const OrderService();
	List<Order> _orders = [];
	bool _isLoading = true;
	String? _errorMessage;
	int _currentPage = 1;
	int _pageSize = 10;
	int _totalCount = 0;
	final TextEditingController _searchController = TextEditingController();
	final List<int> _pageSizeOptions = [5, 10, 20, 50];

	@override
	void initState() {
		super.initState();
		_loadOrders();
	}

	@override
	void dispose() {
		_searchController.dispose();
		super.dispose();
	}

	Future<void> _loadOrders({int? searchOrderId}) async {
		setState(() {
			_isLoading = true;
			_errorMessage = null;
		});

		try {
			final result = await _orderService.get(
				page: _currentPage,
				pageSize: _pageSize,
				orderId: searchOrderId,
			);

			setState(() {
				_orders = result['items'] as List<Order>;
				_totalCount = result['totalCount'] as int;
				_isLoading = false;
			});
		} catch (e) {
			setState(() {
				_errorMessage = 'Failed to load orders: $e';
				_isLoading = false;
			});
		}
	}

	void _searchByOrderId() {
		final searchText = _searchController.text.trim();
		if (searchText.isNotEmpty) {
			final orderId = int.tryParse(searchText);
			if (orderId != null) {
				setState(() => _currentPage = 1);
				_loadOrders(searchOrderId: orderId);
			}
		} else {
			setState(() => _currentPage = 1);
			_loadOrders();
		}
	}

	void _goToPage(int page) {
		if (page < 1 || page > _totalPages) return;
		setState(() => _currentPage = page);
		_loadOrders();
	}

	void _changePageSize(int newSize) {
		setState(() {
			_pageSize = newSize;
			_currentPage = 1; // Reset to first page when changing page size
		});
		_loadOrders();
	}

	int get _totalPages => (_totalCount / _pageSize).ceil();

	List<Widget> _buildPageNumbers() {
		List<Widget> pageButtons = [];
		int startPage = (_currentPage - 2).clamp(1, _totalPages);
		int endPage = (_currentPage + 2).clamp(1, _totalPages);

		if (_currentPage <= 3) {
			endPage = 5.clamp(1, _totalPages);
		}

		if (_currentPage >= _totalPages - 2) {
			startPage = (_totalPages - 4).clamp(1, _totalPages);
		}

		if (startPage > 1) {
			pageButtons.add(_buildPageButton(1));
			if (startPage > 2) {
				pageButtons.add(Padding(
					padding: const EdgeInsets.symmetric(horizontal: 4),
					child: Text('...', style: TextStyle(color: Colors.white54)),
				));
			}
		}

		for (int i = startPage; i <= endPage; i++) {
			pageButtons.add(_buildPageButton(i));
		}

		if (endPage < _totalPages) {
			if (endPage < _totalPages - 1) {
				pageButtons.add(Padding(
					padding: const EdgeInsets.symmetric(horizontal: 4),
					child: Text('...', style: TextStyle(color: Colors.white54)),
				));
			}
			pageButtons.add(_buildPageButton(_totalPages));
		}

		return pageButtons;
	}

	Widget _buildPageButton(int page) {
		final isActive = page == _currentPage;
		return Container(
			margin: const EdgeInsets.symmetric(horizontal: 4),
			child: InkWell(
				onTap: () => _goToPage(page),
				borderRadius: BorderRadius.circular(4),
				child: Container(
					padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
					decoration: BoxDecoration(
						color: isActive ? Color(0xFFFFCC00) : Colors.transparent,
						borderRadius: BorderRadius.circular(4),
						border: Border.all(
							color: isActive ? Color(0xFFFFCC00) : Colors.white24,
						),
					),
					child: Text(
						'$page',
						style: TextStyle(
							color: isActive ? Colors.black : Colors.white70,
							fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
						),
					),
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			backgroundColor: const Color(0xFF23191A),
			appBar: const DesktopAppBar(currentPage: 'Orders'),
			body: Container(
				width: double.infinity,
				height: double.infinity,
				decoration: const BoxDecoration(
					gradient: LinearGradient(
						begin: Alignment.topCenter,
						end: Alignment.bottomCenter,
						colors: [Color(0xFF232325), Color(0xFF2B1C1C)],
					),
				),
				child: SingleChildScrollView(
					child: Padding(
						padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 24),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.center,
							children: [
								const SizedBox(height: 8),
								Text(
									'Your Orders',
									style: TextStyle(
										color: Color(0xFFFFCC00),
										fontSize: 36,
										fontWeight: FontWeight.bold,
									),
									textAlign: TextAlign.center,
								),
								const SizedBox(height: 24),
								Row(
									mainAxisAlignment: MainAxisAlignment.center,
									children: [
										Expanded(
											child: TextField(
												controller: _searchController,
												decoration: InputDecoration(
													hintText: 'Search orders by ID',
													hintStyle: TextStyle(color: Colors.white70),
													filled: true,
													fillColor: Color(0xFF232325),
													border: OutlineInputBorder(
														borderRadius: BorderRadius.circular(6),
														borderSide: BorderSide(color: Colors.grey.shade700),
													),
													enabledBorder: OutlineInputBorder(
														borderRadius: BorderRadius.circular(6),
														borderSide: BorderSide(color: Colors.grey.shade700),
													),
													contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
												),
												style: TextStyle(color: Colors.white),
												onSubmitted: (_) => _searchByOrderId(),
											),
										),
										const SizedBox(width: 16),
										SizedBox(
											height: 48,
											child: ElevatedButton(
												onPressed: _searchByOrderId,
												style: ElevatedButton.styleFrom(
													backgroundColor: Color(0xFFFFCC00),
													foregroundColor: Colors.black,
												),
												child: Text('Search'),
											),
										),
										const SizedBox(width: 16),
										SizedBox(
											height: 48,
											child: ElevatedButton.icon(
												onPressed: _orders.isEmpty ? null : () async {
													try {
														final filePath = await PdfReportService.generateOrdersReport(_orders);
														if (mounted) {
															ScaffoldMessenger.of(context).showSnackBar(
																SnackBar(
																	content: Text('PDF saved to: $filePath'),
																	backgroundColor: Colors.green,
																	duration: Duration(seconds: 5),
																	action: SnackBarAction(
																		label: 'OK',
																		textColor: Colors.white,
																		onPressed: () {},
																	),
																),
															);
														}
													} catch (e) {
														if (mounted) {
															ScaffoldMessenger.of(context).showSnackBar(
																SnackBar(
																	content: Text('Error saving PDF: $e'),
																	backgroundColor: Colors.red,
																	duration: Duration(seconds: 3),
																),
															);
														}
													}
												},
												style: ElevatedButton.styleFrom(
													backgroundColor: Color(0xFFFFCC00),
													foregroundColor: Colors.black,
													disabledBackgroundColor: Colors.grey.shade700,
													disabledForegroundColor: Colors.grey.shade500,
												),
												icon: Icon(Icons.print),
												label: Text('Print All'),
											),
										),
									],
								),
								const SizedBox(height: 24),
								Row(
									mainAxisAlignment: MainAxisAlignment.spaceBetween,
									children: [
										Row(
											children: [
												Text(
													'Items per page:',
													style: TextStyle(color: Colors.white70, fontSize: 14),
												),
												const SizedBox(width: 12),
												Container(
													padding: EdgeInsets.symmetric(horizontal: 12),
													decoration: BoxDecoration(
														color: Color(0xFF232325),
														borderRadius: BorderRadius.circular(6),
														border: Border.all(color: Colors.grey.shade700),
													),
													child: DropdownButton<int>(
														value: _pageSize,
														dropdownColor: Color(0xFF232325),
														underline: Container(),
														style: TextStyle(color: Colors.white),
														items: _pageSizeOptions.map((size) {
															return DropdownMenuItem<int>(
																value: size,
																child: Text('$size'),
															);
														}).toList(),
														onChanged: (newSize) {
															if (newSize != null) {
																_changePageSize(newSize);
															}
														},
													),
												),
											],
										),
										if (_totalCount > 0)
											Text(
												'Total: $_totalCount orders',
												style: TextStyle(
													color: Color(0xFFFFCC00),
													fontSize: 14,
													fontWeight: FontWeight.bold,
												),
											),
									],
								),
								const SizedBox(height: 16),
								if (_isLoading)
									Center(
										child: CircularProgressIndicator(
											valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFCC00)),
										),
									)
								else if (_errorMessage != null)
									Center(
										child: Text(
											_errorMessage!,
											style: TextStyle(color: Colors.red, fontSize: 16),
										),
									)
								else if (_orders.isEmpty)
									Center(
										child: Text(
											'No orders found',
											style: TextStyle(color: Colors.white70, fontSize: 16),
										),
									)
								else
									..._orders.map((order) => _OrderCard(order: order)),
								const SizedBox(height: 32),
								if (_totalPages > 1) ...[
									Text(
										'Showing ${(_currentPage - 1) * _pageSize + 1}-${(_currentPage * _pageSize) > _totalCount ? _totalCount : (_currentPage * _pageSize)} of $_totalCount orders',
										style: TextStyle(color: Colors.white70, fontSize: 14),
										textAlign: TextAlign.center,
									),
									const SizedBox(height: 16),
									Row(
										mainAxisAlignment: MainAxisAlignment.center,
										children: [
											IconButton(
												onPressed: _currentPage > 1 ? () => _goToPage(1) : null,
												icon: Icon(
													Icons.first_page,
													color: _currentPage > 1 ? Colors.white70 : Colors.grey,
												),
											),
											TextButton(
												onPressed: _currentPage > 1 ? () => _goToPage(_currentPage - 1) : null,
												child: Row(
													children: [
														Text('«', style: TextStyle(color: _currentPage > 1 ? Colors.white70 : Colors.grey, fontSize: 18)),
														const SizedBox(width: 8),
														Text('Previous', style: TextStyle(color: _currentPage > 1 ? Colors.white70 : Colors.grey)),
													],
												),
											),
											const SizedBox(width: 16),
											..._buildPageNumbers(),
											const SizedBox(width: 16),
											TextButton(
												onPressed: _currentPage < _totalPages ? () => _goToPage(_currentPage + 1) : null,
												child: Row(
													children: [
														Text('Next', style: TextStyle(color: _currentPage < _totalPages ? Colors.white70 : Colors.grey)),
														const SizedBox(width: 8),
														Text('»', style: TextStyle(color: _currentPage < _totalPages ? Colors.white70 : Colors.grey, fontSize: 18)),
													],
												),
											),
											IconButton(
												onPressed: _currentPage < _totalPages ? () => _goToPage(_totalPages) : null,
												icon: Icon(
													Icons.last_page,
													color: _currentPage < _totalPages ? Colors.white70 : Colors.grey,
												),
											),
										],
									),
								],
								const SizedBox(height: 32),
							],
						),
					),
				),
			),
		);
	}
}



class _OrderCard extends StatelessWidget {
	final Order order;
	
	const _OrderCard({required this.order});

	@override
	Widget build(BuildContext context) {
		final dateFormat = DateFormat('dd-MM-yyyy');
		
		return Container(
			margin: const EdgeInsets.symmetric(vertical: 12),
			padding: const EdgeInsets.all(18),
			decoration: BoxDecoration(
				color: const Color(0xFF191919),
				border: Border.all(color: Color(0xFFFFCC00), width: 1.5),
				borderRadius: BorderRadius.circular(8),
			),
			child: Row(
				crossAxisAlignment: CrossAxisAlignment.start,
				children: [
					Expanded(
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							children: [
								Text('Order ID: #${order.id}', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
								const SizedBox(height: 4),
								Text('Date: ${dateFormat.format(order.orderDate)}', style: TextStyle(color: Colors.white)),
								const SizedBox(height: 4),
								Text('User ID: ${order.userId}', style: TextStyle(color: Colors.white)),
								const SizedBox(height: 4),
								if (order.paymentMethod != null)
									Row(
										children: [
											Text('Payment: ', style: TextStyle(color: Colors.white)),
											Container(
												padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
												decoration: BoxDecoration(
													color: Color(0xFFFFCC00).withOpacity(0.2),
													borderRadius: BorderRadius.circular(4),
													border: Border.all(color: Color(0xFFFFCC00)),
												),
												child: Text(
													order.paymentMethod!,
													style: TextStyle(
														color: Color(0xFFFFCC00),
														fontWeight: FontWeight.bold,
													),
												),
											),
										],
									),
								const SizedBox(height: 4),
								Text('Total: \$${order.totalPrice}', style: TextStyle(color: Colors.white)),
							],
						),
					),
					Row(
						mainAxisSize: MainAxisSize.min,
						children: [
							IconButton(
								onPressed: () async {
									try {
										final filePath = await PdfReportService.generateSingleOrderReport(order);
										if (context.mounted) {
											ScaffoldMessenger.of(context).showSnackBar(
												SnackBar(
													content: Text('PDF saved to: $filePath'),
													backgroundColor: Colors.green,
													duration: Duration(seconds: 5),
													action: SnackBarAction(
														label: 'OK',
														textColor: Colors.white,
														onPressed: () {},
													),
												),
											);
										}
									} catch (e) {
										if (context.mounted) {
											ScaffoldMessenger.of(context).showSnackBar(
												SnackBar(
													content: Text('Error saving PDF: $e'),
													backgroundColor: Colors.red,
													duration: Duration(seconds: 3),
												),
											);
										}
									}
								},
								icon: Icon(Icons.print, color: Color(0xFFFFCC00)),
								tooltip: 'Print Order',
							),
							const SizedBox(width: 8),
							SizedBox(
								width: 120,
								child: ElevatedButton(
									onPressed: () => OrderDetailsDialog.show(context, order),
									style: ElevatedButton.styleFrom(
										backgroundColor: Color(0xFFFFCC00),
										foregroundColor: Colors.black,
										padding: const EdgeInsets.symmetric(vertical: 12),
										shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
									),
									child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.bold)),
								),
							),
						],
					),
				],
			),
		);
	}
}
