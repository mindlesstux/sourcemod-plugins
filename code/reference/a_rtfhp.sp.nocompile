#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#define AUTOLOAD_EXTENSIONS
#define REQUIRE_EXTENSIONS
#include <steamtools>
//https://forums.alliedmods.net/showthread.php?t=280402
#include "sourcetvmanager"

#undef REQUIRE_PLUGIN
#include <updater>

new const String:PLUGIN_VERSION[] = "0.0.7";
new const String:UPDATE_URL[] = "https://mindlesstux.com/sourcemod/rtfhp/rtfhp.update.txt";
new g_ReportTarget[MAXPLAYERS+1];

new Handle:g_Cvar_HTTPTarget = INVALID_HANDLE;
new Handle:g_Cvar_HTTPAPIKey = INVALID_HANDLE;
new Handle:g_Cvar_NotifyInGameAdmins = INVALID_HANDLE;

/*
TODO:
-Create the menu
-Handle http returns and error codes
-Inform admins (if set) as the person is submitting the report

*/

public Plugin:myinfo = 
{
	name = "Report To Forums via HTTP Post",
	author = "mindlesstux",
	description = "Allows users to report other users for problems in the server and server sends via HTTP Post",
	version = PLUGIN_VERSION,
	url = "https://mindlesstux.com/sourcemod/rtfhp/"
}

public OnPluginStart()
{
	LoadTranslations("rtfhp.phrases.txt");
	
	RegisterCvars( );
	RegisterCmds( );
}

RegisterCvars( )
{
	// Create our version vcar
	CreateConVar("rtfhp_version", PLUGIN_VERSION, "Version of Report to Forums HTTP", FCVAR_PLUGIN|FCVAR_REPLICATED);

	// For the where
	g_Cvar_HTTPTarget = CreateConVar("rtfhp_target", "https://www.example.com/rtfhp.php", "URL of API Endpoint", FCVAR_PLUGIN|FCVAR_PROTECTED|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_PRINTABLEONLY);
	g_Cvar_HTTPAPIKey = CreateConVar("rtfhp_apikey", "cb0875365a5ec054ce49a691801dc6a711efffbc", "API Key set in Endpoint", FCVAR_PLUGIN|FCVAR_PROTECTED|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_PRINTABLEONLY);

	// Use this to figure out if the admins in game should be notified of every step of the report process or not
	g_Cvar_NotifyInGameAdmins = CreateConVar("rtfhp_notifyingameadmins", "1", "Notify admins ingame of 'in-flight' report status", FCVAR_PLUGIN|FCVAR_PROTECTED|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_PRINTABLEONLY, _, true, 0.0, true, 1.0);

	// TODO: Add to this so rtfhp_target and rtfhp_apikey get loaded into the cfg on generation
	//AutoExecConfig(true, "rtfhp");
}

RegisterCmds( )
{
	// Report CMD
	RegConsoleCmd("sm_rtf", Menu_RTF_1, "Report a player to the forums.");
}

public OnLibraryAdded(const String:szName[])
{
	if(StrEqual(szName, "updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
}

public OnConfigsExecuted()
{
	if(LibraryExists("updater"))
	{
		Updater_AddPlugin(UPDATE_URL);
	}
}

// Make HTTP call
public SendHTTPRequest(iClient, iTarget, char[] iReason) {
	// Create the HTTP request
	new String:g_szAPITarget[128];
	GetConVarString(g_Cvar_HTTPTarget, g_szAPITarget, sizeof(g_szAPITarget));
	new HTTPRequestHandle:request = Steam_CreateHTTPRequest(HTTPMethod_POST, g_szAPITarget);

	//PrintToServer("[RTFHP] URL: %s", g_szAPITarget);

	// Base information we need
	new String:g_szAPIKey[64];
	GetConVarString(g_Cvar_HTTPAPIKey, g_szAPIKey, sizeof(g_szAPIKey));
	Steam_SetHTTPRequestGetOrPostParameter(request, "apikey", g_szAPIKey);

	Steam_SetHTTPRequestGetOrPostParameter(request, "reason", iReason);

	new String:g_szHostname[128];
	GetConVarString(FindConVar("hostname"), g_szHostname, sizeof(g_szHostname));
	Steam_SetHTTPRequestGetOrPostParameter(request, "hostname", g_szHostname);

	new String:g_szHostport[6];
	GetConVarString(FindConVar("hostport"), g_szHostport, sizeof(g_szHostport));
	Steam_SetHTTPRequestGetOrPostParameter(request, "hostport", g_szHostport);
	
	new String:g_szHostIP[16];
	GetConVarString(FindConVar("ip"), g_szHostIP, sizeof(g_szHostIP));
	Steam_SetHTTPRequestGetOrPostParameter(request, "hostip", g_szHostIP);
	
	new String:g_szMapName[32];
	GetCurrentMap(g_szMapName, sizeof(g_szMapName));
	Steam_SetHTTPRequestGetOrPostParameter(request, "map_name", g_szMapName);
	
	if(StrContains(g_szMapName, "workshop", false) != -1)
	{
		new String:szWorkShopID[32];
		GetCurrentWorkshopMap(g_szMapName, sizeof(g_szMapName), szWorkShopID, sizeof(szWorkShopID));
		Steam_SetHTTPRequestGetOrPostParameter(request, "map_workshopid", szWorkShopID); // Set post param "herp" value to "derp"
	}

	new String:g_szTIP[16];
	new String:g_szCIP[16];
	GetClientIP(iTarget, g_szTIP, sizeof(g_szTIP));
	GetClientIP(iClient, g_szCIP, sizeof(g_szCIP));
	Steam_SetHTTPRequestGetOrPostParameter(request, "target_ip", g_szTIP);
	Steam_SetHTTPRequestGetOrPostParameter(request, "report_ip", g_szCIP);

	new String:g_szTSteamID2[32];
	new String:g_szCSteamID2[32];
	GetClientAuthId(iTarget, AuthId_Steam2, g_szTSteamID2, sizeof(g_szTSteamID2));
	GetClientAuthId(iClient, AuthId_Steam2, g_szCSteamID2, sizeof(g_szCSteamID2));
	Steam_SetHTTPRequestGetOrPostParameter(request, "target_steamid2", g_szTSteamID2);
	Steam_SetHTTPRequestGetOrPostParameter(request, "report_steamid2", g_szCSteamID2);

	new String:g_szTSteamID3[32];
	new String:g_szCSteamID3[32];
	GetClientAuthId(iTarget, AuthId_Steam3, g_szTSteamID3, sizeof(g_szTSteamID3));
	GetClientAuthId(iClient, AuthId_Steam3, g_szCSteamID3, sizeof(g_szCSteamID3));
	Steam_SetHTTPRequestGetOrPostParameter(request, "target_steamid3", g_szTSteamID3);
	Steam_SetHTTPRequestGetOrPostParameter(request, "report_steamid3", g_szCSteamID3);

	new String:g_szTSteamID64[32];
	new String:g_szCSteamID64[32];
	GetClientAuthId(iTarget, AuthId_SteamID64, g_szTSteamID64, sizeof(g_szTSteamID64));
	GetClientAuthId(iClient, AuthId_SteamID64, g_szCSteamID64, sizeof(g_szCSteamID64));
	Steam_SetHTTPRequestGetOrPostParameter(request, "target_steamid64", g_szTSteamID64);
	Steam_SetHTTPRequestGetOrPostParameter(request, "report_steamid64", g_szCSteamID64);

	new String:g_szTName[32];
	new String:g_szCName[32];
	GetClientName(iTarget, g_szTName, sizeof(g_szTName));
	GetClientName(iClient, g_szCName, sizeof(g_szCName));
	Steam_SetHTTPRequestGetOrPostParameter(request, "target_name", g_szTName);
	Steam_SetHTTPRequestGetOrPostParameter(request, "report_name", g_szCName);

	if (SourceTV_IsRecording())
	{
		new String:sFileName[PLATFORM_MAX_PATH];
		SourceTV_GetDemoFileName(sFileName, sizeof(sFileName));
		Steam_SetHTTPRequestGetOrPostParameter(request, "demo_file", sFileName);
		
		int iTickNum;
		iTickNum = SourceTV_GetRecordingTick();
		new String:sTickNum[8];
		IntToString(iTickNum, sTickNum, sizeof(sTickNum));
		Steam_SetHTTPRequestGetOrPostParameter(request, "demo_tick", sTickNum);
	}

	
	// For the LOLz
	Steam_SetHTTPRequestGetOrPostParameter(request, "herp", "derp"); // Set post param "herp" value to "derp"

	// Send the request
	Steam_SendHTTPRequest(request, OnRequestComplete);
}

public OnRequestComplete(HTTPRequestHandle:request, bool:successful, HTTPStatusCode:status) {
	decl String:response[1024];
	Steam_GetHTTPResponseBodyData(request, response, sizeof(response)); // Get the response from the server
	Steam_ReleaseHTTPRequest(request); // Close the handle
}  

stock GetCurrentWorkshopMap(String:szMap[], iMapBuf, String:szWorkShopID[], iWorkShopBuf)
{
	decl String:szCurMapSplit[2][64];
	
	ReplaceString(szMap, iMapBuf, "workshop/", "", false);
	ExplodeString(szMap, "/", szCurMapSplit, 2, sizeof(szCurMapSplit[]));
	
	strcopy(szMap, iMapBuf, szCurMapSplit[1]);
	strcopy(szWorkShopID, iWorkShopBuf, szCurMapSplit[0]);
}

/*
// Just make it a menu item... Keeping code for reference later or use if needed
public Action:Command_ReportUser(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "[SM] Usage: sm_report2 <#userid|name> <aimbot/wallhack/hacking/offensechat/offensename/voicespam/trolling/rulebreak>");
		return Plugin_Handled;
	}

	decl String:arg[65];
	GetCmdArg(1, arg, sizeof(arg));
	
	decl String:target_name[MAX_TARGET_LENGTH];
	decl target_list[MAXPLAYERS], target_count, bool:tn_is_ml;
	
	if ((target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, COMMAND_FILTER_ALIVE, target_name, sizeof(target_name), tn_is_ml)) <= 0)
	{
		ReplyToTargetError(client, target_count);
		return Plugin_Handled;
	}
	
	for (new i = 0; i < target_count; i++)
	{
		//PerformGravity(client, target_list[i], amount);
		SendHTTPRequest(client, target_list[i], arg);
	}
	
	return Plugin_Handled;
}
*/

// https://wiki.alliedmods.net/Menus_Step_By_Step_(SourceMod_Scripting)#The_working_menu_example
public MenuHandler(Handle:menu, MenuAction:action, param1, param2)
{
	switch(action)
	{

		case MenuAction_Select:
		{
			decl String:info[32];
			GetMenuItem(menu, param2, info, sizeof(info));
			PrintToServer("Client %d selected %s", param1, info);
		}

		case MenuAction_Cancel:
		{
			PrintToServer("Client %d's menu was cancelled for reason %d", param1, param2);
		}
	}
 
	return 0;
}

public Action:Menu_RTF_1(client, args)
{
	new Handle:menu = CreateMenu(MenuHandler, MenuAction_Select|MenuAction_Cancel);
	SetMenuTitle(menu, "%T", "Report player", LANG_SERVER);

	decl String:sName[MAX_NAME_LENGTH], String:sUserId[10];
	for(new i=1;i<=MaxClients;i++)
	{
		if(IsClientInGame(i))
		{
			GetClientName(i, sName, sizeof(sName));
			IntToString(GetClientUserId(i), sUserId, sizeof(sUserId));
			AddMenuItem(menu, sUserId, sName);
		}
	}  

	DisplayMenu(menu, client, 20);
 
	return Plugin_Handled;
}
