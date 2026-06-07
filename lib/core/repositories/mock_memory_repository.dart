import 'memory_repository.dart';
import '../storage/entities/memory_fact.dart';

class MockMemoryRepository implements MemoryRepository {
  MockMemoryRepository() {
    _resetToSeeded();
  }

  late List<MemoryFact> _facts;
  bool _memoryEnabled = true;

  void _resetToSeeded() {
    final now = DateTime.now();
    _facts = [
      // Category: about (о вас)
      MemoryFact(
        id: 'fact-1',
        category: 'about',
        text: 'Гражданин России',
        sourceText: 'Виза для Японии · 12 мин назад',
        createdAt: now.subtract(const Duration(minutes: 12)),
        expiresIn: '23h',
      ),
      MemoryFact(
        id: 'fact-2',
        category: 'about',
        text: 'Живёт в Алматы',
        sourceText: 'установлено явно · 3 нед назад',
        createdAt: now.subtract(const Duration(days: 21)),
      ),
      MemoryFact(
        id: 'fact-3',
        category: 'about',
        text: 'Путешествует в одиночку большую часть времени',
        sourceText: '10 дней в Турции · 2 нед назад',
        createdAt: now.subtract(const Duration(days: 14)),
      ),

      // Category: preferences (предпочтения)
      MemoryFact(
        id: 'fact-4',
        category: 'preferences',
        text: 'Предпочитает небольшие гостиницы отелям',
        sourceText: 'Что поесть в Токио · 1 день назад',
        createdAt: now.subtract(const Duration(days: 1)),
        expiresIn: '3h',
        isCritical: true,
      ),
      MemoryFact(
        id: 'fact-5',
        category: 'preferences',
        text: 'Любит уличную еду, умеренно-средняя острота',
        sourceText: 'Лучшая уличная еда в Токио · 1 день назад',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      MemoryFact(
        id: 'fact-6',
        category: 'preferences',
        text: 'Поезда вместо самолётов при возможности',
        sourceText: 'Цена JR Pass · 12 мин назад',
        createdAt: now.subtract(const Duration(minutes: 12)),
        expiresIn: '23h',
      ),

      // Category: restrictions (ограничения)
      MemoryFact(
        id: 'fact-7',
        category: 'restrictions',
        text: 'Потолок бюджета: ~\$2,500 за поездку',
        sourceText: 'установлено явно · 2 нед назад',
        createdAt: now.subtract(const Duration(days: 14)),
      ),
      MemoryFact(
        id: 'fact-8',
        category: 'restrictions',
        text: 'Ограничение подвижности — избегать длинных лестниц',
        sourceText: 'Планирование Дубровника · 1 мес назад',
        createdAt: now.subtract(const Duration(days: 30)),
      ),

      // Category: trips (поездки)
      MemoryFact(
        id: 'fact-9',
        category: 'trips',
        text: 'Япония · Ноябрь 2026 (активно)',
        sourceText: '7 чатов · 5 фактов',
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      MemoryFact(
        id: 'fact-10',
        category: 'trips',
        text: 'Турция · зима',
        sourceText: '3 чата · 2 факта',
        createdAt: now.subtract(const Duration(days: 14)),
      ),
    ];
  }

  @override
  Future<List<MemoryFact>> getMemoryFacts() async {
    // Return a sorted copy of facts (latest first)
    final sorted = List<MemoryFact>.from(_facts)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted;
  }

  @override
  Future<void> saveMemoryFact(MemoryFact fact) async {
    final index = _facts.indexWhere((element) => element.id == fact.id);
    if (index >= 0) {
      _facts[index] = fact;
    } else {
      _facts.add(fact);
    }
  }

  @override
  Future<void> deleteMemoryFact(String id) async {
    _facts.removeWhere((element) => element.id == id);
  }

  @override
  Future<void> clearAllMemory() async {
    _facts.clear();
  }

  @override
  Future<bool> isMemoryEnabled() async {
    return _memoryEnabled;
  }

  @override
  Future<void> setMemoryEnabled(bool enabled) async {
    _memoryEnabled = enabled;
  }
}
