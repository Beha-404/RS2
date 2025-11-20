import 'dart:math' as math;
import 'package:easy_pc/models/i18n.dart';
import 'package:easy_pc/models/user.dart';
import 'package:easy_pc/providers/user_provider.dart';
import 'package:easy_pc/services/user_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';

import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key, required this.user});

  final User user;

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const _yellow = Color(0xFFDDC03D);

  final _formKey = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String _language = 'English';
  Uint8List? _pickedImage;

  late User _user;
  User? _updatedUserForReturn;
  bool _isPopping = false;

  @override
  void initState() {
    super.initState();
    _user = widget.user;

    _firstCtrl.text = _user.firstName ?? '';
    _lastCtrl.text = _user.lastName ?? '';
    _cityCtrl.text = _user.city ?? '';
    _stateCtrl.text = _user.state ?? '';
    _postalCtrl.text = _user.postalCode ?? '';
    _addressCtrl.text = _user.address ?? '';

    _loadDefaultLang();
  }

  Future<void> _loadDefaultLang() async {
    await I18n.load(const Locale('en'));
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    _postalCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop || _isPopping) return;
        _popWithResult();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(color: _yellow, onPressed: _popWithResult),
          title: Row(
            children: [
              const Icon(Icons.computer, color: _yellow),
              const SizedBox(width: 8),
              const Text('EasyPC', style: TextStyle(color: _yellow)),
            ],
          ),
          backgroundColor: const Color(0xFF262626),
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: const [Color(0xFF2F2F2F), Color(0xFF3E3E3E)],
              transform: GradientRotation(135 * math.pi / 180),
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: _card(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _popWithResult() {
    if (_isPopping || !mounted) return;
    _isPopping = true;
    Navigator.of(context).pop<User>(_updatedUserForReturn);
    }

  Widget _card() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2B2B),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _languagePicker(),
            const SizedBox(height: 12),
            Center(
              child: Text(
                I18n.path('EDIT_PROFILE.TITLE'),
                style: TextStyle(
                  color: _yellow,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _labeledField(
                    I18n.path('EDIT_PROFILE.FIRST_NAME'),
                    _firstCtrl,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _labeledField(
                    I18n.path('EDIT_PROFILE.LAST_NAME'),
                    _lastCtrl,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _labeledField(
                    I18n.path('EDIT_PROFILE.CITY'),
                    _cityCtrl,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _labeledField(
                    I18n.path('EDIT_PROFILE.STATE'),
                    _stateCtrl,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _labeledField(
                    I18n.path('EDIT_PROFILE.POSTAL_CODE'),
                    _postalCtrl,
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            _labeledField(I18n.path('EDIT_PROFILE.ADDRESS'), _addressCtrl),
            const SizedBox(height: 12),
            const Divider(color: Colors.white24),

            const SizedBox(height: 8),
            Text(
              I18n.path('EDIT_PROFILE.PROFILE_PICTURE'),
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _pictureBox(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          I18n.path('EDIT_PROFILE.CURRENT'),
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        SizedBox(height: 10),
                        SizedBox(
                          height: 96,
                          child:
                              (_user.profilePicture == null ||
                                  _user.profilePicture!.isEmpty)
                              ? const Icon(
                                  Icons.account_circle,
                                  color: Colors.white54,
                                  size: 96,
                                )
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.memory(
                                    _user.profilePicture!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _pickImage,
                    child: _pictureBox(
                      borderStyle: BorderStyle.solid,
                      child: SizedBox(
                        height: 140,
                        child: _pickedImage == null
                            ? Center(
                                child: Text(
                                  I18n.path('EDIT_PROFILE.TAP_TO_SELECT_IMAGE'),
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white60),
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  _pickedImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _yellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      I18n.path('EDIT_PROFILE.ACCEPT_CHANGES'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _popWithResult,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C6C6C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      I18n.path('EDIT_PROFILE.CANCEL_CHANGES'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _languagePicker() {
    return DropdownButtonFormField<String>(
      initialValue: _language,
      items: const [
        DropdownMenuItem(value: 'English', child: Text('English')),
        DropdownMenuItem(value: 'Bosnian', child: Text('Bosnian')),
      ],
      onChanged: (v) async {
        final lang = v ?? 'English';
        setState(() => _language = lang);
        await I18n.load(
          lang == 'Bosnian' ? const Locale('bs') : const Locale('en'),
        );
        if (mounted) {
          setState(() {});
        }
      },
      decoration: InputDecoration(
        isDense: true,
        filled: true,
        fillColor: const Color(0xFFE6E6E6),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _labeledField(
    String label,
    TextEditingController ctrl, {
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: ctrl,
          keyboardType: keyboardType,
          style: const TextStyle(color: Colors.white),
          decoration: _inputDecoration(),
        ),
      ],
    );
  }

  Widget _pictureBox({
    required Widget child,
    BorderStyle borderStyle = BorderStyle.solid,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.black26, style: borderStyle),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }

  static InputDecoration _inputDecoration() {
    return InputDecoration(
      isDense: true,
      filled: true,
      fillColor: const Color(0xFF262626),
      hintStyle: const TextStyle(color: Colors.white54),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _yellow, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _yellow, width: 2),
      ),
    );
  }

  void _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result != null &&
          result.files.isNotEmpty &&
          result.files.first.bytes != null) {
        final file = result.files.first;
        if (file.bytes != null) {
          setState(() => _pickedImage = result.files.single.bytes);
        }
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  void _submit() async {
    String? nullIfEmpty(String? v) {
      final t = v?.trim();
      if (t == null || t.isEmpty) return null;
      return t;
    }

    final messenger = ScaffoldMessenger.of(context);

    final updatedUser = User(
      id: _user.id,
      username: _user.username,
      firstName: nullIfEmpty(_firstCtrl.text),
      lastName: nullIfEmpty(_lastCtrl.text),
      city: nullIfEmpty(_cityCtrl.text),
      state: nullIfEmpty(_stateCtrl.text),
      postalCode: nullIfEmpty(_postalCtrl.text),
      address: nullIfEmpty(_addressCtrl.text),
    );
    try {
      final response = await const UserService().updateUser(
        user: updatedUser,
        profilePicture: _pickedImage,
      );

      if (!mounted) return;

      setState(() {
        _user = (response.profilePicture != null)
            ? response
            : response.copyWith(profilePicture: _pickedImage);
        _firstCtrl.text = _user.firstName ?? '';
        _lastCtrl.text = _user.lastName ?? '';
        _cityCtrl.text = _user.city ?? '';
        _stateCtrl.text = _user.state ?? '';
        _postalCtrl.text = _user.postalCode ?? '';
        _addressCtrl.text = _user.address ?? '';
      });
      _updatedUserForReturn = _user;

      Provider.of<UserProvider>(context, listen: false).setUser(_user);
      messenger.showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }
}
