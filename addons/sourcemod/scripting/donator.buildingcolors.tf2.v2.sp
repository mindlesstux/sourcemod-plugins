#include <sourcemod>
#include <clientprefs>
#include <sdktools>
#include <donator>

#undef REQUIRE_PLUGIN
#include <updater>

#define UPDATE_URL    "http://teamplayfirst.com/sourcemod-plugins/buildingcolors.tf2/updatefile.txt"

#pragma semicolon 1

#define PLUGIN_VERSION	"b13"

new Handle:g_RedColorCookie = INVALID_HANDLE;
new Handle:g_BlueColorCookie = INVALID_HANDLE;

new Handle:g_CustomColorCookieR = INVALID_HANDLE;
new Handle:g_CustomColorCookieG = INVALID_HANDLE;
new Handle:g_CustomColorCookieB = INVALID_HANDLE;
new Handle:g_CustomColorCookieA = INVALID_HANDLE;

new g_red_Color[MAXPLAYERS + 1];
new g_blue_Color[MAXPLAYERS + 1];

new g_CustomColorR[MAXPLAYERS + 1];
new g_CustomColorG[MAXPLAYERS + 1];
new g_CustomColorB[MAXPLAYERS + 1];
new g_CustomColorA[MAXPLAYERS + 1];

public Plugin:myinfo = 
{
	name = "[TPF] Donator - Engineer Building Colors",
	author = "mindlesstux",
	description = "Donator Feature: Color your Engineer Buildings",
	version = PLUGIN_VERSION,
	url = "http://www.teamplayfirst.com/source-plugins.php"
}

public OnPluginStart()
{
	CreateConVar("basicdonator_buildingcolor", PLUGIN_VERSION, "Donator Feature: Color Engineer Buildings", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY);

	// Store custom building colors
	g_RedColorCookie = RegClientCookie("donator_redbuildingcolor", "Color for red engie buildings", CookieAccess_Protected);
	g_BlueColorCookie = RegClientCookie("donator_bluebuildingcolor", "Color for blue engie buildings", CookieAccess_Protected);

	g_CustomColorCookieR = RegClientCookie("donator_buildingcustomcolorR", "Custom Color R", CookieAccess_Protected);
	g_CustomColorCookieG = RegClientCookie("donator_buildingcustomcolorG", "Custom Color G", CookieAccess_Protected);
	g_CustomColorCookieB = RegClientCookie("donator_buildingcustomcolorB", "Custom Color B", CookieAccess_Protected);
	g_CustomColorCookieA = RegClientCookie("donator_buildingcustomcolorA", "Custom Color A", CookieAccess_Protected);

	HookEvent("player_builtobject", Event_BuiltObject);

	if (LibraryExists("updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
}

public OnLibraryAdded(const String:name[])
{
    if (StrEqual(name, "updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
}

public OnPluginEnd() 
{ 
    new iEntity = INVALID_ENT_REFERENCE; 
    while((iEntity = FindEntityByClassname(iEntity, "obj_dispenser")) != INVALID_ENT_REFERENCE) 
        SetEntityRenderColor(iEntity, 255, 255, 255, _); 
    while((iEntity = FindEntityByClassname(iEntity, "obj_teleporter")) != INVALID_ENT_REFERENCE) 
        SetEntityRenderColor(iEntity, 255, 255, 255, _); 
    while((iEntity = FindEntityByClassname(iEntity, "obj_sentrygun")) != INVALID_ENT_REFERENCE) 
        SetEntityRenderColor(iEntity, 255, 255, 255, _); 
} 

public OnAllPluginsLoaded()
{
	if(!LibraryExists("donator.core"))
	{
		SetFailState("Unabled to find plugin: Basic Donator Interface");
	}
	Donator_RegisterMenuItem("Change Red Building Color", ChangeBuildingRedColorCallback);
	Donator_RegisterMenuItem("Change Blue Building Color", ChangeBuildingBlueColorCallback);
	Donator_RegisterMenuItem("Custom (R)GBA", ChangeBuildingCustomCallbackR);
	Donator_RegisterMenuItem("Custom R(G)BA", ChangeBuildingCustomCallbackG);
	Donator_RegisterMenuItem("Custom RG(B)A", ChangeBuildingCustomCallbackB);
	Donator_RegisterMenuItem("Custom RGB(A)", ChangeBuildingCustomCallbackA);

}

public DonatorMenu:ChangeBuildingRedColorCallback(iClient)
{
	Menu_ChangeBuildingRedColor(iClient);
}

public DonatorMenu:ChangeBuildingBlueColorCallback(iClient)
{
	Menu_ChangeBuildingBlueColor(iClient);
}

public DonatorMenu:ChangeBuildingCustomCallbackR(iClient)
{
	Menu_ChangeBuildingCustomColor(iClient, 0);
}
public DonatorMenu:ChangeBuildingCustomCallbackG(iClient)
{
	Menu_ChangeBuildingCustomColor(iClient, 1);
}
public DonatorMenu:ChangeBuildingCustomCallbackB(iClient)
{
	Menu_ChangeBuildingCustomColor(iClient, 2);
}
public DonatorMenu:ChangeBuildingCustomCallbackA(iClient)
{
	Menu_ChangeBuildingCustomColor(iClient, 3);
}

public Action:Menu_ChangeBuildingRedColor(iClient)
{
	new Handle:menu = CreateMenu(BuildingRedColorMenuSelected);
	SetMenuTitle(menu, "Donator: Change Building Red Color:");

	AddMenuItem(menu, "0", "No Color");
	AddMenuItem(menu, "1", "Black");
	AddMenuItem(menu, "2", "Red");
	AddMenuItem(menu, "3", "Green");
	AddMenuItem(menu, "4", "Blue");
	AddMenuItem(menu, "5", "Yellow");
	AddMenuItem(menu, "6", "Purple");
	AddMenuItem(menu, "7", "Cyan");
	AddMenuItem(menu, "8", "Orange");
	AddMenuItem(menu, "9", "Pink");
	AddMenuItem(menu, "10", "Olive");
	AddMenuItem(menu, "11", "Lime");
	AddMenuItem(menu, "12", "Violet");
	AddMenuItem(menu, "13", "Light Blue");
	AddMenuItem(menu, "14", "Silver");
	AddMenuItem(menu, "15", "Chocolate");
	AddMenuItem(menu, "16", "Saddle Brown");
	AddMenuItem(menu, "17", "Indigo");
	AddMenuItem(menu, "18", "Ghost White");
	AddMenuItem(menu, "19", "Thistle");
	AddMenuItem(menu, "20", "Alice Blue");
	AddMenuItem(menu, "21", "Steel Blue");
	AddMenuItem(menu, "22", "Teal");
	AddMenuItem(menu, "23", "Gold");
	AddMenuItem(menu, "24", "Tan");
	AddMenuItem(menu, "25", "Tomato");
	AddMenuItem(menu, "26", "Based on Cookie");
	AddMenuItem(menu, "27", "Based on Cookie Alpha");
	
	DisplayMenu(menu, iClient, 20);
}

public Action:Menu_ChangeBuildingBlueColor(iClient)
{
	new Handle:menu = CreateMenu(BuildingBlueColorMenuSelected);
	SetMenuTitle(menu, "Donator: Change Building Blue Color:");

	AddMenuItem(menu, "0", "No Color");
	AddMenuItem(menu, "1", "Black");
	AddMenuItem(menu, "2", "Red");
	AddMenuItem(menu, "3", "Green");
	AddMenuItem(menu, "4", "Blue");
	AddMenuItem(menu, "5", "Yellow");
	AddMenuItem(menu, "6", "Purple");
	AddMenuItem(menu, "7", "Cyan");
	AddMenuItem(menu, "8", "Orange");
	AddMenuItem(menu, "9", "Pink");
	AddMenuItem(menu, "10", "Olive");
	AddMenuItem(menu, "11", "Lime");
	AddMenuItem(menu, "12", "Violet");
	AddMenuItem(menu, "13", "Light Blue");
	AddMenuItem(menu, "14", "Silver");
	AddMenuItem(menu, "15", "Chocolate");
	AddMenuItem(menu, "16", "Saddle Brown");
	AddMenuItem(menu, "17", "Indigo");
	AddMenuItem(menu, "18", "Ghost White");
	AddMenuItem(menu, "19", "Thistle");
	AddMenuItem(menu, "20", "Alice Blue");
	AddMenuItem(menu, "21", "Steel Blue");
	AddMenuItem(menu, "22", "Teal");
	AddMenuItem(menu, "23", "Gold");
	AddMenuItem(menu, "24", "Tan");
	AddMenuItem(menu, "25", "Tomato");
	AddMenuItem(menu, "26", "Based on Cookie");
	AddMenuItem(menu, "27", "Based on Cookie Alpha");

	DisplayMenu(menu, iClient, 20);
}

public Action:Menu_ChangeBuildingCustomColor(iClient, iChannel)
{
	new Handle:menu = INVALID_HANDLE;

	switch(iChannel)
	{
		case 0: {
			menu = CreateMenu(BuildingCustomColorMenuSelectedR);
			SetMenuTitle(menu, "Channel Value - Red");
			}
		case 1: {
			menu = CreateMenu(BuildingCustomColorMenuSelectedG);
			SetMenuTitle(menu, "Channel Value - Green");
			}
		case 2: {
			menu = CreateMenu(BuildingCustomColorMenuSelectedB);
			SetMenuTitle(menu, "Channel Value - Blue");
			}
		case 3: {
			menu = CreateMenu(BuildingCustomColorMenuSelectedA);
			SetMenuTitle(menu, "Channel Value - Alpha");
			}
	}

	AddMenuItem(menu, "0", "0");
	AddMenuItem(menu, "32", "32");
	AddMenuItem(menu, "64", "64");
	AddMenuItem(menu, "96", "96");
	AddMenuItem(menu, "128", "128");
	AddMenuItem(menu, "160", "160");
	AddMenuItem(menu, "192", "192");
	AddMenuItem(menu, "224", "224");
	AddMenuItem(menu, "255", "255");
	
	DisplayMenu(menu, iClient, 20);
}

public BuildingCustomColorMenuSelectedR(Handle:menu, MenuAction:action, iClient, param2)
{
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}

	if(action == MenuAction_Select)
	{
		decl String:info[12];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_CustomColorR[iClient] = StringToInt(info);
		UpdateExistingBuildings(iClient);
		SetClientCookie(iClient, g_CustomColorCookieR, info);
	}
}

public BuildingCustomColorMenuSelectedG(Handle:menu, MenuAction:action, iClient, param2)
{
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}

	if(action == MenuAction_Select)
	{
		decl String:info[12];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_CustomColorG[iClient] = StringToInt(info);
		UpdateExistingBuildings(iClient);
		SetClientCookie(iClient, g_CustomColorCookieG, info);
	}
}

public BuildingCustomColorMenuSelectedB(Handle:menu, MenuAction:action, iClient, param2)
{
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}

	if(action == MenuAction_Select)
	{
		decl String:info[12];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_CustomColorB[iClient] = StringToInt(info);
		UpdateExistingBuildings(iClient);
		SetClientCookie(iClient, g_CustomColorCookieB, info);
	}
}

public BuildingCustomColorMenuSelectedA(Handle:menu, MenuAction:action, iClient, param2)
{
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}

	if(action == MenuAction_Select)
	{
		decl String:info[12];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_CustomColorA[iClient] = StringToInt(info);
		UpdateExistingBuildings(iClient);
		SetClientCookie(iClient, g_CustomColorCookieA, info);
	}
}

public BuildingRedColorMenuSelected(Handle:menu, MenuAction:action, iClient, param2)
{
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}

	if(action == MenuAction_Select)
	{
		decl String:info[12];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_red_Color[iClient] = StringToInt(info);
		UpdateExistingBuildings(iClient);
		SetClientCookie(iClient, g_RedColorCookie, info);
	}
}

public BuildingBlueColorMenuSelected(Handle:menu, MenuAction:action, iClient, param2)
{
	if(action == MenuAction_End)
	{
		CloseHandle(menu);
	}

	if(action == MenuAction_Select)
	{
		decl String:info[12];
		GetMenuItem(menu, param2, info, sizeof(info));
		g_blue_Color[iClient] = StringToInt(info);
		UpdateExistingBuildings(iClient);
		SetClientCookie(iClient, g_BlueColorCookie, info);
	}
}


public OnClientPostAdminCheck(iClient)
{
	if (IsPlayerDonator(iClient))
	{
		new String:szBuffer[8];

		GetClientCookie(iClient, g_RedColorCookie, szBuffer, sizeof(szBuffer));
		g_red_Color[iClient] = StringToInt(szBuffer);

		GetClientCookie(iClient, g_BlueColorCookie, szBuffer, sizeof(szBuffer));
		g_blue_Color[iClient] = StringToInt(szBuffer);

		GetClientCookie(iClient, g_CustomColorCookieR, szBuffer, sizeof(szBuffer));
		g_CustomColorR[iClient] = StringToInt(szBuffer);
		GetClientCookie(iClient, g_CustomColorCookieG, szBuffer, sizeof(szBuffer));
		g_CustomColorG[iClient] = StringToInt(szBuffer);
		GetClientCookie(iClient, g_CustomColorCookieB, szBuffer, sizeof(szBuffer));
		g_CustomColorB[iClient] = StringToInt(szBuffer);
		GetClientCookie(iClient, g_CustomColorCookieA, szBuffer, sizeof(szBuffer));
		g_CustomColorA[iClient] = StringToInt(szBuffer);
	
	} else {
		g_red_Color[iClient] = 0;	
		g_red_Color[iClient] = 0;

		g_CustomColorR[iClient] = 0;
		g_CustomColorG[iClient] = 0;
		g_CustomColorB[iClient] = 0;
		g_CustomColorA[iClient] = 0;
	}
}

public OnClientDisconnect(iClient)
{
	g_red_Color[iClient] = 0;	
	g_blue_Color[iClient] = 0;

	g_CustomColorR[iClient] = 0;
	g_CustomColorG[iClient] = 0;
	g_CustomColorB[iClient] = 0;
	g_CustomColorA[iClient] = 0;
}

stock bool:IsValidClient(iClient, bool:replay = true)
{
	if(iClient <= 0 || iClient > MaxClients || !IsClientInGame(iClient)) return false;
	if(replay && (IsClientSourceTV(iClient) || IsClientReplay(iClient))) return false;
	return true;
}

stock SetBuildingColor(iBuilding, iOwner)
{
	// Red?
	if (GetClientTeam(iOwner) == 2) 
	{
		switch(g_red_Color[iOwner])
		{
		case 1: SetEntityRenderColor(iBuilding, 0, 0, 0, _);
		case 2: SetEntityRenderColor(iBuilding, 255, 0, 0, _);
		case 3: SetEntityRenderColor(iBuilding, 0, 255, 0, _);
		case 4: SetEntityRenderColor(iBuilding, 0, 0, 255, _);
		case 5: SetEntityRenderColor(iBuilding, 255, 255, 0, _);
		case 6: SetEntityRenderColor(iBuilding, 255, 0, 255, _);
		case 7: SetEntityRenderColor(iBuilding, 0, 255, 255, _);
		case 8: SetEntityRenderColor(iBuilding, 255, 128, 0, _);
		case 9: SetEntityRenderColor(iBuilding, 255, 0, 128, _);
		case 10: SetEntityRenderColor(iBuilding, 128, 255, 0, _);
		case 11: SetEntityRenderColor(iBuilding, 0, 255, 128, _);
		case 12: SetEntityRenderColor(iBuilding, 128, 0, 255, _);
		case 13: SetEntityRenderColor(iBuilding, 0, 128, 255, _);
		case 14: SetEntityRenderColor(iBuilding, 192, 192, 192, _);
		case 15: SetEntityRenderColor(iBuilding, 210, 105, 30, _);
		case 16: SetEntityRenderColor(iBuilding, 139, 69, 19, _);
		case 17: SetEntityRenderColor(iBuilding, 75, 0, 130, _);
		case 18: SetEntityRenderColor(iBuilding, 248, 248, 255, _);
		case 19: SetEntityRenderColor(iBuilding, 216, 191, 216, _);
		case 20: SetEntityRenderColor(iBuilding, 240, 248, 255, _);
		case 21: SetEntityRenderColor(iBuilding, 70, 130, 180, _);
		case 22: SetEntityRenderColor(iBuilding, 0, 128, 128, _);
		case 23: SetEntityRenderColor(iBuilding, 255, 215, 0, _);
		case 24: SetEntityRenderColor(iBuilding, 210, 180, 140, _);
		case 25: SetEntityRenderColor(iBuilding, 255, 99, 71, _);
		case 26: SetEntityRenderColor(iBuilding, g_CustomColorR[iOwner], g_CustomColorG[iOwner], g_CustomColorB[iOwner], _);
		case 27: SetEntityRenderColor(iBuilding, g_CustomColorR[iOwner], g_CustomColorG[iOwner], g_CustomColorB[iOwner], g_CustomColorA[iOwner]);
		}
	}
	// Blue?
	if (GetClientTeam(iOwner) == 3)
	{
		switch(g_blue_Color[iOwner])
		{
		case 1: SetEntityRenderColor(iBuilding, 0, 0, 0, _);
		case 2: SetEntityRenderColor(iBuilding, 255, 0, 0, _);
		case 3: SetEntityRenderColor(iBuilding, 0, 255, 0, _);
		case 4: SetEntityRenderColor(iBuilding, 0, 0, 255, _);
		case 5: SetEntityRenderColor(iBuilding, 255, 255, 0, _);
		case 6: SetEntityRenderColor(iBuilding, 255, 0, 255, _);
		case 7: SetEntityRenderColor(iBuilding, 0, 255, 255, _);
		case 8: SetEntityRenderColor(iBuilding, 255, 128, 0, _);
		case 9: SetEntityRenderColor(iBuilding, 255, 0, 128, _);
		case 10: SetEntityRenderColor(iBuilding, 128, 255, 0, _);
		case 11: SetEntityRenderColor(iBuilding, 0, 255, 128, _);
		case 12: SetEntityRenderColor(iBuilding, 128, 0, 255, _);
		case 13: SetEntityRenderColor(iBuilding, 0, 128, 255, _);
		case 14: SetEntityRenderColor(iBuilding, 192, 192, 192, _);
		case 15: SetEntityRenderColor(iBuilding, 210, 105, 30, _);
		case 16: SetEntityRenderColor(iBuilding, 139, 69, 19, _);
		case 17: SetEntityRenderColor(iBuilding, 75, 0, 130, _);
		case 18: SetEntityRenderColor(iBuilding, 248, 248, 255, _);
		case 19: SetEntityRenderColor(iBuilding, 216, 191, 216, _);
		case 20: SetEntityRenderColor(iBuilding, 240, 248, 255, _);
		case 21: SetEntityRenderColor(iBuilding, 70, 130, 180, _);
		case 22: SetEntityRenderColor(iBuilding, 0, 128, 128, _);
		case 23: SetEntityRenderColor(iBuilding, 255, 215, 0, _);
		case 24: SetEntityRenderColor(iBuilding, 210, 180, 140, _);
		case 25: SetEntityRenderColor(iBuilding, 255, 99, 71, _);
		case 26: SetEntityRenderColor(iBuilding, g_CustomColorR[iOwner], g_CustomColorG[iOwner], g_CustomColorB[iOwner], _);
		case 27: SetEntityRenderColor(iBuilding, g_CustomColorR[iOwner], g_CustomColorG[iOwner], g_CustomColorB[iOwner], g_CustomColorA[iOwner]);
		}
	}
}

stock UpdateExistingBuildings(iOwner)
{
	// Loop through all buildings, if owned, change the color
        new iEntity = INVALID_ENT_REFERENCE; 
        while((iEntity = FindEntityByClassname(iEntity, "obj_dispenser")) != INVALID_ENT_REFERENCE) 
        { 
            if(GetEntPropEnt(iEntity, Prop_Send, "m_hBuilder") == iOwner) 
                SetBuildingColor(iEntity, iOwner); 
        } 
        while((iEntity = FindEntityByClassname(iEntity, "obj_teleporter")) != INVALID_ENT_REFERENCE) 
        { 
            if(GetEntPropEnt(iEntity, Prop_Send, "m_hBuilder") == iOwner) 
                SetBuildingColor(iEntity, iOwner); 
        } 
        while((iEntity = FindEntityByClassname(iEntity, "obj_sentrygun")) != INVALID_ENT_REFERENCE) 
        { 
            if(GetEntPropEnt(iEntity, Prop_Send, "m_hBuilder") == iOwner) 
                SetBuildingColor(iEntity, iOwner); 
        } 
}

public Action:Event_BuiltObject(Handle:event, const String:name[], bool:dontBroadcast)
{
	new iClient = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!IsValidClient(iClient)) return Plugin_Continue;

	new iBuilding = GetEventInt(event, "index");
	
	if (IsPlayerDonator(iClient))
	{
		SetBuildingColor(iBuilding, iClient);
	}
	return Plugin_Continue;
}
