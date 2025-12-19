import 'package:flutter_test/flutter_test.dart';
import 'package:shoes_store/main.dart';

void main() {
  testWidgets('Hiển thị tab đăng nhập/đăng ký và chuyển tab', (tester) async {
    await tester.pumpWidget(const ShoesStoreApp());

    expect(find.text('ĐĂNG NHẬP'), findsOneWidget);
    expect(find.text('ĐĂNG KÝ'), findsOneWidget);
    expect(find.text('Chào mừng trở lại'), findsOneWidget);

    await tester.tap(find.text('ĐĂNG KÝ'));
    await tester.pumpAndSettle();

    expect(find.text('Tạo tài khoản mới'), findsOneWidget);
    expect(find.text('Đăng ký'), findsWidgets);
  });
}
