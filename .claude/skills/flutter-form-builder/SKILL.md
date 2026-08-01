---
name: flutter-form-builder
description: Example widget pattern and field-change-listening snippet for building forms with flutter_form_builder. Use when creating or editing a form/dialog/sheet in this app.
---

# flutter_form_builder Example Pattern

See `CLAUDE.md` for the core rules (always use `flutter_form_builder`, wrap in `FormBuilder` + `GlobalKey<FormBuilderState>`, validate with `saveAndValidate()`). This skill has the full example.

**Example pattern:**
```dart
class MyFormSheet extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = useMemoized(() => GlobalKey<FormBuilderState>());
    final isSaving = useState(false);

    Future<void> handleSave() async {
      if (!formKey.currentState!.saveAndValidate()) return;

      final values = formKey.currentState!.value;
      // values is Map<String, dynamic> with all field values
      final name = values['name'] as String?;
      // ...
    }

    return FormBuilder(
      key: formKey,
      child: Column(
        children: [
          FormBuilderTextField(
            name: 'name',
            decoration: const InputDecoration(labelText: 'Name *'),
            validator: FormBuilderValidators.required(),
          ),
          FormBuilderDropdown<String>(
            name: 'species',
            decoration: const InputDecoration(labelText: 'Species'),
            items: speciesList.map((s) =>
              DropdownMenuItem(value: s.id, child: Text(s.name))
            ).toList(),
          ),
          FormBuilderDateTimePicker(
            name: 'dateOfBirth',
            decoration: const InputDecoration(labelText: 'Date of Birth'),
            inputType: InputType.date,
          ),
        ],
      ),
    );
  }
}
```

**Listening to field changes:**
```dart
FormBuilderTextField(
  name: 'species',
  onChanged: (value) {
    // React to changes, e.g., clear dependent fields
    formKey.currentState?.fields['breed']?.didChange(null);
  },
)
```
