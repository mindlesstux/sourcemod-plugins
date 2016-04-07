#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#define AUTOLOAD_EXTENSIONS
#define REQUIRE_EXTENSIONS
#include <steamtools>
//https://forums.alliedmods.net/showthread.php?t=280402
#include "sourcetvmanager"

#undef REQUIRE_PLUGIN
#include <adminmenu>
#include <updater>

new const String:PLUGIN_VERSION[] = "0.0.6";
new const String:UPDATE_URL[] = "https://mindlesstux.com/sourcemod/rtfhp/rtfhp.update.txt";
new g_ReportTarget[MAXPLAYERS+1];

new Handle:g_Cvar_HTTPTarget = INVALID_HANDLE;
new Handle:g_Cvar_HTTPAPIKey = INVALID_HANDLE;

// Admin Menu
TopMenu hTopMenu;

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

	/* Account for late loading */
	TopMenu topmenu;
	if (LibraryExists("adminmenu") && ((topmenu = GetAdminTopMenu()) != null))
	{
		OnAdminMenuReady(topmenu);
	}

}

RegisterCvars( )
{
	// Create our version vcar
	CreateConVar("rtfhp_version", PLUGIN_VERSION, "Version of Report to Forums HTTP", FCVAR_PLUGIN|FCVAR_REPLICATED);

	// For the where
	g_Cvar_HTTPTarget = CreateConVar("rtfhp_target", "https://www.example.com/rtfhp.php", "URL of API Endpoint", FCVAR_PLUGIN|FCVAR_PROTECTED|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_PRINTABLEONLY);
	g_Cvar_HTTPAPIKey = CreateConVar("rtfhp_apikey", "cb0875365a5ec054ce49a691801dc6a711efffbc", "API Key set in Endpoint", FCVAR_PLUGIN|FCVAR_PROTECTED|FCVAR_DONTRECORD|FCVAR_REPLICATED|FCVAR_PRINTABLEONLY);

	// TODO: Add to this so rtfhp_target and rtfhp_apikey get loaded into the cfg on generation
	//AutoExecConfig(true, "rtfhp");
}

RegisterCmds( )
{
	// Report CMD
	RegConsoleCmd("sm_report2", Command_ReportUser, "Report a player to the forums.");
	//RegConsoleCmd("sm_report2menu", AdminMenu_Report, "Report a player to the forums.");
}

public OnAdminMenuReady(Handle aTopMenu)
{
	TopMenu topmenu = TopMenu.FromHandle(aTopMenu);

	/* Block us from being called twice */
	if (topmenu == hTopMenu)
	{
		return;
	}
	
	/* Save the Handle */
	hTopMenu = topmenu;
	
	/* Find the "Player Commands" category */
	TopMenuObject player_commands = hTopMenu.FindCategory(ADMINMENU_PLAYERCOMMANDS);

	if (player_commands != INVALID_TOPMENUOBJECT)
	{
		hTopMenu.AddItem("sm_report2", AdminMenu_Report, player_commands, "sm_report2");
	}
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

	PrintToServer("[RTFHP] URL: %s", g_szAPITarget);

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

/* MENU STUFF */
public AdminMenu_Report(Handle:topmenu, TopMenuAction:action, TopMenuObject:object_id, param, String:buffer[], maxlength)
{
	if (action == TopMenuAction_DisplayOption)
	{
		Format(buffer, maxlength, "%T", "Report player", param);
	}
	else if (action == TopMenuAction_SelectOption)
	{
		DisplayReportMenu(param);
	}
}
DisplayReportMenu(client)
{
	Menu menu = CreateMenu(MenuHandler_Report);
	
	decl String:title[100];
	Format(title, sizeof(title), "%T:", "Report player", client);
	menu.SetTitle(title);
	menu.ExitBackButton = true;
	
	AddTargetsToMenu(menu, client, true, true);
	
	menu.Display(client, MENU_TIME_FOREVER);
}
DisplayReportTypeMenu(client)
{
	Menu menu = CreateMenu(MenuHandler_ReportType);
	
	decl String:title[100];
	Format(title, sizeof(title), "%T: %N", "Report Reason", client, GetClientOfUserId(g_ReportTarget[client]));
	menu.SetTitle(title);
	menu.ExitBackButton = true;
	
	AddTranslatedMenuItem(menu, "aimbot",      "Aimbot", client);
	AddTranslatedMenuItem(menu, "wallhack",    "Wallhacking", client);
	AddTranslatedMenuItem(menu, "hacking",     "General Hacking", client);
	AddTranslatedMenuItem(menu, "offensechat", "Offensive Chat", client);
	AddTranslatedMenuItem(menu, "offensename", "Offensive Name", client);
	AddTranslatedMenuItem(menu, "voicespam",   "Voice Spam", client);
	AddTranslatedMenuItem(menu, "trolling",    "Trolling", client);
	AddTranslatedMenuItem(menu, "rulebreak",   "Server Rule Break", client);
	
	menu.Display(client, MENU_TIME_FOREVER);
}

public MenuHandler_Report(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu)
		{
			hTopMenu.Display(param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:info[32];
		new userid, target;
		
		menu.GetItem(param2, info, sizeof(info));
		userid = StringToInt(info);

		if ((target = GetClientOfUserId(userid)) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target");
		}
		else
		{
			g_ReportTarget[param1] = userid;
			DisplayReportTypeMenu(param1);
			return;	// Return, because we went to a new menu and don't want the re-draw to occur.
		}
		
		/* Re-draw the menu if they're still valid */
		if (IsClientInGame(param1) && !IsClientInKickQueue(param1))
		{
			DisplayReportMenu(param1);
		}
	}
	
	return;
}

public MenuHandler_ReportType(Menu menu, MenuAction action, int param1, int param2)
{
	if (action == MenuAction_End)
	{
		delete menu;
	}
	else if (action == MenuAction_Cancel)
	{
		if (param2 == MenuCancel_ExitBack && hTopMenu)
		{
			hTopMenu.Display(param1, TopMenuPosition_LastCategory);
		}
	}
	else if (action == MenuAction_Select)
	{
		decl String:info[32];
		new target;
		
		menu.GetItem(param2, info, sizeof(info));

		if ((target = GetClientOfUserId(g_ReportTarget[param1])) == 0)
		{
			PrintToChat(param1, "[SM] %t", "Player no longer available");
		}
		else if (!CanUserTarget(param1, target))
		{
			PrintToChat(param1, "[SM] %t", "Unable to target");
		}
		else
		{
			new String:name[32];
			GetClientName(target, name, sizeof(name));
			
			//PerformGravity(param1, target, amount);
			SendHTTPRequest(param1, target, info);
		}
	}
}

void AddTranslatedMenuItem(Menu menu, const char[] opt, const char[] phrase, int client)
{
	char buffer[128];
	Format(buffer, sizeof(buffer), "%T", phrase, client);
	menu.AddItem(opt, buffer);
}

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
