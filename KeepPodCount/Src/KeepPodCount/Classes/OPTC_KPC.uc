class OPTC_KPC extends X2DownloadableContentInfo config(KeepPodCount);

`define KPG_Log(msg) `Log(`msg,, 'KeepPodCount')

struct AdditionalPod
{
	var name FindEncounterID;
	var PrePlacedEncounterPair AdditionalPrePlacedEncounter;
};

var config array<AdditionalPod> MissionScheduleModifier;
var config array<Name> ExcludedMissions;

static event OnPostTemplatesCreated()
{
	`KPG_Log("KeepPodCount loaded.");
	PatchMissionSchedules();
}

// We create new EncounterBuckets including replaced pod if Chosen/Ruler is active
// The mission must have Chosen/Ruler in the mission for the new Encounter to spawn
static function PatchMissionSchedules()
{
	local XComTacticalMissionManager MissionManager;
	local PrePlacedEncounterPair AdditionalEncounter;
	local int i, j, Scan;

	MissionManager = `TACTICALMISSIONMGR;

	// Cycle through MissionSchedules
	for(i = 0; i < MissionManager.MissionSchedules.Length; i++)
	{

		// Won't add Encounters if missions are in the exclusion list.
		if( default.ExcludedMissions.Find(MissionManager.MissionSchedules[i].ScheduleID) != INDEX_NONE )
		{
			`KPG_Log(MissionManager.MissionSchedules[i].ScheduleID @ "is restricted. Not adding additional encounter.");
			continue;
		}

		// Cycle through PrePlacedEncounters
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
