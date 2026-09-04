-- Classless DAoC prototype:
-- Give Classless Midgard characters who individually own Sword
-- the Warrior version of the Midgard Sword style list.
--
-- This does not automatically grant the Sword specialization or
-- Weaponry: Swords ability.
--
-- This script is idempotent: running it multiple times should not
-- create duplicate records.

SAVEPOINT classless_sword_prototype;

-- Copy Warrior Sword styles from ClassID 22 to
-- Classless Midgard ClassID 63.
--
-- StyleID is omitted because it is auto-generated.
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
    warrior.ID,
    63,
    warrior.Name,
    warrior.SpecKeyName,
    warrior.SpecLevelRequirement,
    warrior.Icon,
    warrior.EnduranceCost,
    warrior.StealthRequirement,
    warrior.OpeningRequirementType,
    warrior.OpeningRequirementValue,
    warrior.AttackResultRequirement,
    warrior.WeaponTypeRequirement,
    warrior.GrowthOffset,
    warrior.GrowthRate,
    warrior.BonusToHit,
    warrior.BonusToDefense,
    warrior.TwoHandAnimation,
    warrior.RandomProc,
    warrior.ArmorHitLocation,
    warrior.LastTimeRowUpdated
FROM Style AS warrior
WHERE warrior.SpecKeyName = 'Sword'
  AND warrior.ClassId = 22
  AND NOT EXISTS
  (
      SELECT 1
      FROM Style AS classless
      WHERE classless.SpecKeyName = warrior.SpecKeyName
        AND classless.ClassId = 63
        AND classless.ID = warrior.ID
  );

RELEASE SAVEPOINT classless_sword_prototype;

-- Verification: source and destination counts should match.
SELECT
    ClassId,
    COUNT(*) AS StyleCount
FROM Style
WHERE SpecKeyName = 'Sword'
  AND ClassId IN (22, 63)
GROUP BY ClassId
ORDER BY ClassId;

-- Verification: show the resulting Classless Sword progression.
SELECT
    ID,
    ClassId,
    Name,
    SpecLevelRequirement,
    OpeningRequirementType,
    OpeningRequirementValue,
    AttackResultRequirement,
    WeaponTypeRequirement
FROM Style
WHERE SpecKeyName = 'Sword'
  AND ClassId = 63
ORDER BY SpecLevelRequirement, ID;