import 'package:e_online/constants/colors.dart';
import 'package:e_online/controllers/product_controller.dart';
import 'package:e_online/utils/page_analytics.dart';
import 'package:e_online/widgets/heading_text.dart';
import 'package:e_online/widgets/no_data.dart';
import 'package:e_online/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:shimmer/shimmer.dart';

class CategoriesProductsPage extends StatefulWidget {
  final dynamic category;
  bool hideAppBar = false;

  CategoriesProductsPage(
      {super.key, required this.category, this.hideAppBar = false});

  @override
  State<CategoriesProductsPage> createState() => _CategoriesProductsPageState();
}

class _CategoriesProductsPageState extends State<CategoriesProductsPage> {
  bool loading = true;
  List products = [];
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int _currentPage = 1;
  final int _limit = 10; // Kept at 10 as per original code
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String _selectedSubcategoryId = '';
  String _searchKeyword = '';
  Map<String, dynamic> _activeFilters = {}; // Store active spec filters

  @override
  void initState() {
    super.initState();
    trackScreenView("CategoriesProductsPage");
    _fetchProducts(_currentPage); // Initial fetch
    _scrollController.addListener(_onScroll); // Attach scroll listener
  }

  Future<void> _fetchProducts(int page) async {
    if (page > 1 && (_isLoadingMore || !_hasMore)) return; // Prevent overlap
    if (page == 1) {
      setState(() => loading = true); // Only show initial loading for first
    }
    if (page > 1) setState(() => _isLoadingMore = true);

    try {
      final targetId = _selectedSubcategoryId.isNotEmpty
          ? _selectedSubcategoryId
          : widget.category["id"];
      final res = await ProductController().getProducts(
        page: page,
        limit: _limit,
        keyword: _searchKeyword,
        category: targetId,
        specFilters: _activeFilters, // Pass specification filters
      );

      final filteredRes = res; // Server handles filtering

      setState(() {
        if (filteredRes.isEmpty || filteredRes.length < _limit) {
          _hasMore = false; // No more data to fetch
        }

        if (page == 1) {
          products = filteredRes; // Replace for first page
        } else {
          products = [
            ...products,
            ...filteredRes,
          ]; // Append for subsequent pages
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading products: $e')),
      );
    } finally {
      if (page == 1) setState(() => loading = false);
      if (page > 1) setState(() => _isLoadingMore = false);
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoadingMore &&
        _hasMore) {
      _currentPage++;
      _fetchProducts(_currentPage);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose(); // Clean up the controller
    _searchController.dispose(); // Clean up the search controller
    super.dispose();
  }

  Widget _buildSearchBarWithFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          // Filter icon
          if (widget.category["CategoryProductSpecifications"] != null &&
              (widget.category["CategoryProductSpecifications"] as List)
                  .isNotEmpty)
            InkWell(
              onTap: () => _showFiltersBottomSheet(),
              child: Container(
                padding: const EdgeInsets.all(6),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  border: Border.all(color: primary),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(Icons.filter_list, size: 18, color: primary),
              ),
            ),
          // Search bar
          Expanded(
            child: Container(
              height: 38,
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchKeyword = value;
                    _currentPage = 1;
                    _hasMore = true;
                    products = [];
                  });
                  // Debounce search to avoid too many API calls
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_searchController.text == value) {
                      _fetchProducts(_currentPage);
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search products in this category...',
                  hintStyle: TextStyle(fontSize: 15),
                  prefixIcon:
                      Icon(Icons.search, color: mutedTextColor, size: 18),
                  suffixIcon: _searchKeyword.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear,
                              color: mutedTextColor, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              _searchKeyword = '';
                              _currentPage = 1;
                              _hasMore = true;
                              products = [];
                            });
                            _fetchProducts(_currentPage);
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(40),
                    borderSide: BorderSide(color: primary, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  isDense: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mainColor,
      appBar: widget.hideAppBar
          ? null
          : AppBar(
              backgroundColor: mainColor,
              elevation: 0,
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: mutedTextColor,
                  size: 14.0,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              title: HeadingText(widget.category["name"]),
              centerTitle: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(
                  color: const Color.fromARGB(255, 242, 242, 242),
                  height: 1.0,
                ),
              ),
              actions: [
                const SizedBox(width: 16),
              ],
            ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((widget.category["Subcategories"] as List?)?.isNotEmpty == true)
              SizedBox(
                height: 38,
                child: Builder(builder: (context) {
                  final subs = (widget.category["Subcategories"] as List)
                      .cast<Map<String, dynamic>>();
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: subs.length + 1,
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        final isSelected = _selectedSubcategoryId.isEmpty;
                        return ChoiceChip(
                          padding: EdgeInsets.all(0),
                          label: const Text('All'),
                          selected: isSelected,
                          backgroundColor: primaryColor,
                          selectedColor: primary,
                          labelStyle: TextStyle(
                            color: isSelected ? mainColor : mutedTextColor,
                          ),
                          side: BorderSide(
                            color: isSelected ? primary : Colors.grey.shade300,
                          ),
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          onSelected: (val) {
                            if (!isSelected) {
                              setState(() {
                                _selectedSubcategoryId = '';
                                _currentPage = 1;
                                _hasMore = true;
                                products = [];
                                // Reset search when switching to "All"
                                _searchController.clear();
                                _searchKeyword = '';
                              });
                              _fetchProducts(_currentPage);
                            }
                          },
                        );
                      }
                      final sub = subs[index - 1];
                      final isSelected = _selectedSubcategoryId == sub["id"];
                      return ChoiceChip(
                        padding: const EdgeInsets.all(0),
                        label: Text(
                            "${sub["name"]} (${sub["productsCount"] ?? 0})"),
                        selected: isSelected,
                        backgroundColor: primaryColor,
                        selectedColor: primary,
                        labelStyle: TextStyle(
                          color: isSelected ? mainColor : mutedTextColor,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? primary
                              : mutedTextColor.withOpacity(0.2),
                        ),
                        showCheckmark: false,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        onSelected: (val) {
                          final newId = val ? sub["id"] : '';
                          if (_selectedSubcategoryId != newId) {
                            setState(() {
                              _selectedSubcategoryId = newId;
                              _currentPage = 1;
                              _hasMore = true;
                              products = [];
                              // Reset search when switching subcategories
                              _searchController.clear();
                              _searchKeyword = '';
                            });
                            _fetchProducts(_currentPage);
                          }
                        },
                      );
                    },
                  );
                }),
              ),
            // Add search bar with filter icon
            _buildSearchBarWithFilter(),
            // Add specification filters if they exist
            if ((widget.category["CategoryProductSpecifications"] as List?)
                    ?.isNotEmpty ==
                true)
              _buildSpecificationFilters(),
            Expanded(
              child: Builder(builder: (context) {
                if (loading && _currentPage == 1) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(color: Colors.black),
                    ),
                  );
                }
                if (products.isEmpty) {
                  return Center(child: SingleChildScrollView(child: noData()));
                }
                return MasonryGridView.count(
                  controller: _scrollController,
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  physics: const BouncingScrollPhysics(),
                  itemCount: products.length + (_isLoadingMore ? 2 : 0),
                  itemBuilder: (context, index) {
                    if (index < products.length) {
                      final product = products[index];
                      return ProductCard(
                        isStagger: true,
                        data: product,
                      );
                    }
                    // Loading placeholders when fetching more
                    return Shimmer.fromColors(
                      baseColor: Colors.grey.shade200,
                      highlightColor: Colors.grey.shade50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Container(height: 180, color: Colors.black),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecificationFilters() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Show active filters as chips and filters button
          SizedBox(
            height: _activeFilters.length == 0 ? 1 : 28,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _activeFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                // Active filter chips
                final filterKey = _activeFilters.keys.elementAt(index);
                final filterValue = _activeFilters[filterKey];

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$filterKey: $filterValue',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                      const SizedBox(width: 3),
                      InkWell(
                        onTap: () => _removeFilter(filterKey),
                        child: const Icon(Icons.close,
                            size: 14, color: Colors.white),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _removeFilter(String filterKey) {
    setState(() {
      _activeFilters.remove(filterKey);
      _currentPage = 1;
      _hasMore = true;
      products = [];
    });
    _fetchProducts(_currentPage);
  }

  void _showFiltersBottomSheet() {
    final specs = (widget.category["CategoryProductSpecifications"] as List)
        .cast<Map<String, dynamic>>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      if (_activeFilters.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _activeFilters.clear();
                              _currentPage = 1;
                              _hasMore = true;
                              products = [];
                            });
                            _fetchProducts(_currentPage);
                          },
                          child: Text(
                            'Clear All',
                            style: TextStyle(color: primary),
                          ),
                        ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: specs.length,
                itemBuilder: (context, index) {
                  final spec = specs[index];
                  return _buildBottomSheetFilterWidget(spec);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetFilterWidget(Map<String, dynamic> spec) {
    final inputStyle = spec["inputStyle"] ?? "single-select";
    final label = spec["label"] ?? "";

    // Handle different data structures for values
    List<String> values = [];
    final valuesData = spec["values"];

    if (valuesData is List) {
      // If values is already a list
      values = valuesData.cast<String>();
    } else if (valuesData is Map) {
      // If values is a map, extract the values or keys
      if (valuesData.containsKey('options') && valuesData['options'] is List) {
        values = (valuesData['options'] as List).cast<String>();
      } else {
        // Try to use the map values as options
        values = valuesData.values
            .where((v) => v != null)
            .map((v) => v.toString())
            .toList();
      }
    } else if (valuesData is String) {
      // If it's a single string, split by comma or use as single option
      values = valuesData.contains(',')
          ? valuesData.split(',').map((s) => s.trim()).toList()
          : [valuesData];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          _buildBottomSheetFilterInput(inputStyle, label, values),
        ],
      ),
    );
  }

  Widget _buildBottomSheetFilterInput(
      String inputStyle, String label, List<String> values) {
    switch (inputStyle) {
      case "single-select":
        return _buildBottomSheetDropdown(label, values);
      case "multi-select":
        return _buildBottomSheetMultiSelect(label, values);
      case "toggle":
        return _buildBottomSheetToggle(label);
      case "range":
        return _buildBottomSheetRange(label);
      default:
        return _buildBottomSheetDropdown(label, values);
    }
  }

  Widget _buildBottomSheetDropdown(String label, List<String> values) {
    final currentValue = _activeFilters[label] as String?;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          hint: Text('Select $label'),
          value: currentValue,
          onChanged: (String? newValue) {
            setState(() {
              if (newValue != null && newValue.isNotEmpty) {
                _activeFilters[label] = newValue;
              } else {
                _activeFilters.remove(label);
              }
              _currentPage = 1;
              _hasMore = true;
              products = [];
            });
            _fetchProducts(_currentPage);
            Navigator.pop(context); // Close bottom sheet after selection
          },
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text('Any $label', style: TextStyle(color: Colors.grey)),
            ),
            ...values.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomSheetMultiSelect(String label, List<String> values) {
    final selectedValues = (_activeFilters[label] as List<String>?) ?? [];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values.map((value) {
        final isSelected = selectedValues.contains(value);
        return FilterChip(
          label: Text(value),
          selected: isSelected,
          backgroundColor: primaryColor,
          selectedColor: primary,
          checkmarkColor: Colors.white,
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : mutedTextColor,
            fontSize: 12,
          ),
          side: BorderSide(
            color: isSelected ? primary : mutedTextColor.withOpacity(0.2),
          ),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                if (!selectedValues.contains(value)) {
                  _activeFilters[label] = [...selectedValues, value];
                }
              } else {
                final newList =
                    selectedValues.where((item) => item != value).toList();
                if (newList.isEmpty) {
                  _activeFilters.remove(label);
                } else {
                  _activeFilters[label] = newList;
                }
              }
              _currentPage = 1;
              _hasMore = true;
              products = [];
            });
            _fetchProducts(_currentPage);
          },
        );
      }).toList(),
    );
  }

  Widget _buildBottomSheetToggle(String label) {
    final isEnabled = _activeFilters[label] == true;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Switch(
            value: isEnabled,
            activeColor: primary,
            onChanged: (value) {
              setState(() {
                if (value) {
                  _activeFilters[label] = true;
                } else {
                  _activeFilters.remove(label);
                }
                _currentPage = 1;
                _hasMore = true;
                products = [];
              });
              _fetchProducts(_currentPage);
            },
          ),
          const SizedBox(width: 8),
          Text('Enable $label'),
        ],
      ),
    );
  }

  Widget _buildBottomSheetRange(String label) {
    final currentRange = _activeFilters[label] as Map<String, dynamic>?;
    final minController = TextEditingController(
      text: currentRange?['min']?.toString() ?? '',
    );
    final maxController = TextEditingController(
      text: currentRange?['max']?.toString() ?? '',
    );

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: minController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Min $label',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: const TextStyle(fontSize: 14),
            onChanged: (value) {
              _updateRangeFilter(label, 'min', value, maxController.text);
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextField(
            controller: maxController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Max $label',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            style: const TextStyle(fontSize: 14),
            onChanged: (value) {
              _updateRangeFilter(label, 'max', value, minController.text);
            },
          ),
        ),
      ],
    );
  }

  void _updateRangeFilter(
      String label, String type, String value, String otherValue) {
    final currentRange = _activeFilters[label] as Map<String, dynamic>? ?? {};

    if (value.isNotEmpty) {
      currentRange[type] = value;
      if (currentRange.isNotEmpty) {
        _activeFilters[label] = currentRange;
      }
    } else {
      currentRange.remove(type);
      if (currentRange.isEmpty) {
        _activeFilters.remove(label);
      } else {
        _activeFilters[label] = currentRange;
      }
    }

    // Call API after a short delay to avoid too many calls while typing
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _currentPage = 1;
        _hasMore = true;
        products = [];
      });
      _fetchProducts(_currentPage);
    });
  }
}
