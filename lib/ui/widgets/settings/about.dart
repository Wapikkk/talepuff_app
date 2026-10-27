import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/app_assets.dart';
import '../../../core/app_colors.dart';
import '../../../data/models/legal_document.dart';
import '../../../data/services/app_info.dart';
import '../../../l10n/app_localizations.dart';

class About extends StatefulWidget {
  const About({super.key});

  @override
  State<About> createState() => _AboutState();
}

class _AboutState extends State<About> {
  late final Future<String> _version = context.read<AppInfo>().versionLabel();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.about,
          style: const TextStyle(
            fontFamily: AppAssets.fontFamily,
            color: AppColors.slideBubble,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildAboutItem(
          title: l10n.version,
          trailing: FutureBuilder<String>(
            future: _version,
            builder: (context, snapshot) => Text(
              snapshot.data ?? '',
              style: const TextStyle(
                color: AppColors.slideBubble,
                fontSize: 16,
                fontFamily: AppAssets.fontFamily,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        _buildAboutItem(
          title: l10n.serverAddress,
          onTap: () async {
            await Navigator.pushNamed(context, '/server_address');
            if (mounted) setState(() {});
          },
        ),
        _buildAboutItem(
          title: l10n.sendFeedback,
          onTap: () => Navigator.pushNamed(context, '/feedback'),
        ),
        _buildAboutItem(
          title: l10n.termsAndConditions,
          onTap: () => Navigator.pushNamed(context, '/legal', arguments: LegalDocument.terms),
        ),
        _buildAboutItem(
          title: l10n.privacyPolicy,
          onTap: () => Navigator.pushNamed(context, '/legal', arguments: LegalDocument.privacy),
        ),
      ],
    );
  }

  Widget _buildAboutItem({
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.darkPurple,
              fontWeight: FontWeight.bold,
              fontFamily: AppAssets.fontFamily,
            ),
          ),
          trailing: trailing ??
              const Icon(
                Icons.chevron_right,
                color: AppColors.slideBubble,
              ),
          onTap: onTap,
        ),
        const Divider(
          height: 2,
          thickness: 2,
          color: AppColors.dividerLine,
        ),
      ],
    );
  }
}
