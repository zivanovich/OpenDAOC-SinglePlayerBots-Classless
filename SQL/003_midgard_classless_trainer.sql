-- Classless DAoC prototype:
-- Change a trainer to ClasslessMidgard trainer,
--
-- This script is idempotent: running it multiple times should not
-- create duplicate records.

SAVEPOINT classless_trainer_prototype;

-- Assign Saeunn to the Classless Midgard trainer script.

UPDATE Mob
SET Guild = 'Classless Midgard Trainer'
WHERE Mob_ID = 'd0cfb7f0-fb44-4307-bbc7-e55724b4b1dd'
AND (
    Guild IS NULL
    OR Guild <> 'Classless Midgard Trainer'
);

RELEASE SAVEPOINT classless_trainer_prototype;

-- Verification results
SELECT Mob_ID, Name, Guild, Region, X, Y, Z
FROM Mob
WHERE Mob_ID = 'd0cfb7f0-fb44-4307-bbc7-e55724b4b1dd';
