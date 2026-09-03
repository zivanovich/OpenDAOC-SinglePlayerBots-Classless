-- Classless DAoC prototype:
-- Give Viking and Skald access to Midgard Spear specialization,
-- give VikingCareer the spear weapon proficiency,
-- and give Skald the Hunter variant of the Spear style list.
--
-- This script is idempotent: running it multiple times should not
-- create duplicate records.

SAVEPOINT classless_spear_prototype;

-- 1. Make Spear trainable by Vikings at level 1.
INSERT INTO ClassXSpecialization
    (ClassID, SpecKeyName, LevelAcquired, LastTimeRowUpdated)
SELECT
    35, 'Spear', 1, '2000-01-01 00:00:00'
WHERE NOT EXISTS
(
    SELECT 1
    FROM ClassXSpecialization
    WHERE ClassID = 35
      AND SpecKeyName = 'Spear'
);

-- 2. Preserve Spear access after promotion from Viking to Skald.
INSERT INTO ClassXSpecialization
    (ClassID, SpecKeyName, LevelAcquired, LastTimeRowUpdated)
SELECT
    24, 'Spear', 1, '2000-01-01 00:00:00'
WHERE NOT EXISTS
(
    SELECT 1
    FROM ClassXSpecialization
    WHERE ClassID = 24
      AND SpecKeyName = 'Spear'
);

-- 3. Allow Vikings, and classes inheriting VikingCareer, to equip spears.
INSERT INTO SpecXAbility
    (Spec, SpecLevel, AbilityKey, AbilityLevel, ClassId, LastTimeRowUpdated)
SELECT
    'VikingCareer',
    1,
    'Weaponry: Spears',
    0,
    0,
    '2000-01-01 00:00:00'
WHERE NOT EXISTS
(
    SELECT 1
    FROM SpecXAbility
    WHERE Spec = 'VikingCareer'
      AND AbilityKey = 'Weaponry: Spears'
);

-- 4. Give Skalds the Hunter version of the Midgard Spear styles.
-- StyleID is deliberately omitted because it is auto-generated.
-- ID is retained because style chains refer to the DAoC style ID.

INSERT INTO Style
(
    ID,
    ClassId,
    Name,
    SpecKeyName,
    SpecLevelRequirement,
    Icon,
    EnduranceCost,
    StealthRequirement,
    OpeningRequirementType,
    OpeningRequirementValue,
    AttackResultRequirement,
    WeaponTypeRequirement,
    GrowthOffset,
    GrowthRate,
    BonusToHit,
    BonusToDefense,
    TwoHandAnimation,
    RandomProc,
    ArmorHitLocation,
    LastTimeRowUpdated
)
SELECT
    hunter.ID,
    24,
    hunter.Name,
    hunter.SpecKeyName,
    hunter.SpecLevelRequirement,
    hunter.Icon,
    hunter.EnduranceCost,
    hunter.StealthRequirement,
    hunter.OpeningRequirementType,
    hunter.OpeningRequirementValue,
    hunter.AttackResultRequirement,
    hunter.WeaponTypeRequirement,
    hunter.GrowthOffset,
    hunter.GrowthRate,
    hunter.BonusToHit,
    hunter.BonusToDefense,
    hunter.TwoHandAnimation,
    hunter.RandomProc,
    hunter.ArmorHitLocation,
    hunter.LastTimeRowUpdated
FROM Style AS hunter
WHERE hunter.SpecKeyName = 'Spear'
  AND hunter.ClassId = 25
  AND NOT EXISTS
  (
      SELECT 1
      FROM Style AS skald
      WHERE skald.SpecKeyName = hunter.SpecKeyName
        AND skald.ClassId = 24
        AND skald.ID = hunter.ID
  );

RELEASE SAVEPOINT classless_spear_prototype;

-- Verification results

SELECT ClassID, SpecKeyName, LevelAcquired
FROM ClassXSpecialization
WHERE SpecKeyName = 'Spear'
  AND ClassID IN (24, 35)
ORDER BY ClassID;

SELECT Spec, SpecLevel, AbilityKey, AbilityLevel
FROM SpecXAbility
WHERE Spec = 'VikingCareer'
  AND AbilityKey = 'Weaponry: Spears';

SELECT ID, ClassId, Name, SpecLevelRequirement
FROM Style
WHERE SpecKeyName = 'Spear'
  AND ClassId = 24
ORDER BY SpecLevelRequirement;