import '../../data/constants/locale_keys.g.dart';

enum StaticBlockType { heading, body, bullet }

class StaticBlock {
  const StaticBlock(this.type, this.key);

  final StaticBlockType type;
  final String key;
}

/// the site's static pages, in reading order. the copy itself lives in the
/// translation files; this only says how each line is styled.
const List<StaticBlock> aboutBlocks = [
  StaticBlock(StaticBlockType.body, LocaleKeys.about_page_l01),
  StaticBlock(StaticBlockType.body, LocaleKeys.about_page_l02),
  StaticBlock(StaticBlockType.bullet, LocaleKeys.about_page_l03),
  StaticBlock(StaticBlockType.bullet, LocaleKeys.about_page_l04),
  StaticBlock(StaticBlockType.bullet, LocaleKeys.about_page_l05),
  StaticBlock(StaticBlockType.bullet, LocaleKeys.about_page_l06),
  StaticBlock(StaticBlockType.bullet, LocaleKeys.about_page_l07),
  StaticBlock(StaticBlockType.bullet, LocaleKeys.about_page_l08),
  StaticBlock(StaticBlockType.bullet, LocaleKeys.about_page_l09),
  StaticBlock(StaticBlockType.bullet, LocaleKeys.about_page_l10),
  StaticBlock(StaticBlockType.bullet, LocaleKeys.about_page_l11),
  StaticBlock(StaticBlockType.bullet, LocaleKeys.about_page_l12),
  StaticBlock(StaticBlockType.bullet, LocaleKeys.about_page_l13),
  StaticBlock(StaticBlockType.heading, LocaleKeys.about_page_l14),
  StaticBlock(StaticBlockType.body, LocaleKeys.about_page_l15),
  StaticBlock(StaticBlockType.heading, LocaleKeys.about_page_l16),
  StaticBlock(StaticBlockType.body, LocaleKeys.about_page_l17),
  StaticBlock(StaticBlockType.heading, LocaleKeys.about_page_l18),
  StaticBlock(StaticBlockType.bullet, LocaleKeys.about_page_l19),
  StaticBlock(StaticBlockType.bullet, LocaleKeys.about_page_l20),
  StaticBlock(StaticBlockType.bullet, LocaleKeys.about_page_l21),
  StaticBlock(StaticBlockType.bullet, LocaleKeys.about_page_l22),
  StaticBlock(StaticBlockType.bullet, LocaleKeys.about_page_l23),
];

const List<StaticBlock> privacyBlocks = [
  StaticBlock(StaticBlockType.body, LocaleKeys.privacy_page_l01),
  StaticBlock(StaticBlockType.body, LocaleKeys.privacy_page_l02),
  StaticBlock(StaticBlockType.body, LocaleKeys.privacy_page_l03),
  StaticBlock(StaticBlockType.body, LocaleKeys.privacy_page_l04),
  StaticBlock(StaticBlockType.body, LocaleKeys.privacy_page_l05),
  StaticBlock(StaticBlockType.body, LocaleKeys.privacy_page_l06),
  StaticBlock(StaticBlockType.body, LocaleKeys.privacy_page_l07),
  StaticBlock(StaticBlockType.body, LocaleKeys.privacy_page_l08),
  StaticBlock(StaticBlockType.body, LocaleKeys.privacy_page_l09),
  StaticBlock(StaticBlockType.body, LocaleKeys.privacy_page_l10),
];

const List<StaticBlock> termsBlocks = [
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l01),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l02),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l03),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l04),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l05),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l06),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l07),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l08),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l09),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l10),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l11),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l12),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l13),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l14),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l15),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l16),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l17),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l18),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l19),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l20),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l21),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l22),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l23),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l24),
  StaticBlock(StaticBlockType.body, LocaleKeys.terms_page_l25),
];
