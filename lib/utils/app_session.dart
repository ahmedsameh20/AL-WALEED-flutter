class AppSession {
  AppSession._();
  static final AppSession instance = AppSession._();

  int currentEmployeeId = -1;
  String? currentEmployeeName;
  bool isOwner = false;

  void login(int id, String name, bool owner) {
    currentEmployeeId = id;
    currentEmployeeName = name;
    isOwner = owner;
  }

  void logout() {
    currentEmployeeId = -1;
    currentEmployeeName = null;
    isOwner = false;
  }
}
