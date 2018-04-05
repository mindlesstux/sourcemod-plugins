#pragma semicolon 1

#include <basecomm>
#include <logging>
#include <sourcemod>
#include <sdktools>
#define PLUGIN_VERSION "0.1.0"
#define UPDATE_FILE	"mt_template.updater.txt"
#define CONVAR_PREFIX	"mt_template"

#undef REQUIRE_PLUGIN

// Load the auto updater add that Doctor McKay made
#include "updater_mindlesstux.sp"

public Plugin:myinfo = {
  name = "MT - Template",
  author = "MindlessTux",
  description = "Template plugin that does nothing",
  version = PLUGIN_VERSION,
  url = "https://mindlesstux.com/sourcemod-plugins/"
};

public OnPluginStart()
{
  LogMessage("Plugin Version: %s", PLUGIN_VERSION);
}
