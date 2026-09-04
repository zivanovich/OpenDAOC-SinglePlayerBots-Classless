using System;
using System.Collections.Generic;
using System.Text;
using DOL.Database;
using DOL.GS.PacketHandler;
using DOL.Language;

namespace DOL.GS.Trainer
{
    [NPCGuildScript("Classless Midgard Trainer", eRealm.Midgard)]		// this attribute instructs DOL to use this script for all "Classless Midgard Trainer" NPC's in Midgard (multiple guilds are possible for one script)
    public class ClasslessMidgardTrainer : GameTrainer
    {
        public override eCharacterClass TrainedClass
        {
            get { return eCharacterClass.ClasslessMidgard; }
        }

        public ClasslessMidgardTrainer() : base(eChampionTrainerType.None)
        {
        }
    }
}