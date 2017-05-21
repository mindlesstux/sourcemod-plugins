#pragma semicolon 1

#include <basecomm>
#include <clientprefs>
#include <sourcemod>
#include <sdktools>
#include <tf2>
#include <tf2_stocks>
#define PLUGIN_VERSION "0.0.1"
#define UPDATE_FILE	"mt_cheatannoy.updater.txt"
#define CONVAR_PREFIX	"mt_cheatannoy"

#undef REQUIRE_PLUGIN

// Load the auto updater add that Doctor McKay made
#include "updater_mindlesstux.sp"

new Handle:cookieCheater;

public Plugin:myinfo = {
  name = "MT - Cheater Annoy",
  author = "MindlessTux",
  description = "Annoy a cheater (or player)",
  version = PLUGIN_VERSION,
  url = "https://mindlesstux.com/sourcemod-plugins/cheater-annoy-er/"
};

public OnPluginStart()
{
  RegAdminCmd("sm_cheaterannoy", MT_CheatAnnoy, ADMFLAG_KICK, "sm_cheaterannoy <#userid|name>");
  cookieCheater = RegClientCookie("mt_cheaterannoy_toggle", "MT Cheater Annoyer Toggle", CookieAccess_Private);

}

/*
bool:GetCookieValue(client, Handle:cookie, Handle:defaultCvar) {
	decl String:value[8];
	GetClientCookie(client, cookie, value, sizeof(value));

	if(strlen(value) == 0) {
		return GetConVarBool(defaultCvar);
	} else {
		return bool:StringToInt(value);
	}
}
*/

void PerformCheatAnnoyance(int target)
{
  // Only do these actions if client is in game
  if(IsClientInGame(target)) {

    // Mute + Gag
    BaseComm_SetClientGag(target, true);
    BaseComm_SetClientMute(target, true);

    // TODO: Fix this to check if we are in TF2 right now.
    TF2_RemoveAllWeapons(target);

    // Not sure if this is TF2 specific...
    SetEntProp(target, Prop_Send, "m_bGlowEnabled", 1, 1);
  }
}

// What happens when the cmd is run...
public Action MT_CheatAnnoy(int client, int args)
{
  // If no username supplied, kick back help to client
  if (args < 1)
  {
    ReplyToCommand(client, "[SM] Usage: smmt_cheatannoy <#userid|name>");
    return Plugin_Handled;
  }

  // NO IDEA, borrowed from command_kick
  char Arguments[256];
  GetCmdArgString(Arguments, sizeof(Arguments));

  char arg[65];
  int len = BreakString(Arguments, arg, sizeof(arg));

  if (len == -1)
  {
    /* Safely null terminate */
    len = 0;
    Arguments[0] = '\0';
  }

  char target_name[MAX_TARGET_LENGTH];
  int target_list[MAXPLAYERS], target_count;
  bool tn_is_ml;
  // END NO IDEA

  if ((target_count = ProcessTargetString(arg, client, target_list, MAXPLAYERS, COMMAND_FILTER_CONNECTED, target_name, sizeof(target_name), tn_is_ml)) > 0) {
    for (int i = 0; i < target_count; i++) {
        //SetClientCookie(target_list[i], Handle cookie, const char[] value)
        //LogAction(client, target_list[i], "\"%L\" set \"%L\" as cheater.", client, target_list[i]);
        PerformCheatAnnoyance(target_list[i]);
    }
  }
  return Plugin_Handled;
}

