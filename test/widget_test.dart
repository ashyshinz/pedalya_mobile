import 'package:flutter_test/flutter_test.dart';
import 'package:pedalya_mobile/main.dart';

void main() {
  test('PedalyaApp can be created', () {
    const app = PedalyaApp();

    expect(app, isA<PedalyaApp>());
  });
}