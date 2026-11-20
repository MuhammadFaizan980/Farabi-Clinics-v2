import 'package:file_picker/file_picker.dart';
import 'package:flutter/widgets.dart';

import '../../data/base/app_base_vm.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../data/models/support/support_models.dart';
import '../../repos/support/support_repo.dart';

/// what the Area of Specialization and Years of Experience dropdowns offer.
/// the site ships these lists in its own code (there is no endpoint), and the
/// english `value` is what it posts, so the same values are posted here.
class JobOption {
  const JobOption(this.labelKey, this.value);

  final String labelKey;
  final String value;
}

class JobApplyOptions {
  JobApplyOptions._();

  static const List<JobOption> experience = [
    JobOption(LocaleKeys.careers_exp_lt_1, 'Less than 1 year'),
    JobOption(LocaleKeys.careers_exp_1_3, '1 - 3 years'),
    JobOption(LocaleKeys.careers_exp_3_6, '3 - 6 years'),
    JobOption(LocaleKeys.careers_exp_6_10, '6 - 10 years'),
    JobOption(LocaleKeys.careers_exp_gt_10, 'More than 10 years'),
  ];

  static const List<JobOption> specializations = [
    JobOption(LocaleKeys.careers_spec_orthodontics, 'Orthodontics'),
    JobOption(LocaleKeys.careers_spec_dentist, 'Dentist'),
    JobOption(LocaleKeys.careers_spec_dermatology_and_beauty,
        'Dermatology and Beauty'),
    JobOption(LocaleKeys.careers_spec_ophthalmologist, 'Ophthalmologist'),
    JobOption(LocaleKeys.careers_spec_ent, 'Ear, nose and throat doctor'),
    JobOption(LocaleKeys.careers_spec_gynaecologist, 'Gynaecologist'),
    JobOption(LocaleKeys.careers_spec_orthopedic_doctor, 'Orthopedic doctor'),
    JobOption(LocaleKeys.careers_spec_pediatrician, 'Pediatrician'),
    JobOption(LocaleKeys.careers_spec_internist, 'Internist'),
    JobOption(LocaleKeys.careers_spec_nursing, 'Nursing'),
    JobOption(LocaleKeys.careers_spec_receptionist, 'Receptionist'),
    JobOption(LocaleKeys.careers_spec_customer_service, 'Customer Service'),
    JobOption(LocaleKeys.careers_spec_accountant, 'Accountant'),
    JobOption(LocaleKeys.careers_spec_marketing, 'Marketing'),
    JobOption(LocaleKeys.careers_spec_insurance, 'Insurance'),
    JobOption(LocaleKeys.careers_spec_pediatric_dentist, 'Pediatric Dentist'),
    JobOption(LocaleKeys.careers_spec_urologist, 'Urologist'),
    JobOption(LocaleKeys.careers_spec_other, 'Other'),
  ];
}

class JobApplyVm extends AppBaseVm {
  JobApplyVm(this.job);

  final JobDataModel job;

  static const int maxCvBytes = 5 * 1024 * 1024;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final positionController = TextEditingController();
  final licenseController = TextEditingController();
  final degreeController = TextEditingController();
  final institutionController = TextEditingController();
  final coverController = TextEditingController();
  final refNameController = TextEditingController();
  final refRelationController = TextEditingController();
  final refContactController = TextEditingController();

  String? _experience;
  String? _specialization;
  int? _graduationYear;
  String? _cvPath;
  String? _cvName;
  String? _cvError;
  bool _certify = false;
  bool _agree = false;
  bool _submitted = false;
  bool _showErrors = false;

  /// the site offers the last 55 years, newest first
  List<int> get graduationYears {
    final now = DateTime.now().year;
    return List.generate(55, (i) => now - i);
  }

  /// "DD / MM / YYYY": day 1-31, month 1-12, year 1940 up to this year
  static bool isValidDob(String raw, int currentYear) {
    final match = RegExp(r'^(\d{2}) / (\d{2}) / (\d{4})$').firstMatch(raw);
    if (match == null) return false;
    final day = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final year = int.parse(match.group(3)!);
    return day >= 1 &&
        day <= 31 &&
        month >= 1 &&
        month <= 12 &&
        year >= 1940 &&
        year <= currentYear;
  }

  static bool _isEmail(String v) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());

  void setExperience(String? v) {
    _experience = v;
    notifyListeners();
  }

  void setSpecialization(String? v) {
    _specialization = v;
    notifyListeners();
  }

  void setGraduationYear(int? v) {
    _graduationYear = v;
    notifyListeners();
  }

  void setCertify(bool v) {
    _certify = v;
    notifyListeners();
  }

  void setAgree(bool v) {
    _agree = v;
    notifyListeners();
  }

  void onFieldChanged(String _) => notifyListeners();

  /// PDF or DOCX, 5 MB at most (the site's rule)
  Future<void> pickCv() async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'docx'],
    );
    final file = result?.files.single;
    if (file == null || file.path == null) return;

    final name = file.name.toLowerCase();
    if (!name.endsWith('.pdf') && !name.endsWith('.docx')) {
      _cvError = LocaleKeys.careers_cv_bad_type;
    } else if (file.size > maxCvBytes) {
      _cvError = LocaleKeys.careers_cv_too_large;
    } else {
      _cvError = null;
      _cvPath = file.path;
      _cvName = file.name;
    }
    notifyListeners();
  }

  void removeCv() {
    _cvPath = null;
    _cvName = null;
    _cvError = null;
    notifyListeners();
  }

  /// every field the site marks with a star, plus both consents
  bool get isValid =>
      nameController.text.trim().isNotEmpty &&
      _isEmail(emailController.text) &&
      phoneController.text.trim().isNotEmpty &&
      isValidDob(dobController.text.trim(), DateTime.now().year) &&
      positionController.text.trim().isNotEmpty &&
      _experience != null &&
      licenseController.text.trim().isNotEmpty &&
      _specialization != null &&
      degreeController.text.trim().isNotEmpty &&
      institutionController.text.trim().isNotEmpty &&
      _graduationYear != null &&
      coverController.text.trim().isNotEmpty &&
      _certify &&
      _agree;

  Future<void> submit() async {
    _showErrors = true;
    clearFailure(notify: false);
    if (!isValid) {
      notifyListeners();
      return;
    }

    setBusy(true);
    final response = await repo<SupportRepo>().applyToJob(
      job.slug,
      JobApplicationModel(
        jobId: job.id,
        jobTitle: job.names.nameEn ?? job.names.name ?? '',
        fullName: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        dateOfBirth: dobController.text.trim(),
        currentPosition: positionController.text,
        yearsOfExperience: _experience!,
        licenseNumber: licenseController.text,
        speciality: _specialization!,
        highestDegree: degreeController.text,
        institution: institutionController.text,
        graduationYear: _graduationYear!,
        coverLetter: coverController.text,
        referenceName: refNameController.text,
        referenceRelationship: refRelationController.text,
        referenceContact: refContactController.text,
        cvPath: _cvPath,
        cvName: _cvName,
      ),
    );
    setBusy(false);

    if (!response.success) {
      captureFailure(response);
      return;
    }
    _submitted = true;
    notifyListeners();
  }

  @override
  void dispose() {
    for (final c in [
      nameController,
      emailController,
      phoneController,
      dobController,
      positionController,
      licenseController,
      degreeController,
      institutionController,
      coverController,
      refNameController,
      refRelationController,
      refContactController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// getters/setters below this line...

  String? get experience => _experience;
  String? get specialization => _specialization;
  int? get graduationYear => _graduationYear;
  String? get cvName => _cvName;
  String? get cvError => _cvError;
  bool get certify => _certify;
  bool get agree => _agree;
  bool get submitted => _submitted;
  bool get showErrors => _showErrors;

  bool get dobInvalid =>
      _showErrors &&
      !isValidDob(dobController.text.trim(), DateTime.now().year);
  bool get emailInvalid => _showErrors && !_isEmail(emailController.text);
  bool isEmptyField(TextEditingController c) =>
      _showErrors && c.text.trim().isEmpty;
}
