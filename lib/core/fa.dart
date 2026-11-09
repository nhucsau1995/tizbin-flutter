/// Persian number and date formatting (no extra package: the app stays small).
library;

const _digits = ['۰', '۱', '۲', '۳', '۴', '۵', '۶', '۷', '۸', '۹'];

/// Persian digits, with the Persian thousands separator by default: 1590 -> ۱٬۵۹۰.
String fa(num n, {bool group = true}) {
  final neg = n < 0;
  var s = n.abs().toInt().toString();
  if (group && s.length > 3) {
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) b.write('٬');
      b.write(s[i]);
    }
    s = b.toString();
  }
  final out = s.split('').map((c) => int.tryParse(c) == null ? c : _digits[int.parse(c)]).join();
  return neg ? '-$out' : out;
}

/// Two-digit Persian clock part: 7 -> ۰۷.
String fa2(int n) => fa(n, group: false).padLeft(2, '۰');

const jalaliMonths = ['فروردین', 'اردیبهشت', 'خرداد', 'تیر', 'مرداد', 'شهریور', 'مهر', 'آبان', 'آذر', 'دی', 'بهمن', 'اسفند'];

/// Gregorian -> Jalali (solar hijri) date, the calendar the players use.
(int, int, int) toJalali(DateTime d) {
  const gDays = [0, 31, 59, 90, 120, 151, 181, 212, 243, 273, 304, 334];
  final gy = d.year - 1600, gm = d.month - 1, gd = d.day - 1;
  var gDayNo = 365 * gy + (gy + 3) ~/ 4 - (gy + 99) ~/ 100 + (gy + 399) ~/ 400;
  gDayNo += gDays[gm] + gd;
  if (gm > 1 && ((d.year % 4 == 0 && d.year % 100 != 0) || d.year % 400 == 0)) gDayNo++;
  var jDayNo = gDayNo - 79;
  final jNp = jDayNo ~/ 12053;
  jDayNo %= 12053;
  var jy = 979 + 33 * jNp + 4 * (jDayNo ~/ 1461);
  jDayNo %= 1461;
  if (jDayNo >= 366) {
    jy += (jDayNo - 1) ~/ 365;
    jDayNo = (jDayNo - 1) % 365;
  }
  var jm = 0;
  for (; jm < 11; jm++) {
    final len = jm < 6 ? 31 : 30;
    if (jDayNo < len) break;
    jDayNo -= len;
  }
  return (jy, jm + 1, jDayNo + 1);
}

/// "۱۸ آبان"
String faDayMonth(DateTime d) {
  final (_, m, day) = toJalali(d);
  return '${fa(day)} ${jalaliMonths[m - 1]}';
}
