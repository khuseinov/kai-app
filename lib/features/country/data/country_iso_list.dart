/// Static ISO-3166-1 alpha-2 country list (travel-relevant subset, ~70 entries).
/// Names are in Russian. Flag emoji is derived from ISO code at runtime.
class IsoCountry {
  final String iso2; // e.g. 'TH'
  final String name; // e.g. 'Таиланд'

  const IsoCountry(this.iso2, this.name);

  /// Returns the flag emoji for this country (uses Unicode regional indicators).
  String get flag {
    const base = 0x1F1A5; // 0x1F1E6 - 0x41
    return iso2
        .toUpperCase()
        .runes
        .map((r) => String.fromCharCode(r + base))
        .join();
  }
}

const kCountryList = <IsoCountry>[
  // ── SE Asia ────────────────────────────────────────────────────────────────
  IsoCountry('TH', 'Таиланд'),
  IsoCountry('VN', 'Вьетнам'),
  IsoCountry('ID', 'Индонезия'),
  IsoCountry('MY', 'Малайзия'),
  IsoCountry('SG', 'Сингапур'),
  IsoCountry('PH', 'Филиппины'),
  IsoCountry('KH', 'Камбоджа'),
  IsoCountry('MM', 'Мьянма'),
  IsoCountry('LA', 'Лаос'),
  IsoCountry('BN', 'Бруней'),
  IsoCountry('TL', 'Восточный Тимор'),
  // ── South Asia ─────────────────────────────────────────────────────────────
  IsoCountry('IN', 'Индия'),
  IsoCountry('NP', 'Непал'),
  IsoCountry('LK', 'Шри-Ланка'),
  IsoCountry('BT', 'Бутан'),
  IsoCountry('MV', 'Мальдивы'),
  IsoCountry('BD', 'Бангладеш'),
  // ── East Asia ──────────────────────────────────────────────────────────────
  IsoCountry('JP', 'Япония'),
  IsoCountry('CN', 'Китай'),
  IsoCountry('KR', 'Южная Корея'),
  IsoCountry('TW', 'Тайвань'),
  IsoCountry('HK', 'Гонконг'),
  IsoCountry('MO', 'Макао'),
  IsoCountry('MN', 'Монголия'),
  // ── Central Asia ───────────────────────────────────────────────────────────
  IsoCountry('KZ', 'Казахстан'),
  IsoCountry('UZ', 'Узбекистан'),
  IsoCountry('KG', 'Кыргызстан'),
  IsoCountry('TJ', 'Таджикистан'),
  // ── Caucasus ───────────────────────────────────────────────────────────────
  IsoCountry('GE', 'Грузия'),
  IsoCountry('AM', 'Армения'),
  IsoCountry('AZ', 'Азербайджан'),
  // ── Middle East ────────────────────────────────────────────────────────────
  IsoCountry('AE', 'ОАЭ'),
  IsoCountry('QA', 'Катар'),
  IsoCountry('JO', 'Иордания'),
  IsoCountry('IL', 'Израиль'),
  IsoCountry('TR', 'Турция'),
  IsoCountry('SA', 'Саудовская Аравия'),
  IsoCountry('OM', 'Оман'),
  IsoCountry('BH', 'Бахрейн'),
  IsoCountry('LB', 'Ливан'),
  // ── Africa ─────────────────────────────────────────────────────────────────
  IsoCountry('EG', 'Египет'),
  IsoCountry('MA', 'Марокко'),
  IsoCountry('TN', 'Тунис'),
  IsoCountry('ZA', 'ЮАР'),
  IsoCountry('KE', 'Кения'),
  IsoCountry('TZ', 'Танзания'),
  IsoCountry('ET', 'Эфиопия'),
  IsoCountry('GH', 'Гана'),
  IsoCountry('SN', 'Сенегал'),
  IsoCountry('MU', 'Маврикий'),
  // ── Europe ─────────────────────────────────────────────────────────────────
  IsoCountry('FR', 'Франция'),
  IsoCountry('IT', 'Италия'),
  IsoCountry('ES', 'Испания'),
  IsoCountry('DE', 'Германия'),
  IsoCountry('GB', 'Великобритания'),
  IsoCountry('PT', 'Португалия'),
  IsoCountry('GR', 'Греция'),
  IsoCountry('NL', 'Нидерланды'),
  IsoCountry('CZ', 'Чехия'),
  IsoCountry('AT', 'Австрия'),
  IsoCountry('CH', 'Швейцария'),
  IsoCountry('HR', 'Хорватия'),
  IsoCountry('HU', 'Венгрия'),
  IsoCountry('PL', 'Польша'),
  IsoCountry('RO', 'Румыния'),
  IsoCountry('BG', 'Болгария'),
  IsoCountry('RS', 'Сербия'),
  IsoCountry('ME', 'Черногория'),
  IsoCountry('BA', 'Босния и Герцеговина'),
  IsoCountry('MK', 'Северная Македония'),
  IsoCountry('AL', 'Албания'),
  IsoCountry('IS', 'Исландия'),
  IsoCountry('NO', 'Норвегия'),
  IsoCountry('SE', 'Швеция'),
  IsoCountry('FI', 'Финляндия'),
  IsoCountry('DK', 'Дания'),
  IsoCountry('SK', 'Словакия'),
  IsoCountry('SI', 'Словения'),
  IsoCountry('EE', 'Эстония'),
  IsoCountry('LV', 'Латвия'),
  IsoCountry('LT', 'Литва'),
  IsoCountry('MT', 'Мальта'),
  IsoCountry('CY', 'Кипр'),
  // ── Americas ───────────────────────────────────────────────────────────────
  IsoCountry('US', 'США'),
  IsoCountry('CA', 'Канада'),
  IsoCountry('MX', 'Мексика'),
  IsoCountry('BR', 'Бразилия'),
  IsoCountry('AR', 'Аргентина'),
  IsoCountry('CO', 'Колумбия'),
  IsoCountry('PE', 'Перу'),
  IsoCountry('CL', 'Чили'),
  IsoCountry('EC', 'Эквадор'),
  IsoCountry('BO', 'Боливия'),
  IsoCountry('CR', 'Коста-Рика'),
  IsoCountry('PA', 'Панама'),
  IsoCountry('CU', 'Куба'),
  IsoCountry('DO', 'Доминиканская Республика'),
  IsoCountry('JM', 'Ямайка'),
  // ── Oceania ────────────────────────────────────────────────────────────────
  IsoCountry('AU', 'Австралия'),
  IsoCountry('NZ', 'Новая Зеландия'),
  IsoCountry('FJ', 'Фиджи'),
  IsoCountry('PF', 'Французская Полинезия'),
];
