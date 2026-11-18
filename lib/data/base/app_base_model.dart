import '../models/auth/patient_data_model.dart';

/// app-wide state that outlives any one screen: session-derived profile plus
/// whatever bootstrap data the shell needs.
class AppBaseModel {
  PatientDataModel? patient;

  bool get hasCompleteProfile =>
      (patient?.citizenIdNumber ?? '').isNotEmpty &&
      (patient?.firstName ?? '').isNotEmpty;

  void clear() {
    patient = null;
  }
}
