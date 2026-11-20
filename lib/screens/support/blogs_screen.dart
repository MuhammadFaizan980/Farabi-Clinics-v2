import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/locale_keys.g.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../widgets/common/app_state_views.dart';
import '../../widgets/more/more_header.dart';
import 'blogs_vm.dart';

class BlogsScreen extends StatelessWidget {
  const BlogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.locale.languageCode;

    return ViewModelBuilder<BlogsVm>.reactive(
      viewModelBuilder: BlogsVm.new,
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: AppColors.listBackground,
        body: Column(
          children: [
            MoreHeader(
              title: LocaleKeys.blogs_title.tr(),
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: vm.isBusy
                  ? const AppShimmerList()
                  : vm.hasFailure
                  ? AppErrorView(
                      message: LocaleKeys.errors_unexpected.tr(),
                      retryLabel: LocaleKeys.common_retry.tr(),
                      onRetry: vm.load,
                    )
                  : vm.isEmpty
                  // the dev dataset has no posts, so this is the state
                  // that actually ships today
                  ? AppEmptyView(title: LocaleKeys.blogs_no_posts.tr())
                  : RefreshIndicator(
                      onRefresh: vm.refresh,
                      child: ListView.separated(
                        padding: EdgeInsetsDirectional.fromSTEB(
                          16.rw,
                          8.rh,
                          16.rw,
                          16.rh,
                        ),
                        itemCount: vm.posts.length,
                        separatorBuilder: (_, __) => SizedBox(height: 4.rh),
                        itemBuilder: (context, index) {
                          final post = vm.posts[index];
                          return Container(
                            padding: EdgeInsetsDirectional.fromSTEB(
                              18.rw,
                              12.rh,
                              18.rw,
                              12.rh,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.names.display(language),
                                  style: AppTextStyles.listCardTitle.copyWith(
                                    color: AppColors.ink,
                                  ),
                                ),
                                if (post.summary != null) ...[
                                  SizedBox(height: 6.rh),
                                  Text(
                                    post.summary!,
                                    style: AppTextStyles.profileBody.copyWith(
                                      color: AppColors.inkSecondary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
