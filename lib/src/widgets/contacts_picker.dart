import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../models/contact_picker_model.dart';
import '../utils/contact_utils.dart';

// ─────────────────────────────────────────────────────────────────────────────
// List entries (section header or contact row)
// ─────────────────────────────────────────────────────────────────────────────

sealed class _Entry {
  const _Entry();
}

class _HeaderEntry extends _Entry {
  const _HeaderEntry(this.letter);
  final String letter;
}

class _ContactEntry extends _Entry {
  const _ContactEntry(this.contact);
  final ContactPickerModel contact;
}

// ─────────────────────────────────────────────────────────────────────────────
// Contacts picker
// ─────────────────────────────────────────────────────────────────────────────

class ContactsPicker extends StatefulWidget {
  final Function(ContactPickerModel)? onContactSelected;
  final bool multiSelect;

  const ContactsPicker({
    super.key,
    this.onContactSelected,
    this.multiSelect = false,
  });

  @override
  State<ContactsPicker> createState() => _ContactsPickerState();
}

class _ContactsPickerState extends State<ContactsPicker> {
  static const double _headerHeight = 36;
  static const double _tileHeight = 68;
  static const double _sidebarWidth = 30;
  static const double _bubbleSize = 56;

  static const List<String> _filters = ['All', 'Phone', 'Email'];
  static const List<String> alphabet = [
    '#', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', //
    'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z',
  ];

  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode _searchFocus = FocusNode();

  final List<_Entry> _entries = [];
  final List<double> _offsets = [];
  final Map<String, double> _letterOffsets = {};
  final Set<String> _selectedIds = {};

  List<ContactPickerModel> contacts = [];
  List<ContactPickerModel> filteredContacts = [];

  String selectedFilter = 'All';
  String selectedLetter = '#';

  /// Letter currently being touched on the sidebar (null when idle).
  String? _scrubLetter;

  /// Letter that has no contacts – drives the "No contacts found" message.
  String? _emptyLetter;
  Timer? _emptyTimer;

  bool isLoading = true;
  bool _permissionDenied = false;

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    searchController.addListener(_applyFilters);
    scrollController.addListener(_onScroll);
    getContacts();
  }

  @override
  void dispose() {
    _emptyTimer?.cancel();
    searchController.removeListener(_applyFilters);
    scrollController.removeListener(_onScroll);
    searchController.dispose();
    scrollController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  // ── Data ───────────────────────────────────────────────────────────────────

  /// Note: no setState before the first `await`, so it is safe in initState.
  Future<void> getContacts() async {
    try {
      final permission = await FlutterContacts.permissions.request(
        PermissionType.read,
      );

      if (permission != PermissionStatus.granted &&
          permission != PermissionStatus.limited) {
        if (!mounted) return;
        setState(() {
          isLoading = false;
          _permissionDenied = true;
        });
        return;
      }

      final result = await FlutterContacts.getAll(
        properties: {
          ContactProperty.name,
          ContactProperty.phone,
          ContactProperty.email,
          ContactProperty.photoThumbnail,
        },
      );

      final loaded = result.map((contact) {
        return ContactPickerModel(
          id: contact.id ?? '',
          displayName: contact.displayName ?? 'Unknown',
          phones: contact.phones.map((phone) => phone.number).toList(),
          emails: contact.emails.map((email) => email.address).toList(),
          photo: contact.photo != null ? contact.id : null,
        );
      }).toList();

      if (!mounted) return;

      contacts = loaded..sort(_compareContacts);
      _applyFilters();
      setState(() => isLoading = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  void _retryPermission() {
    setState(() {
      isLoading = true;
      _permissionDenied = false;
    });
    getContacts();
  }

  /// "#" (symbols / numbers) first, then A–Z, alphabetical inside each group.
  int _compareContacts(ContactPickerModel a, ContactPickerModel b) {
    final la = _letterOf(a.displayName);
    final lb = _letterOf(b.displayName);
    if (la != lb) return alphabet.indexOf(la).compareTo(alphabet.indexOf(lb));
    return a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase());
  }

  String _letterOf(String name) {
    final letter = ContactUtils.getFirstLetter(name).toUpperCase();
    return alphabet.contains(letter) ? letter : '#';
  }

  String _firstChar(String value) => String.fromCharCode(value.runes.first);

  String _initialsOf(String name) {
    final words = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    final first = _firstChar(words.first);
    final last = words.length > 1 ? _firstChar(words.last) : '';
    return (first + last).toUpperCase();
  }

  // ── Search / filter ────────────────────────────────────────────────────────

  void changeFilter(String filter) {
    if (filter == selectedFilter) return;
    selectedFilter = filter;
    _applyFilters();
  }

  void _applyFilters() {
    if (!mounted) return;

    final searched = ContactUtils.searchContacts(
      contacts,
      searchController.text,
    );
    final result = List<ContactPickerModel>.of(
      ContactUtils.filterContacts(searched, selectedFilter),
    )..sort(_compareContacts); // guarantees one header per letter

    setState(() {
      filteredContacts = result;
      _emptyLetter = null;
      _rebuildIndex();

      final first = _entries.isNotEmpty ? _entries.first : null;
      selectedLetter = first is _HeaderEntry ? first.letter : '#';
    });

    if (scrollController.hasClients) scrollController.jumpTo(0);
  }

  /// Builds the flat list (headers + contacts) and the scroll offset table.
  void _rebuildIndex() {
    _entries.clear();
    _offsets.clear();
    _letterOffsets.clear();

    double offset = 0;
    String? current;

    for (final contact in filteredContacts) {
      final letter = _letterOf(contact.displayName);

      if (letter != current) {
        current = letter;
        _letterOffsets.putIfAbsent(letter, () => offset);
        _entries.add(_HeaderEntry(letter));
        _offsets.add(offset);
        offset += _headerHeight;
      }

      _entries.add(_ContactEntry(contact));
      _offsets.add(offset);
      offset += _tileHeight;
    }
  }

  // ── Selection ──────────────────────────────────────────────────────────────

  void selectContact(ContactPickerModel contact) {
    if (widget.multiSelect) {
      setState(() {
        if (!_selectedIds.add(contact.id)) _selectedIds.remove(contact.id);
      });
    }
    widget.onContactSelected?.call(contact);
  }

  // ── Scrolling & alphabet ───────────────────────────────────────────────────

  int _entryIndexAt(double offset) {
    int low = 0;
    int high = _offsets.length - 1;
    while (low < high) {
      final mid = (low + high + 1) >> 1;
      if (_offsets[mid] <= offset) {
        low = mid;
      } else {
        high = mid - 1;
      }
    }
    return low;
  }

  void _onScroll() {
    if (_scrubLetter != null ||
        !scrollController.hasClients ||
        _entries.isEmpty) {
      return;
    }

    final entry = _entries[_entryIndexAt(scrollController.offset)];
    final String current = switch (entry) {
      _HeaderEntry(:final letter) => letter,
      _ContactEntry(:final contact) => _letterOf(contact.displayName),
    };

    if (current != selectedLetter && mounted) {
      setState(() => selectedLetter = current);
    }
  }

  void _onScrub(double dy, double height) {
    if (height <= 0) return;

    final int index = (dy / (height / alphabet.length))
        .floor()
        .clamp(0, alphabet.length - 1)
        .toInt();
    final letter = alphabet[index];

    if (letter == _scrubLetter) return;

    HapticFeedback.selectionClick();
    _emptyTimer?.cancel();

    final offset = _letterOffsets[letter];

    setState(() {
      _scrubLetter = letter;
      if (offset == null) {
        _emptyLetter = letter; // nothing under this letter
      } else {
        _emptyLetter = null;
        selectedLetter = letter;
      }
    });

    if (offset != null && scrollController.hasClients) {
      final maxScroll = scrollController.position.maxScrollExtent;
      scrollController.jumpTo(offset.clamp(0.0, maxScroll).toDouble());
    }
  }

  void _endScrub() {
    if (!mounted) return;
    setState(() => _scrubLetter = null);

    // Keep the "No contacts found" message visible for a moment.
    if (_emptyLetter != null) {
      _emptyTimer?.cancel();
      _emptyTimer = Timer(const Duration(milliseconds: 1600), () {
        if (mounted) setState(() => _emptyLetter = null);
      });
    }
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: _buildSearchBar(context),
        ),
        const SizedBox(height: 14),
        _buildFilterRow(context),
        const SizedBox(height: 8),
        Expanded(child: _buildBody(context)),
      ],
    );
  }

  // Search bar ────────────────────────────────────────────────────────────────

  Widget _buildSearchBar(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: scheme.primary.withValues(alpha: 0.10),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        focusNode: _searchFocus,
        textInputAction: TextInputAction.search,
        onTapOutside: (_) => _searchFocus.unfocus(),
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Search name, phone or email',
          hintStyle: TextStyle(
            color: scheme.onSurface.withValues(alpha: 0.4),
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: scheme.primary),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: searchController,
            builder: (_, value, __) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                color: scheme.onSurface.withValues(alpha: 0.5),
                onPressed: searchController.clear,
              );
            },
          ),
          filled: true,
          fillColor: scheme.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
          border: _searchBorder(Colors.transparent),
          enabledBorder: _searchBorder(Colors.transparent),
          focusedBorder: _searchBorder(scheme.primary.withValues(alpha: 0.6)),
        ),
      ),
    );
  }

  OutlineInputBorder _searchBorder(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(18),
    borderSide: BorderSide(color: color, width: 1.5),
  );

  // Filter chips ──────────────────────────────────────────────────────────────

  Widget _buildFilterRow(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    const icons = {
      'All': Icons.people_alt_rounded,
      'Phone': Icons.phone_rounded,
      'Email': Icons.email_rounded,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          for (final filter in _filters) ...[
            _FilterPill(
              label: filter,
              icon: icons[filter]!,
              selected: selectedFilter == filter,
              onTap: () => changeFilter(filter),
            ),
            const SizedBox(width: 8),
          ],
          // Expanded + FittedBox prevents a RenderFlex overflow on narrow phones.
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: (!isLoading && !_permissionDenied)
                  ? FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${filteredContacts.length} contacts',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: scheme.onSurface.withValues(alpha: 0.45),
                  ),
                ),
              )
                  : const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  // Body ──────────────────────────────────────────────────────────────────────

  Widget _buildBody(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_permissionDenied) {
      return _StateMessage(
        icon: Icons.lock_outline_rounded,
        title: 'Contacts permission needed',
        message: 'Allow access to your contacts to pick someone.',
        actionLabel: 'Allow access',
        onAction: _retryPermission,
      );
    }

    if (filteredContacts.isEmpty) {
      final query = searchController.text.trim();
      return _StateMessage(
        icon: Icons.person_search_rounded,
        title: 'No contacts found',
        message: query.isNotEmpty
            ? 'No results for “$query”.'
            : selectedFilter == 'All'
            ? 'Your contact list is empty.'
            : 'No contacts with a ${selectedFilter.toLowerCase()} found.',
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;

        return Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _buildList(context)),
                _buildSidebar(context, height),
                const SizedBox(width: 6),
              ],
            ),
            _buildEmptyLetterMessage(context),
            _buildBubble(context, height),
          ],
        );
      },
    );
  }

  // List ──────────────────────────────────────────────────────────────────────

  Widget _buildList(BuildContext context) {
    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.only(left: 8, bottom: 16),
      itemCount: _entries.length,
      itemExtentBuilder: (index, _) =>
      _entries[index] is _HeaderEntry ? _headerHeight : _tileHeight,
      itemBuilder: (context, index) {
        return switch (_entries[index]) {
          _HeaderEntry(:final letter) => _buildHeader(context, letter),
          _ContactEntry(:final contact) => _buildTile(context, contact),
        };
      },
    );
  }

  Widget _buildHeader(BuildContext context, String letter) {
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 0, 6),
        child: Text(
          letter,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: scheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context, ContactPickerModel contact) {
    final scheme = Theme.of(context).colorScheme;
    final isSelected = _selectedIds.contains(contact.id);

    final name = contact.displayName.trim().isEmpty
        ? 'Unknown'
        : contact.displayName;
    final hasPhone = contact.phones.isNotEmpty;
    final hasEmail = contact.emails.isNotEmpty;

    final String subtitle;
    final IconData subtitleIcon;
    if (hasPhone) {
      subtitle = contact.phones.first;
      subtitleIcon = Icons.phone_rounded;
    } else if (hasEmail) {
      subtitle = contact.emails.first;
      subtitleIcon = Icons.email_rounded;
    } else {
      subtitle = 'No contact information';
      subtitleIcon = Icons.info_outline_rounded;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Material(
        color: isSelected
            ? scheme.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => selectContact(contact),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                _Avatar(name: name, initials: _initialsOf(name)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(
                            subtitleIcon,
                            size: 13,
                            color: scheme.onSurface.withValues(alpha: 0.4),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                color: scheme.onSurface.withValues(alpha: 0.55),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(Icons.check_circle_rounded, color: scheme.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Alphabet sidebar ──────────────────────────────────────────────────────────

  Widget _buildSidebar(BuildContext context, double height) {
    final scheme = Theme.of(context).colorScheme;

    // Only drag callbacks are used (no tap callbacks) so a tap-cancel can never
    // end the scrub in the middle of a drag.
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragDown: (d) => _onScrub(d.localPosition.dy, height),
      onVerticalDragStart: (d) => _onScrub(d.localPosition.dy, height),
      onVerticalDragUpdate: (d) => _onScrub(d.localPosition.dy, height),
      onVerticalDragEnd: (_) => _endScrub(),
      onVerticalDragCancel: _endScrub,
      child: Container(
        width: _sidebarWidth,
        decoration: BoxDecoration(
          color: scheme.onSurface.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            for (final letter in alphabet)
              Expanded(
                child: Center(
                  child: _SidebarLetter(
                    letter: letter,
                    isSelected: selectedLetter == letter,
                    isAvailable: _letterOffsets.containsKey(letter),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// Big magnified letter that follows the finger.
  Widget _buildBubble(BuildContext context, double height) {
    final letter = _scrubLetter;
    if (letter == null) return const SizedBox.shrink();

    final scheme = Theme.of(context).colorScheme;
    final available = _letterOffsets.containsKey(letter);
    final slot = height / alphabet.length;
    final maxTop = math.max(0.0, height - _bubbleSize);
    final top = (alphabet.indexOf(letter) * slot + slot / 2 - _bubbleSize / 2)
        .clamp(0.0, maxTop)
        .toDouble();

    return Positioned(
      right: _sidebarWidth + 22,
      top: top,
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          key: ValueKey(letter),
          tween: Tween(begin: 0.6, end: 1),
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutBack,
          builder: (_, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Container(
            width: _bubbleSize,
            height: _bubbleSize,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: available
                    ? [scheme.primary, scheme.primary.withValues(alpha: 0.75)]
                    : [Colors.grey.shade500, Colors.grey.shade400],
              ),
              boxShadow: [
                BoxShadow(
                  color: (available ? scheme.primary : Colors.grey)
                      .withValues(alpha: 0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              letter,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// "No contacts found" card shown when a letter has no matching contacts.
  Widget _buildEmptyLetterMessage(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final letter = _emptyLetter;

    final qualifier = selectedFilter == 'All'
        ? ''
        : ' with ${selectedFilter.toLowerCase()}';

    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: letter == null
              ? const SizedBox.shrink()
              : Center(
            key: ValueKey(letter),
            child: Container(
              margin: const EdgeInsets.only(right: 40),
              padding: const EdgeInsets.symmetric(
                horizontal: 28,
                vertical: 22,
              ),
              decoration: BoxDecoration(
                color: scheme.surface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.person_search_rounded,
                    size: 42,
                    color: scheme.primary.withValues(alpha: 0.8),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'No contacts found',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No contacts$qualifier start with “$letter”',
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Small reusable widgets
// ─────────────────────────────────────────────────────────────────────────────

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? scheme.primary : scheme.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected
                ? scheme.primary
                : scheme.onSurface.withValues(alpha: 0.12),
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected
                  ? scheme.onPrimary
                  : scheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? scheme.onPrimary
                    : scheme.onSurface.withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.name, required this.initials});

  final String name;
  final String initials;

  static const List<List<Color>> _palette = [
    [Color(0xFF6C63FF), Color(0xFF8E86FF)],
    [Color(0xFF00B4DB), Color(0xFF0083B0)],
    [Color(0xFFFF6B6B), Color(0xFFFF8E72)],
    [Color(0xFF11998E), Color(0xFF38EF7D)],
    [Color(0xFFF7971E), Color(0xFFFFB75E)],
    [Color(0xFFDA4453), Color(0xFF89216B)],
    [Color(0xFF4776E6), Color(0xFF8E54E9)],
  ];

  /// Stable colour per name (String.hashCode is not guaranteed stable).
  int get _colorIndex {
    var sum = 0;
    for (final unit in name.codeUnits) {
      sum = (sum + unit) % 9973;
    }
    return sum % _palette.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _palette[_colorIndex],
        ),
      ),
      child: Text(
        initials,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SidebarLetter extends StatelessWidget {
  const _SidebarLetter({
    required this.letter,
    required this.isSelected,
    required this.isAvailable,
  });

  final String letter;
  final bool isSelected;
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      width: isSelected ? 22 : 18,
      height: isSelected ? 22 : 18,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? scheme.primary : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Text(
        letter,
        style: TextStyle(
          fontSize: isSelected ? 11.5 : 10.5,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
          color: isSelected
              ? scheme.onPrimary
              : scheme.onSurface.withValues(alpha: isAvailable ? 0.8 : 0.22),
        ),
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.primary.withValues(alpha: 0.10),
              ),
              child: Icon(icon, size: 40, color: scheme.primary),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: scheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 18),
              FilledButton(
                onPressed: onAction,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}