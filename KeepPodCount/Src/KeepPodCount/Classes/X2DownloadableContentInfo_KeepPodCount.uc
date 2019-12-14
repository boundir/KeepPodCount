//---------------------------------------------------------------------------------------
//  FILE:   XComDownloadableContentInfo_KeepPodCount.uc                                    
//           
//	Use the X2DownloadableContentInfo class to specify unique mod behavior when the 
//  player creates a new campaign or loads a saved game.
//  
//---------------------------------------------------------------------------------------
//  Copyright (c) 2016 Firaxis Games, Inc. All rights reserved.
//---------------------------------------------------------------------------------------

class X2DownloadableContentInfo_KeepPodCount extends X2DownloadableContentInfo;

`define KPG_Log(msg) `Log(`msg,, 'KeepPodCount')

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