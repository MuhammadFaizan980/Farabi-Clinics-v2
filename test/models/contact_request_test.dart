import 'package:farabi_booking_app/data/models/support/support_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  ContactRequestModel build({
    String name = 'Agent',
    String phone = '0564772491',
    int? branchId = 8,
    int? serviceId = 19,
    String? aboutUs = 'friend',
  }) =>
      ContactRequestModel(
        name: name,
        phone: phone,
        branchId: branchId,
        serviceId: serviceId,
        aboutUs: aboutUs,
      );

  test('mirrors the website required set', () {
    expect(build().isComplete, isTrue);
    expect(build(name: ' ').isComplete, isFalse);
    expect(build(phone: '').isComplete, isFalse);
    expect(build(branchId: null).isComplete, isFalse);
    expect(build(serviceId: null).isComplete, isFalse);
    expect(build(aboutUs: null).isComplete, isFalse);
  });

  test('serialises the multipart field names the api expects', () {
    final fields = build().toFields();
    expect(fields.keys.toSet(), {
      'name',
      'email',
      'phone_number',
      'service_id',
      'branch_id',
      'about_us',
    });
    // ids go over the wire as strings in a multipart body
    expect(fields['branch_id'], '8');
    expect(fields['service_id'], '19');
  });

  test('offers exactly the website source options', () {
    expect(ContactSources.values.length, 9);
    expect(ContactSources.values, contains('snapchat'));
    expect(ContactSources.values, contains('other'));
  });
}
