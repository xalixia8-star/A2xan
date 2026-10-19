import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/routes.dart';
import '../../data/models/credential.dart';
import '../../data/providers.dart';
import '../../shared/widgets/service_icon.dart';
import '../../shared/widgets/staggered_item.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'credential_detail_screen.dart';

/// Daftar sandi (ListView.builder) dengan animasi muncul bertahap.
class CredentialList extends StatelessWidget {
  const CredentialList({
    super.key,
    required this.items,
    this.bottomPadding = 100,
  });

  final List<Credential> items;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20, 8, 20, bottomPadding),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final c = items[i];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: StaggeredItem(
            key: ValueKey(c.id),
            index: i,
            child: CredentialTile(credential: c),
          ),
        );
      },
    );
  }
}

class CredentialTile extends ConsumerWidget {
  const CredentialTile({super.key, required this.credential});

  final Credential credential;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service =
        ref.watch(serviceResolverProvider)(credential.serviceId, credential.serviceName);
    return RepaintBoundary(
      child: Material(
        color: AppColors.espresso,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: AppColors.goldBorder()),
        ),
        elevation: 3,
        shadowColor: Colors.black,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => Navigator.of(context).push(
            FadeSlideRoute(
              builder: (_) => CredentialDetailScreen(credentialId: credential.id),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                ServiceIcon(
                  service: service,
                  size: 52,
                  heroTag: 'cred-${credential.id}',
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        credential.serviceName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(16, weight: 600),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        credential.username.isEmpty ? '—' : credential.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.body(13, color: AppColors.champagneMuted),
                      ),
                    ],
                  ),
                ),
                if (credential.favorite)
                  const Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.star_rounded, color: AppColors.gold, size: 22),
                  ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.gold),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
