-- Classless DAoC prototype:
-- Give Classless Midgard characters who individually own Mending
-- the Healer variant of the specialized Mending spell line.
--
-- This does NOT add Mending to ClassXSpecialization. Ownership is
-- recorded individually in each character's SerializedSpecs.
--
-- This script is idempotent: running it multiple times should not
-- create duplicate records.

SAVEPOINT classless_midgard_mending_prototype;

-- Create a Classless Midgard-specific version of the
-- Healer specialized Mending spell line.
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
    'Classless Midgard Mending Spec',
    'Mending',
    'Mending',
    0,
    63,
    '2000-01-01 00:00:00'
WHERE NOT EXISTS
(
    SELECT 1
    FROM SpellLine
    WHERE KeyName = 'Classless Midgard Mending Spec'
);

-- Copy every specialized Healer Mending spell into
-- the Classless Midgard spell line.
INSERT INTO LineXSpell
(
    LineName,
    SpellID,
    Level,
    LastTimeRowUpdated,
    LineXSpell_ID
)
SELECT
    'Classless Midgard Mending Spec',
    healer.SpellID,
    healer.Level,
    healer.LastTimeRowUpdated,
    'Classless_Midgard_Mending_' ||
        healer.SpellID || '_' || healer.Level
FROM LineXSpell AS healer
WHERE healer.LineName = 'Healer Mending Spec'
  AND NOT EXISTS
  (
      SELECT 1
      FROM LineXSpell AS classless
      WHERE classless.LineName =
                'Classless Midgard Mending Spec'
        AND classless.SpellID = healer.SpellID
        AND classless.Level = healer.Level
  );

RELEASE SAVEPOINT classless_midgard_mending_prototype;

-- Verification: one Classless-specific spell line should appear.
SELECT
    KeyName,
    Name,
    Spec,
    IsBaseLine,
    ClassIDHint
FROM SpellLine
WHERE KeyName = 'Classless Midgard Mending Spec';

-- Verification: compare copied spell counts.
SELECT
    LineName,
    COUNT(*) AS SpellCount
FROM LineXSpell
WHERE LineName IN
(
    'Healer Mending Spec',
    'Classless Midgard Mending Spec'
)
GROUP BY LineName;