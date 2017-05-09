#include <sourcemod>

#define PLUGIN_VERSION "0.2"

#pragma semicolon 1

public Plugin myinfo =
{
    name = "[TPF/TF2] Move Self To Team",
    author = "MindlessTux",
    description = "Move Self To Team",
    version = PLUGIN_VERSION,
    url = "http://www.mindlesstux.com"
};

public void OnPluginStart()
{
	CreateConVar("sm_movetospec_version", PLUGIN_VERSION, "Move To Spectator Version", FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_PLUGIN|FCVAR_SPONLY);
	RegAdminCmd("sm_changeteam", Command_MoveToTeam, ADMFLAG_KICK, "Allows you to switch your team forcefully");    
}

public Action Command_MoveToTeam(int iClient, int iArgs)
{
	if (iArgs < 1)
	{
		PrintToConsole(iClient, "[SM] Usage: sm_changeteam <spec/red/blue>");
		return Plugin_Handled;
	}

	char arg1[6];
	GetCmdArg(1, arg1, sizeof(arg1));

	if (StrEqual(arg1, "spec", false))
	{
		MoveToSpec(iClient);
	}
	if (StrEqual(arg1, "red", false))
	{
		MoveToRed(iClient);
	}
	if (StrEqual(arg1, "blue", false))
	{
		MoveToBlue(iClient);
	}
					
	return Plugin_Handled;
}

public MoveToSpec(int client)
{
	//1
	ChangeClientTeam(client, 1);
	PrintToChat(client, "[SM] Switched you to Spectator");
}
public MoveToRed(int client)
{
	//2
	ChangeClientTeam(client, 2);
	PrintToChat(client, "[SM] Switched you to Red Team");

}
public MoveToBlue(int client)
{
	//3
	ChangeClientTeam(client, 3);
	PrintToChat(client, "[SM] Switched you to Blue");

}
