import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

import '../i18n/strings.g.dart';
import 'failure.dart';

/// Parsed, UI-ready representation of an error for display widgets.
class ErrorDisplayInfo {
  const ErrorDisplayInfo({
    required this.title,
    required this.message,
    this.details,
    this.statusCode,
  });

  /// Friendly localized title (e.g. "Server error. Please try again later.").
  final String title;

  /// Primary human-readable message (server message when available).
  final String message;

  /// Optional technical details for copy/debug (pretty JSON, raw error).
  final String? details;

  /// HTTP status code when the error came from a [ClientException].
  final int? statusCode;

  /// Text suitable for clipboard copy (title + message + details).
  String get copyText {
    final buffer = StringBuffer(title);
    if (message.isNotEmpty && message != title) {
      buffer.writeln();
      buffer.write(message);
    }
    if (details != null && details!.isNotEmpty) {
      buffer.writeln();
      buffer.writeln();
      buffer.write(details);
    }
    if (statusCode != null && statusCode! > 0) {
      buffer.writeln();
      buffer.write('HTTP $statusCode');
    }
    return buffer.toString();
  }

  /// Builds display info from any thrown object, [Failure], or [ClientException].
  factory ErrorDisplayInfo.from(Object error, {Translations? translations}) {
    final t = translations ?? LocaleSettings.instance.currentTranslations;
    final failures = t.failures;

    final client = _extractClientException(error);
    if (client != null) {
      final status = client.statusCode;
      final title = _titleForStatus(failures, status, client);
      final message = _clientMessage(client) ?? title;
      final details = _clientDetails(client);
      return ErrorDisplayInfo(
        title: title,
        message: message,
        details: details,
        statusCode: status > 0 ? status : null,
      );
    }

    if (error is Failure) {
      final nested = _extractClientException(error.message);
      if (nested != null) {
        return ErrorDisplayInfo.from(nested, translations: translations);
      }
      final message = error.messageString;
      return ErrorDisplayInfo(
        title: failures.generic,
        message: message,
        details: _stringifyDetails(error.message),
      );
    }

    if (error is String) {
      return ErrorDisplayInfo(
        title: failures.generic,
        message: error,
      );
    }

    final raw = error.toString();
    final looksNetwork = raw.toLowerCase().contains('socket') ||
        raw.toLowerCase().contains('network') ||
        raw.toLowerCase().contains('connection');
    return ErrorDisplayInfo(
      title: looksNetwork ? failures.networkError : failures.generic,
      message: looksNetwork ? failures.networkError : raw,
      details: raw != failures.generic ? raw : null,
    );
  }

  static ClientException? _extractClientException(Object? error) {
    if (error is ClientException) return error;
    if (error is Failure) {
      final nested = error.message;
      if (nested is ClientException) return nested;
      if (nested is Failure) return _extractClientException(nested);
    }
    return null;
  }

  static String _titleForStatus(
    Translations$failures$en failures,
    int status,
    ClientException client,
  ) {
    if (client.isAbort) return failures.timeout;
    if (status == 0) return failures.networkError;
    if (status == 401) return failures.sessionExpired;
    if (status == 403) return failures.unauthorized;
    if (status == 404) return failures.notFound;
    if (status == 409) return failures.conflict;
    if (status == 400 || status == 422) return failures.badRequest;
    if (status == 429) return failures.tooManyRequests;
    if (status >= 500) return failures.serverError;
    return failures.generic;
  }

  static String? _clientMessage(ClientException client) {
    final data = client.response;
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;

    final original = client.originalError;
    if (original is String && original.isNotEmpty) return original;
    if (original != null) return original.toString();

    return null;
  }

  static String? _clientDetails(ClientException client) {
    final parts = <String>[];

    if (client.statusCode > 0) {
      parts.add('statusCode: ${client.statusCode}');
    }
    if (client.url != null) {
      parts.add('url: ${client.url}');
    }
    if (client.response.isNotEmpty) {
      parts.add('response:\n${_prettyJson(client.response)}');
    }
    if (client.originalError != null) {
      parts.add('originalError: ${client.originalError}');
    }

    if (parts.isEmpty) return null;
    return parts.join('\n');
  }

  static String? _stringifyDetails(Object? value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map || value is List) return _prettyJson(value);
    final text = value.toString();
    if (text.isEmpty || text == 'null') return null;
    return text;
  }

  static String _prettyJson(Object value) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(value);
    } catch (_) {
      return value.toString();
    }
  }
}
