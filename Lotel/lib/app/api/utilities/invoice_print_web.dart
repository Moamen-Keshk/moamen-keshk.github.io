import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

Future<void> openPrintableInvoiceHtml(String htmlContent) async {
  final popup = web.window.open('', '_blank');
  if (popup == null) {
    throw UnsupportedError(
      'The invoice print window was blocked. Allow pop-ups and try again.',
    );
  }

  popup.document.open();
  popup.document.write(htmlContent.toJS);
  popup.document.close();
  popup.focus();

  await Future<void>.delayed(const Duration(milliseconds: 300));
  popup.print();
}
