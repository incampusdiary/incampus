class UserInfo {
  String firstName,
      middleName,
      lastName,
      email,
      password,
      department,
      section,
      college;
  int year, phoneNumber;

  UserInfo({
    this.firstName,
    this.lastName,
    this.middleName,
    this.email,
    this.college,
    this.department,
    this.section,
    this.year,
    this.password,
    this.phoneNumber,
  });
  static UserInfo _currentUser;
  static setCurrentUser(UserInfo userInfo) {
    _currentUser = userInfo;
  }

  static get currentUser => _currentUser;
}
