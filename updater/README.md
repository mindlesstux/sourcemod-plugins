# sourcemod-plugins

Things in this folder are to allow for the Updater plugin to pull updates as I write them.
https://forums.alliedmods.net/showthread.php?t=169095


Structure should be as follows where needed

   /plugin_name/
   /plugin_name/updatefile.txt
   /plugin_name/plugins/plugin_name.smx
   /plugin_name/translations/plugin_name.phrases.txt
   /plugin_name/translations/[ru,uk,ff,etc.]/plugin_name.phrases.txt
   /plugin_name/models/characters/batman.mdl
   /plugin_name/materials/models/characters/batman.vmt
   /plugin_name/scripting/plugin_name.sp


Contents of the updatefile.txt:

   "Updater"
   {
   	"Information"
   	{
   		"Version"
   		{
   			"Latest"	"1.0.1"
   		}
   		
   		"Notes"	"More info @ www.sourcemod.net. Changes in 1.0.1:"
   		"Notes"	"Added new Batman model"
   		"Notes"	"Minor code changes"
   	}
   	
   	"Files"
   	{
   		"Plugin"	"Path_SM/plugins/myplugin.smx"
   		"Plugin"	"Path_SM/translations/myplugin.phrases.txt"
   		"Plugin"	"Path_SM/translations/ru/myplugin.phrases.txt"
   		"Plugin"	"Path_Mod/models/characters/batman.mdl"
   		"Plugin"	"Path_Mod/materials/models/characters/batman.vmt"
   		
   		"Source"	"Path_SM/scripting/myplugin.sp"
   	}
   }
