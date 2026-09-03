-- Classless DAoC prototype:
-- Give Skald access to Midgard Mending specialization,
-- and give Skald the Healer variant of the Mending spell list.
--
-- This script is idempotent: running it multiple times should not
-- create duplicate records.

SAVEPOINT classless_mending_prototype;

-- add base mending to the Skald class
INSERT INTO ClassXSpecialization
    (ClassID, SpecKeyName, LevelAcquired, LastTimeRowUpdated)
SELECT
    24, 'Mending', 1, '2000-01-01 00:00:00'
WHERE NOT EXISTS
(
    SELECT 1
    FROM ClassXSpecialization
    WHERE ClassID = 24
      AND SpecKeyName = 'Mending'
);

-- Create a Skald-specific copy of the Healer Mending spell line.
INSERT INTO SpellLine
(
    KeyName,
    Name,
    Spec,
    IsBaseLine,
    ClassIDHint,
    LastTimeRowUpdated
)
SELECT
    'Classless Healer Mending Spec',
    'Mending',
    'Mending',
    0,
    24,
    '2000-01-01 00:00:00'
WHERE NOT EXISTS
(
    SELECT 1
    FROM SpellLine
    WHERE KeyName = 'Classless Healer Mending Spec'
);

-- Attach copies of all Healer Mending specialized spells.
INSERT INTO LineXSpell
(
    LineName,
    SpellID,
    Level,
    LastTimeRowUpdated,
    LineXSpell_ID
)
SELECT
    'Classless Healer Mending Spec',
    healer.SpellID,
    healer.Level,
    healer.LastTimeRowUpdated,
    'Classless_Healer_Mending_' ||
        healer.SpellID || '_' || healer.Level
FROM LineXSpell AS healer
WHERE healer.LineName = 'Healer Mending Spec'
  AND NOT EXISTS
  (
      SELECT 1
      FROM LineXSpell AS classless
      WHERE classless.LineName =
                'Classless Healer Mending Spec'
        AND classless.SpellID = healer.SpellID
        AND classless.Level = healer.Level
  );

RELEASE SAVEPOINT classless_mending_prototype;

-- Verification results

SELECT ClassID, SpecKeyName, LevelAcquired
FROM ClassXSpecialization
WHERE ClassID = 24
  AND SpecKeyName = 'Mending';

SELECT KeyName, Name, Spec, IsBaseLine, ClassIDHint
FROM SpellLine
WHERE KeyName = 'Classless Healer Mending Spec';

SELECT LineName, SpellID, Level
FROM LineXSpell
WHERE LineName = 'Classless Healer Mending Spec'
ORDER BY Level;