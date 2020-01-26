//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_KeepPodCount.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_KeepPodCount extends X2DownloadableContentInfo config(KeepPodCount);

`define KPG_Log(msg) `Log(`msg, default.EnableLogs, 'KeepPodCount')

var config(Engine) bool EnableLogs;

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


/*
static function PostEncounterCreation(out name EncounterName, out PodSpawnInfo Encounter, int ForceLevel, int AlertLevel, optional XComGameState_BaseObject SourceObject)
{
	local XComGameState_MissionSite Mission;

	Mission = XComGameState_MissionSite(SourceObject);

	`KPG_Log("Mission: " $ Mission.GeneratedMission.Mission.MissionName);
	`KPG_Log("MissionScheduleName: " $ Mission.SelectedMissionData.SelectedMissionScheduleName);
	`KPG_Log("EncounterName: " $ EncounterName);
	`KPG_Log("SelectedCharacterTemplateName: " $ Encounter.SelectedCharacterTemplateNames[0]);
}
*/

static event OnPostTemplatesCreated()
{
	`Log("Keep Pod Count loaded.", , 'KeepPodCount');
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
	local int i, Scan;

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
		Scan = MatchEncounter(MissionManager.MissionSchedules[i].PrePlacedEncounters);

		if(Scan != INDEX_NONE)
		{
			`KPG_Log("Adding" @ default.MissionScheduleModifier[Scan].AdditionalPrePlacedEncounter.EncounterID @ "Encounter to" @ MissionManager.MissionSchedules[i].ScheduleID);
			MissionManager.MissionSchedules[i].PrePlacedEncounters.AddItem(default.MissionScheduleModifier[Scan].AdditionalPrePlacedEncounter);
		}
	}
}

static function int MatchEncounter(const array<PrePlacedEncounterPair> PrePlacedEncounters)
{
	local int i, idx;

	idx = INDEX_NONE;

	for (i = 0; i < PrePlacedEncounters.Length; i++)
	{
		if(default.MissionScheduleModifier.Find('FindEncounterID', PrePlacedEncounters[i].EncounterID) != INDEX_NONE)
		{
			idx = default.MissionScheduleModifier.Find('FindEncounterID', PrePlacedEncounters[i].EncounterID);
		}

		if(PrePlacedEncounters[i].EncounterID == 'LIST_ChosenSelector_EmptyFallback')
		{
			return INDEX_NONE;
		}
	}

	return idx;
}