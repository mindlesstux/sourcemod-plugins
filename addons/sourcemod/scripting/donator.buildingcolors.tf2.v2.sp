#include <sourcemod>
#include <clientprefs>
#include <sdktools>
#include <donator>

#undef REQUIRE_PLUGIN
#include <updater>

#define UPDATE_URL    "http://teamplayfirst.com/sourcemod-plugins/buildingcolors.tf2/updatefile.txt"

#pragma semicolon 1

#define PLUGIN_VERSION	"b2"

new Handle:g_RedColorCookie = INVALID_HANDLE;
new Handle:g_BlueColorCookie = INVALID_HANDLE;
new g_red_Color[MAXPLAYERS + 1];
new g_blue_Color[MAXPLAYERS + 1];

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
	g_RedColorCookie = RegClientCookie("donator_redcolorcookie", "Color for red engie buildings", CookieAccess_Private);
	g_BlueColorCookie = RegClientCookie("donator_bluecolorcookie", "Color for blue engie buildings", CookieAccess_Private);

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
}

public DonatorMenu:ChangeBuildingRedColorCallback(iClient)
{
	Menu_ChangeBuildingRedColor(iClient);
}

public DonatorMenu:ChangeBuildingBlueColorCallback(iClient)
{
	Menu_ChangeBuildingBlueColor(iClient);
}

public Action:Menu_ChangeBuildingRedColor(iClient)
{
	new Handle:menu = CreateMenu(BuildingRedColorMenuSelected);
	SetMenuTitle(menu, "Donator: Change Building Red Color:");

	AddMenuItem(menu, "0", "No Color/Default");
	AddMenuItem(menu, "1", "Black");
	AddMenuItem(menu, "2", "Red");
	AddMenuItem(menu, "3", "Green");
	AddMenuItem(menu, "4", "Blue");
	AddMenuItem(menu, "5", "Yellow");
	AddMenuItem(menu, "6", "Purple");
	AddMenuItem(menu, "7", "Cyan");
	AddMenuItem(menu, "8", "Orange");
	AddMenuItem(menu, "9", "Pink");
	
	DisplayMenu(menu, iClient, 20);
}

public Action:Menu_ChangeBuildingBlueColor(iClient)
{
	new Handle:menu = CreateMenu(BuildingBlueColorMenuSelected);
	SetMenuTitle(menu, "Donator: Change Building Blue Color:");

	AddMenuItem(menu, "0", "No Color/Default");
	AddMenuItem(menu, "1", "Black");
	AddMenuItem(menu, "2", "Red");
	AddMenuItem(menu, "3", "Green");
	AddMenuItem(menu, "4", "Blue");
	AddMenuItem(menu, "5", "Yellow");
	AddMenuItem(menu, "6", "Purple");
	AddMenuItem(menu, "7", "Cyan");
	AddMenuItem(menu, "8", "Orange");
	AddMenuItem(menu, "9", "Pink");
	
	DisplayMenu(menu, iClient, 20);
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

		decl String:szBuffer[2];
		FormatEx(szBuffer, sizeof(szBuffer), "%i", info);
		SetClientCookie(iClient, g_RedColorCookie, szBuffer);
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

		decl String:szBuffer[2];
		FormatEx(szBuffer, sizeof(szBuffer), "%i", info);
		SetClientCookie(iClient, g_BlueColorCookie, szBuffer);
	}
}

public OnClientPutInServer(iClient)
{
	if (IsPlayerDonator(iClient))
	{
		new String:szBuffer[2];

		GetClientCookie(iClient, g_RedColorCookie, szBuffer, sizeof(szBuffer));
		g_red_Color[iClient] = StringToInt(szBuffer);

		GetClientCookie(iClient, g_BlueColorCookie, szBuffer, sizeof(szBuffer));
		g_blue_Color[iClient] = StringToInt(szBuffer);		
	} else {
		g_red_Color[iClient] = 0;	
		g_red_Color[iClient] = 0;
	}
}

public OnClientDisconnect(iClient)
{
	g_red_Color[iClient] = 0;	
	g_blue_Color[iClient] = 0;
}

stock bool:IsValidClient(iClient, bool:replay = true)
{
	if(iClient <= 0 || iClient > MaxClients || !IsClientInGame(iClient)) return false;
	if(replay && (IsClientSourceTV(iClient) || IsClientReplay(iClient))) return false;
	return true;
}

stock SetBuildingColor(iEntity, iOwner)
{
	// Red?
	if (GetClientTeam(iOwner) == 2) 
	{
		switch(g_red_Color[iOwner])
		{
			case 1: SetEntityRenderColor(iEntity, 0, 0, 0, _);
			case 2: SetEntityRenderColor(iEntity, 255, 0, 0, _);
			case 3: SetEntityRenderColor(iEntity, 0, 255, 0, _);
			case 4: SetEntityRenderColor(iEntity, 0, 0, 255, _);
			case 5: SetEntityRenderColor(iEntity, 255, 255, 0, _);
			case 6: SetEntityRenderColor(iEntity, 255, 0, 255, _);
			case 7: SetEntityRenderColor(iEntity, 0, 255, 255, _);
			case 8: SetEntityRenderColor(iEntity, 255, 128, 0, _);
			case 9: SetEntityRenderColor(iEntity, 255, 0, 128, _);
		}
	}
	// Blue?
	if (GetClientTeam(iOwner) == 3)
	{
		switch(g_blue_Color[iOwner])
		{
			case 1: SetEntityRenderColor(iEntity, 0, 0, 0, _);
			case 2: SetEntityRenderColor(iEntity, 255, 0, 0, _);
			case 3: SetEntityRenderColor(iEntity, 0, 255, 0, _);
			case 4: SetEntityRenderColor(iEntity, 0, 0, 255, _);
			case 5: SetEntityRenderColor(iEntity, 255, 255, 0, _);
			case 6: SetEntityRenderColor(iEntity, 255, 0, 255, _);
			case 7: SetEntityRenderColor(iEntity, 0, 255, 255, _);
			case 8: SetEntityRenderColor(iEntity, 255, 128, 0, _);
			case 9: SetEntityRenderColor(iEntity, 255, 0, 128, _);
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
