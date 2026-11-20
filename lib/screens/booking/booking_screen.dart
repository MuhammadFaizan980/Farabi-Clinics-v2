import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:stacked/stacked.dart';

import '../../data/constants/app_assets.dart';
import '../../data/constants/locale_keys.g.dart';
import '../../data/models/booking/booking_models.dart';
import '../../utils/app_text_styles.dart';
import '../../utils/color/app_colors.dart';
import '../../utils/extensions/responsive_extensions.dart';
import '../../utils/extensions/vm_init_extension.dart';
import '../../widgets/common/bottom_action_bar.dart';
import '../../widgets/common/verified_badge.dart';
import '../../widgets/more/more_header.dart';
import 'booking_vm.dart';

/// the site's mobile booking page: doctor card, treatment cards, branch card,
/// month tabs with day chips, time chips and a fixed Confirm bar. treatments,
/// branches, dates and slots all come from the api for the chosen doctor.
class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key, required this.args});

  final BookingArgsModel args;

  @override
  Widget build(BuildContext context) {
    final language = context.locale.languageCode;

    return ViewModelBuilder<BookingVm>.reactive(
      viewModelBuilder: () => BookingVm(args.doctor, args.serviceId),
      onViewModelReady: (vm) => runAfterFirstFrame(vm.onInit),
      builder: (context, vm, child) => Scaffold(
        backgroundColor: AppColors.listBackground,
        body: Column(
          children: [
            MoreHeader(
              title: LocaleKeys.booking_title.tr(),
              onBack: () => Navigator.of(context).maybePop(),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsetsDirectional.fromSTEB(
                  16.rw,
                  16.rh,
                  16.rw,
                  24.rh,
                ),
                children: [
                  _DoctorCard(vm: vm, language: language),
                  SizedBox(height: 12.rh),
                  _Section(
                    title: LocaleKeys.booking_choose_service.tr(),
                    child: _TreatmentRow(vm: vm, language: language),
                  ),
                  SizedBox(height: 12.rh),
                  _Section(
                    title: LocaleKeys.booking_choose_branch.tr(),
                    child: _BranchRow(vm: vm, language: language),
                  ),
                  SizedBox(height: 12.rh),
                  _Section(
                    title: LocaleKeys.booking_choose_date.tr(),
                    child: _DatePicker(vm: vm),
                  ),
                  SizedBox(height: 12.rh),
                  _Section(
                    title: LocaleKeys.booking_choose_time.tr(),
                    child: _TimeGrid(vm: vm),
                  ),
                ],
              ),
            ),
            BottomActionBar(
              label: LocaleKeys.booking_confirm.tr(),
              onPressed: vm.canConfirm ? vm.confirm : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.sectionTitle.copyWith(color: AppColors.ink),
          ),
          SizedBox(height: 14.rh),
          child,
        ],
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.vm, required this.language});

  final BookingVm vm;
  final String language;

  @override
  Widget build(BuildContext context) {
    final image = vm.doctor.image;
    final placeholder = Icon(
      Icons.person_outline,
      size: 34.rw,
      color: AppColors.primary.withValues(alpha: 0.5),
    );

    return Container(
      width: double.infinity,
      padding: EdgeInsetsDirectional.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipOval(
            child: Container(
              width: 64.rw,
              height: 64.rw,
              color: AppColors.redSelected6,
              child: (image == null || image.isEmpty)
                  ? placeholder
                  : CachedNetworkImage(
                      imageUrl: image,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => placeholder,
                    ),
            ),
          ),
          SizedBox(height: 12.rh),
          Row(
            children: [
              Flexible(
                child: Text(
                  vm.doctor.names.display(language),
                  style: AppTextStyles.listCardTitle.copyWith(
                    color: AppColors.ink,
                  ),
                ),
              ),
              SizedBox(width: 6.rw),
              const VerifiedBadge(size: 18),
            ],
          ),
        ],
      ),
    );
  }
}

/// a selectable card with a soft icon tile above its label (treatments,
/// branches)
class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: BoxConstraints(minWidth: 140.rw, maxWidth: 220.rw),
          padding: EdgeInsetsDirectional.all(14.r),
          decoration: BoxDecoration(
            color: selected ? AppColors.redSelected6 : AppColors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : AppColors.hairline8,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38.rw,
                height: 38.rw,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : AppColors.listBackground,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: icon,
              ),
              SizedBox(height: 18.rh),
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.rowTitle.copyWith(
                  color: selected ? AppColors.ink : AppColors.inkSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TreatmentRow extends StatelessWidget {
  const _TreatmentRow({required this.vm, required this.language});

  final BookingVm vm;
  final String language;

  @override
  Widget build(BuildContext context) {
    if (vm.isBusy) return const _Loader();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final service in vm.services) ...[
            _OptionCard(
              label: service.names.display(language),
              selected: vm.serviceId == service.id,
              onTap: () => vm.selectService(service.id),
              icon: Icon(
                Icons.medical_services_outlined,
                size: 20.rw,
                color: vm.serviceId == service.id
                    ? AppColors.primary
                    : AppColors.iconGrey,
              ),
            ),
            SizedBox(width: 10.rw),
          ],
        ],
      ),
    );
  }
}

class _BranchRow extends StatelessWidget {
  const _BranchRow({required this.vm, required this.language});

  final BookingVm vm;
  final String language;

  @override
  Widget build(BuildContext context) {
    if (vm.loadingBranches) return const _Loader();
    if (vm.noBranches) {
      return Text(
        LocaleKeys.booking_no_branches_for_service.tr(),
        style: AppTextStyles.cardSubtitle.copyWith(
          color: AppColors.inkSecondary,
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final branch in vm.branches) ...[
            _OptionCard(
              label: branch.names.display(language),
              selected: vm.branchId == branch.id,
              onTap: () => vm.selectBranch(branch.id),
              icon: SvgPicture.asset(
                AppAssets.iconLocationPin,
                width: 20.rw,
                height: 20.rw,
                colorFilter: ColorFilter.mode(
                  vm.branchId == branch.id
                      ? AppColors.primary
                      : AppColors.iconGrey,
                  BlendMode.srcIn,
                ),
              ),
            ),
            SizedBox(width: 10.rw),
          ],
        ],
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  const _DatePicker({required this.vm});

  final BookingVm vm;

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.toString();
    final months = <int>[];
    for (final date in vm.dates) {
      if (!months.contains(date.month)) months.add(date.month);
    }
    final selectedMonth = vm.date?.month ?? months.first;
    final days = vm.dates.where((d) => d.month == selectedMonth).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.rw,
          children: [
            for (final month in months)
              _Chip(
                label: DateFormat.MMMM(
                  locale,
                ).format(vm.dates.firstWhere((d) => d.month == month)),
                selected: month == selectedMonth,
                onTap: () =>
                    vm.selectDate(vm.dates.firstWhere((d) => d.month == month)),
              ),
          ],
        ),
        SizedBox(height: 14.rh),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final date in days) ...[
                _DayChip(
                  date: date,
                  locale: locale,
                  selected:
                      vm.date?.day == date.day && vm.date?.month == date.month,
                  onTap: () => vm.selectDate(date),
                ),
                SizedBox(width: 8.rw),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.date,
    required this.locale,
    required this.selected,
    required this.onTap,
  });

  final DateTime date;
  final String locale;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56.rw,
          padding: EdgeInsetsDirectional.symmetric(vertical: 10.rh),
          decoration: BoxDecoration(
            color: selected ? AppColors.redSelected6 : AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.hairline8,
            ),
          ),
          child: Column(
            children: [
              Text(
                DateFormat.E(locale).format(date).toUpperCase(),
                style: AppTextStyles.chip.copyWith(
                  color: selected ? AppColors.primary : AppColors.inkSecondary,
                ),
              ),
              SizedBox(height: 6.rh),
              Text(
                '${date.day}',
                style: AppTextStyles.sectionTitle.copyWith(
                  color: selected ? AppColors.primary : AppColors.ink,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeGrid extends StatelessWidget {
  const _TimeGrid({required this.vm});

  final BookingVm vm;

  /// the api sends "10:30"; the site shows "10:30 AM"
  static String format(String time, String locale) {
    final parts = time.split(':');
    if (parts.length < 2) return time;
    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) return time;
    return DateFormat.jm(locale).format(DateTime(2000, 1, 1, hour, minute));
  }

  @override
  Widget build(BuildContext context) {
    final locale = context.locale.toString();

    // services and branches resolve before the first slots request starts
    if (vm.loadingSlots || vm.isBusy || vm.loadingBranches) {
      return const _Loader();
    }

    String? message;
    if (vm.doctorOff) {
      // a distinct state from "no slots": the website conflates them
      message = LocaleKeys.booking_doctor_off.tr();
    } else if (vm.slots.isEmpty) {
      message = LocaleKeys.booking_no_slots.tr();
    }
    if (message != null) {
      return Text(
        message,
        style: AppTextStyles.cardSubtitle.copyWith(
          color: AppColors.inkSecondary,
        ),
      );
    }

    return Wrap(
      spacing: 8.rw,
      runSpacing: 8.rh,
      children: [
        for (final slot in vm.slots)
          _Chip(
            label: format(slot.startTime, locale),
            selected: vm.slot?.slot == slot.slot,
            enabled: slot.isBookable,
            onTap: () => vm.selectSlot(slot),
          ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.enabled = true,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      enabled: enabled,
      button: true,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          height: 40.rh,
          padding: EdgeInsetsDirectional.symmetric(horizontal: 16.rw),
          decoration: BoxDecoration(
            color: selected ? AppColors.redSelected6 : AppColors.white,
            borderRadius: BorderRadius.circular(100.r),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.hairline8,
            ),
          ),
          // a Row keeps the chip hugging its label inside a Wrap
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.filterChip.copyWith(
                  color: !enabled
                      ? AppColors.inkSecondary.withValues(alpha: 0.5)
                      : selected
                      ? AppColors.primary
                      : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Loader extends StatelessWidget {
  const _Loader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(vertical: 12.rh),
      child: Center(
        child: SizedBox(
          width: 20.r,
          height: 20.r,
          child: CircularProgressIndicator(
            strokeWidth: 2.r,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
