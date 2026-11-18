/// the api takes an integer here. the website sends strings and gets a 422 on
/// every call, which is why its booking history always renders empty.
///
/// 1 and 6 are confirmed by moving a real booking through them; 2-5 are
/// accepted by the api but no booking was ever observed in those states, so
/// they are deliberately left unnamed rather than guessed.
enum BookingStatus {
  created(1),
  status2(2),
  status3(3),
  status4(4),
  status5(5),
  cancelled(6);

  const BookingStatus(this.value);

  final int value;

  static BookingStatus? fromValue(int? value) {
    if (value == null) return null;
    for (final status in BookingStatus.values) {
      if (status.value == value) return status;
    }
    return null;
  }
}
