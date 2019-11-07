class OPTC_KPC extends X2DownloadableContentInfo config(KeepPodCount);

`define KPG_Log(msg) `Log(`msg,, 'KeepPodCount')

struct AdditionalPod
{
	var name FindEncounterID;
	var PrePlacedEncounterPair AdditionalPrePlacedEncounter;
};

var config PrePlacedEncounterPair ChosenPrePlacedEncounter;
var config PrePlacedEncounterPair RulerPrePlacedEncounter;
var config array<AdditionalPod> MissionScheduleModifier;

static event OnPostTemplatesCreated()
{
	`KPG_Log("KeepPodCount loaded.");
	// FirstMethod();
	SecondMethod();
}

// We extract Chosen and Rulers from EncounterBuckets
// We create a new one for the Rulers "LIST_RulerSelector"
// The Chosen one is "LIST_ChosenSelector_EmptyFallback"
// In every Sheduled missions where we find the modified EncounterBuckets we will add their respective Chosen/Rulers EncounterBucket
static function FirstMethod()
{
	local XComTacticalMissionManager MissionManager;
	local int i, j;

	local array<Name> CommonEncounters, ChosenEcounters, RulerEcounters, RestrictedChosen, RestrictedRuler;
	local bool AddChosen, AddRuler;
	local bool ChosenEncounterFound, RulerEncounterFound;

	// List of Encounters where we removed Chosen and Ruler lists
	CommonEncounters.AddItem('LIST_BOSSx2_Standard_Chosen');
	CommonEncounters.AddItem('LIST_BOSSx3_Standard_Chosen');
	CommonEncounters.AddItem('LIST_BOSSx4_Standard_Chosen');
	CommonEncounters.AddItem('LIST_OPNx2_Special_Chosen');
	CommonEncounters.AddItem('LIST_OPNx3_Special_Chosen');
	CommonEncounters.AddItem('LIST_OPNx4_Special_Chosen');

	// Unused Encounters where we removed Chosen list
	ChosenEcounters.AddItem('LIST_OPNTERx2_Special_Chosen');
	ChosenEcounters.AddItem('LIST_OPNTERx3_Special_Chosen');
	ChosenEcounters.AddItem('LIST_OPNTERx4_Special_Chosen');

	// List of Encounters where we removed Ruler list
	RulerEcounters.AddItem('LIST_OPNx2_Special');
	RulerEcounters.AddItem('LIST_OPNx3_Special');
	RulerEcounters.AddItem('LIST_OPNx4_Special');
	RulerEcounters.AddItem('LIST_BOSSx2_Standard');
	RulerEcounters.AddItem('LIST_BOSSx3_Standard');
	RulerEcounters.AddItem('LIST_BOSSx4_Standard');
	RulerEcounters.AddItem('LIST_BOSSx2_Expanded');
	RulerEcounters.AddItem('LIST_BOSSx3_Expanded');
	RulerEcounters.AddItem('LIST_BOSSx4_Expanded');

	// Should not add if Encounters already exist
	RestrictedChosen.AddItem('LIST_ChosenSelector_EmptyFallback');
	RestrictedRuler.AddItem('LIST_RulerSelector');

	MissionManager = `TACTICALMISSIONMGR;

	for(i = 0; i < MissionManager.MissionSchedules.Length; i++)
	{
		ChosenEncounterFound = false;
		RulerEncounterFound = false;
		AddChosen = false;
		AddRuler = false;

		for(j = 0; j < MissionManager.MissionSchedules[i].PrePlacedEncounters.Length; j++)
		{
			// If Chosen Encounter is found no need to add it again.
			if( RestrictedChosen.Find(MissionManager.MissionSchedules[i].PrePlacedEncounters[j].EncounterID) != INDEX_NONE )
			{
				// `KPG_Log(MissionManager.MissionSchedules[i].PrePlacedEncounters[j].EncounterID @ "already in" @ MissionManager.MissionSchedules[i].ScheduleID);
				ChosenEncounterFound = true;
			}

			// Should not happen since we just created it and never added it
			else if( RestrictedRuler.Find(MissionManager.MissionSchedules[i].PrePlacedEncounters[j].EncounterID) != INDEX_NONE )
			{
				// `KPG_Log(MissionManager.MissionSchedules[i].PrePlacedEncounters[j].EncounterID @ "already in" @ MissionManager.MissionSchedules[i].ScheduleID);
				RulerEncounterFound = true;
			}

			// Should not happen either. You never know
			if(RulerEncounterFound && ChosenEncounterFound)
			{
				`KPG_Log("No need to add encounters in" @ MissionManager.MissionSchedules[i].ScheduleID);
				break; // Should switch to next Schedule
			}

			else
			{
				if( CommonEncounters.Find(MissionManager.MissionSchedules[i].PrePlacedEncounters[j].EncounterID) != INDEX_NONE )
				{
					// `KPG_Log(MissionManager.MissionSchedules[i].PrePlacedEncounters[j].EncounterID @ "found in" @ MissionManager.MissionSchedules[i].ScheduleID);
					AddChosen = true;
					AddRuler = true;
				}
				else
				{
					if( !ChosenEncounterFound && ChosenEcounters.Find(MissionManager.MissionSchedules[i].PrePlacedEncounters[j].EncounterID) != INDEX_NONE )
					{
						// `KPG_Log(MissionManager.MissionSchedules[i].PrePlacedEncounters[j].EncounterID @ "found in" @ MissionManager.MissionSchedules[i].ScheduleID);
						AddChosen = true;
					}

					if( !RulerEncounterFound && RulerEcounters.Find(MissionManager.MissionSchedules[i].PrePlacedEncounters[j].EncounterID) != INDEX_NONE )
					{
						// `KPG_Log(MissionManager.MissionSchedules[i].PrePlacedEncounters[j].EncounterID @ "found in" @ MissionManager.MissionSchedules[i].ScheduleID);
						AddRuler = true;
					}
				}
			}
		}

		if(AddChosen && !ChosenEncounterFound)
		{
			`KPG_Log("Adding" @ default.ChosenPrePlacedEncounter.EncounterID @ "Encounter to" @ MissionManager.MissionSchedules[i].ScheduleID);
			MissionManager.MissionSchedules[i].PrePlacedEncounters.AddItem(default.ChosenPrePlacedEncounter);
		}

		if(AddRuler && !RulerEncounterFound)
		{
			`KPG_Log("Adding" @ default.RulerPrePlacedEncounter.EncounterID @ "Encounter to" @ MissionManager.MissionSchedules[i].ScheduleID);
			MissionManager.MissionSchedules[i].PrePlacedEncounters.AddItem(default.RulerPrePlacedEncounter);
		}
	}
}


// We create new EncounterBuckets including replaced pod if Chosen/Ruler is active
// The mission must have Chosen/Ruler in the mission for the new Encounter to spawn
static function SecondMethod()
{
	local XComTacticalMissionManager MissionManager;
	local int i, j, Scan;

	MissionManager = `TACTICALMISSIONMGR;

	// Looping through MissionSchedules
	for(i = 0; i < MissionManager.MissionSchedules.Length; i++)
	{
		// Looping through PrePlacedEncounters
		for(j = 0; j < MissionManager.MissionSchedules[i].PrePlacedEncounters.Length; j++)
		{
			Scan = default.MissionScheduleModifier.Find('FindEncounterID', MissionManager.MissionSchedules[i].PrePlacedEncounters[j].EncounterID);

			if(Scan != INDEX_NONE)
			{
				`KPG_Log("Adding" @ default.MissionScheduleModifier[Scan].AdditionalPrePlacedEncounter.EncounterID @ "Encounter to" @ MissionManager.MissionSchedules[i].ScheduleID);
				MissionManager.MissionSchedules[i].PrePlacedEncounters.AddItem(default.MissionScheduleModifier[Scan].AdditionalPrePlacedEncounter);
			}
		}
	}
}
