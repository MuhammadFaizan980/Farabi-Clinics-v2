/// route argument for the sign-in screen. with [popOnSuccess] it returns `true`
/// to whoever opened it (the booking page) instead of resetting to the shell,
/// so the flow carries on where it stopped.
class LoginArgsModel {
  const LoginArgsModel({this.popOnSuccess = false});

  final bool popOnSuccess;
}
