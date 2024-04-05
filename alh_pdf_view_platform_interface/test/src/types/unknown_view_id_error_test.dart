import 'package:alh_pdf_view_platform_interface/alh_pdf_view_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('#toString', () {
    test(
        'GIVEN id '
        'WHEN calling toString '
        'THEN should return expected message', () {
      // given
      const givenViewId = 321;

      final givenError = UnknownViewIdError(givenViewId);

      // when
      final actual = givenError.toString();

      // then
      const expectedString = 'Unknown view id $givenViewId';
      expect(actual, equals(expectedString));
    });

    test(
        'GIVEN id and message '
        'WHEN calling toString '
        'THEN should return expected message', () {
      // given
      const givenViewId = 123;
      const givenMessage = ['I am a message'];

      final givenError = UnknownViewIdError(
        givenViewId,
        givenMessage,
      );

      // when
      final actual = givenError.toString();

      // then
      final expectedString =
          'Unknown view id $givenViewId: ${Error.safeToString(givenMessage)}';
      expect(actual, equals(expectedString));
    });
  });
}
