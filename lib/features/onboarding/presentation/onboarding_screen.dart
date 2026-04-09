import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/storage/local_storage.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;
  String _selectedLanguage = 'en';
  final _nameController = TextEditingController();
  final Set<String> _interests = {};

  static const _allInterests = [
    ('Visas & Migration', Icons.flight_takeoff),
    ('Adventure & Hiking', Icons.terrain),
    ('Culture & History', Icons.museum),
    ('Beaches & Islands', Icons.beach_access),
    ('Mountains & Snow', Icons.ac_unit),
    ('Food & Cuisine', Icons.restaurant),
    ('Budget Travel', Icons.savings),
    ('Digital Nomad', Icons.laptop),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() {
    final storage = ref.read(localStorageProvider);
    storage.language = _selectedLanguage;
    storage.userName = _nameController.text.trim().isNotEmpty
        ? _nameController.text.trim()
        : null;
    storage.isOnboarded = true;
    context.go('/chat');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildLanguagePage(),
                  _buildNamePage(),
                  _buildInterestsPage(),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguagePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.language, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text('Choose your language', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 32),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'en', label: Text('English'), icon: Text('🇬🇧')),
              ButtonSegment(value: 'ru', label: Text('Русский'), icon: Text('🇷🇺')),
            ],
            selected: {_selectedLanguage},
            onSelectionChanged: (v) => setState(() => _selectedLanguage = v.first),
          ),
        ],
      ),
    );
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.waving_hand, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text("What's your name?", style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 32),
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _next(),
            decoration: const InputDecoration(
              hintText: 'Optional — KAI will remember you',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.explore, size: 64, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text('What interests you?', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allInterests.map((item) {
              final selected = _interests.contains(item.$1);
              return FilterChip(
                label: Text(item.$1),
                avatar: Icon(item.$2, size: 18),
                selected: selected,
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      _interests.add(item.$1);
                    } else {
                      _interests.remove(item.$1);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('${_currentPage + 1} / 3', style: Theme.of(context).textTheme.bodySmall),
          Row(
            children: [
              if (_currentPage > 0)
                TextButton(
                  onPressed: () => _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                  child: const Text('Back'),
                ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _next,
                child: Text(_currentPage == 2 ? 'Start' : 'Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
