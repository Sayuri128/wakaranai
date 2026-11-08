// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a uk locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'uk';

  static String m0(time) => "Переглянуто ${time}";

  static String m1(number) => "Розділ ${number}";

  static String m2(seconds) => "Вперед на ${seconds} с";

  static String m3(seconds) => "Назад на ${seconds} с";

  static String m4(number) => "Джерело ${number}";

  static String m5(minutes) => "${minutes} хв";

  static String m6(minutes) => "${minutes} хв";

  static String m7(count, queued) =>
      "Знайдено новинок: ${count}, у черзі на завантаження: ${queued}";

  static String m8(count) => "До ${count}";

  static String m9(title, count, queued) =>
      "${title} · нових: ${count}, до завантаження: ${queued}";

  static String m10(count) =>
      "${Intl.plural(count, one: '${count} завантаження почнеться, щойно ви відкриєте застосунок', few: '${count} завантаження почнуться, щойно ви відкриєте застосунок', many: '${count} завантажень почнуться, щойно ви відкриєте застосунок', other: '${count} завантаження почнуться, щойно ви відкриєте застосунок')}";

  static String m11(mode) => "Автозавантаження: ${mode}";

  static String m12(count) =>
      "${Intl.plural(count, zero: 'Категорії не вибрано', one: '${count} категорія', few: '${count} категорії', many: '${count} категорій', other: '${count} категорії')}";

  static String m13(count) =>
      "${Intl.plural(count, one: '${count} сторінка', few: '${count} сторінки', many: '${count} сторінок', other: '${count} сторінки')}";

  static String m14(failed) => "Перекладено · сторінок з помилкою: ${failed}";

  static String m15(count) =>
      "${Intl.plural(count, one: 'Перекладено ${count} розділ', few: 'Перекладено ${count} розділи', many: 'Перекладено ${count} розділів', other: 'Перекладено ${count} розділу')}";

  static String m16(count) =>
      "${Intl.plural(count, one: 'Залишився ${count} розділ', few: 'Залишилося ${count} розділи', many: 'Залишилося ${count} розділів', other: 'Залишилося ${count} розділу')}";

  static String m17(done, total) => "Переклад ${done}/${total}";

  static String m18(count) =>
      "${Intl.plural(count, one: '${count} розділ додано до черги перекладу', few: '${count} розділи додано до черги перекладу', many: '${count} розділів додано до черги перекладу', other: '${count} розділу додано до черги перекладу')}";

  static String m19(required, supported) =>
      "Цьому джерелу потрібен API розширень ${required}, а застосунок підтримує до ${supported}.";

  static String m20(required, current) =>
      "Цьому джерелу потрібна версія застосунку ${required} або новіша, у вас ${current}.";

  static String m21(count) => "Вибрано: ${count}";

  static String m22(names) => "Художники: ${names}";

  static String m23(names) => "Автори: ${names}";

  static String m24(ending) => "Ключ ••••${ending}";

  static String m25(used, limit) => "${used} з ${limit} символів";

  static String m26(count) => "Залишилося ${count}";

  static String m27(count) =>
      "${Intl.plural(count, one: '${count} розділ', few: '${count} розділи', many: '${count} розділів', other: '${count} розділу')}";

  static String m28(count) =>
      "${Intl.plural(count, one: '${count} серія', few: '${count} серії', many: '${count} серій', other: '${count} серії')}";

  static String m29(score) => "${score}%";

  static String m30(year) => "Осінь ${year}";

  static String m31(year) => "Весна ${year}";

  static String m32(year) => "Літо ${year}";

  static String m33(year) => "Зима ${year}";

  static String m34(speed) => "${speed} МБ/с";

  static String m35(time) => "Залишилося ${time}";

  static String m36(done, total) => "Завантажено розділів: ${done}/${total}";

  static String m37(downloaded) => "Завантажено ${downloaded}";

  static String m38(percent, downloaded, total) =>
      "${percent}% · ${downloaded} з ${total}";

  static String m39(size) => "Можна дивитися офлайн · ${size}";

  static String m40(done, total) => "Сегмент ${done}/${total}";

  static String m41(size) => "${size} ГБ";

  static String m42(size) => "${size} МБ";

  static String m43(done, total) => "Завантажено серій: ${done}/${total}";

  static String m44(count) =>
      "${Intl.plural(count, one: 'Завантажено ${count} розділ', few: 'Завантажено ${count} розділи', many: 'Завантажено ${count} розділів', other: 'Завантажено ${count} розділу')}";

  static String m45(done, total) => "Сторінки: ${done}/${total}";

  static String m46(count) => "Черга (${count})";

  static String m47(progress) => "Призупинено · ${progress}";

  static String m48(title, size) =>
      "Усі завантаження «${title}» (${size}) буде видалено з цього пристрою.";

  static String m49(count, title, size) =>
      "${Intl.plural(count, one: 'З цього пристрою буде видалено ${count} переглянуту серію «${title}» (${size}).', few: 'З цього пристрою буде видалено ${count} переглянуті серії «${title}» (${size}).', many: 'З цього пристрою буде видалено ${count} переглянутих серій «${title}» (${size}).', other: 'З цього пристрою буде видалено ${count} переглянутої серії «${title}» (${size}).')}";

  static String m50(count) => "Видалено переглянутих серій: ${count}";

  static String m51(size) => "Можна звільнити до ${size}";

  static String m52(summary, size) => "${summary} · ${size}";

  static String m53(count, size) =>
      "${Intl.plural(count, one: '${count} завантаження · ${size}', few: '${count} завантаження · ${size}', many: '${count} завантажень · ${size}', other: '${count} завантаження · ${size}')}";

  static String m54(count, size) => "Переглянуто: ${count} · ${size}";

  static String m55(hours, minutes) => "${hours} год ${minutes} хв";

  static String m56(minutes) => "${minutes} хв";

  static String m57(seconds) => "${seconds} с";

  static String m58(size) => "${size} ГБ";

  static String m59(source) => "Збережені дані ${source} очищено";

  static String m60(value) => "Типово: ${value}";

  static String m61(count) => "${count} на сторінку (типово)";

  static String m62(count) => "${count} на сторінку";

  static String m63(source) => "Збережену сесію для ${source} очищено";

  static String m64(name) => "Додано ${name}";

  static String m65(name) => "${name} видалено";

  static String m66(name) => "Видалити ${name}?";

  static String m67(count) =>
      "${Intl.plural(count, one: 'Активний ${count} фільтр', few: 'Активні ${count} фільтри', many: 'Активно ${count} фільтрів', other: 'Активно ${count} фільтра')}";

  static String m68(count) =>
      "${Intl.plural(count, zero: 'Фільтри', one: 'Фільтри, активний ${count}', few: 'Фільтри, активні ${count}', many: 'Фільтри, активно ${count}', other: 'Фільтри, активно ${count}')}";

  static String m69(value) => "Прибрати «${value}»";

  static String m70(name) => "Пошук: ${name}";

  static String m71(count) => "Показати всі (${count})";

  static String m72(count) => "Застосувати (${count})";

  static String m73(count) => "Ще ${count} — уточніть пошук";

  static String m74(title) => "Востаннє відкрито: ${title}";

  static String m75(layout) => "Вигляд: ${layout}";

  static String m76(sources) => "Немає результатів у: ${sources}";

  static String m77(query) => "У вибраних джерелах немає «${query}».";

  static String m78(count) =>
      "${Intl.plural(count, one: '${count} результат', few: '${count} результати', many: '${count} результатів', other: '${count} результату')}";

  static String m79(count) =>
      "${Intl.plural(count, zero: 'Джерела не вибрано', one: 'Пошук в ${count} джерелі', few: 'Пошук у ${count} джерелах', many: 'Пошук у ${count} джерелах', other: 'Пошук у ${count} джерелах')}";

  static String m80(name) =>
      "Помилка під час ініціалізації джерела конфігурацій ${name}";

  static String m81(count) => "Завантажено: ${count}";

  static String m82(current, total) => "Завантаження ${current} з ${total}";

  static String m83(position) => "У черзі · №${position}";

  static String m84(count) =>
      "${Intl.plural(count, one: 'Не вдалося завантажити ${count} тайтл', few: 'Не вдалося завантажити ${count} тайтли', many: 'Не вдалося завантажити ${count} тайтлів', other: 'Не вдалося завантажити ${count} тайтлу')}";

  static String m85(count) =>
      "${Intl.plural(count, one: 'Шукаємо розділи для ${count} тайтлу…', few: 'Шукаємо розділи для ${count} тайтлів…', many: 'Шукаємо розділи для ${count} тайтлів…', other: 'Шукаємо розділи для ${count} тайтлу…')}";

  static String m86(count) => "Нових: ${count}";

  static String m87(query) => "У бібліотеці немає нічого за запитом «${query}»";

  static String m88(count) => "Вибрано: ${count}";

  static String m89(count) =>
      "${Intl.plural(count, zero: 'Нічого не імпортовано', one: 'Імпортовано ${count} книгу', few: 'Імпортовано ${count} книги', many: 'Імпортовано ${count} книг', other: 'Імпортовано ${count} книги')}";

  static String m90(number) => "Частина ${number}";

  static String m91(path) =>
      "Скопіюйте файли EPUB до\n${path}\n\nКожен файл — це книга, підпапки теж підходять. Розділи відповідають змісту книги. Папка доступна з комп’ютера через USB.";

  static String m92(count) =>
      "${Intl.plural(count, zero: 'Нічого не імпортовано', one: 'Імпортовано ${count} файл', few: 'Імпортовано ${count} файли', many: 'Імпортовано ${count} файлів', other: 'Імпортовано ${count} файлу')}";

  static String m93(path) =>
      "Скопіюйте папки із зображеннями, файли CBZ або ZIP до\n${path}\n\nКожна папка — це тайтл, а кожен архів чи папка із зображеннями всередині неї — розділ. Якщо є cover.jpg і ComicInfo.xml, їх буде використано. Папка доступна з комп’ютера через USB.";

  static String m94(done, total) => "${done} з ${total}";

  static String m95(source) => "Точний збіг на ${source}";

  static String m96(source) => "Перенесено на ${source}";

  static String m97(source) => "Перенесення на ${source}…";

  static String m98(count) =>
      "${Intl.plural(count, zero: 'Збігів немає, пошукайте самі', one: '${count} збіг, підтвердьте', few: '${count} збіги, виберіть', many: '${count} збігів, виберіть', other: '${count} збігу, виберіть')}";

  static String m99(moved, skipped, failed) =>
      "Перенесено: ${moved}, пропущено: ${skipped}, помилок: ${failed}";

  static String m100(count) =>
      "${Intl.plural(count, one: 'Перенести ${count} тайтл', few: 'Перенести ${count} тайтли', many: 'Перенести ${count} тайтлів', other: 'Перенести ${count} тайтлу')}";

  static String m101(source) => "Перенесено на ${source}";

  static String m102(count) =>
      "${Intl.plural(count, one: '${count} завантаження залишиться зі старим тайтлом, файли не переносяться', few: '${count} завантаження залишаться зі старим тайтлом, файли не переносяться', many: '${count} завантажень залишаться зі старим тайтлом, файли не переносяться', other: '${count} завантаження залишаться зі старим тайтлом, файли не переносяться')}";

  static String m103(count) =>
      "${Intl.plural(count, one: 'і ще ${count}', few: 'і ще ${count}', many: 'і ще ${count}', other: 'і ще ${count}')}";

  static String m104(percent) => "${percent}%";

  static String m105(name) => "Додати новий тайтл до «${name}»";

  static String m106(count) =>
      "${Intl.plural(count, one: 'Збігається ${count} розділ', few: 'Збігаються ${count} розділи', many: 'Збігається ${count} розділів', other: 'Збігається ${count} розділу')}";

  static String m107(count) =>
      "${Intl.plural(count, one: 'Збігається ${count} серія', few: 'Збігаються ${count} серії', many: 'Збігається ${count} серій', other: 'Збігається ${count} серії')}";

  static String m108(count) =>
      "${Intl.plural(count, one: '${count} прив\'язка перейде до нового тайтлу', few: '${count} прив\'язки перейдуть до нового тайтлу', many: '${count} прив\'язок перейдуть до нового тайтлу', other: '${count} прив\'язки перейдуть до нового тайтлу')}";

  static String m109(source) => "Зараз на ${source}";

  static String m110(count) =>
      "${Intl.plural(count, one: '${count} цільове джерело', few: '${count} цільові джерела', many: '${count} цільових джерел', other: '${count} цільового джерела')}";

  static String m111(seconds) => "Наступна серія через ${seconds} с";

  static String m112(index) => "Джерело ${index}";

  static String m113(seconds) => "−${seconds} с";

  static String m114(seconds) => "+${seconds} с";

  static String m115(seconds) => "+${seconds} с";

  static String m116(index) => "Субтитри ${index}";

  static String m117(percent) => "${percent}%";

  static String m118(title) => "Далі: ${title}";

  static String m119(progress) => "Завантаження ШІ-моделі ${progress}%";

  static String m120(model, size) =>
      "${model} потрібно один раз завантажити (${size} ГБ). Скористайтеся Wi-Fi: модель зберігається на телефоні, і далі переклад працює повністю офлайн.";

  static String m121(count) =>
      "${Intl.plural(count, one: '${count} запис', few: '${count} записи', many: '${count} записів', other: '${count} запису')}";

  static String m122(current, total) =>
      "Завантаження мовних пакетів ${current}/${total}…";

  static String m123(source, target) =>
      "Для перекладу (${source} → ${target}) потрібні мовні пакети на пристрої, близько 30 МБ кожен. Їх завантажують один раз, після чого сторінки перекладаються повністю на вашому пристрої.";

  static String m124(count) => "Збережено сторінок: ${count}";

  static String m125(count) =>
      "${Intl.plural(count, one: '${count} сторінка зі старішої версії', few: '${count} сторінки зі старішої версії', many: '${count} сторінок зі старішої версії', other: '${count} сторінки зі старішої версії')}";

  static String m126(done, total) => "Переклад розділу ${done}/${total}";

  static String m127(size) => "До ${size} пкс";

  static String m128(query) => "За запитом «${query}» нічого не знайдено";

  static String m129(query) => "Результати за запитом «${query}»";

  static String m130(time) => "Щодня в Download/Wakaranai · остання ${time}";

  static String m131(version) => "Доступна нова версія ${version}";

  static String m132(count) => "пропущено: ${count}";

  static String m133(imported, total) => "Імпортовано ${imported} з ${total}";

  static String m134(url) => "Завантажувати розширення з ${url}";

  static String m135(seconds) => "${seconds} с";

  static String m136(name) => "Не вдалося увійти в ${name}";

  static String m137(name) => "Вийти з ${name}?";

  static String m138(name) => "Ви ввійшли як ${name}";

  static String m139(hours) => "Кожні ${hours} год";

  static String m140(source) => "Увійдіть у ${source}";

  static String m141(count) =>
      "${Intl.plural(count, one: '${count} тайтл видалено з джерела', few: '${count} тайтли видалено з джерел', many: '${count} тайтлів видалено з джерел', other: '${count} тайтлу видалено з джерел')}";

  static String m142(count) =>
      "${Intl.plural(count, one: '${count} дія', few: '${count} дії', many: '${count} дій', other: '${count} дії')}";

  static String m143(current, longest) =>
      "Зараз ${current} · Рекорд ${longest}";

  static String m144(count) =>
      "${Intl.plural(count, one: '${count} розділ', few: '${count} розділи', many: '${count} розділів', other: '${count} розділу')}";

  static String m145(count) =>
      "${Intl.plural(count, one: '${count} серія', few: '${count} серії', many: '${count} серій', other: '${count} серії')}";

  static String m146(count) =>
      "${Intl.plural(count, one: 'Шукаємо серії для ${count} тайтлу…', few: 'Шукаємо серії для ${count} тайтлів…', many: 'Шукаємо серії для ${count} тайтлів…', other: 'Шукаємо серії для ${count} тайтлу…')}";

  static String m147(count) =>
      "${Intl.plural(count, one: 'Шукаємо ${count} тайтл…', few: 'Шукаємо ${count} тайтли…', many: 'Шукаємо ${count} тайтлів…', other: 'Шукаємо ${count} тайтлу…')}";

  static String m148(count) => "Наступні розділи або серії: ${count}";

  static String m149(count) =>
      "${Intl.plural(count, one: '${count} завантаження в черзі', few: '${count} завантаження в черзі', many: '${count} завантажень у черзі', other: '${count} завантаження в черзі')}";

  static String m150(count) =>
      "${Intl.plural(count, one: 'Наступна ${count} серія', few: 'Наступні ${count} серії', many: 'Наступні ${count} серій', other: 'Наступні ${count} серії')}";

  static String m151(count) =>
      "${Intl.plural(count, one: '${count} серія в черзі', few: '${count} серії в черзі', many: '${count} серій у черзі', other: '${count} серії в черзі')}";

  static String m152(count) =>
      "${Intl.plural(count, one: 'Наступний ${count} розділ', few: 'Наступні ${count} розділи', many: 'Наступні ${count} розділів', other: 'Наступні ${count} розділу')}";

  static String m153(count) =>
      "${Intl.plural(count, one: '${count} розділ у черзі', few: '${count} розділи в черзі', many: '${count} розділів у черзі', other: '${count} розділу в черзі')}";

  static String m154(number) => "Група ${number}";

  static String m155(name) => "Пошук на ${name}";

  static String m156(size) =>
      "Буде звільнено ${size} ГБ. Ви зможете завантажити її знову будь-коли.";

  static String m157(model, size) => "${model} · ${size} ГБ · готова";

  static String m158(size) => "Не завантажено · ${size} ГБ";

  static String m159(need, ram) =>
      "Потрібно ${need} ГБ ОЗП (у цього телефона ${ram} ГБ)";

  static String m160(model, ram) => "Цей телефон: ${model} · ${ram} ГБ ОЗП";

  static String m161(ram) => "${ram} ГБ ОЗП або більше";

  static String m162(size) => "Близько ${size} ГБ вільного місця";

  static String m163(size) => "Завантажено · ${size} ГБ";

  static String m164(count) =>
      "${Intl.plural(count, zero: 'Мовних пакетів ще немає', one: 'Завантажено ${count} мовний пакет', few: 'Завантажено ${count} мовні пакети', many: 'Завантажено ${count} мовних пакетів', other: 'Завантажено ${count} мовного пакета')}";

  static String m165(size) =>
      "Не завантажено · ${size} ГБ · виберіть її рушієм, щоб завантажити";

  static String m166(count, size) =>
      "${Intl.plural(count, zero: 'Немає завантажених ШІ-моделей', one: '${count} ШІ-модель · ${size} ГБ', few: '${count} ШІ-моделі · ${size} ГБ', many: '${count} ШІ-моделей · ${size} ГБ', other: '${count} ШІ-моделі · ${size} ГБ')}";

  static String m167(source) =>
      "${source}: потрібна швидка перевірка в браузері";

  static String m168(count) =>
      "${Intl.plural(count, one: '${count} джерело потребує уваги', few: '${count} джерела потребують уваги', many: '${count} джерел потребують уваги', other: '${count} джерела потребують уваги')}";

  static String m169(sources) => "Потрібна перевірка в браузері: ${sources}";

  static String m170(sources) => "Потрібно увійти: ${sources}";

  static String m171(source) =>
      "Сесію для ${source} збережено. Потягніть униз, щоб перевірити знову";

  static String m172(source) => "${source}: потрібно увійти";

  static String m173(source) => "${source}: потрібно увійти знову";

  static String m174(source) => "${source} не підтримує вхід через браузер";

  static String m175(count) =>
      "${Intl.plural(count, one: 'Не вдалося перевірити ${count} джерело', few: 'Не вдалося перевірити ${count} джерела', many: 'Не вдалося перевірити ${count} джерел', other: 'Не вдалося перевірити ${count} джерела')}";

  static String m176(count) =>
      "${Intl.plural(count, one: 'Знайдено ${count} новинку', few: 'Знайдено ${count} новинки', many: 'Знайдено ${count} новинок', other: 'Знайдено ${count} новинки')}";

  static String m177(title, count) => "${title} · нових: ${count}";

  static String m178(count) =>
      "${Intl.plural(count, one: 'і ще ${count} тайтл', few: 'і ще ${count} тайтли', many: 'і ще ${count} тайтлів', other: 'і ще ${count} тайтлу')}";

  static String m179(count) =>
      "${Intl.plural(count, one: 'У ${count} тайтлі', few: 'У ${count} тайтлах', many: 'У ${count} тайтлах', other: 'У ${count} тайтлах')}";

  static String m180(count) =>
      "${Intl.plural(count, one: '${count} новинка', few: '${count} новинки', many: '${count} новинок', other: '${count} новинки')}";

  static String m181(count) => "${count} дн. тому";

  static String m182(count) => "${count} год тому";

  static String m183(count) => "${count} хв тому";

  static String m184(host) => "Cookie для ${host} очищено";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "activity_history_anime_appbar_title": MessageLookupByLibrary.simpleMessage(
      "Перегляд",
    ),
    "activity_history_deleted_activity": MessageLookupByLibrary.simpleMessage(
      "Запис видалено",
    ),
    "activity_history_empty_anime_list_message":
        MessageLookupByLibrary.simpleMessage(
          "Історія порожня :c\nПочніть дивитися, і вона з’явиться тут",
        ),
    "activity_history_empty_manga_list_message":
        MessageLookupByLibrary.simpleMessage(
          "Історія порожня :c\nПочніть читати, і вона з’явиться тут",
        ),
    "activity_history_error_loading_extension":
        MessageLookupByLibrary.simpleMessage(
          "Помилка під час завантаження розширення",
        ),
    "activity_history_error_loading_history":
        MessageLookupByLibrary.simpleMessage(
          "Помилка під час завантаження історії",
        ),
    "activity_history_long_tap_dialog_delete_button":
        MessageLookupByLibrary.simpleMessage("Видалити"),
    "activity_history_manga_appbar_title": MessageLookupByLibrary.simpleMessage(
      "Читання",
    ),
    "add_extension_source_page_add_button_title":
        MessageLookupByLibrary.simpleMessage("Зберегти"),
    "add_extension_source_page_appbar_edit_title":
        MessageLookupByLibrary.simpleMessage("Редагування джерела"),
    "add_extension_source_page_appbar_title":
        MessageLookupByLibrary.simpleMessage("Нове джерело"),
    "add_extension_source_page_branch_default_option":
        MessageLookupByLibrary.simpleMessage("Типова гілка"),
    "add_extension_source_page_branch_fetch_button":
        MessageLookupByLibrary.simpleMessage("Отримати"),
    "add_extension_source_page_branch_fetch_error":
        MessageLookupByLibrary.simpleMessage("Не вдалося завантажити гілки"),
    "add_extension_source_page_branch_field_label":
        MessageLookupByLibrary.simpleMessage("Гілка"),
    "add_extension_source_page_branch_helper_text":
        MessageLookupByLibrary.simpleMessage(
          "Необов’язково. Отримайте гілки репозиторію, щоб вибрати тестову гілку.",
        ),
    "add_extension_source_page_branch_invalid_url_error":
        MessageLookupByLibrary.simpleMessage(
          "Спершу введіть правильний URL GitHub",
        ),
    "add_extension_source_page_description":
        MessageLookupByLibrary.simpleMessage(
          "Додайте репозиторій GitHub, у якому розміщено розширення Wakaranai.",
        ),
    "add_extension_source_page_name_field_error_text":
        MessageLookupByLibrary.simpleMessage("Неправильна назва"),
    "add_extension_source_page_name_field_hint_text":
        MessageLookupByLibrary.simpleMessage(
          "Репозиторій конфігурацій Wakaranai",
        ),
    "add_extension_source_page_name_field_label":
        MessageLookupByLibrary.simpleMessage("Назва"),
    "add_extension_source_page_update_button_title":
        MessageLookupByLibrary.simpleMessage("Оновити"),
    "add_extension_source_page_url_field_error_text":
        MessageLookupByLibrary.simpleMessage("Неправильний URL"),
    "add_extension_source_page_url_field_hint_text":
        MessageLookupByLibrary.simpleMessage(
          "https://github.com/username/repository",
        ),
    "add_extension_source_page_url_field_label":
        MessageLookupByLibrary.simpleMessage("URL"),
    "anime_concrete_viewer_watched_at_title": m0,
    "api_client_error_title": MessageLookupByLibrary.simpleMessage(
      "Не вдалося завантажити це розширення",
    ),
    "api_client_no_extension_selected": MessageLookupByLibrary.simpleMessage(
      "Розширення не вибрано",
    ),
    "app_name": MessageLookupByLibrary.simpleMessage("Wakaranai"),
    "audio_notification_channel_name": MessageLookupByLibrary.simpleMessage(
      "Відтворення аудіокниг",
    ),
    "audio_player_chapter_number": m1,
    "audio_player_chapters": MessageLookupByLibrary.simpleMessage("Розділи"),
    "audio_player_close": MessageLookupByLibrary.simpleMessage("Закрити"),
    "audio_player_error": MessageLookupByLibrary.simpleMessage(
      "Не вдалося відтворити доріжку",
    ),
    "audio_player_forward": m2,
    "audio_player_idle_message": MessageLookupByLibrary.simpleMessage(
      "Відкрийте аудіокнигу й виберіть доріжку, щоб почати слухати",
    ),
    "audio_player_idle_title": MessageLookupByLibrary.simpleMessage(
      "Нічого не відтворюється",
    ),
    "audio_player_more": MessageLookupByLibrary.simpleMessage("Більше"),
    "audio_player_next_track": MessageLookupByLibrary.simpleMessage(
      "Наступна доріжка",
    ),
    "audio_player_no_sources": MessageLookupByLibrary.simpleMessage(
      "Ця доріжка не має аудіо для відтворення",
    ),
    "audio_player_pause": MessageLookupByLibrary.simpleMessage("Пауза"),
    "audio_player_play": MessageLookupByLibrary.simpleMessage("Відтворити"),
    "audio_player_previous_track": MessageLookupByLibrary.simpleMessage(
      "Попередня доріжка",
    ),
    "audio_player_retry": MessageLookupByLibrary.simpleMessage("Повторити"),
    "audio_player_rewind": m3,
    "audio_player_source": MessageLookupByLibrary.simpleMessage("Якість аудіо"),
    "audio_player_source_number": m4,
    "audio_player_speed": MessageLookupByLibrary.simpleMessage(
      "Швидкість відтворення",
    ),
    "audio_player_stop": MessageLookupByLibrary.simpleMessage(
      "Зупинити відтворення",
    ),
    "audio_player_tracks": MessageLookupByLibrary.simpleMessage("Доріжки"),
    "audio_selection_mark_listened": MessageLookupByLibrary.simpleMessage(
      "Позначити прослуханим",
    ),
    "audio_selection_mark_not_listened": MessageLookupByLibrary.simpleMessage(
      "Позначити непрослуханим",
    ),
    "audio_sleep_end_of_track": MessageLookupByLibrary.simpleMessage(
      "До кінця доріжки",
    ),
    "audio_sleep_end_of_track_short": MessageLookupByLibrary.simpleMessage(
      "Доріжка",
    ),
    "audio_sleep_minutes": m5,
    "audio_sleep_minutes_short": m6,
    "audio_sleep_off": MessageLookupByLibrary.simpleMessage("Вимкнути таймер"),
    "audio_sleep_timer": MessageLookupByLibrary.simpleMessage("Таймер сну"),
    "audio_track_finished": MessageLookupByLibrary.simpleMessage("Прослухано"),
    "audio_tracks_section_title": MessageLookupByLibrary.simpleMessage(
      "Доріжки",
    ),
    "auto_download_categories_done": MessageLookupByLibrary.simpleMessage(
      "Готово",
    ),
    "auto_download_categories_empty": MessageLookupByLibrary.simpleMessage(
      "Спершу створіть категорію в бібліотеці",
    ),
    "auto_download_categories_title": MessageLookupByLibrary.simpleMessage(
      "Категорії для автозавантаження",
    ),
    "auto_download_check_found": m7,
    "auto_download_chip_off": MessageLookupByLibrary.simpleMessage(
      "Автозавантаження вимкнено",
    ),
    "auto_download_chip_on": MessageLookupByLibrary.simpleMessage(
      "Автозавантаження ввімкнено",
    ),
    "auto_download_limit_subtitle": MessageLookupByLibrary.simpleMessage(
      "Скільки найбільше завантажувати для одного тайтлу за перевірку",
    ),
    "auto_download_limit_title": MessageLookupByLibrary.simpleMessage(
      "Нових на тайтл",
    ),
    "auto_download_limit_unlimited": MessageLookupByLibrary.simpleMessage(
      "Без обмежень",
    ),
    "auto_download_limit_value": m8,
    "auto_download_notification_line": m9,
    "auto_download_notification_pending": m10,
    "auto_download_override_always": MessageLookupByLibrary.simpleMessage(
      "Завжди",
    ),
    "auto_download_override_default": MessageLookupByLibrary.simpleMessage(
      "Як у налаштуваннях",
    ),
    "auto_download_override_mixed": MessageLookupByLibrary.simpleMessage(
      "По-різному",
    ),
    "auto_download_override_never": MessageLookupByLibrary.simpleMessage(
      "Ніколи",
    ),
    "auto_download_override_row": m11,
    "auto_download_override_title": MessageLookupByLibrary.simpleMessage(
      "Автозавантаження",
    ),
    "auto_download_scope_all": MessageLookupByLibrary.simpleMessage(
      "Усіх тайтлів бібліотеки",
    ),
    "auto_download_scope_categories": MessageLookupByLibrary.simpleMessage(
      "Вибраних категорій",
    ),
    "auto_download_scope_categories_count": m12,
    "auto_download_scope_title": MessageLookupByLibrary.simpleMessage(
      "Автозавантаження для",
    ),
    "auto_download_subtitle": MessageLookupByLibrary.simpleMessage(
      "Ставити в чергу нові розділи й серії, знайдені під час перевірки оновлень бібліотеки. Враховує налаштування «Лише через Wi-Fi»",
    ),
    "auto_download_title": MessageLookupByLibrary.simpleMessage(
      "Автозавантаження нових розділів",
    ),
    "browser_check_dismiss": MessageLookupByLibrary.simpleMessage("Закрити"),
    "browser_check_open_button": MessageLookupByLibrary.simpleMessage(
      "Відкрити браузер",
    ),
    "browser_check_reconnecting": MessageLookupByLibrary.simpleMessage(
      "Повторне підключення до джерела…",
    ),
    "browser_check_required_message": MessageLookupByLibrary.simpleMessage(
      "Сторінка захисту не пройшла автоматично. Завершіть перевірку в браузері, а потім торкніться «Готово», щоб продовжити.",
    ),
    "browser_check_required_title": MessageLookupByLibrary.simpleMessage(
      "Цьому джерелу потрібна швидка перевірка в браузері",
    ),
    "chapter_divider_back": MessageLookupByLibrary.simpleMessage("До тайтлу"),
    "chapter_divider_downloaded": MessageLookupByLibrary.simpleMessage(
      "Завантажено",
    ),
    "chapter_divider_end_message": MessageLookupByLibrary.simpleMessage(
      "Більше розділів немає",
    ),
    "chapter_divider_end_title": MessageLookupByLibrary.simpleMessage(
      "Ви все прочитали",
    ),
    "chapter_divider_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося завантажити розділ",
    ),
    "chapter_divider_finished": MessageLookupByLibrary.simpleMessage(
      "Прочитано",
    ),
    "chapter_divider_load_previous": MessageLookupByLibrary.simpleMessage(
      "Завантажити попередній розділ",
    ),
    "chapter_divider_loading": MessageLookupByLibrary.simpleMessage(
      "Завантажуємо наступний розділ…",
    ),
    "chapter_divider_next": MessageLookupByLibrary.simpleMessage("Далі"),
    "chapter_divider_pages": m13,
    "chapter_divider_previous": MessageLookupByLibrary.simpleMessage(
      "Попередній розділ",
    ),
    "chapter_translation_cancel": MessageLookupByLibrary.simpleMessage(
      "Зупинити переклад",
    ),
    "chapter_translation_cancel_all": MessageLookupByLibrary.simpleMessage(
      "Скасувати все",
    ),
    "chapter_translation_done": MessageLookupByLibrary.simpleMessage(
      "Перекладено",
    ),
    "chapter_translation_done_partial": m14,
    "chapter_translation_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося перекласти",
    ),
    "chapter_translation_notification_channel":
        MessageLookupByLibrary.simpleMessage("Переклад розділів"),
    "chapter_translation_notification_done_body": m15,
    "chapter_translation_notification_done_title":
        MessageLookupByLibrary.simpleMessage("Переклад завершено"),
    "chapter_translation_notification_paused":
        MessageLookupByLibrary.simpleMessage("Призупинено"),
    "chapter_translation_notification_remaining": m16,
    "chapter_translation_pause": MessageLookupByLibrary.simpleMessage(
      "Призупинити",
    ),
    "chapter_translation_preparing": MessageLookupByLibrary.simpleMessage(
      "Готуємо переклад…",
    ),
    "chapter_translation_progress": m17,
    "chapter_translation_queue_title": MessageLookupByLibrary.simpleMessage(
      "Черга перекладу",
    ),
    "chapter_translation_queued": m18,
    "chapter_translation_queued_status": MessageLookupByLibrary.simpleMessage(
      "Очікує перекладу",
    ),
    "chapter_translation_resume": MessageLookupByLibrary.simpleMessage(
      "Відновити",
    ),
    "chapter_translation_translate": MessageLookupByLibrary.simpleMessage(
      "Перекласти розділ",
    ),
    "chapter_translation_translate_all": MessageLookupByLibrary.simpleMessage(
      "Перекласти всі завантажені розділи",
    ),
    "chapter_translation_waiting_download":
        MessageLookupByLibrary.simpleMessage("Завантаження, потім переклад"),
    "chapter_viewer_bottom_modal_settings_reading_mode_title":
        MessageLookupByLibrary.simpleMessage("Режим читання"),
    "chapter_viewer_bottom_modal_settings_tap_controls":
        MessageLookupByLibrary.simpleMessage("Керування дотиками"),
    "chapter_viewer_left_to_right_read_mode":
        MessageLookupByLibrary.simpleMessage("Зліва направо"),
    "chapter_viewer_next_chapter_button_title":
        MessageLookupByLibrary.simpleMessage("Далі"),
    "chapter_viewer_previous_chapter_button_title":
        MessageLookupByLibrary.simpleMessage("Назад"),
    "chapter_viewer_right_to_left_read_mode":
        MessageLookupByLibrary.simpleMessage("Справа наліво"),
    "chapter_viewer_webtoon": MessageLookupByLibrary.simpleMessage("Вебтун"),
    "common_add": MessageLookupByLibrary.simpleMessage("Додати"),
    "common_cancel": MessageLookupByLibrary.simpleMessage("Скасувати"),
    "common_go_back": MessageLookupByLibrary.simpleMessage("Назад"),
    "common_ok_button": MessageLookupByLibrary.simpleMessage("OK"),
    "common_save": MessageLookupByLibrary.simpleMessage("Зберегти"),
    "compat_download_latest_app": MessageLookupByLibrary.simpleMessage(
      "Завантажити останню версію застосунку",
    ),
    "compat_installed_keeps_working": MessageLookupByLibrary.simpleMessage(
      "Встановлена версія працюватиме, доки ви не оновите застосунок.",
    ),
    "compat_open_installed": MessageLookupByLibrary.simpleMessage(
      "Відкрити встановлену версію",
    ),
    "compat_reason_api_version": m19,
    "compat_reason_min_app_version": m20,
    "compat_requires_newer_app": MessageLookupByLibrary.simpleMessage(
      "Оновіть застосунок, щоб користуватися цим джерелом",
    ),
    "compat_update_needs_newer_app": MessageLookupByLibrary.simpleMessage(
      "Є оновлення — потрібна новіша версія застосунку",
    ),
    "concrete_continue_resume": MessageLookupByLibrary.simpleMessage(
      "Продовжити",
    ),
    "concrete_continue_start": MessageLookupByLibrary.simpleMessage("Почати"),
    "concrete_new_badge": MessageLookupByLibrary.simpleMessage("НОВЕ"),
    "concrete_offline_banner": MessageLookupByLibrary.simpleMessage(
      "Офлайн — показано збережені дані. Відкрити можна лише завантажені розділи.",
    ),
    "concrete_related_title": MessageLookupByLibrary.simpleMessage("Пов’язане"),
    "concrete_selection_clear": MessageLookupByLibrary.simpleMessage(
      "Очистити",
    ),
    "concrete_selection_count": m21,
    "concrete_selection_download": MessageLookupByLibrary.simpleMessage(
      "Завантажити",
    ),
    "concrete_selection_invert": MessageLookupByLibrary.simpleMessage(
      "Інвертувати",
    ),
    "concrete_selection_mark_read": MessageLookupByLibrary.simpleMessage(
      "Прочитано",
    ),
    "concrete_selection_mark_unread": MessageLookupByLibrary.simpleMessage(
      "Непрочитано",
    ),
    "concrete_selection_mark_unwatched": MessageLookupByLibrary.simpleMessage(
      "Непереглянуто",
    ),
    "concrete_selection_mark_watched": MessageLookupByLibrary.simpleMessage(
      "Переглянуто",
    ),
    "concrete_selection_select_all": MessageLookupByLibrary.simpleMessage(
      "Усі",
    ),
    "concrete_selection_translate": MessageLookupByLibrary.simpleMessage(
      "Перекласти",
    ),
    "concrete_viewer_art_by": m22,
    "concrete_viewer_by_authors": m23,
    "concrete_viewer_chapters_section_title":
        MessageLookupByLibrary.simpleMessage("Розділи"),
    "concrete_viewer_description_show_less":
        MessageLookupByLibrary.simpleMessage("Згорнути"),
    "concrete_viewer_description_show_more":
        MessageLookupByLibrary.simpleMessage("Показати більше"),
    "concrete_viewer_episodes_section_title":
        MessageLookupByLibrary.simpleMessage("Серії"),
    "concrete_viewer_error_title": MessageLookupByLibrary.simpleMessage(
      "Не вдалося завантажити тайтл",
    ),
    "concrete_viewer_open_website": MessageLookupByLibrary.simpleMessage(
      "Відкрити сайт",
    ),
    "concrete_viewer_retry_button": MessageLookupByLibrary.simpleMessage(
      "Повторити",
    ),
    "configs_filter_all_kinds": MessageLookupByLibrary.simpleMessage("Усі"),
    "configs_filter_all_languages": MessageLookupByLibrary.simpleMessage(
      "Усі мови",
    ),
    "configs_filter_all_prices": MessageLookupByLibrary.simpleMessage(
      "Будь-яка ціна",
    ),
    "configs_filter_language_title": MessageLookupByLibrary.simpleMessage(
      "Мова",
    ),
    "configs_filter_price_title": MessageLookupByLibrary.simpleMessage("Ціна"),
    "configs_layout_cards": MessageLookupByLibrary.simpleMessage("Картки"),
    "configs_layout_compact": MessageLookupByLibrary.simpleMessage(
      "Щільний список",
    ),
    "configs_layout_grid": MessageLookupByLibrary.simpleMessage("Сітка"),
    "configs_pin": MessageLookupByLibrary.simpleMessage("Закріпити вгорі"),
    "configs_pinned_group_title": MessageLookupByLibrary.simpleMessage(
      "Закріплені",
    ),
    "configs_search_hint": MessageLookupByLibrary.simpleMessage("Пошук джерел"),
    "configs_sort_listing": MessageLookupByLibrary.simpleMessage("Як у списку"),
    "configs_sort_name": MessageLookupByLibrary.simpleMessage("Назва"),
    "configs_unpin": MessageLookupByLibrary.simpleMessage("Відкріпити"),
    "configs_view_layout": MessageLookupByLibrary.simpleMessage("Вигляд"),
    "configs_view_options": MessageLookupByLibrary.simpleMessage(
      "Параметри вигляду",
    ),
    "configs_view_sort": MessageLookupByLibrary.simpleMessage("Сортування"),
    "content_kind_anime": MessageLookupByLibrary.simpleMessage("Аніме"),
    "content_kind_audiobook": MessageLookupByLibrary.simpleMessage(
      "Аудіокниги",
    ),
    "content_kind_cartoon": MessageLookupByLibrary.simpleMessage("Мультфільми"),
    "content_kind_comic": MessageLookupByLibrary.simpleMessage("Комікси"),
    "content_kind_documentary": MessageLookupByLibrary.simpleMessage(
      "Документальне",
    ),
    "content_kind_dorama": MessageLookupByLibrary.simpleMessage("Дорами"),
    "content_kind_manga": MessageLookupByLibrary.simpleMessage("Манга"),
    "content_kind_manhua": MessageLookupByLibrary.simpleMessage("Маньхуа"),
    "content_kind_manhwa": MessageLookupByLibrary.simpleMessage("Манхва"),
    "content_kind_movie": MessageLookupByLibrary.simpleMessage("Фільми"),
    "content_kind_novel": MessageLookupByLibrary.simpleMessage("Новели"),
    "content_kind_series": MessageLookupByLibrary.simpleMessage("Серіали"),
    "deepl_key_cancel": MessageLookupByLibrary.simpleMessage("Скасувати"),
    "deepl_key_change": MessageLookupByLibrary.simpleMessage("Змінити"),
    "deepl_key_dialog_message": MessageLookupByLibrary.simpleMessage(
      "Створіть безкоштовний обліковий запис DeepL API і вставте сюди його ключ автентифікації. Безкоштовний план має щомісячний ліміт символів — після збереження ключа його буде видно тут. Ключ зберігається лише на цьому телефоні.",
    ),
    "deepl_key_get": MessageLookupByLibrary.simpleMessage(
      "Отримати безкоштовний ключ",
    ),
    "deepl_key_hint": MessageLookupByLibrary.simpleMessage("Вставте ключ API"),
    "deepl_key_invalid": MessageLookupByLibrary.simpleMessage(
      "DeepL не прийняв цей ключ",
    ),
    "deepl_key_masked": m24,
    "deepl_key_missing": MessageLookupByLibrary.simpleMessage("Не задано"),
    "deepl_key_needed": MessageLookupByLibrary.simpleMessage(
      "Спершу додайте ключ API DeepL у налаштуваннях перекладу сторінок",
    ),
    "deepl_key_network": MessageLookupByLibrary.simpleMessage(
      "Не вдалося з’єднатися з DeepL. Перевірте підключення.",
    ),
    "deepl_key_remove": MessageLookupByLibrary.simpleMessage("Видалити"),
    "deepl_key_save": MessageLookupByLibrary.simpleMessage("Зберегти"),
    "deepl_key_title": MessageLookupByLibrary.simpleMessage("Ключ API DeepL"),
    "deepl_usage_characters": m25,
    "deepl_usage_left": m26,
    "deepl_usage_unavailable": MessageLookupByLibrary.simpleMessage(
      "Дані про використання зараз недоступні",
    ),
    "deepl_usage_used": MessageLookupByLibrary.simpleMessage(
      "використано цього місяця",
    ),
    "discover_attribution": MessageLookupByLibrary.simpleMessage(
      "Дані з AniList",
    ),
    "discover_chapters": m27,
    "discover_empty_title": MessageLookupByLibrary.simpleMessage(
      "Тут поки порожньо",
    ),
    "discover_episodes": m28,
    "discover_error_message": MessageLookupByLibrary.simpleMessage(
      "Перевірте з’єднання і спробуйте ще раз.",
    ),
    "discover_error_title": MessageLookupByLibrary.simpleMessage(
      "Не вдалося завантажити AniList",
    ),
    "discover_find_on_sources": MessageLookupByLibrary.simpleMessage(
      "Знайти в моїх джерелах",
    ),
    "discover_format_manga": MessageLookupByLibrary.simpleMessage("Манга"),
    "discover_format_movie": MessageLookupByLibrary.simpleMessage("Фільм"),
    "discover_format_music": MessageLookupByLibrary.simpleMessage("Кліп"),
    "discover_format_novel": MessageLookupByLibrary.simpleMessage("Новела"),
    "discover_format_ona": MessageLookupByLibrary.simpleMessage("ONA"),
    "discover_format_one_shot": MessageLookupByLibrary.simpleMessage("Ваншот"),
    "discover_format_ova": MessageLookupByLibrary.simpleMessage("OVA"),
    "discover_format_special": MessageLookupByLibrary.simpleMessage("Спешл"),
    "discover_format_tv": MessageLookupByLibrary.simpleMessage("ТБ"),
    "discover_format_tv_short": MessageLookupByLibrary.simpleMessage(
      "Коротке ТБ",
    ),
    "discover_load_more_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося завантажити більше",
    ),
    "discover_no_synopsis": MessageLookupByLibrary.simpleMessage(
      "Опису поки немає.",
    ),
    "discover_open_tooltip": MessageLookupByLibrary.simpleMessage(
      "Огляд з AniList",
    ),
    "discover_retry": MessageLookupByLibrary.simpleMessage("Повторити"),
    "discover_score": m29,
    "discover_search_as": MessageLookupByLibrary.simpleMessage("Шукати як"),
    "discover_season_fall": m30,
    "discover_season_spring": m31,
    "discover_season_summer": m32,
    "discover_season_winter": m33,
    "discover_tab_novels": MessageLookupByLibrary.simpleMessage("Новели"),
    "discover_tab_season": MessageLookupByLibrary.simpleMessage("Цей сезон"),
    "discover_tab_trending_anime": MessageLookupByLibrary.simpleMessage(
      "Популярне аніме",
    ),
    "discover_tab_trending_manga": MessageLookupByLibrary.simpleMessage(
      "Популярна манга",
    ),
    "discover_title": MessageLookupByLibrary.simpleMessage("Огляд"),
    "download_speed_megabytes": m34,
    "download_time_left": m35,
    "downloads_chapters_summary": m36,
    "downloads_confirm_cancel": MessageLookupByLibrary.simpleMessage(
      "Скасувати",
    ),
    "downloads_confirm_delete": MessageLookupByLibrary.simpleMessage(
      "Видалити",
    ),
    "downloads_delete_all": MessageLookupByLibrary.simpleMessage(
      "Видалити все",
    ),
    "downloads_delete_all_confirmation_message":
        MessageLookupByLibrary.simpleMessage(
          "Усі завантажені розділи буде видалено з цього пристрою.",
        ),
    "downloads_delete_all_confirmation_title":
        MessageLookupByLibrary.simpleMessage("Видалити всі завантаження?"),
    "downloads_delete_confirmation_message":
        MessageLookupByLibrary.simpleMessage(
          "Цей розділ буде видалено з цього пристрою.",
        ),
    "downloads_delete_confirmation_title": MessageLookupByLibrary.simpleMessage(
      "Видалити завантаження?",
    ),
    "downloads_empty_message": MessageLookupByLibrary.simpleMessage(
      "Тут з’являться розділи, які ви завантажите для читання офлайн.",
    ),
    "downloads_empty_title": MessageLookupByLibrary.simpleMessage(
      "Немає завантажень",
    ),
    "downloads_episode_bytes_downloaded": m37,
    "downloads_episode_bytes_progress": m38,
    "downloads_episode_delete_confirmation_message":
        MessageLookupByLibrary.simpleMessage(
          "Цю серію буде видалено з цього пристрою.",
        ),
    "downloads_episode_done": MessageLookupByLibrary.simpleMessage(
      "Можна дивитися офлайн",
    ),
    "downloads_episode_done_size": m39,
    "downloads_episode_files_missing": MessageLookupByLibrary.simpleMessage(
      "Завантажені файли цієї серії зникли. Завантажте її знову, щоб дивитися офлайн.",
    ),
    "downloads_episode_preparing": MessageLookupByLibrary.simpleMessage(
      "Підготовка відео…",
    ),
    "downloads_episode_retry": MessageLookupByLibrary.simpleMessage(
      "Повторити завантаження",
    ),
    "downloads_episode_segments_progress": m40,
    "downloads_episode_size_gb": m41,
    "downloads_episode_size_mb": m42,
    "downloads_episode_summary": m43,
    "downloads_notification_channel_name": MessageLookupByLibrary.simpleMessage(
      "Завантаження",
    ),
    "downloads_notification_complete_body": m44,
    "downloads_notification_complete_title":
        MessageLookupByLibrary.simpleMessage("Завантаження завершено"),
    "downloads_notification_downloading_title":
        MessageLookupByLibrary.simpleMessage("Завантаження"),
    "downloads_novel_chapter_done": MessageLookupByLibrary.simpleMessage(
      "Збережено для читання офлайн",
    ),
    "downloads_novel_chapter_downloading": MessageLookupByLibrary.simpleMessage(
      "Зберігаємо текст…",
    ),
    "downloads_order_newest": MessageLookupByLibrary.simpleMessage(
      "Спершу нові",
    ),
    "downloads_order_oldest": MessageLookupByLibrary.simpleMessage(
      "Спершу старі",
    ),
    "downloads_pages_progress": m45,
    "downloads_quality_1080": MessageLookupByLibrary.simpleMessage("1080p"),
    "downloads_quality_480": MessageLookupByLibrary.simpleMessage("480p"),
    "downloads_quality_720": MessageLookupByLibrary.simpleMessage("720p"),
    "downloads_quality_highest": MessageLookupByLibrary.simpleMessage(
      "Найвища доступна",
    ),
    "downloads_quality_same_as_player": MessageLookupByLibrary.simpleMessage(
      "Як у плеєрі",
    ),
    "downloads_quality_title": MessageLookupByLibrary.simpleMessage(
      "Якість завантаження",
    ),
    "downloads_queue_button": m46,
    "downloads_queue_download_next": MessageLookupByLibrary.simpleMessage(
      "Завантажити наступним",
    ),
    "downloads_queue_empty": MessageLookupByLibrary.simpleMessage(
      "У черзі нічого немає",
    ),
    "downloads_queue_move_title_to_top": MessageLookupByLibrary.simpleMessage(
      "Перемістити на початок черги",
    ),
    "downloads_queue_now_downloading": MessageLookupByLibrary.simpleMessage(
      "Завантажується зараз",
    ),
    "downloads_queue_pause": MessageLookupByLibrary.simpleMessage(
      "Призупинити",
    ),
    "downloads_queue_pause_all": MessageLookupByLibrary.simpleMessage(
      "Призупинити все",
    ),
    "downloads_queue_pause_title": MessageLookupByLibrary.simpleMessage(
      "Призупинити завантаження тайтлу",
    ),
    "downloads_queue_paused_progress": m47,
    "downloads_queue_remove": MessageLookupByLibrary.simpleMessage(
      "Прибрати з черги",
    ),
    "downloads_queue_reorder_hint": MessageLookupByLibrary.simpleMessage(
      "Перетягуйте за маркери, щоб змінити порядок завантаження",
    ),
    "downloads_queue_resume": MessageLookupByLibrary.simpleMessage("Відновити"),
    "downloads_queue_resume_all": MessageLookupByLibrary.simpleMessage(
      "Відновити все",
    ),
    "downloads_queue_resume_title": MessageLookupByLibrary.simpleMessage(
      "Відновити завантаження тайтлу",
    ),
    "downloads_queue_status_paused": MessageLookupByLibrary.simpleMessage(
      "Призупинено",
    ),
    "downloads_queue_title": MessageLookupByLibrary.simpleMessage("Черга"),
    "downloads_runtime_app_must_stay_open": MessageLookupByLibrary.simpleMessage(
      "Android зупинив фонове завантаження. Не закривайте застосунок, доки завантаження не завершаться.",
    ),
    "downloads_runtime_waiting_for_wifi": MessageLookupByLibrary.simpleMessage(
      "Очікування Wi-Fi",
    ),
    "downloads_runtime_waiting_for_wifi_message":
        MessageLookupByLibrary.simpleMessage(
          "Завантаження відновляться автоматично, щойно ви підключитеся до Wi-Fi",
        ),
    "downloads_runtime_wifi_only_subtitle": MessageLookupByLibrary.simpleMessage(
      "Завантаження в черзі чекатимуть на підключення до Wi-Fi або Ethernet",
    ),
    "downloads_runtime_wifi_only_title": MessageLookupByLibrary.simpleMessage(
      "Завантажувати лише через Wi-Fi",
    ),
    "downloads_status_downloading": MessageLookupByLibrary.simpleMessage(
      "Завантаження",
    ),
    "downloads_status_failed": MessageLookupByLibrary.simpleMessage("Помилка"),
    "downloads_status_queued": MessageLookupByLibrary.simpleMessage("У черзі"),
    "downloads_storage_calculating": MessageLookupByLibrary.simpleMessage(
      "Обчислення…",
    ),
    "downloads_storage_delete_after_watching_subtitle":
        MessageLookupByLibrary.simpleMessage(
          "Видаляти завантажену серію, щойно ви додивитеся її в плеєрі",
        ),
    "downloads_storage_delete_after_watching_title":
        MessageLookupByLibrary.simpleMessage("Видаляти серії після перегляду"),
    "downloads_storage_delete_all_short": MessageLookupByLibrary.simpleMessage(
      "Видалити все",
    ),
    "downloads_storage_delete_title_confirm_message": m48,
    "downloads_storage_delete_title_confirm_title":
        MessageLookupByLibrary.simpleMessage("Видалити ці завантаження?"),
    "downloads_storage_delete_title_downloads":
        MessageLookupByLibrary.simpleMessage(
          "Видалити всі завантаження цього тайтлу",
        ),
    "downloads_storage_delete_watched": MessageLookupByLibrary.simpleMessage(
      "Видалити переглянуте",
    ),
    "downloads_storage_delete_watched_confirm_message": m49,
    "downloads_storage_delete_watched_confirm_title":
        MessageLookupByLibrary.simpleMessage("Видалити переглянуті серії?"),
    "downloads_storage_delete_watched_episodes":
        MessageLookupByLibrary.simpleMessage("Видалити переглянуті серії"),
    "downloads_storage_deleted_watched": m50,
    "downloads_storage_free_up": MessageLookupByLibrary.simpleMessage(
      "Звільнити місце",
    ),
    "downloads_storage_free_up_empty": MessageLookupByLibrary.simpleMessage(
      "Нічого звільняти",
    ),
    "downloads_storage_free_up_reclaimable": m51,
    "downloads_storage_no_watched": MessageLookupByLibrary.simpleMessage(
      "Немає переглянутих серій для видалення",
    ),
    "downloads_storage_playback_fallback": MessageLookupByLibrary.simpleMessage(
      "Не вдалося відтворити завантажений файл, тому відео відтворюється онлайн.",
    ),
    "downloads_storage_redownload": MessageLookupByLibrary.simpleMessage(
      "Завантажити знову",
    ),
    "downloads_storage_section_title": MessageLookupByLibrary.simpleMessage(
      "Завантаження",
    ),
    "downloads_storage_summary_with_size": m52,
    "downloads_storage_title_size": m53,
    "downloads_storage_used": MessageLookupByLibrary.simpleMessage(
      "Зайнято місця",
    ),
    "downloads_storage_watched_size": m54,
    "downloads_title": MessageLookupByLibrary.simpleMessage("Завантаження"),
    "duration_hours_minutes": m55,
    "duration_minutes": m56,
    "duration_seconds": m57,
    "engine_tag_best": MessageLookupByLibrary.simpleMessage("Найкраща якість"),
    "engine_tag_fast": MessageLookupByLibrary.simpleMessage("Швидкий"),
    "engine_tag_literal": MessageLookupByLibrary.simpleMessage("Дослівний"),
    "engine_tag_natural": MessageLookupByLibrary.simpleMessage("Природний"),
    "engine_tag_offline": MessageLookupByLibrary.simpleMessage("Офлайн"),
    "engine_tag_online": MessageLookupByLibrary.simpleMessage("Онлайн"),
    "engine_tag_size": m58,
    "engine_tag_speed_e2b": MessageLookupByLibrary.simpleMessage(
      "≈4–10 с на сторінку",
    ),
    "engine_tag_speed_e4b": MessageLookupByLibrary.simpleMessage(
      "≈20–45 с на сторінку",
    ),
    "episode_playback_fallback_notice": MessageLookupByLibrary.simpleMessage(
      "Не вдалося завантажити відеопотік, відкрито вебплеєр",
    ),
    "episode_playback_loading_sources": MessageLookupByLibrary.simpleMessage(
      "Завантаження відео…",
    ),
    "export_section_categories": MessageLookupByLibrary.simpleMessage(
      "Категорії",
    ),
    "export_section_categories_subtitle": MessageLookupByLibrary.simpleMessage(
      "Категорії бібліотеки",
    ),
    "export_section_history": MessageLookupByLibrary.simpleMessage(
      "Історія читання",
    ),
    "export_section_history_subtitle": MessageLookupByLibrary.simpleMessage(
      "Прочитані розділи й переглянуті серії",
    ),
    "export_section_library": MessageLookupByLibrary.simpleMessage(
      "Бібліотека",
    ),
    "export_section_library_subtitle": MessageLookupByLibrary.simpleMessage(
      "Тайтли, додані до бібліотеки",
    ),
    "export_section_settings": MessageLookupByLibrary.simpleMessage(
      "Налаштування",
    ),
    "export_section_settings_subtitle": MessageLookupByLibrary.simpleMessage(
      "Тема, читалка, плеєр, вигляд і переклад",
    ),
    "export_section_sources": MessageLookupByLibrary.simpleMessage(
      "Джерела розширень",
    ),
    "export_section_sources_subtitle": MessageLookupByLibrary.simpleMessage(
      "Додані вами репозиторії",
    ),
    "export_section_translations": MessageLookupByLibrary.simpleMessage(
      "Переклади сторінок",
    ),
    "export_section_translations_subtitle":
        MessageLookupByLibrary.simpleMessage(
          "Перекладені сторінки, щоб не перекладати їх знову",
        ),
    "ext_prefs_clear_data": MessageLookupByLibrary.simpleMessage(
      "Очистити збережені дані",
    ),
    "ext_prefs_clear_data_done": m59,
    "ext_prefs_default_hint": m60,
    "ext_prefs_done": MessageLookupByLibrary.simpleMessage("Готово"),
    "ext_prefs_mirror_automatic": MessageLookupByLibrary.simpleMessage(
      "Автоматично",
    ),
    "ext_prefs_mirror_summary": MessageLookupByLibrary.simpleMessage(
      "На яку адресу сайту надсилати запити. «Автоматично» перебирає дзеркала, доки одне не відповість.",
    ),
    "ext_prefs_mirror_title": MessageLookupByLibrary.simpleMessage("Дзеркало"),
    "ext_prefs_number_invalid": MessageLookupByLibrary.simpleMessage(
      "Введіть число",
    ),
    "ext_prefs_page_size_default_option": m61,
    "ext_prefs_page_size_option": m62,
    "ext_prefs_page_size_summary": MessageLookupByLibrary.simpleMessage(
      "Скільки тайтлів завантажує кожна сторінка галереї.",
    ),
    "ext_prefs_page_size_title": MessageLookupByLibrary.simpleMessage(
      "Розмір сторінки",
    ),
    "ext_prefs_reset": MessageLookupByLibrary.simpleMessage(
      "Скинути все до типових",
    ),
    "ext_prefs_reset_one": MessageLookupByLibrary.simpleMessage(
      "Скинути до типового",
    ),
    "ext_prefs_sheet_title": MessageLookupByLibrary.simpleMessage(
      "Налаштування розширення",
    ),
    "extension_clear_session": MessageLookupByLibrary.simpleMessage(
      "Очистити збережену сесію",
    ),
    "extension_clear_session_done": m63,
    "extension_instance_add": MessageLookupByLibrary.simpleMessage(
      "Додати ще один сервер",
    ),
    "extension_instance_add_confirm": MessageLookupByLibrary.simpleMessage(
      "Додати",
    ),
    "extension_instance_add_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося додати сервер. Перевірте підключення й спробуйте ще раз.",
    ),
    "extension_instance_added": m64,
    "extension_instance_rename": MessageLookupByLibrary.simpleMessage(
      "Перейменувати",
    ),
    "extension_instance_rename_confirm": MessageLookupByLibrary.simpleMessage(
      "Зберегти",
    ),
    "extension_source_page_error_adding_source":
        MessageLookupByLibrary.simpleMessage(
          "Помилка під час додавання джерела",
        ),
    "extension_source_page_error_removing_source":
        MessageLookupByLibrary.simpleMessage(
          "Помилка під час видалення джерела",
        ),
    "extension_source_page_error_updating_source":
        MessageLookupByLibrary.simpleMessage(
          "Помилка під час оновлення джерела",
        ),
    "extension_source_page_remove_source_dialog_cancel_label":
        MessageLookupByLibrary.simpleMessage("Скасувати"),
    "extension_source_page_remove_source_dialog_message":
        MessageLookupByLibrary.simpleMessage(
          "Ви впевнені, що хочете видалити це джерело?",
        ),
    "extension_source_page_remove_source_dialog_ok_label":
        MessageLookupByLibrary.simpleMessage("Видалити"),
    "extension_source_page_remove_source_dialog_title":
        MessageLookupByLibrary.simpleMessage("Видалити джерело"),
    "extension_sources_page_appbar_title": MessageLookupByLibrary.simpleMessage(
      "Репозиторії",
    ),
    "extension_sources_page_default_badge":
        MessageLookupByLibrary.simpleMessage("Типовий"),
    "extension_sources_page_error_loading_sources":
        MessageLookupByLibrary.simpleMessage(
          "Помилка під час завантаження джерел",
        ),
    "extension_sources_page_wakaranai_github_repo_title":
        MessageLookupByLibrary.simpleMessage("Wakaranai Extensions"),
    "extension_uninstall": MessageLookupByLibrary.simpleMessage("Видалити"),
    "extension_uninstall_done": m65,
    "extension_uninstall_message": MessageLookupByLibrary.simpleMessage(
      "Буде видалено завантажений скрипт, його налаштування, збережені дані та вхід. Тайтли в бібліотеці й завантаження залишаться; якщо відкрити один із них, розширення встановиться знову.",
    ),
    "extension_uninstall_title": m66,
    "external_player_action": MessageLookupByLibrary.simpleMessage(
      "Зовнішній плеєр",
    ),
    "external_player_unavailable": MessageLookupByLibrary.simpleMessage(
      "Зовнішній відеоплеєр не встановлено. Відтворюємо у вбудованому плеєрі.",
    ),
    "feeds_row_label": MessageLookupByLibrary.simpleMessage("Стрічки"),
    "filters_active_summary": m67,
    "filters_add_value": MessageLookupByLibrary.simpleMessage("Додати"),
    "filters_any_option": MessageLookupByLibrary.simpleMessage("Будь-яке"),
    "filters_button_semantics": m68,
    "filters_clear_search": MessageLookupByLibrary.simpleMessage(
      "Очистити пошук",
    ),
    "filters_clear_section": MessageLookupByLibrary.simpleMessage("Очистити"),
    "filters_empty_message": MessageLookupByLibrary.simpleMessage(
      "Це джерело не має фільтрів.",
    ),
    "filters_empty_title": MessageLookupByLibrary.simpleMessage(
      "Немає фільтрів",
    ),
    "filters_none_active": MessageLookupByLibrary.simpleMessage("Показано все"),
    "filters_range_any": MessageLookupByLibrary.simpleMessage("Будь-яке"),
    "filters_remove_value": m69,
    "filters_search_hint": m70,
    "filters_show_all": m71,
    "filters_show_less": MessageLookupByLibrary.simpleMessage("Згорнути"),
    "gallery_filters_apply_button": MessageLookupByLibrary.simpleMessage(
      "Застосувати",
    ),
    "gallery_filters_apply_button_count": m72,
    "gallery_filters_button_label": MessageLookupByLibrary.simpleMessage(
      "Фільтри",
    ),
    "gallery_filters_more_options": m73,
    "gallery_filters_multiple_of_any_hint":
        MessageLookupByLibrary.simpleMessage("Введіть і додайте"),
    "gallery_filters_no_matches": MessageLookupByLibrary.simpleMessage(
      "Нічого не знайдено",
    ),
    "gallery_filters_one_of_any_hint": MessageLookupByLibrary.simpleMessage(
      "Введіть значення",
    ),
    "gallery_filters_option_search_hint": MessageLookupByLibrary.simpleMessage(
      "Пошук",
    ),
    "gallery_filters_range_from_hint": MessageLookupByLibrary.simpleMessage(
      "Від",
    ),
    "gallery_filters_range_to_hint": MessageLookupByLibrary.simpleMessage("До"),
    "gallery_filters_reset_button": MessageLookupByLibrary.simpleMessage(
      "Скинути",
    ),
    "gallery_filters_sheet_title": MessageLookupByLibrary.simpleMessage(
      "Фільтри",
    ),
    "gallery_last_opened": m74,
    "gallery_layout_button_tooltip": m75,
    "gallery_layout_comfortable": MessageLookupByLibrary.simpleMessage(
      "Звичайна сітка",
    ),
    "gallery_layout_compact": MessageLookupByLibrary.simpleMessage(
      "Щільна сітка",
    ),
    "gallery_layout_list": MessageLookupByLibrary.simpleMessage("Список"),
    "global_search_empty_sources": m76,
    "global_search_hint": MessageLookupByLibrary.simpleMessage(
      "Шукати тайтли у ваших джерелах",
    ),
    "global_search_idle_message": MessageLookupByLibrary.simpleMessage(
      "Кожне джерело показує результати, щойно відповість.",
    ),
    "global_search_idle_title": MessageLookupByLibrary.simpleMessage(
      "Шукайте в усіх своїх джерелах",
    ),
    "global_search_no_results_message": m77,
    "global_search_no_results_title": MessageLookupByLibrary.simpleMessage(
      "Нічого не знайдено",
    ),
    "global_search_no_scope_message": MessageLookupByLibrary.simpleMessage(
      "Виберіть хоча б одне джерело.",
    ),
    "global_search_no_scope_title": MessageLookupByLibrary.simpleMessage(
      "Немає джерел для пошуку",
    ),
    "global_search_open_tooltip": MessageLookupByLibrary.simpleMessage(
      "Шукати в усіх джерелах",
    ),
    "global_search_rail_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося виконати пошук у цьому джерелі",
    ),
    "global_search_rail_open": MessageLookupByLibrary.simpleMessage("Відкрити"),
    "global_search_rail_retry": MessageLookupByLibrary.simpleMessage(
      "Повторити",
    ),
    "global_search_rail_sign_in": MessageLookupByLibrary.simpleMessage(
      "Потрібен вхід",
    ),
    "global_search_rail_timeout": MessageLookupByLibrary.simpleMessage(
      "Джерело відповідало надто довго",
    ),
    "global_search_rail_unavailable": MessageLookupByLibrary.simpleMessage(
      "Не вдалося завантажити це джерело",
    ),
    "global_search_rail_verify": MessageLookupByLibrary.simpleMessage(
      "Потрібна перевірка",
    ),
    "global_search_recent_clear": MessageLookupByLibrary.simpleMessage(
      "Очистити",
    ),
    "global_search_recent_title": MessageLookupByLibrary.simpleMessage(
      "Нещодавні запити",
    ),
    "global_search_results_count": m78,
    "global_search_scope_custom_hint": MessageLookupByLibrary.simpleMessage(
      "Ваш власний вибір",
    ),
    "global_search_scope_default_hint": MessageLookupByLibrary.simpleMessage(
      "Типово: закріплені джерела та ті, якими ви користувалися",
    ),
    "global_search_scope_edit": MessageLookupByLibrary.simpleMessage("Змінити"),
    "global_search_scope_empty": MessageLookupByLibrary.simpleMessage(
      "Немає джерел із пошуком",
    ),
    "global_search_scope_loading": MessageLookupByLibrary.simpleMessage(
      "Шукаємо інші джерела…",
    ),
    "global_search_scope_reset": MessageLookupByLibrary.simpleMessage(
      "Як типово",
    ),
    "global_search_scope_select_all": MessageLookupByLibrary.simpleMessage(
      "Вибрати всі",
    ),
    "global_search_scope_select_none": MessageLookupByLibrary.simpleMessage(
      "Очистити",
    ),
    "global_search_scope_summary": m79,
    "global_search_scope_title": MessageLookupByLibrary.simpleMessage(
      "Де шукати",
    ),
    "global_search_title": MessageLookupByLibrary.simpleMessage(
      "Пошук у джерелах",
    ),
    "global_search_try_titles": MessageLookupByLibrary.simpleMessage(
      "Шукати як",
    ),
    "home_anime_group_title": MessageLookupByLibrary.simpleMessage("Відео"),
    "home_audio_group_title": MessageLookupByLibrary.simpleMessage(
      "Аудіокниги",
    ),
    "home_configs_source_initializing_error": m80,
    "home_extensions_error_message": MessageLookupByLibrary.simpleMessage(
      "Помилка джерела розширень :c",
    ),
    "home_extensions_error_title": MessageLookupByLibrary.simpleMessage(
      "Не вдалося завантажити розширення",
    ),
    "home_fetching_mangas_configs_error": MessageLookupByLibrary.simpleMessage(
      "Помилка під час отримання конфігурацій манги",
    ),
    "home_manga_group_title": MessageLookupByLibrary.simpleMessage("Манга"),
    "home_navigation_bar_activity_history_title":
        MessageLookupByLibrary.simpleMessage("Історія"),
    "home_navigation_bar_library_title": MessageLookupByLibrary.simpleMessage(
      "Бібліотека",
    ),
    "home_navigation_bar_settings_title": MessageLookupByLibrary.simpleMessage(
      "Налаштування",
    ),
    "home_navigation_bar_sources_title": MessageLookupByLibrary.simpleMessage(
      "Огляд",
    ),
    "home_no_extensions_message": MessageLookupByLibrary.simpleMessage(
      "У цьому джерелі ще немає розширень",
    ),
    "home_no_extensions_title": MessageLookupByLibrary.simpleMessage(
      "Немає розширень",
    ),
    "home_novel_group_title": MessageLookupByLibrary.simpleMessage("Новели"),
    "home_nsfw_suffix": MessageLookupByLibrary.simpleMessage("NSFW"),
    "home_remote_configs_page_appbar_title":
        MessageLookupByLibrary.simpleMessage("Розширення"),
    "home_sources_button": MessageLookupByLibrary.simpleMessage("Джерела"),
    "language_packs_available_section": MessageLookupByLibrary.simpleMessage(
      "Доступні",
    ),
    "language_packs_cancel": MessageLookupByLibrary.simpleMessage("Скасувати"),
    "language_packs_downloaded_count": m81,
    "language_packs_downloaded_section": MessageLookupByLibrary.simpleMessage(
      "Завантажені",
    ),
    "language_packs_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося завантажити",
    ),
    "language_packs_hint": MessageLookupByLibrary.simpleMessage(
      "Кожен пакет займає близько 30 МБ. Потрібні лише мови, з яких і на які ви перекладаєте.",
    ),
    "language_packs_hint_wifi": MessageLookupByLibrary.simpleMessage(
      "Кожен пакет займає близько 30 МБ. Потрібні лише мови, з яких і на які ви перекладаєте. Завантаження чекатимуть на Wi-Fi.",
    ),
    "language_packs_queue_progress": m82,
    "language_packs_queued": m83,
    "language_packs_retry": MessageLookupByLibrary.simpleMessage("Повторити"),
    "language_packs_title": MessageLookupByLibrary.simpleMessage(
      "Мовні пакети",
    ),
    "library_add": MessageLookupByLibrary.simpleMessage("Додати до бібліотеки"),
    "library_add_category": MessageLookupByLibrary.simpleMessage(
      "Додати категорію",
    ),
    "library_add_to_category": MessageLookupByLibrary.simpleMessage(
      "Додати до категорії",
    ),
    "library_added_message": MessageLookupByLibrary.simpleMessage(
      "Додано до бібліотеки",
    ),
    "library_category_all": MessageLookupByLibrary.simpleMessage("Усі"),
    "library_category_name_hint": MessageLookupByLibrary.simpleMessage(
      "Назва категорії",
    ),
    "library_category_uncategorized": MessageLookupByLibrary.simpleMessage(
      "Без категорії",
    ),
    "library_continue": MessageLookupByLibrary.simpleMessage("Продовжити"),
    "library_delete_category": MessageLookupByLibrary.simpleMessage("Видалити"),
    "library_download_first_group_hint": MessageLookupByLibrary.simpleMessage(
      "Для кожного тайтлу завантажується перша група розділів",
    ),
    "library_download_many_failed": m84,
    "library_download_many_loading": m85,
    "library_empty_message": MessageLookupByLibrary.simpleMessage(
      "Торкніться сердечка на сторінці тайтлу, щоб додати його сюди",
    ),
    "library_empty_title": MessageLookupByLibrary.simpleMessage(
      "Ваша бібліотека порожня",
    ),
    "library_manage_categories": MessageLookupByLibrary.simpleMessage(
      "Керувати категоріями",
    ),
    "library_more_actions": MessageLookupByLibrary.simpleMessage("Ще"),
    "library_move_to_category": MessageLookupByLibrary.simpleMessage(
      "Перемістити до категорії",
    ),
    "library_mute_notifications": MessageLookupByLibrary.simpleMessage(
      "Вимкнути сповіщення",
    ),
    "library_new_chapters": m86,
    "library_no_category": MessageLookupByLibrary.simpleMessage(
      "Без категорії",
    ),
    "library_remove": MessageLookupByLibrary.simpleMessage(
      "Прибрати з бібліотеки",
    ),
    "library_removed_message": MessageLookupByLibrary.simpleMessage(
      "Прибрано з бібліотеки",
    ),
    "library_rename_category": MessageLookupByLibrary.simpleMessage(
      "Перейменувати",
    ),
    "library_search_hint": MessageLookupByLibrary.simpleMessage(
      "Пошук у бібліотеці",
    ),
    "library_search_no_results_message": m87,
    "library_search_no_results_title": MessageLookupByLibrary.simpleMessage(
      "Нічого не знайдено",
    ),
    "library_select_all": MessageLookupByLibrary.simpleMessage("Вибрати все"),
    "library_selected_count": m88,
    "library_sort_added_newest": MessageLookupByLibrary.simpleMessage(
      "Нещодавно додані",
    ),
    "library_sort_added_oldest": MessageLookupByLibrary.simpleMessage(
      "Давно додані",
    ),
    "library_sort_alphabetical": MessageLookupByLibrary.simpleMessage("Назва"),
    "library_sort_last_read": MessageLookupByLibrary.simpleMessage(
      "Останнє прочитане",
    ),
    "library_sort_title": MessageLookupByLibrary.simpleMessage("Сортування"),
    "library_source_unavailable_message": MessageLookupByLibrary.simpleMessage(
      "Розширення для цього тайтлу більше не встановлене",
    ),
    "library_source_unavailable_title": MessageLookupByLibrary.simpleMessage(
      "Джерело недоступне",
    ),
    "library_tab_titles": MessageLookupByLibrary.simpleMessage("Тайтли"),
    "library_track_updates": MessageLookupByLibrary.simpleMessage(
      "Перевіряти оновлення",
    ),
    "library_unmute_notifications": MessageLookupByLibrary.simpleMessage(
      "Увімкнути сповіщення",
    ),
    "local_books_import": MessageLookupByLibrary.simpleMessage(
      "Імпортувати файли EPUB",
    ),
    "local_books_imported": m89,
    "local_books_name": MessageLookupByLibrary.simpleMessage("Локальні книги"),
    "local_books_untitled_chapter": m90,
    "local_books_where": MessageLookupByLibrary.simpleMessage(
      "Куди класти книги",
    ),
    "local_books_where_message": m91,
    "local_extension_server_source_name": MessageLookupByLibrary.simpleMessage(
      "Локальний сервер",
    ),
    "local_source_import": MessageLookupByLibrary.simpleMessage(
      "Імпортувати файли CBZ або ZIP",
    ),
    "local_source_imported": m92,
    "local_source_imported_title": MessageLookupByLibrary.simpleMessage(
      "Імпортовані",
    ),
    "local_source_name": MessageLookupByLibrary.simpleMessage("Локальні файли"),
    "local_source_where": MessageLookupByLibrary.simpleMessage(
      "Куди класти файли",
    ),
    "local_source_where_message": m93,
    "migration_action_find_elsewhere": MessageLookupByLibrary.simpleMessage(
      "Знайти на іншому джерелі",
    ),
    "migration_action_move": MessageLookupByLibrary.simpleMessage(
      "Перенести на інше джерело",
    ),
    "migration_apply": MessageLookupByLibrary.simpleMessage("Перенести"),
    "migration_apply_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося перенести тайтл. Нічого не змінено.",
    ),
    "migration_best_match": MessageLookupByLibrary.simpleMessage(
      "Найкращий збіг",
    ),
    "migration_bulk_auto_pick": MessageLookupByLibrary.simpleMessage(
      "Автовибір точних збігів",
    ),
    "migration_bulk_auto_pick_hint": MessageLookupByLibrary.simpleMessage(
      "Тайтл з одним точним збігом переноситься без запитання",
    ),
    "migration_bulk_choose": MessageLookupByLibrary.simpleMessage("Вибрати"),
    "migration_bulk_done": MessageLookupByLibrary.simpleMessage("Готово"),
    "migration_bulk_downloads_note": MessageLookupByLibrary.simpleMessage(
      "Завантаження залишаються зі старими тайтлами, файли не переносяться",
    ),
    "migration_bulk_progress": m94,
    "migration_bulk_running_title": MessageLookupByLibrary.simpleMessage(
      "Перенесення тайтлів",
    ),
    "migration_bulk_skip": MessageLookupByLibrary.simpleMessage("Пропустити"),
    "migration_bulk_start": MessageLookupByLibrary.simpleMessage("Почати"),
    "migration_bulk_status_auto": m95,
    "migration_bulk_status_done": m96,
    "migration_bulk_status_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося перенести",
    ),
    "migration_bulk_status_migrating": m97,
    "migration_bulk_status_pick": m98,
    "migration_bulk_status_searching": MessageLookupByLibrary.simpleMessage(
      "Пошук…",
    ),
    "migration_bulk_status_skipped": MessageLookupByLibrary.simpleMessage(
      "Пропущено",
    ),
    "migration_bulk_status_waiting": MessageLookupByLibrary.simpleMessage(
      "Очікує",
    ),
    "migration_bulk_stop": MessageLookupByLibrary.simpleMessage("Зупинити"),
    "migration_bulk_summary": m99,
    "migration_bulk_targets": MessageLookupByLibrary.simpleMessage(
      "Цільові джерела",
    ),
    "migration_bulk_title": m100,
    "migration_chip": MessageLookupByLibrary.simpleMessage("Змінити джерело"),
    "migration_choose_sources": MessageLookupByLibrary.simpleMessage(
      "Обрати джерела",
    ),
    "migration_continue": MessageLookupByLibrary.simpleMessage("Далі"),
    "migration_done": m101,
    "migration_downloads_note": m102,
    "migration_exact_match": MessageLookupByLibrary.simpleMessage(
      "Точний збіг",
    ),
    "migration_load_failed_title": MessageLookupByLibrary.simpleMessage(
      "Не вдалося відкрити новий тайтл",
    ),
    "migration_mapping_empty": MessageLookupByLibrary.simpleMessage(
      "Немає прогресу для перенесення",
    ),
    "migration_mapping_more": m103,
    "migration_mapping_partial": m104,
    "migration_mapping_read": MessageLookupByLibrary.simpleMessage("Прочитано"),
    "migration_mapping_title": MessageLookupByLibrary.simpleMessage("Прогрес"),
    "migration_mapping_unmatched_title": MessageLookupByLibrary.simpleMessage(
      "Не знайдено на новому джерелі",
    ),
    "migration_mapping_watched": MessageLookupByLibrary.simpleMessage(
      "Переглянуто",
    ),
    "migration_no_candidates_message": MessageLookupByLibrary.simpleMessage(
      "Спробуйте іншу назву або додайте більше цільових джерел.",
    ),
    "migration_no_candidates_title": MessageLookupByLibrary.simpleMessage(
      "Нічого не знайдено",
    ),
    "migration_no_scope_message": MessageLookupByLibrary.simpleMessage(
      "Оберіть джерела, на які слід перенести тайтл.",
    ),
    "migration_no_scope_title": MessageLookupByLibrary.simpleMessage(
      "Оберіть, де шукати",
    ),
    "migration_open": MessageLookupByLibrary.simpleMessage("Відкрити"),
    "migration_option_category": MessageLookupByLibrary.simpleMessage(
      "Категорія",
    ),
    "migration_option_category_hint": m105,
    "migration_option_chapters_hint": m106,
    "migration_option_episodes_hint": m107,
    "migration_option_keep_old_hint": MessageLookupByLibrary.simpleMessage(
      "Обидва тайтли залишаться в бібліотеці",
    ),
    "migration_option_read_progress": MessageLookupByLibrary.simpleMessage(
      "Прогрес читання",
    ),
    "migration_option_remove_old": MessageLookupByLibrary.simpleMessage(
      "Прибрати старий запис",
    ),
    "migration_option_remove_old_hint": MessageLookupByLibrary.simpleMessage(
      "Новий тайтл займе його місце в бібліотеці",
    ),
    "migration_option_trackers": MessageLookupByLibrary.simpleMessage(
      "Прив\'язки до трекерів",
    ),
    "migration_option_trackers_hint": m108,
    "migration_option_watch_progress": MessageLookupByLibrary.simpleMessage(
      "Прогрес перегляду",
    ),
    "migration_options_title": MessageLookupByLibrary.simpleMessage(
      "Що перенести",
    ),
    "migration_pick_hint": MessageLookupByLibrary.simpleMessage(
      "Торкніться тайтлу, щоб вибрати його",
    ),
    "migration_preview_new": MessageLookupByLibrary.simpleMessage("Нове"),
    "migration_preview_old": MessageLookupByLibrary.simpleMessage("Зараз"),
    "migration_preview_title": MessageLookupByLibrary.simpleMessage(
      "Перевірте перенесення",
    ),
    "migration_retry": MessageLookupByLibrary.simpleMessage(
      "Спробувати ще раз",
    ),
    "migration_search_from": m109,
    "migration_search_hint": MessageLookupByLibrary.simpleMessage(
      "Пошук на цільових джерелах",
    ),
    "migration_search_idle_message": MessageLookupByLibrary.simpleMessage(
      "Введіть назву нижче, щоб пошукати його на цільових джерелах.",
    ),
    "migration_search_idle_title": MessageLookupByLibrary.simpleMessage(
      "Знайдіть тайтл",
    ),
    "migration_search_title": MessageLookupByLibrary.simpleMessage(
      "Перенесення на інше джерело",
    ),
    "migration_search_unknown_source": MessageLookupByLibrary.simpleMessage(
      "джерелі, якого вже немає",
    ),
    "migration_selected": MessageLookupByLibrary.simpleMessage("Вибрано"),
    "migration_targets_summary": m110,
    "migration_use_this": MessageLookupByLibrary.simpleMessage("Вибрати"),
    "native_player_auto_next_cancel": MessageLookupByLibrary.simpleMessage(
      "Скасувати",
    ),
    "native_player_auto_next_countdown": m111,
    "native_player_auto_next_play_now": MessageLookupByLibrary.simpleMessage(
      "Відтворити зараз",
    ),
    "native_player_cancel_switch": MessageLookupByLibrary.simpleMessage(
      "Скасувати",
    ),
    "native_player_debug_action": MessageLookupByLibrary.simpleMessage(
      "Відтворити URL у вбудованому плеєрі",
    ),
    "native_player_debug_play": MessageLookupByLibrary.simpleMessage(
      "Відтворити",
    ),
    "native_player_debug_url_hint": MessageLookupByLibrary.simpleMessage(
      "https://example.com/video.m3u8",
    ),
    "native_player_debug_url_label": MessageLookupByLibrary.simpleMessage(
      "URL потоку",
    ),
    "native_player_debug_url_title": MessageLookupByLibrary.simpleMessage(
      "Відтворити URL потоку",
    ),
    "native_player_error_title": MessageLookupByLibrary.simpleMessage(
      "Не вдалося відтворити відео",
    ),
    "native_player_fit_mode": MessageLookupByLibrary.simpleMessage(
      "Масштаб відео",
    ),
    "native_player_fit_mode_fill": MessageLookupByLibrary.simpleMessage(
      "Заповнити",
    ),
    "native_player_fit_mode_fit": MessageLookupByLibrary.simpleMessage(
      "Вмістити",
    ),
    "native_player_fit_mode_stretch": MessageLookupByLibrary.simpleMessage(
      "Розтягнути",
    ),
    "native_player_lock": MessageLookupByLibrary.simpleMessage(
      "Заблокувати керування",
    ),
    "native_player_more": MessageLookupByLibrary.simpleMessage(
      "Інші параметри",
    ),
    "native_player_next_episode": MessageLookupByLibrary.simpleMessage(
      "Наступна серія",
    ),
    "native_player_no_streams": MessageLookupByLibrary.simpleMessage(
      "Немає потоків, які можна відтворити",
    ),
    "native_player_open_web_player": MessageLookupByLibrary.simpleMessage(
      "Відкрити у вебплеєрі",
    ),
    "native_player_pause": MessageLookupByLibrary.simpleMessage("Пауза"),
    "native_player_pip_enter": MessageLookupByLibrary.simpleMessage(
      "Картинка в картинці",
    ),
    "native_player_play": MessageLookupByLibrary.simpleMessage("Відтворити"),
    "native_player_quality": MessageLookupByLibrary.simpleMessage("Якість"),
    "native_player_quality_auto": MessageLookupByLibrary.simpleMessage("Авто"),
    "native_player_quality_fallback": m112,
    "native_player_retry": MessageLookupByLibrary.simpleMessage("Повторити"),
    "native_player_seek_backward": m113,
    "native_player_seek_forward": m114,
    "native_player_skip_opening": m115,
    "native_player_speed": MessageLookupByLibrary.simpleMessage(
      "Швидкість відтворення",
    ),
    "native_player_speed_normal": MessageLookupByLibrary.simpleMessage(
      "Звичайна",
    ),
    "native_player_speed_unsupported": MessageLookupByLibrary.simpleMessage(
      "Ця швидкість відтворення не підтримується",
    ),
    "native_player_subtitle_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося завантажити ці субтитри",
    ),
    "native_player_subtitle_fallback": m116,
    "native_player_subtitles": MessageLookupByLibrary.simpleMessage("Субтитри"),
    "native_player_subtitles_off": MessageLookupByLibrary.simpleMessage(
      "Вимкнено",
    ),
    "native_player_unlock": MessageLookupByLibrary.simpleMessage(
      "Розблокувати керування",
    ),
    "novel_progress_percent": m117,
    "novel_reader_background_sepia": MessageLookupByLibrary.simpleMessage(
      "Сепія",
    ),
    "novel_reader_empty_chapter": MessageLookupByLibrary.simpleMessage(
      "У цьому розділі немає тексту",
    ),
    "novel_reader_font_family": MessageLookupByLibrary.simpleMessage("Шрифт"),
    "novel_reader_font_serif": MessageLookupByLibrary.simpleMessage(
      "З засічками",
    ),
    "novel_reader_font_size": MessageLookupByLibrary.simpleMessage(
      "Розмір тексту",
    ),
    "novel_reader_font_ubuntu": MessageLookupByLibrary.simpleMessage("Ubuntu"),
    "novel_reader_justify": MessageLookupByLibrary.simpleMessage(
      "Вирівнювати за шириною",
    ),
    "novel_reader_keep_screen_on": MessageLookupByLibrary.simpleMessage(
      "Не вимикати екран",
    ),
    "novel_reader_line_height": MessageLookupByLibrary.simpleMessage(
      "Міжрядковий інтервал",
    ),
    "novel_reader_margins": MessageLookupByLibrary.simpleMessage("Бічні поля"),
    "novel_reader_next_chapter": MessageLookupByLibrary.simpleMessage(
      "Наступний розділ",
    ),
    "novel_reader_next_chapter_named": m118,
    "novel_reader_previous_chapter": MessageLookupByLibrary.simpleMessage(
      "Попередній розділ",
    ),
    "novel_reader_settings_title": MessageLookupByLibrary.simpleMessage(
      "Налаштування читання",
    ),
    "page_language_arabic": MessageLookupByLibrary.simpleMessage("Арабська"),
    "page_language_chinese": MessageLookupByLibrary.simpleMessage("Китайська"),
    "page_language_english": MessageLookupByLibrary.simpleMessage("Англійська"),
    "page_language_french": MessageLookupByLibrary.simpleMessage("Французька"),
    "page_language_german": MessageLookupByLibrary.simpleMessage("Німецька"),
    "page_language_indonesian": MessageLookupByLibrary.simpleMessage(
      "Індонезійська",
    ),
    "page_language_italian": MessageLookupByLibrary.simpleMessage("Італійська"),
    "page_language_japanese": MessageLookupByLibrary.simpleMessage("Японська"),
    "page_language_korean": MessageLookupByLibrary.simpleMessage("Корейська"),
    "page_language_polish": MessageLookupByLibrary.simpleMessage("Польська"),
    "page_language_portuguese": MessageLookupByLibrary.simpleMessage(
      "Португальська",
    ),
    "page_language_russian": MessageLookupByLibrary.simpleMessage("Російська"),
    "page_language_spanish": MessageLookupByLibrary.simpleMessage("Іспанська"),
    "page_language_thai": MessageLookupByLibrary.simpleMessage("Тайська"),
    "page_language_turkish": MessageLookupByLibrary.simpleMessage("Турецька"),
    "page_language_ukrainian": MessageLookupByLibrary.simpleMessage(
      "Українська",
    ),
    "page_language_vietnamese": MessageLookupByLibrary.simpleMessage(
      "В’єтнамська",
    ),
    "page_translation_ai_model_downloading": m119,
    "page_translation_ai_model_message": m120,
    "page_translation_ai_model_title": MessageLookupByLibrary.simpleMessage(
      "Завантажте ШІ-модель",
    ),
    "page_translation_appearance_section": MessageLookupByLibrary.simpleMessage(
      "Вигляд",
    ),
    "page_translation_copied": MessageLookupByLibrary.simpleMessage(
      "Скопійовано",
    ),
    "page_translation_copy": MessageLookupByLibrary.simpleMessage("Копіювати"),
    "page_translation_copy_original": MessageLookupByLibrary.simpleMessage(
      "Копіювати оригінал",
    ),
    "page_translation_copy_translation": MessageLookupByLibrary.simpleMessage(
      "Копіювати переклад",
    ),
    "page_translation_edit": MessageLookupByLibrary.simpleMessage("Редагувати"),
    "page_translation_font": MessageLookupByLibrary.simpleMessage("Шрифт"),
    "page_translation_font_comic": MessageLookupByLibrary.simpleMessage(
      "Комікс",
    ),
    "page_translation_font_system": MessageLookupByLibrary.simpleMessage(
      "Системний",
    ),
    "page_translation_glossary_add": MessageLookupByLibrary.simpleMessage(
      "Додати ім’я",
    ),
    "page_translation_glossary_count": m121,
    "page_translation_glossary_empty": MessageLookupByLibrary.simpleMessage(
      "Поки нічого",
    ),
    "page_translation_glossary_save": MessageLookupByLibrary.simpleMessage(
      "Зберегти",
    ),
    "page_translation_glossary_save_retranslate":
        MessageLookupByLibrary.simpleMessage("Зберегти й перекласти розділ"),
    "page_translation_glossary_subtitle": MessageLookupByLibrary.simpleMessage(
      "Допомагає однаково перекладати імена персонажів і терміни в цьому тайтлі. Використовується DeepL і Gemma.",
    ),
    "page_translation_glossary_title": MessageLookupByLibrary.simpleMessage(
      "Імена й терміни",
    ),
    "page_translation_glossary_unsupported": MessageLookupByLibrary.simpleMessage(
      "ML Kit не підтримує імена й терміни. Виберіть DeepL або Gemma в налаштуваннях перекладу сторінок.",
    ),
    "page_translation_label_background": MessageLookupByLibrary.simpleMessage(
      "Фон підписів",
    ),
    "page_translation_label_background_subtitle":
        MessageLookupByLibrary.simpleMessage(
          "Для тексту поза бульбашками реплік",
        ),
    "page_translation_languages_from": MessageLookupByLibrary.simpleMessage(
      "Текст на сторінках",
    ),
    "page_translation_languages_save": MessageLookupByLibrary.simpleMessage(
      "Зберегти",
    ),
    "page_translation_languages_start": MessageLookupByLibrary.simpleMessage(
      "Перекласти",
    ),
    "page_translation_languages_subtitle": MessageLookupByLibrary.simpleMessage(
      "Зберігається лише для цього тайтлу.",
    ),
    "page_translation_languages_title": MessageLookupByLibrary.simpleMessage(
      "Мови перекладу",
    ),
    "page_translation_languages_to": MessageLookupByLibrary.simpleMessage(
      "Перекласти на",
    ),
    "page_translation_models_cancel": MessageLookupByLibrary.simpleMessage(
      "Не зараз",
    ),
    "page_translation_models_download": MessageLookupByLibrary.simpleMessage(
      "Завантажити",
    ),
    "page_translation_models_downloading": MessageLookupByLibrary.simpleMessage(
      "Завантаження мовних пакетів…",
    ),
    "page_translation_models_downloading_progress": m122,
    "page_translation_models_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося завантажити мовні пакети",
    ),
    "page_translation_models_message": m123,
    "page_translation_models_title": MessageLookupByLibrary.simpleMessage(
      "Завантаження мовних пакетів",
    ),
    "page_translation_models_wifi_note": MessageLookupByLibrary.simpleMessage(
      "Завантаження чекатимуть на Wi-Fi. Це можна змінити в розділі Налаштування → Переклад сторінок.",
    ),
    "page_translation_original_edit_hint": MessageLookupByLibrary.simpleMessage(
      "Виправте помилки розпізнавання й перекладіть знову",
    ),
    "page_translation_original_label": MessageLookupByLibrary.simpleMessage(
      "Оригінал",
    ),
    "page_translation_peek_hint": MessageLookupByLibrary.simpleMessage(
      "Утримуйте, щоб побачити оригінал",
    ),
    "page_translation_preview_bubble": MessageLookupByLibrary.simpleMessage(
      "Що ти тут робиш?!",
    ),
    "page_translation_preview_label": MessageLookupByLibrary.simpleMessage(
      "Тим часом у Токіо…",
    ),
    "page_translation_region_empty": MessageLookupByLibrary.simpleMessage(
      "У вибраній області немає тексту",
    ),
    "page_translation_retranslate": MessageLookupByLibrary.simpleMessage(
      "Перекласти знову",
    ),
    "page_translation_retranslate_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося перекласти цю репліку знову",
    ),
    "page_translation_settings_clear_cache":
        MessageLookupByLibrary.simpleMessage("Очистити перекладені сторінки"),
    "page_translation_settings_clear_cache_confirm_message":
        MessageLookupByLibrary.simpleMessage(
          "Сторінки буде перекладено знову, коли ви наступного разу їх відкриєте.",
        ),
    "page_translation_settings_clear_cache_confirm_ok":
        MessageLookupByLibrary.simpleMessage("Очистити"),
    "page_translation_settings_clear_cache_confirm_title":
        MessageLookupByLibrary.simpleMessage("Очистити перекладені сторінки?"),
    "page_translation_settings_clear_cache_subtitle": m124,
    "page_translation_settings_delete_pack":
        MessageLookupByLibrary.simpleMessage("Видалити"),
    "page_translation_settings_download_pack":
        MessageLookupByLibrary.simpleMessage("Завантажити"),
    "page_translation_settings_enable": MessageLookupByLibrary.simpleMessage(
      "Увімкнути переклад сторінок",
    ),
    "page_translation_settings_enable_subtitle":
        MessageLookupByLibrary.simpleMessage(
          "Додає до читалки кнопку перекладу. Текст розпізнається й перекладається на вашому пристрої.",
        ),
    "page_translation_settings_experimental":
        MessageLookupByLibrary.simpleMessage("Експериментально"),
    "page_translation_settings_languages_section":
        MessageLookupByLibrary.simpleMessage("Мови"),
    "page_translation_settings_ocr_note": MessageLookupByLibrary.simpleMessage(
      "Розпізнавання японської, корейської та китайської забезпечують сервіси Google Play; воно завантажується автоматично під час першого використання.",
    ),
    "page_translation_settings_ocr_title": MessageLookupByLibrary.simpleMessage(
      "Розпізнавання тексту",
    ),
    "page_translation_settings_pack_downloaded":
        MessageLookupByLibrary.simpleMessage("Завантажено"),
    "page_translation_settings_pack_missing":
        MessageLookupByLibrary.simpleMessage("Не завантажено · близько 30 МБ"),
    "page_translation_settings_packs_section":
        MessageLookupByLibrary.simpleMessage("Мовні пакети"),
    "page_translation_settings_remove_outdated":
        MessageLookupByLibrary.simpleMessage("Видалити старі переклади"),
    "page_translation_settings_remove_outdated_subtitle": m125,
    "page_translation_settings_storage_section":
        MessageLookupByLibrary.simpleMessage("Сховище"),
    "page_translation_settings_target": MessageLookupByLibrary.simpleMessage(
      "Мова перекладу",
    ),
    "page_translation_settings_target_subtitle":
        MessageLookupByLibrary.simpleMessage(
          "Типово для тайтлів, які ви перекладаєте вперше. Кожен тайтл пам’ятає власні мови.",
        ),
    "page_translation_settings_title": MessageLookupByLibrary.simpleMessage(
      "Переклад сторінок",
    ),
    "page_translation_settings_wifi_only": MessageLookupByLibrary.simpleMessage(
      "Завантажувати лише через Wi-Fi",
    ),
    "page_translation_show_original": MessageLookupByLibrary.simpleMessage(
      "Показати оригінал",
    ),
    "page_translation_show_translation": MessageLookupByLibrary.simpleMessage(
      "Показати переклад",
    ),
    "page_translation_status_chapter": m126,
    "page_translation_status_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося перекласти · торкніться, щоб повторити",
    ),
    "page_translation_status_model_pending":
        MessageLookupByLibrary.simpleMessage(
          "Сервіси Google Play завантажують розпізнавання тексту…",
        ),
    "page_translation_status_outdated": MessageLookupByLibrary.simpleMessage(
      "Старий переклад · торкніться, щоб оновити",
    ),
    "page_translation_status_preparing": MessageLookupByLibrary.simpleMessage(
      "Готуємо переклад…",
    ),
    "page_translation_status_translating": MessageLookupByLibrary.simpleMessage(
      "Перекладаємо сторінку…",
    ),
    "page_translation_text_size": MessageLookupByLibrary.simpleMessage(
      "Розмір тексту",
    ),
    "page_translation_text_size_auto": MessageLookupByLibrary.simpleMessage(
      "Авто",
    ),
    "page_translation_text_size_pixels": m127,
    "page_translation_text_size_subtitle": MessageLookupByLibrary.simpleMessage(
      "Найбільший розмір перекладеного тексту на екрані",
    ),
    "page_translation_translate_chapter": MessageLookupByLibrary.simpleMessage(
      "Перекласти весь розділ",
    ),
    "page_translation_translate_chapter_hint":
        MessageLookupByLibrary.simpleMessage(
          "Перекласти всі сторінки у фоновому режимі",
        ),
    "page_translation_translation_label": MessageLookupByLibrary.simpleMessage(
      "Переклад",
    ),
    "player_dub_player": MessageLookupByLibrary.simpleMessage(
      "Озвучка / плеєр",
    ),
    "player_episodes": MessageLookupByLibrary.simpleMessage("Серії"),
    "player_playlist": MessageLookupByLibrary.simpleMessage("Плейлист"),
    "player_previous_episode": MessageLookupByLibrary.simpleMessage(
      "Попередня серія",
    ),
    "player_skip_auto_subtitle": MessageLookupByLibrary.simpleMessage(
      "Перемотувати їх, коли розширення позначає, де вони",
    ),
    "player_skip_auto_title": MessageLookupByLibrary.simpleMessage(
      "Автоматично пропускати опенінги й ендінги",
    ),
    "player_skip_intro": MessageLookupByLibrary.simpleMessage(
      "Пропустити опенінг",
    ),
    "player_skip_outro": MessageLookupByLibrary.simpleMessage(
      "Пропустити ендінг",
    ),
    "player_skip_recap": MessageLookupByLibrary.simpleMessage(
      "Пропустити рекап",
    ),
    "player_skip_skipped_intro": MessageLookupByLibrary.simpleMessage(
      "Опенінг пропущено",
    ),
    "player_skip_skipped_outro": MessageLookupByLibrary.simpleMessage(
      "Ендінг пропущено",
    ),
    "player_skip_skipped_recap": MessageLookupByLibrary.simpleMessage(
      "Рекап пропущено",
    ),
    "reader_background_black": MessageLookupByLibrary.simpleMessage("Чорний"),
    "reader_background_grey": MessageLookupByLibrary.simpleMessage("Сірий"),
    "reader_background_theme": MessageLookupByLibrary.simpleMessage(
      "Як у темі",
    ),
    "reader_background_title": MessageLookupByLibrary.simpleMessage("Фон"),
    "reader_background_white": MessageLookupByLibrary.simpleMessage("Білий"),
    "reader_crop_borders_subtitle": MessageLookupByLibrary.simpleMessage(
      "Прибирати порожні білі чи чорні поля в посторінкових режимах",
    ),
    "reader_crop_borders_title": MessageLookupByLibrary.simpleMessage(
      "Обрізати поля",
    ),
    "reader_double_page_subtitle": MessageLookupByLibrary.simpleMessage(
      "Показувати сторінки поруч, коли телефон повернуто горизонтально",
    ),
    "reader_double_page_title": MessageLookupByLibrary.simpleMessage(
      "Дві сторінки в альбомній орієнтації",
    ),
    "reader_page_fit_height": MessageLookupByLibrary.simpleMessage(
      "За висотою",
    ),
    "reader_page_fit_screen": MessageLookupByLibrary.simpleMessage(
      "За екраном",
    ),
    "reader_page_fit_title": MessageLookupByLibrary.simpleMessage(
      "Масштаб сторінки",
    ),
    "reader_page_fit_width": MessageLookupByLibrary.simpleMessage("За шириною"),
    "reader_volume_keys_invert_title": MessageLookupByLibrary.simpleMessage(
      "Інвертувати кнопки гучності",
    ),
    "reader_volume_keys_title": MessageLookupByLibrary.simpleMessage(
      "Гортати кнопками гучності",
    ),
    "save_image_error": MessageLookupByLibrary.simpleMessage(
      "Не вдалося зберегти зображення",
    ),
    "save_image_save_button": MessageLookupByLibrary.simpleMessage(
      "Зберегти як…",
    ),
    "save_image_sheet_title": MessageLookupByLibrary.simpleMessage(
      "Зображення",
    ),
    "save_image_success": MessageLookupByLibrary.simpleMessage(
      "Зображення збережено",
    ),
    "service_view_clear_search": MessageLookupByLibrary.simpleMessage(
      "Очистити",
    ),
    "service_view_empty_message": MessageLookupByLibrary.simpleMessage(
      "Потягніть униз, щоб оновити",
    ),
    "service_view_empty_title": MessageLookupByLibrary.simpleMessage(
      "Тут поки порожньо",
    ),
    "service_view_error": MessageLookupByLibrary.simpleMessage("Помилка :c"),
    "service_view_error_title": MessageLookupByLibrary.simpleMessage(
      "Щось пішло не так",
    ),
    "service_view_no_results_message": m128,
    "service_view_no_results_title": MessageLookupByLibrary.simpleMessage(
      "Нічого не знайдено",
    ),
    "service_view_open_web_view_button_title":
        MessageLookupByLibrary.simpleMessage("Відкрити у WebView"),
    "service_view_retry_button_title": MessageLookupByLibrary.simpleMessage(
      "Повторити",
    ),
    "service_view_search_results_for": m129,
    "service_viewer_search_field_hint_text":
        MessageLookupByLibrary.simpleMessage("Пошук"),
    "settings_about_section_title": MessageLookupByLibrary.simpleMessage(
      "Про застосунок",
    ),
    "settings_appearance_section_title": MessageLookupByLibrary.simpleMessage(
      "Вигляд",
    ),
    "settings_auto_backup_failed": MessageLookupByLibrary.simpleMessage(
      "Остання копія не вдалася · торкніться «Створити копію», щоб повторити",
    ),
    "settings_auto_backup_last": m130,
    "settings_auto_backup_never": MessageLookupByLibrary.simpleMessage(
      "Щодня в Download/Wakaranai · копій ще немає",
    ),
    "settings_auto_backup_now": MessageLookupByLibrary.simpleMessage(
      "Створити копію",
    ),
    "settings_auto_backup_off": MessageLookupByLibrary.simpleMessage(
      "Вимкнено · зберігайте копію самостійно через Експорт",
    ),
    "settings_auto_backup_saved": MessageLookupByLibrary.simpleMessage(
      "Копію збережено в Download/Wakaranai",
    ),
    "settings_auto_backup_title": MessageLookupByLibrary.simpleMessage(
      "Автоматичні резервні копії",
    ),
    "settings_check_updates": MessageLookupByLibrary.simpleMessage(
      "Перевіряти оновлення бібліотеки",
    ),
    "settings_check_updates_subtitle": MessageLookupByLibrary.simpleMessage(
      "Періодично шукати нові розділи й серії у фоновому режимі",
    ),
    "settings_clear_activity_history": MessageLookupByLibrary.simpleMessage(
      "Очистити історію активності",
    ),
    "settings_clear_activity_history_dialog_confirmation_cancel_label":
        MessageLookupByLibrary.simpleMessage("Скасувати"),
    "settings_clear_activity_history_dialog_confirmation_message":
        MessageLookupByLibrary.simpleMessage("Цю дію не можна скасувати"),
    "settings_clear_activity_history_dialog_confirmation_ok_label":
        MessageLookupByLibrary.simpleMessage("Видалити"),
    "settings_clear_activity_history_dialog_confirmation_title":
        MessageLookupByLibrary.simpleMessage("Очистити всю історію?"),
    "settings_clear_activity_history_dialog_error":
        MessageLookupByLibrary.simpleMessage(
          "Помилка під час очищення історії",
        ),
    "settings_clear_activity_history_dialog_success":
        MessageLookupByLibrary.simpleMessage("Історію очищено"),
    "settings_clear_cookies_cache": MessageLookupByLibrary.simpleMessage(
      "Очистити файли cookie",
    ),
    "settings_clear_cookies_cache_dialog_confirmation_cancel_label":
        MessageLookupByLibrary.simpleMessage("Скасувати"),
    "settings_clear_cookies_cache_dialog_confirmation_message":
        MessageLookupByLibrary.simpleMessage("Цю дію не можна скасувати"),
    "settings_clear_cookies_cache_dialog_confirmation_ok_label":
        MessageLookupByLibrary.simpleMessage("Видалити"),
    "settings_clear_cookies_cache_dialog_confirmation_title":
        MessageLookupByLibrary.simpleMessage("Очистити всі файли cookie?"),
    "settings_clear_cookies_dialog_success":
        MessageLookupByLibrary.simpleMessage("Файли cookie очищено"),
    "settings_clear_history_title": MessageLookupByLibrary.simpleMessage(
      "Очистити історію",
    ),
    "settings_collect_statistics_subtitle":
        MessageLookupByLibrary.simpleMessage(
          "Відстежувати активність для статистики",
        ),
    "settings_collect_statistics_title": MessageLookupByLibrary.simpleMessage(
      "Збирати статистику",
    ),
    "settings_content_section_title": MessageLookupByLibrary.simpleMessage(
      "Вміст",
    ),
    "settings_default_reader_mode_title": MessageLookupByLibrary.simpleMessage(
      "Типовий режим читання",
    ),
    "settings_developer_section": MessageLookupByLibrary.simpleMessage(
      "Для розробників",
    ),
    "settings_download_latest_release": m131,
    "settings_export_data_button": MessageLookupByLibrary.simpleMessage(
      "Експортувати дані",
    ),
    "settings_export_error": MessageLookupByLibrary.simpleMessage(
      "Не вдалося експортувати",
    ),
    "settings_export_notification_complete":
        MessageLookupByLibrary.simpleMessage("Експорт завершено"),
    "settings_export_progress_title": MessageLookupByLibrary.simpleMessage(
      "Експорт",
    ),
    "settings_export_select_all": MessageLookupByLibrary.simpleMessage(
      "Вибрати все",
    ),
    "settings_export_sheet_confirm": MessageLookupByLibrary.simpleMessage(
      "Експортувати",
    ),
    "settings_export_sheet_title": MessageLookupByLibrary.simpleMessage(
      "Експорт даних",
    ),
    "settings_export_success": MessageLookupByLibrary.simpleMessage(
      "Експорт завершено",
    ),
    "settings_hide_nsfw_titles_subtitle": MessageLookupByLibrary.simpleMessage(
      "Не показувати їх у бібліотеці, історії, оновленнях і завантаженнях",
    ),
    "settings_hide_nsfw_titles_title": MessageLookupByLibrary.simpleMessage(
      "Приховувати тайтли з NSFW-джерел",
    ),
    "settings_import_data_button": MessageLookupByLibrary.simpleMessage(
      "Імпортувати дані",
    ),
    "settings_import_error": MessageLookupByLibrary.simpleMessage(
      "Не вдалося імпортувати",
    ),
    "settings_import_export_info_export_body": MessageLookupByLibrary.simpleMessage(
      "Зберігає вибрані розділи — історію читання, бібліотеку, категорії, джерела розширень і налаштування — в один файл JSON, який можна зберегти як резервну копію або перенести на інший пристрій.",
    ),
    "settings_import_export_info_export_title":
        MessageLookupByLibrary.simpleMessage("Експорт"),
    "settings_import_export_info_import_body": MessageLookupByLibrary.simpleMessage(
      "Завантажує раніше експортований файл JSON і об’єднує вибрані розділи з наявними даними: наявні записи оновлюються, нові додаються, нічого не видаляється.",
    ),
    "settings_import_export_info_import_title":
        MessageLookupByLibrary.simpleMessage("Імпорт"),
    "settings_import_export_info_title": MessageLookupByLibrary.simpleMessage(
      "Імпорт і експорт",
    ),
    "settings_import_nothing_to_import": MessageLookupByLibrary.simpleMessage(
      "У цьому файлі немає даних для імпорту",
    ),
    "settings_import_notification_complete":
        MessageLookupByLibrary.simpleMessage("Імпорт завершено"),
    "settings_import_progress_title": MessageLookupByLibrary.simpleMessage(
      "Імпорт",
    ),
    "settings_import_sheet_confirm": MessageLookupByLibrary.simpleMessage(
      "Імпортувати",
    ),
    "settings_import_sheet_title": MessageLookupByLibrary.simpleMessage(
      "Імпорт даних",
    ),
    "settings_import_skipped": m132,
    "settings_import_success": m133,
    "settings_incognito_subtitle": MessageLookupByLibrary.simpleMessage(
      "Не зберігати прогрес читання чи перегляду, історію та статистику",
    ),
    "settings_incognito_title": MessageLookupByLibrary.simpleMessage(
      "Режим інкогніто",
    ),
    "settings_language_english": MessageLookupByLibrary.simpleMessage(
      "English",
    ),
    "settings_language_system": MessageLookupByLibrary.simpleMessage(
      "Як у системі",
    ),
    "settings_language_title": MessageLookupByLibrary.simpleMessage(
      "Мова застосунку",
    ),
    "settings_language_ukrainian": MessageLookupByLibrary.simpleMessage(
      "Українська",
    ),
    "settings_local_extension_server_missing":
        MessageLookupByLibrary.simpleMessage(
          "Щоб увімкнути, задайте LOCAL_REPOSITORY_URL у .env",
        ),
    "settings_local_extension_server_subtitle": m134,
    "settings_local_extension_server_title":
        MessageLookupByLibrary.simpleMessage("Локальний сервер розширень"),
    "settings_page_translation_subtitle": MessageLookupByLibrary.simpleMessage(
      "Експериментально · розпізнавання й переклад тексту на сторінках",
    ),
    "settings_page_translation_title": MessageLookupByLibrary.simpleMessage(
      "Переклад сторінок",
    ),
    "settings_player_auto_next_subtitle": MessageLookupByLibrary.simpleMessage(
      "Після завершення серії відлічувати час і запускати наступну",
    ),
    "settings_player_auto_next_title": MessageLookupByLibrary.simpleMessage(
      "Автовідтворення наступної серії",
    ),
    "settings_player_hold_speed_subtitle": MessageLookupByLibrary.simpleMessage(
      "Утримуйте палець на відео, щоб прискорити відтворення",
    ),
    "settings_player_hold_speed_title": MessageLookupByLibrary.simpleMessage(
      "Прискорення утриманням",
    ),
    "settings_player_section_title": MessageLookupByLibrary.simpleMessage(
      "Плеєр",
    ),
    "settings_player_skip_opening_subtitle":
        MessageLookupByLibrary.simpleMessage(
          "На скільки перемотує кнопка пропуску",
        ),
    "settings_player_skip_opening_title": MessageLookupByLibrary.simpleMessage(
      "Пропуск опенінгу",
    ),
    "settings_player_skip_opening_value": m135,
    "settings_progress_preparing": MessageLookupByLibrary.simpleMessage(
      "Підготовка…",
    ),
    "settings_reader_section_title": MessageLookupByLibrary.simpleMessage(
      "Читалка",
    ),
    "settings_reading_statistics_subtitle":
        MessageLookupByLibrary.simpleMessage(
          "Ваша активність у читанні та перегляді",
        ),
    "settings_reading_statistics_title": MessageLookupByLibrary.simpleMessage(
      "Статистика читання",
    ),
    "settings_service_viewer_filters_title":
        MessageLookupByLibrary.simpleMessage("Фільтри"),
    "settings_show_nsfw_subtitle": MessageLookupByLibrary.simpleMessage(
      "Показувати розширення з вмістом для дорослих",
    ),
    "settings_show_nsfw_title": MessageLookupByLibrary.simpleMessage(
      "Показувати NSFW-джерела",
    ),
    "settings_statistics_section_title": MessageLookupByLibrary.simpleMessage(
      "Статистика",
    ),
    "settings_submit_issue": MessageLookupByLibrary.simpleMessage(
      "Повідомити про помилку, запропонувати функцію чи розширення",
    ),
    "settings_theme_amoled": MessageLookupByLibrary.simpleMessage("AMOLED"),
    "settings_theme_dracula": MessageLookupByLibrary.simpleMessage("Дракула"),
    "settings_theme_ember": MessageLookupByLibrary.simpleMessage("Жар"),
    "settings_theme_light": MessageLookupByLibrary.simpleMessage("Світла"),
    "settings_theme_midnight": MessageLookupByLibrary.simpleMessage("Північ"),
    "settings_theme_ocean": MessageLookupByLibrary.simpleMessage("Океан"),
    "settings_theme_sakura": MessageLookupByLibrary.simpleMessage("Сакура"),
    "settings_theme_sepia": MessageLookupByLibrary.simpleMessage("Сепія"),
    "settings_theme_sky": MessageLookupByLibrary.simpleMessage("Небо"),
    "settings_theme_title": MessageLookupByLibrary.simpleMessage("Тема"),
    "settings_tracker_login_failed": m136,
    "settings_tracker_logout": MessageLookupByLibrary.simpleMessage("Вийти"),
    "settings_tracker_logout_message": MessageLookupByLibrary.simpleMessage(
      "Тайтли, пов’язані з цим трекером, перестануть синхронізуватися, а зв’язки буде видалено.",
    ),
    "settings_tracker_logout_title": m137,
    "settings_tracker_signed_in": m138,
    "settings_tracker_signed_out": MessageLookupByLibrary.simpleMessage(
      "Вхід не виконано. Торкніться, щоб увійти",
    ),
    "settings_trackers_title": MessageLookupByLibrary.simpleMessage("Трекери"),
    "settings_transfer_notification_channel_name":
        MessageLookupByLibrary.simpleMessage("Імпорт і експорт"),
    "settings_update_frequency": MessageLookupByLibrary.simpleMessage(
      "Частота перевірки",
    ),
    "settings_update_frequency_value": m139,
    "settings_update_notifications": MessageLookupByLibrary.simpleMessage(
      "Сповіщення про оновлення",
    ),
    "settings_update_notifications_subtitle":
        MessageLookupByLibrary.simpleMessage(
          "Показувати сповіщення, коли знайдено новинки",
        ),
    "settings_updates_section": MessageLookupByLibrary.simpleMessage(
      "Оновлення",
    ),
    "settings_video_player_auto": MessageLookupByLibrary.simpleMessage("Авто"),
    "settings_video_player_external": MessageLookupByLibrary.simpleMessage(
      "Зовнішній плеєр",
    ),
    "settings_video_player_subtitle": MessageLookupByLibrary.simpleMessage(
      "Відтворювати відео у вбудованому плеєрі, коли джерело надає прямий потік",
    ),
    "settings_video_player_title": MessageLookupByLibrary.simpleMessage(
      "Відеоплеєр",
    ),
    "settings_video_player_web_only": MessageLookupByLibrary.simpleMessage(
      "Лише вебплеєр",
    ),
    "source_error_login_required_title": m140,
    "source_error_not_found_title": MessageLookupByLibrary.simpleMessage(
      "Видалено з джерела",
    ),
    "source_error_open_saved_button": MessageLookupByLibrary.simpleMessage(
      "Відкрити збережені дані",
    ),
    "source_error_rate_limited_title": MessageLookupByLibrary.simpleMessage(
      "Забагато запитів, спробуйте пізніше",
    ),
    "source_error_region_blocked_title": MessageLookupByLibrary.simpleMessage(
      "Недоступно у вашому регіоні",
    ),
    "source_error_remove_from_library_button":
        MessageLookupByLibrary.simpleMessage("Прибрати з бібліотеки"),
    "source_error_removed_titles_found": m141,
    "source_error_retry_button": MessageLookupByLibrary.simpleMessage(
      "Повторити",
    ),
    "source_error_sign_in_button": MessageLookupByLibrary.simpleMessage(
      "Увійти",
    ),
    "source_error_source_down_title": MessageLookupByLibrary.simpleMessage(
      "Джерело не працює, спробуйте пізніше",
    ),
    "source_error_unsupported_title": MessageLookupByLibrary.simpleMessage(
      "Це джерело не підтримує цю дію",
    ),
    "source_pricing_free": MessageLookupByLibrary.simpleMessage("Безкоштовно"),
    "source_pricing_paid": MessageLookupByLibrary.simpleMessage("Платно"),
    "source_pricing_partial": MessageLookupByLibrary.simpleMessage(
      "Частково безкоштовно",
    ),
    "stats_activity_section_title": MessageLookupByLibrary.simpleMessage(
      "Активність",
    ),
    "stats_disabled_message": MessageLookupByLibrary.simpleMessage(
      "Увімкніть збирання статистики, щоб бачити тут свою активність у читанні та перегляді.",
    ),
    "stats_disabled_title": MessageLookupByLibrary.simpleMessage(
      "Статистику вимкнено",
    ),
    "stats_empty_message": MessageLookupByLibrary.simpleMessage(
      "Почніть читати або дивитися, щоб накопичити статистику.",
    ),
    "stats_empty_title": MessageLookupByLibrary.simpleMessage(
      "Активності ще немає",
    ),
    "stats_enable_button": MessageLookupByLibrary.simpleMessage("Увімкнути"),
    "stats_error_title": MessageLookupByLibrary.simpleMessage(
      "Не вдалося завантажити статистику",
    ),
    "stats_heatmap_hint": MessageLookupByLibrary.simpleMessage(
      "Торкніться тижня, щоб побачити деталі",
    ),
    "stats_heatmap_less": MessageLookupByLibrary.simpleMessage("Менше"),
    "stats_heatmap_more": MessageLookupByLibrary.simpleMessage("Більше"),
    "stats_heatmap_week_count": m142,
    "stats_kpi_active_days": MessageLookupByLibrary.simpleMessage(
      "Активних днів",
    ),
    "stats_kpi_chapters_read": MessageLookupByLibrary.simpleMessage(
      "Прочитано розділів",
    ),
    "stats_kpi_day_streak": MessageLookupByLibrary.simpleMessage(
      "Днів поспіль",
    ),
    "stats_kpi_episodes_watched": MessageLookupByLibrary.simpleMessage(
      "Переглянуто серій",
    ),
    "stats_kpi_pages_read": MessageLookupByLibrary.simpleMessage(
      "Прочитано сторінок",
    ),
    "stats_kpi_time_watched": MessageLookupByLibrary.simpleMessage(
      "Час перегляду",
    ),
    "stats_overview_section_title": MessageLookupByLibrary.simpleMessage(
      "Огляд",
    ),
    "stats_sources_section_title": MessageLookupByLibrary.simpleMessage(
      "Популярні джерела",
    ),
    "stats_streak_summary": m143,
    "stats_title": MessageLookupByLibrary.simpleMessage("Статистика"),
    "title_download": MessageLookupByLibrary.simpleMessage("Завантажити"),
    "title_download_all": MessageLookupByLibrary.simpleMessage("Усі розділи"),
    "title_download_chapter_count": m144,
    "title_download_episode_all": MessageLookupByLibrary.simpleMessage(
      "Усі серії",
    ),
    "title_download_episode_count": m145,
    "title_download_episode_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося завантажити список серій",
    ),
    "title_download_episode_first_group_hint":
        MessageLookupByLibrary.simpleMessage(
          "Для кожного тайтлу завантажується перша група серій",
        ),
    "title_download_episode_groups": MessageLookupByLibrary.simpleMessage(
      "Групи серій",
    ),
    "title_download_episode_how_many": MessageLookupByLibrary.simpleMessage(
      "Скільки серій завантажити",
    ),
    "title_download_episode_loading": MessageLookupByLibrary.simpleMessage(
      "Шукаємо серії…",
    ),
    "title_download_episode_many_loading": m146,
    "title_download_episode_mixed_all": MessageLookupByLibrary.simpleMessage(
      "Усі розділи й серії",
    ),
    "title_download_episode_mixed_hint": MessageLookupByLibrary.simpleMessage(
      "Для кожного тайтлу завантажується перша група",
    ),
    "title_download_episode_mixed_loading": m147,
    "title_download_episode_mixed_next": MessageLookupByLibrary.simpleMessage(
      "Наступний розділ або серія",
    ),
    "title_download_episode_mixed_next_count": m148,
    "title_download_episode_mixed_nothing":
        MessageLookupByLibrary.simpleMessage("Нічого нового для завантаження"),
    "title_download_episode_mixed_queued": m149,
    "title_download_episode_mixed_title": MessageLookupByLibrary.simpleMessage(
      "Завантаження розділів і серій",
    ),
    "title_download_episode_mixed_unread": MessageLookupByLibrary.simpleMessage(
      "Непрочитані розділи й непереглянуті серії",
    ),
    "title_download_episode_next": MessageLookupByLibrary.simpleMessage(
      "Наступна серія",
    ),
    "title_download_episode_next_count": m150,
    "title_download_episode_none": MessageLookupByLibrary.simpleMessage(
      "У цього тайтлу ще немає серій",
    ),
    "title_download_episode_nothing": MessageLookupByLibrary.simpleMessage(
      "Немає нових серій для завантаження",
    ),
    "title_download_episode_queued": m151,
    "title_download_episode_title": MessageLookupByLibrary.simpleMessage(
      "Завантаження серій",
    ),
    "title_download_episode_unwatched": MessageLookupByLibrary.simpleMessage(
      "Непереглянуті серії",
    ),
    "title_download_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося завантажити список розділів",
    ),
    "title_download_groups": MessageLookupByLibrary.simpleMessage(
      "Групи розділів",
    ),
    "title_download_how_many": MessageLookupByLibrary.simpleMessage(
      "Скільки розділів завантажити",
    ),
    "title_download_loading": MessageLookupByLibrary.simpleMessage(
      "Шукаємо розділи…",
    ),
    "title_download_next": MessageLookupByLibrary.simpleMessage(
      "Наступний розділ",
    ),
    "title_download_next_count": m152,
    "title_download_no_chapters": MessageLookupByLibrary.simpleMessage(
      "У цього тайтлу ще немає розділів",
    ),
    "title_download_nothing": MessageLookupByLibrary.simpleMessage(
      "Немає нових розділів для завантаження",
    ),
    "title_download_queued": m153,
    "title_download_title": MessageLookupByLibrary.simpleMessage(
      "Завантаження розділів",
    ),
    "title_download_unread": MessageLookupByLibrary.simpleMessage(
      "Непрочитані розділи",
    ),
    "title_download_untitled_group": m154,
    "title_status_announce": MessageLookupByLibrary.simpleMessage("Анонсовано"),
    "title_status_canceled": MessageLookupByLibrary.simpleMessage("Скасовано"),
    "title_status_ongoing": MessageLookupByLibrary.simpleMessage("Виходить"),
    "title_status_paused": MessageLookupByLibrary.simpleMessage("Призупинено"),
    "title_status_released": MessageLookupByLibrary.simpleMessage("Завершено"),
    "tracker_chip_untracked": MessageLookupByLibrary.simpleMessage(
      "Відстежувати тайтл",
    ),
    "tracker_link_action": MessageLookupByLibrary.simpleMessage("Пов’язати"),
    "tracker_link_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося пов’язати тайтл. Спробуйте ще раз.",
    ),
    "tracker_search_empty": MessageLookupByLibrary.simpleMessage(
      "Нічого не знайдено. Спробуйте іншу назву.",
    ),
    "tracker_search_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося виконати пошук. Перевірте підключення й спробуйте ще раз.",
    ),
    "tracker_search_hint": MessageLookupByLibrary.simpleMessage(
      "Пошук за назвою",
    ),
    "tracker_search_title": m155,
    "tracker_sheet_title": MessageLookupByLibrary.simpleMessage("Відстеження"),
    "tracker_status_completed": MessageLookupByLibrary.simpleMessage(
      "Завершено",
    ),
    "tracker_status_dropped": MessageLookupByLibrary.simpleMessage("Покинуто"),
    "tracker_status_paused": MessageLookupByLibrary.simpleMessage("Відкладено"),
    "tracker_status_planning": MessageLookupByLibrary.simpleMessage("У планах"),
    "tracker_status_reading": MessageLookupByLibrary.simpleMessage("Читаю"),
    "tracker_status_rereading": MessageLookupByLibrary.simpleMessage(
      "Перечитую",
    ),
    "tracker_status_rewatching": MessageLookupByLibrary.simpleMessage(
      "Переглядаю знову",
    ),
    "tracker_status_watching": MessageLookupByLibrary.simpleMessage("Дивлюся"),
    "tracker_unlink_action": MessageLookupByLibrary.simpleMessage("Від’єднати"),
    "translation_ai_model_delete_message": m156,
    "translation_ai_model_delete_title": MessageLookupByLibrary.simpleMessage(
      "Видалити ШІ-модель?",
    ),
    "translation_ai_model_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося завантажити · спробуйте ще раз через Wi-Fi",
    ),
    "translation_ai_model_installed": m157,
    "translation_ai_model_missing": m158,
    "translation_ai_model_title": MessageLookupByLibrary.simpleMessage(
      "ШІ-модель",
    ),
    "translation_engine_change": MessageLookupByLibrary.simpleMessage(
      "Змінити",
    ),
    "translation_engine_deepl": MessageLookupByLibrary.simpleMessage(
      "DeepL · онлайн",
    ),
    "translation_engine_deepl_subtitle": MessageLookupByLibrary.simpleMessage(
      "Найкраща якість · надсилає розпізнаний текст у DeepL · потрібен безкоштовний ключ API",
    ),
    "translation_engine_gemma": MessageLookupByLibrary.simpleMessage(
      "Gemma 4 E2B · ШІ на пристрої",
    ),
    "translation_engine_gemma_e4b": MessageLookupByLibrary.simpleMessage(
      "Gemma 4 E4B · ШІ на пристрої",
    ),
    "translation_engine_gemma_e4b_subtitle": MessageLookupByLibrary.simpleMessage(
      "Кращий переклад, але приблизно вдвічі повільніше · 3,7 ГБ · 12 ГБ ОЗП",
    ),
    "translation_engine_gemma_subtitle": MessageLookupByLibrary.simpleMessage(
      "Природний переклад, що виправляє помилки розпізнавання · 2,6 ГБ · 8 ГБ ОЗП",
    ),
    "translation_engine_gemma_unavailable_64bit":
        MessageLookupByLibrary.simpleMessage("Потрібен 64-бітний телефон"),
    "translation_engine_gemma_unavailable_android":
        MessageLookupByLibrary.simpleMessage("Потрібен Android 11 або новіший"),
    "translation_engine_gemma_unavailable_platform":
        MessageLookupByLibrary.simpleMessage("Недоступно на цьому пристрої"),
    "translation_engine_gemma_unavailable_ram": m159,
    "translation_engine_info_examples": MessageLookupByLibrary.simpleMessage(
      "Швидкість залежно від телефона (оцінка)",
    ),
    "translation_engine_info_footer": MessageLookupByLibrary.simpleMessage(
      "Швидкість орієнтовна; швидкий рівень виміряно на Galaxy S24 Ultra. Переклад наперед під час читання та завчасний переклад завантажених розділів приховують більшу частину очікування.",
    ),
    "translation_engine_info_intro": MessageLookupByLibrary.simpleMessage(
      "Gemma 4 працює повністю на вашому телефоні. Вона читає всю сторінку відразу, виправляє помилки розпізнавання тексту й перекладає природно. E4B перекладає помітно краще за E2B, але приблизно вдвічі повільніше. Ніщо не залишає ваш пристрій.",
    ),
    "translation_engine_info_requirements":
        MessageLookupByLibrary.simpleMessage("Вимоги"),
    "translation_engine_info_this_phone": m160,
    "translation_engine_mlkit": MessageLookupByLibrary.simpleMessage("ML Kit"),
    "translation_engine_mlkit_subtitle": MessageLookupByLibrary.simpleMessage(
      "Швидкий і легкий · працює на будь-якому телефоні · дослівний переклад",
    ),
    "translation_engine_req_64bit": MessageLookupByLibrary.simpleMessage(
      "64-бітний процесор (arm64)",
    ),
    "translation_engine_req_android": MessageLookupByLibrary.simpleMessage(
      "Android 11 або новіший",
    ),
    "translation_engine_req_ram_model": m161,
    "translation_engine_req_storage_model": m162,
    "translation_engine_section": MessageLookupByLibrary.simpleMessage(
      "Рушій перекладу",
    ),
    "translation_engine_tier_e4b": MessageLookupByLibrary.simpleMessage(
      "Приблизно 20–45 с на сторінку",
    ),
    "translation_engine_tier_e4b_no_phones":
        MessageLookupByLibrary.simpleMessage("Телефони з менш ніж 12 ГБ ОЗП"),
    "translation_engine_tier_fast": MessageLookupByLibrary.simpleMessage(
      "Швидко · приблизно 4–10 с на сторінку",
    ),
    "translation_engine_tier_fast_phones": MessageLookupByLibrary.simpleMessage(
      "Galaxy S24 / S25, Pixel 9 / 10, OnePlus 12 / 13, Xiaomi 14 / 15 та інші флагмани 2024+ з 12 ГБ ОЗП",
    ),
    "translation_engine_tier_no": MessageLookupByLibrary.simpleMessage(
      "Не підтримується",
    ),
    "translation_engine_tier_no_phones": MessageLookupByLibrary.simpleMessage(
      "Телефони з менш ніж 8 ГБ ОЗП, 32-бітні телефони та Android 10 або старіший",
    ),
    "translation_engine_tier_ok": MessageLookupByLibrary.simpleMessage(
      "Прийнятно · помітно повільніше",
    ),
    "translation_engine_tier_ok_phones": MessageLookupByLibrary.simpleMessage(
      "Galaxy S22 / S23, Pixel 8, Galaxy A55 та інші телефони з 8 ГБ ОЗП",
    ),
    "translation_models_ai_section": MessageLookupByLibrary.simpleMessage(
      "ШІ на пристрої",
    ),
    "translation_models_downloaded": m163,
    "translation_models_packs_count": m164,
    "translation_models_packs_section": MessageLookupByLibrary.simpleMessage(
      "ML Kit",
    ),
    "translation_models_pick_first": m165,
    "translation_models_summary": m166,
    "translation_models_title": MessageLookupByLibrary.simpleMessage(
      "Завантажені моделі",
    ),
    "translation_models_unsupported": MessageLookupByLibrary.simpleMessage(
      "Не підтримується на цьому телефоні",
    ),
    "updates_attention_action_open": MessageLookupByLibrary.simpleMessage(
      "Відкрити",
    ),
    "updates_attention_action_review": MessageLookupByLibrary.simpleMessage(
      "Переглянути",
    ),
    "updates_attention_browser_check": m167,
    "updates_attention_many": m168,
    "updates_attention_notification_body": MessageLookupByLibrary.simpleMessage(
      "Перевірку оновлень для цих джерел призупинено. Оновіть бібліотеку жестом униз, щоб це виправити.",
    ),
    "updates_attention_notification_browser_title": m169,
    "updates_attention_notification_sign_in_title": m170,
    "updates_attention_session_saved": m171,
    "updates_attention_sheet_title": MessageLookupByLibrary.simpleMessage(
      "Джерела потребують уваги",
    ),
    "updates_attention_sign_in": m172,
    "updates_attention_sign_in_again": m173,
    "updates_attention_unavailable": m174,
    "updates_check_failed": m175,
    "updates_check_found": m176,
    "updates_check_none": MessageLookupByLibrary.simpleMessage(
      "Нових оновлень не знайдено",
    ),
    "updates_checking": MessageLookupByLibrary.simpleMessage(
      "Перевіряємо оновлення…",
    ),
    "updates_clear": MessageLookupByLibrary.simpleMessage("Очистити оновлення"),
    "updates_empty_message": MessageLookupByLibrary.simpleMessage(
      "Тут з’являтимуться нові розділи й серії тайтлів із вашої бібліотеки",
    ),
    "updates_empty_title": MessageLookupByLibrary.simpleMessage(
      "Нових оновлень немає",
    ),
    "updates_mark_all_seen": MessageLookupByLibrary.simpleMessage(
      "Позначити все переглянутим",
    ),
    "updates_notification_channel_name": MessageLookupByLibrary.simpleMessage(
      "Оновлення бібліотеки",
    ),
    "updates_notification_line": m177,
    "updates_notification_more": m178,
    "updates_notification_summary": m179,
    "updates_notification_title": m180,
    "updates_time_days": m181,
    "updates_time_hours": m182,
    "updates_time_minutes": m183,
    "updates_time_now": MessageLookupByLibrary.simpleMessage("Щойно"),
    "updates_title": MessageLookupByLibrary.simpleMessage("Оновлення"),
    "web_browser_back": MessageLookupByLibrary.simpleMessage("Назад"),
    "web_browser_clear_cookies": MessageLookupByLibrary.simpleMessage(
      "Очистити cookie цього сайту",
    ),
    "web_browser_cookies_cleared": m184,
    "web_browser_copy_link": MessageLookupByLibrary.simpleMessage(
      "Копіювати посилання",
    ),
    "web_browser_error_title": MessageLookupByLibrary.simpleMessage(
      "Не вдалося завантажити сторінку",
    ),
    "web_browser_forward": MessageLookupByLibrary.simpleMessage("Уперед"),
    "web_browser_link_copied": MessageLookupByLibrary.simpleMessage(
      "Посилання скопійовано",
    ),
    "web_browser_looks_good": MessageLookupByLibrary.simpleMessage(
      "Усе гаразд — продовжити",
    ),
    "web_browser_more": MessageLookupByLibrary.simpleMessage("Ще"),
    "web_browser_no_login_button": MessageLookupByLibrary.simpleMessage(
      "Готово",
    ),
    "web_browser_open_external": MessageLookupByLibrary.simpleMessage(
      "Відкрити в зовнішньому браузері",
    ),
    "web_browser_open_external_failed": MessageLookupByLibrary.simpleMessage(
      "Не вдалося відкрити зовнішній браузер",
    ),
    "web_browser_popup_close": MessageLookupByLibrary.simpleMessage(
      "Закрити вікно",
    ),
    "web_browser_reload": MessageLookupByLibrary.simpleMessage(
      "Перезавантажити",
    ),
    "web_browser_retry": MessageLookupByLibrary.simpleMessage("Повторити"),
    "web_browser_stop": MessageLookupByLibrary.simpleMessage(
      "Зупинити завантаження",
    ),
  };
}
