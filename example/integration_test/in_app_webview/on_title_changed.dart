part of 'main.dart';

void onTitleChanged() {
  final shouldSkip = kIsWeb
      ? false
      : ![
          TargetPlatform.android,
          TargetPlatform.iOS,
          TargetPlatform.macOS,
        ].contains(defaultTargetPlatform);

  var url = !kIsWeb ? TEST_URL_1 : TEST_WEB_PLATFORM_URL_1;

  skippableTestWidgets('onTitleChanged', (WidgetTester tester) async {
    final Completer<PlatformInAppWebViewController> controllerCompleter =
        Completer<PlatformInAppWebViewController>();
    final Completer<void> pageLoaded = Completer<void>();
    final Completer<void> onTitleChangedCompleter = Completer<void>();

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: InAppWebView(
          key: GlobalKey(),
          initialUrlRequest: URLRequest(url: url),
          onWebViewCreated: (controller) {
            controllerCompleter.complete(controller);
          },
          onLoadStop: (controller, url) {
            if (!pageLoaded.isCompleted) {
              pageLoaded.complete();
            }
          },
          onTitleChanged: (controller, title) {
            if (title == "title test") {
              onTitleChangedCompleter.complete();
            }
          },
        ),
      ),
    );

    final PlatformInAppWebViewController controller = await controllerCompleter.future;
    await pageLoaded.future;
    await tester.pump();
    await controller.evaluateJavascript(
        source: "document.title = 'title test';");
    await expectLater(onTitleChangedCompleter.future, completes);
  }, skip: shouldSkip);
}
