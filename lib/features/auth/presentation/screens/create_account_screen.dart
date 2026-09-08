import 'package:flutter/material.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../widgets/auth_validators.dart';
import '../widgets/login_flow_widgets.dart';

/// Step 3 — collect full name before profession selection.
class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key, this.args});

  final SignupFlowArgs? args;

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _continue() {
    if (!_formKey.currentState!.validate()) return;
    final mobile = widget.args?.mobileNumber;
    if (mobile == null || mobile.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    Navigator.of(context).pushNamed(
      AppRoutes.chooseProfession,
      arguments: SignupFlowArgs(
        mobileNumber: mobile,
        fullName: _nameController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.space6,
            AppSpacing.space6,
            AppSpacing.space6,
            AppSpacing.space4,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create Your Account',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.space2),
                Text(
                  'Please provide your details to continue',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.space8),
                LoginFlowOutlinedField(
                  label: 'Full Name *',
                  controller: _nameController,
                  validator: AuthValidators.fullName,
                ),
                const Spacer(),
                LoginFlowContinueButton(
                  label: 'Continue',
                  onPressed: _continue,
                ),
                const SizedBox(height: AppSpacing.space5),
                const LoginFlowTermsFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
