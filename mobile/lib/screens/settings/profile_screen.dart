import 'package:flutter/material.dart';

import '../../theme/app_dimens.dart';
import '../../theme/app_typography.dart';
import '../../widgets/widgets.dart';

@immutable
class ProfileData {
  const ProfileData({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.company,
  });

  final String fullName;
  final String email;
  final String phone;
  final String company;
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.profile});

  final ProfileData profile;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _companyController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _companyController = TextEditingController(text: widget.profile.company);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      ProfileData(
        fullName: _nameController.text.trim(),
        email: widget.profile.email,
        phone: _phoneController.text.trim(),
        company: _companyController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final initials = _nameController.text
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return Scaffold(
      appBar: const AppTopBar.push(title: 'Profil'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpace.screenX,
            AppSpace.cardPadding,
            AppSpace.screenX,
            AppSpace.sectionGap,
          ),
          children: [
            Center(
              child: CircleAvatar(
                radius: 42,
                child: Text(initials, style: AppTypography.titleL),
              ),
            ),
            const SizedBox(height: AppSpace.sectionGap),
            SectionCard(
              title: 'Hesap bilgileri',
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Ad Soyad'),
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Ad Soyad boş bırakılamaz'
                        : null,
                  ),
                  const SizedBox(height: AppSpace.cardPadding),
                  TextFormField(
                    initialValue: widget.profile.email,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'E-posta'),
                  ),
                  const SizedBox(height: AppSpace.cardPadding),
                  TextFormField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'Telefon'),
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: AppSpace.cardPadding),
                  TextFormField(
                    controller: _companyController,
                    decoration: const InputDecoration(
                      labelText: 'Şirket / Kurum',
                    ),
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _save(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpace.sectionGap),
            FilledButton(onPressed: _save, child: const Text('Kaydet')),
          ],
        ),
      ),
    );
  }
}
