import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ebe_gym/src/core/packages/storage/secure_storage_provider.dart';
import 'package:ebe_gym/src/features/settings/presentation/controllers/camera_preference_controller.dart';

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockFlutterSecureStorage storage;
  final Map<String, String> store = {};

  setUp(() {
    storage = MockFlutterSecureStorage();
    store.clear();
    when(
      () => storage.read(key: any(named: 'key')),
    ).thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key] as String;
      return store[key];
    });
    when(
      () => storage.write(key: any(named: 'key'), value: any(named: 'value')),
    ).thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key] as String;
      final value = invocation.namedArguments[#value] as String;
      store[key] = value;
    });
    when(
      () => storage.delete(key: any(named: 'key')),
    ).thenAnswer((invocation) async {
      final key = invocation.namedArguments[#key] as String;
      store.remove(key);
    });
  });

  ProviderContainer createContainer({String? persisted}) {
    if (persisted != null) {
      store[cameraPreferenceKey] = persisted;
    }
    return ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(storage),
      ],
    );
  }

  test('loads null when no preference is stored', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    final value = await container.read(cameraPreferenceControllerProvider.future);
    expect(value, isNull);
  });

  test('loads persisted camera name', () async {
    final container = createContainer(persisted: 'usb-cam');
    addTearDown(container.dispose);

    final value = await container.read(cameraPreferenceControllerProvider.future);
    expect(value, 'usb-cam');
  });

  test('setPreferredCameraName persists and updates state', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    await container.read(cameraPreferenceControllerProvider.future);
    await container
        .read(cameraPreferenceControllerProvider.notifier)
        .setPreferredCameraName('front');

    expect(
      container.read(cameraPreferenceControllerProvider).value,
      'front',
    );
    expect(store[cameraPreferenceKey], 'front');
  });

  test('clearing preferred camera deletes storage key', () async {
    final container = createContainer(persisted: 'front');
    addTearDown(container.dispose);

    await container.read(cameraPreferenceControllerProvider.future);
    await container
        .read(cameraPreferenceControllerProvider.notifier)
        .setPreferredCameraName(null);

    expect(container.read(cameraPreferenceControllerProvider).value, isNull);
    expect(store.containsKey(cameraPreferenceKey), isFalse);
  });

  test('empty string clears preference like null', () async {
    final container = createContainer(persisted: 'front');
    addTearDown(container.dispose);

    await container.read(cameraPreferenceControllerProvider.future);
    await container
        .read(cameraPreferenceControllerProvider.notifier)
        .setPreferredCameraName('');

    expect(container.read(cameraPreferenceControllerProvider).value, isNull);
    expect(store.containsKey(cameraPreferenceKey), isFalse);
  });
}
