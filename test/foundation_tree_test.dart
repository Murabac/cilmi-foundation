import 'package:flutter_test/flutter_test.dart';

import 'package:reer_sh_yoonis/models/lineage_tree.dart';
import 'package:reer_sh_yoonis/models/models.dart';
import 'package:reer_sh_yoonis/utils/branch_filter.dart';
import 'package:reer_sh_yoonis/utils/lineage_name.dart';
import 'package:reer_sh_yoonis/utils/patriarch_resolver.dart';
import 'package:reer_sh_yoonis/utils/tree_list_display.dart';

Profile _p(
  String id,
  String name, {
  String? fatherId,
  Demographic demographic = Demographic.adult,
}) =>
    Profile(
      id: id,
      fullName: name,
      role: UserRole.familyMember,
      demographic: demographic,
      careRating: 2,
      fatherId: fatherId,
    );

void main() {
  final cilmiProfiles = [
    _p('cilmi', 'CILMI'),
    _p('ahmed', 'AHMED', fatherId: 'cilmi'),
    _p('sheekh', 'SHEEKH YONIS', fatherId: 'ahmed'),
    _p('aadan', 'AADAN', fatherId: 'ahmed'),
    _p('mire', 'MIRE', fatherId: 'sheekh'),
    _p('hodan', 'HODAN', fatherId: 'mire'),
    _p('amiin', 'AMIIN', fatherId: 'hodan'),
    _p('khadra', 'KHADRA SHEEKH', fatherId: 'sheekh'),
    _p('saynab', 'SAYNAB ISMAIL', fatherId: 'khadra'),
    _p('mohamed', 'MOHAMED', fatherId: 'aadan'),
  ];

  test('foundationBranchNodes unwraps Ahmed to Sheekh + Aadan', () {
    final tree = buildLineageTree(cilmiProfiles)!;
    final branches = foundationBranchNodes(tree);
    expect(branches.map((b) => b.profile.id).toSet(), {'sheekh', 'aadan'});
  });

  test('splitFoundationBranches hoists Sheekh daughters and keeps Ahmed', () {
    final tree = buildLineageTree(cilmiProfiles)!;
    final split = splitFoundationBranches(tree);
    expect(split.sons, hasLength(1));
    expect(split.sons.first.profile.id, 'ahmed');
    expect(
      split.sons.first.children.map((c) => c.profile.id).toSet(),
      {'sheekh', 'aadan'},
    );
    expect(split.daughters.map((d) => d.profile.id), ['khadra']);
    // Display clone: Sheekh sons only (daughter hoisted).
    final sheekh = split.sons.first.children
        .firstWhere((c) => c.profile.id == 'sheekh');
    expect(sheekh.children.map((c) => c.profile.id), ['mire']);
  });

  test('BranchFilterIndex lists Sheekh and Aadan', () {
    final index = BranchFilterIndex.fromProfiles(cilmiProfiles);
    expect(index.branches.map((b) => b.id).toSet(), {'sheekh', 'aadan'});
  });

  test('subBranchesOf returns kids of selected branch', () {
    final index = BranchFilterIndex.fromProfiles(cilmiProfiles);
    expect(
      index.subBranchesOf('sheekh').map((p) => p.id).toSet(),
      {'mire'},
    );
    expect(
      index.subBranchesOf('aadan').map((p) => p.id).toSet(),
      {'mohamed'},
    );
  });

  test('fathersWithChildren lists direct kids before deeper parents', () {
    final profiles = [
      ...cilmiProfiles,
      // Unmarried / childless son of Mire — still findable in the filter.
      _p('cabdi', 'CABDI', fatherId: 'mire'),
      // Grandchild of Mire who has their own child (deeper parent).
      _p('faarax', 'FAARAX', fatherId: 'amiin'),
    ];
    final index = BranchFilterIndex.fromProfiles(profiles);
    final options = index.fathersWithChildren(branchId: 'mire');
    final ids = options.map((p) => p.id).toList();

    // Direct kids of Mire first (hodan + cabdi), then deeper parents (amiin).
    expect(ids.indexOf('hodan'), lessThan(ids.indexOf('amiin')));
    expect(ids.indexOf('cabdi'), lessThan(ids.indexOf('amiin')));
    expect(ids, containsAll(['hodan', 'cabdi', 'amiin']));
  });

  test('sortByGeneration puts closer relatives first', () {
    final index = BranchFilterIndex.fromProfiles(cilmiProfiles);
    final underMire = index
        .filterByBranch(
          cilmiProfiles,
          'mire',
          profileId: (p) => p.id,
        )
        .toList();
    index.sortByGeneration(underMire, 'mire');
    final ids = underMire.map((p) => p.id).toList();
    expect(ids.first, 'mire');
    expect(ids.indexOf('hodan'), lessThan(ids.indexOf('amiin')));
  });

  test('findSheekhYonisProfile prefers the profile with more children', () {
    final profiles = [
      _p('fake', 'SHEEKH YONIS EXTRA'),
      _p('real', 'SHEEKH YONIS'),
      _p('son', 'MIRE', fatherId: 'real'),
    ];
    expect(findSheekhYonisProfile(profiles)?.id, 'real');
  });

  test('showsAsLeafChip covers kids, daughter kids, and depth>=2', () {
    final hodan = TreeNode(profile: _p('hodan', 'HODAN'), children: const []);
    final amiin = TreeNode(profile: _p('amiin', 'AMIIN'), children: const []);
    final childDemo = TreeNode(
      profile: _p('kid', 'LITTLE', demographic: Demographic.child),
      children: const [],
    );
    final saynab = TreeNode(
      profile: _p('saynab', 'SAYNAB ISMAIL'),
      children: const [],
    );
    final mireLeaf = TreeNode(
      profile: _p('single', 'UNMARRIED UNCLE'),
      children: const [],
    );

    expect(showsAsLeafChip(amiin, 2, parent: hodan.profile), isTrue);
    expect(showsAsLeafChip(childDemo, 0), isTrue);
    expect(
      showsAsLeafChip(saynab, 0, parent: _p('khadra', 'KHADRA SHEEKH')),
      isTrue,
    );
    // Unmarried adult under Sheekh (depth 0) is a row, not a chip.
    expect(showsAsLeafChip(mireLeaf, 0, parent: _p('sheekh', 'SHEEKH YONIS')),
        isFalse);
    // Unmarried adult sibling of Hodan (depth 1) is a row.
    expect(showsAsLeafChip(mireLeaf, 1, parent: _p('mire', 'MIRE')), isFalse);
  });

  test('canSelectAsFatherForNewMember allows through Sheekh great-grandsons', () {
    final byId = {for (final p in cilmiProfiles) p.id: p};
    expect(
      canSelectAsFatherForNewMember(byId['hodan']!, byId, 'cilmi'),
      isTrue,
    );
    // Amiin is Sheekh great-grandson (depth 5 from Cilmi) — still eligible.
    expect(
      canSelectAsFatherForNewMember(byId['amiin']!, byId, 'cilmi'),
      isTrue,
    );
    final tooYoung = _p('baby', 'BABY', fatherId: 'amiin');
    final withBaby = {...byId, tooYoung.id: tooYoung};
    expect(
      canSelectAsFatherForNewMember(tooYoung, withBaby, 'cilmi'),
      isFalse,
    );
  });
}
