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
import '../../widgets/booking/booking_widgets.dart';
import '../../widgets/common/bottom_action_bar.dart';
import '../../widgets/doctor/doctor_profile_card.dart';
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
                  8.rh,
                  16.rw,
                  16.rh,
                ),
                children: [
                  DoctorProfileCard(
                    doctor: vm.doctor,
                    name: vm.doctor.names.display(language),
                  ),
                  SizedBox(height: 4.rh),
                  BookingSection(
                    title: LocaleKeys.booking_choose_service.tr(),
                    child: _TreatmentRow(vm: vm, language: language),
                  ),
                  SizedBox(height: 4.rh),
                  BookingSection(
                    title: LocaleKeys.booking_choose_branch.tr(),
                    child: _BranchRow(vm: vm, language: language),
                  ),
                  SizedBox(height: 4.rh),
                  BookingSection(
                    title: LocaleKeys.booking_choose_date.tr(),
                    child: _DatePicker(vm: vm),
                  ),
                  SizedBox(height: 4.rh),
                  BookingSection(
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

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.icon,
    this.subtitle,
    this.width,
  });

  final String label;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;
  final Widget icon;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          constraints: width == null
              ? BoxConstraints(minWidth: 148.rw, maxWidth: 248.rw)
              : null,
          height: 116.rh,
          padding: EdgeInsetsDirectional.fromSTEB(16.rw, 12.rh, 16.rw, 0),
          decoration: BoxDecoration(
            color: selected ? const Color(0x0ACC1C1C) : AppColors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: selected
                  ? AppColors.primary.withValues(alpha: 0.12)
                  : AppColors.cardBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36.rw,
                height: 36.rw,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected
                      ? const Color(0x0FCC1C1C)
                      : const Color(0x0F797777),
                  borderRadius: BorderRadius.circular(selected ? 14.r : 12.r),
                ),
                child: icon,
              ),
              SizedBox(height: 14.rh),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.sectionTitle.copyWith(
                  color: AppColors.ink,
                  fontSize: 16.rf,
                  height: 18 / 16,
                ),
              ),
              if ((subtitle ?? '').isNotEmpty) ...[
                SizedBox(height: 2.rh),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.branchAddress.copyWith(
                    color: AppColors.inkSecondary,
                    fontWeight: FontWeight.w400,
                    height: 18 / 14,
                  ),
                ),
              ],
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
      padding: EdgeInsetsDirectional.symmetric(horizontal: 12.rw),
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
            SizedBox(width: 8.rw),
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
      padding: EdgeInsetsDirectional.symmetric(horizontal: 12.rw),
      child: Row(
        children: [
          for (final branch in vm.branches) ...[
            _OptionCard(
              width: 248.rw,
              label: branch.names.display(language),
              subtitle: branch.address,
              selected: vm.branchId == branch.id,
              onTap: () => vm.selectBranch(branch.id),
              icon: SvgPicture.asset(
                vm.branchId == branch.id
                    ? AppAssets.iconUserPinRed
                    : AppAssets.iconUserPinDark,
                width: 18.rw,
                height: 18.rw,
              ),
            ),
            SizedBox(width: 8.rw),
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
        if (months.length > 1) ...[
          Padding(
            padding: EdgeInsetsDirectional.symmetric(horizontal: 16.rw),
            child: Wrap(
              spacing: 8.rw,
              children: [
                for (final month in months)
                  _MonthChip(
                    label: DateFormat.MMMM(
                      locale,
                    ).format(vm.dates.firstWhere((d) => d.month == month)),
                    selected: month == selectedMonth,
                    onTap: () => vm.selectDate(
                      vm.dates.firstWhere((d) => d.month == month),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 10.rh),
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsetsDirectional.symmetric(horizontal: 16.rw),
          child: Row(
            children: [
              for (var i = 0; i < days.length; i++) ...[
                if (i > 0) SizedBox(width: 12.rw),
                BookingDayChip(
                  date: days[i],
                  locale: locale,
                  selected:
                      vm.date?.day == days[i].day &&
                      vm.date?.month == days[i].month,
                  onTap: () => vm.selectDate(days[i]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// month switcher pill above the day tiles (the site has it; Figma shows the
/// days straight through)
class _MonthChip extends StatelessWidget {
  const _MonthChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
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
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: 14.rw,
            vertical: 5.5.rh,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.redSelected6 : AppColors.white,
            borderRadius: BorderRadius.circular(100.r),
            border: Border.all(
              color: selected ? AppColors.primary : bookingHairline,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTextStyles.profileBody.copyWith(
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
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

    // three equal columns, 10 apart, inside a 16 inset
    return Padding(
      padding: EdgeInsetsDirectional.symmetric(horizontal: 16.rw),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final chipWidth = (constraints.maxWidth - 20.rw) / 3;
          return Wrap(
            spacing: 10.rw,
            runSpacing: 10.rh,
            children: [
              for (final slot in vm.slots)
                SizedBox(
                  width: chipWidth,
                  child: BookingTimeChip(
                    label: format(slot.startTime, locale),
                    selected: vm.slot?.slot == slot.slot,
                    enabled: slot.isBookable,
                    onTap: () => vm.selectSlot(slot),
                  ),
                ),
            ],
          );
        },
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
