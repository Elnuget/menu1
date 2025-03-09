import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import '../../services/database_service.dart';

class AdminMenuScreen extends StatefulWidget {
  const AdminMenuScreen({super.key});

  @override
  State<AdminMenuScreen> createState() => _AdminMenuScreenState();
}

class _AdminMenuScreenState extends State<AdminMenuScreen> with SingleTickerProviderStateMixin {
  final List<MenuItem> _menuItems = [];
  bool _isLoading = true;
  String _filter = '';
  String _selectedCategory = 'Todos';
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Todos', 'icon': Icons.all_inclusive, 'color': Colors.blue},
    {'name': 'Entradas', 'icon': Icons.restaurant_menu, 'color': Colors.orange},
    {'name': 'Platos Fuertes', 'icon': Icons.lunch_dining, 'color': Colors.red},
    {'name': 'Bebidas', 'icon': Icons.local_drink, 'color': Colors.blue},
    {'name': 'Postres', 'icon': Icons.icecream, 'color': Colors.pink},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadMenuItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedCategory = _categories[_tabController.index]['name'];
      });
    }
  }

  Future<void> _loadMenuItems() async {
    try {
      final items = await DatabaseService().getMenuItems();
      setState(() {
        _menuItems.clear();
        _menuItems.addAll(items);
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar menú: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<MenuItem> get _filteredItems {
    return _menuItems.where((item) {
      final matchesFilter = _filter.isEmpty || 
          item.name.toLowerCase().contains(_filter.toLowerCase());
      
      final matchesCategory = _selectedCategory == 'Todos' || 
          item.category == _selectedCategory;
      
      return matchesFilter && matchesCategory;
    }).toList();
  }

  Future<void> _showItemDialog([MenuItem? item]) async {
    final nameController = TextEditingController(text: item?.name);
    final priceController = TextEditingController(
        text: item?.price.toString() ?? '0.0');
    String category = item?.category ?? 'Entradas';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              item == null ? Icons.add_circle : Icons.edit,
              color: Colors.blue.shade700,
            ),
            const SizedBox(width: 8),
            Text(item == null ? 'Agregar Producto' : 'Editar Producto'),
          ],
        ),
        content: SingleChildScrollView(
          child: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.fastfood),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: priceController,
                  decoration: const InputDecoration(
                    labelText: 'Precio',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(
                    labelText: 'Categoría',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.category),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Entradas', child: Text('Entradas')),
                    DropdownMenuItem(
                        value: 'Platos Fuertes', child: Text('Platos Fuertes')),
                    DropdownMenuItem(value: 'Bebidas', child: Text('Bebidas')),
                    DropdownMenuItem(value: 'Postres', child: Text('Postres')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      category = value;
                    }
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.cancel),
            label: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton.icon(
            icon: Icon(item == null ? Icons.add : Icons.save),
            label: Text(item == null ? 'Agregar' : 'Guardar'),
            onPressed: () async {
              if (nameController.text.isEmpty || priceController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Todos los campos son obligatorios'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              final price = double.tryParse(priceController.text);
              if (price == null || price <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('El precio debe ser un número positivo'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }
              
              final newItem = MenuItem(
                name: nameController.text,
                price: price,
                category: category,
              );

              try {
                if (item == null) {
                  await DatabaseService().addMenuItem(newItem);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto agregado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  await DatabaseService()
                      .updateMenuItem(newItem, item.name);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Producto actualizado exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
                if (mounted) {
                  Navigator.pop(context);
                  _loadMenuItems();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _deleteItem(MenuItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            const SizedBox(width: 8),
            const Text('Confirmar Eliminación'),
          ],
        ),
        content: Text('¿Está seguro de eliminar "${item.name}"?'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.cancel),
            label: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await DatabaseService().deleteMenuItem(item.name);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} eliminado exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
        _loadMenuItems();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al eliminar: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Color _getCategoryColor(String category) {
    final categoryMap = _categories.firstWhere(
      (cat) => cat['name'] == category,
      orElse: () => {'color': Colors.blue},
    );
    return categoryMap['color'] as Color;
  }

  IconData _getCategoryIcon(String category) {
    final categoryMap = _categories.firstWhere(
      (cat) => cat['name'] == category,
      orElse: () => {'icon': Icons.help},
    );
    return categoryMap['icon'] as IconData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.restaurant_menu),
            const SizedBox(width: 8),
            const Text('Administrar Menú'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar menú',
            onPressed: _loadMenuItems,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories.map((category) {
            return Tab(
              icon: Icon(category['icon'] as IconData),
              text: category['name'] as String,
            );
          }).toList(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar producto...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _filter.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _filter = '';
                              });
                            },
                          )
                        : null,
                    border: InputBorder.none,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _filter = value;
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.no_food,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No hay productos disponibles',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.add),
                              label: const Text('Añadir producto'),
                              onPressed: () => _showItemDialog(),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          final categoryColor = _getCategoryColor(item.category);
                          final categoryIcon = _getCategoryIcon(item.category);
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            elevation: 2,
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: categoryColor.withOpacity(0.2),
                                child: Icon(
                                  categoryIcon,
                                  color: categoryColor,
                                ),
                              ),
                              title: Text(
                                item.name,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: categoryColor.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      item.category,
                                      style: TextStyle(
                                        color: categoryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '\$${item.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _showItemDialog(item),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteItem(item),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showItemDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar Producto'),
        backgroundColor: Colors.blue.shade700,
      ),
    );
  }
} 