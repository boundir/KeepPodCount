class OPTC_KPC extends X2DownloadableContentInfo config(KeepPodCount);

`define KPG_Log(msg) `Log(`msg,, 'KeepPodCount')

struct KeepPodEncounters
{
	var Name BucketID;
	var array<Name> EncounterID;
};

struct AdditionalPod
{
	var name FindEncounterID;
	var PrePlacedEncounterPair AdditionalPrePlacedEncounter;
};

var config array<KeepPodEncounters> RulerEncounters;
var config array<AdditionalPod> MissionScheduleModifier;
var config array<Name> ExcludedMissions;

static event OnPostTemplatesCreated()
{
	`KPG_Log("KeepPodCount loaded.");
	PatchRulerBuckets();
	PatchMissionSchedules();
}


static function PatchRulerBuckets()
{
	local AlienRulerData AlienRuler;
	local KeepPodEncounters RulerEncounter;
	local ConditionalEncounter Encounter;
	local XComTacticalMissionManager MissionManager;
	local int i, pos;
	
	MissionManager = `TACTICALMISSIONMGR;

	foreach default.RulerEncounters(RulerEncounter)
	{
		foreach class'XComGameState_AlienRulerManager'.default.AlienRulerTemplates(AlienRuler)
		{
			pos = INDEX_NONE;
			pos = MissionManager.EncounterBuckets.Find('EncounterBucketID', RulerEncounter.BucketID);
			if(pos != INDEX_NONE)
			{
				for(i = 0; i < RulerEncounter.EncounterID.Length; i++)
				{
					Encounter.EncounterID = RulerEncounter.EncounterID[i];
					Encounter.IncludeTacticalTag = AlienRuler.ActiveTacticalTag;
					Encounter.ExcludeTacticalTag = AlienRuler.DeadTacticalTag;

					MissionManager.EncounterBuckets[pos].EncounterIDs.AddItem(Encounter);
					`KPG_Log("Inserted " $ Encounter.EncounterID $ " into bucket " $ MissionManager.EncounterBuckets[pos].EncounterBucketID);
				}
			}
		}
	}
}

// We create new EncounterBuckets including replaced pod if Chosen/Ruler is active
// The mission must have Chosen/Ruler in the mission for the new Encounter to spawn
static function PatchMissionSchedules()
{
	local XComTacticalMissionManager MissionManager;
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
	// Verify();
}

static function Verify()
{
	local XComTacticalMissionManager MissionManager;
	local int i, j;

	MissionManager = `TACTICALMISSIONMGR;

	for(i = 0; i < MissionManager.MissionSchedules.Length; i++)
	{
		`KPG_Log("ScheduleID : " $ MissionManager.MissionSchedules[i].ScheduleID);
		for(j = 0; j < MissionManager.MissionSchedules[i].PrePlacedEncounters.Length; j++)
		{
			`KPG_Log("EncounterID : " $ MissionManager.MissionSchedules[i].PrePlacedEncounters[j].EncounterID);
		}
	}

	for (i = 0; i < MissionManager.EncounterBuckets.Length; i++)
	{
		`KPG_Log("EncounterBucketID : " $ MissionManager.EncounterBuckets[i].EncounterBucketID);
		for (j = 0; j < MissionManager.EncounterBuckets[i].EncounterIDs.Length; j++)
		{
			`KPG_Log("Bucket EncounterID : " $ MissionManager.EncounterBuckets[i].EncounterIDs[j].EncounterID);
			if(MissionManager.EncounterBuckets[i].EncounterIDs[j].IncludeTacticalTag != '')
			{
				`KPG_Log("IncludeTacticalTag : " $ MissionManager.EncounterBuckets[i].EncounterIDs[j].IncludeTacticalTag);
			}
			if(MissionManager.EncounterBuckets[i].EncounterIDs[j].ExcludeTacticalTag != '')
			{
				`KPG_Log("ExcludeTacticalTag : " $ MissionManager.EncounterBuckets[i].EncounterIDs[j].ExcludeTacticalTag);
			}
		}
	}
}
