import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:reer_sh_yoonis/app.dart';

void main() {
  testWidgets('Shows setup screen when Supabase is not configured', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: ReerShYoonisApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(
      find.textContaining('Copy env.json.example to env.json'),
      findsOneWidget,
    );
  });
}
