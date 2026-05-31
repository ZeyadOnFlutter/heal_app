class Validator {
  static String? validateEmail(String? val) {
    final RegExp emailRegex = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    );
    if (val == null) {
      return 'this field is required';
    } else if (val.trim().isEmpty) {
      return 'this field is required';
    } else if (emailRegex.hasMatch(val) == false) {
      return 'enter valid email';
    } else {
      return null;
    }
  }

  static String? isValidPassword(String? password) {
    final bool isStrongPassword =
        RegExp(r'^(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$')
            .hasMatch(password ?? '');
    if (password == null || password.isEmpty) {
      return 'Please Enter Your Password';
    } else if (password.trim().length < 8) {
      return 'Password Should Be More Than 8 Characters';
    } else if (!isStrongPassword) {
      return 'Password must contain an uppercase letter, a number, and a special character';
    }
    return null;
  }

  static String? validateConfirmPassword(String? val, String? password) {
    if (val == null || val.isEmpty) {
      return 'this field is required';
    } else if (val != password) {
      return 'same password';
    } else {
      return null;
    }
  }

  static String? validateUsername(String? val) {
    final usernameRegex = RegExp(
      r"^(?!.*[-']{2})[^\s'-][\p{L}\s'-]*[^\s'-]$",
      unicode: true,
    );

    if (val == null || val.trim().isEmpty) {
      return 'This field is required';
    } else if (!usernameRegex.hasMatch(val.trim())) {
      return 'Enter a valid full name';
    }
    return null;
  }

  static String? validateFullName(String? val) {
    if (val == null || val.isEmpty) {
      return 'this field is required';
    } else {
      return null;
    }
  }

  static String? validatePhoneNumber(String? val) {
    if (val == null) {
      return 'this field is required';
    } else if (int.tryParse(val.trim()) == null) {
      return 'enter numbers only';
    } else if (val.trim().length != 11) {
      return 'enter value must equal 11 digit';
    } else {
      return null;
    }
  }

  static String? validateEgyptianPhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!value.startsWith('+20')) {
      return 'Phone number must start with +20';
    }
    final String numberWithoutCode = value.substring(3);
    final RegExp egyptianPhoneRegex = RegExp(r'^(10|11|12|15)[0-9]{8}$');

    if (!egyptianPhoneRegex.hasMatch(numberWithoutCode)) {
      return 'Enter a valid Egyptian mobile number (e.g. +201012345678)';
    }

    return null;
  }
}
