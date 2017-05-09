//#undef REQUIRE_EXTENSIONS
#include "sourcetvmanager"

public OnPluginStart()
{
	LoadTranslations("common.phrases");

	RegConsoleCmd("sm_servercount", Cmd_GetServerCount);
	RegConsoleCmd("sm_selectserver", Cmd_SelectServer);
	RegConsoleCmd("sm_selectedserver", Cmd_GetSelectedServer);
	RegConsoleCmd("sm_ismaster", Cmd_IsMasterProxy);
	RegConsoleCmd("sm_serverip", Cmd_GetServerIP);
	RegConsoleCmd("sm_serverport", Cmd_GetServerPort);
	RegConsoleCmd("sm_botindex", Cmd_GetBotIndex);
	RegConsoleCmd("sm_broadcasttick", Cmd_GetBroadcastTick);
	RegConsoleCmd("sm_localstats", Cmd_Localstats);
	RegConsoleCmd("sm_globalstats", Cmd_Globalstats);
	RegConsoleCmd("sm_getdelay", Cmd_GetDelay);
	RegConsoleCmd("sm_spectators", Cmd_Spectators);
	RegConsoleCmd("sm_spechintmsg", Cmd_SendHintMessage);
	RegConsoleCmd("sm_specchat", Cmd_SendChatMessage);
	RegConsoleCmd("sm_specchatlocal", Cmd_SendChatMessageLocal);
	RegConsoleCmd("sm_specmsg", Cmd_SendMessage);
	RegConsoleCmd("sm_viewentity", Cmd_GetViewEntity);
	RegConsoleCmd("sm_vieworigin", Cmd_GetViewOrigin);
	RegConsoleCmd("sm_forcechasecam", Cmd_ForceChaseCameraShot);
	//RegConsoleCmd("sm_forcefixedcam", Cmd_ForceFixedCameraShot);
	RegConsoleCmd("sm_startrecording", Cmd_StartRecording);
	RegConsoleCmd("sm_stoprecording", Cmd_StopRecording);
	RegConsoleCmd("sm_isrecording", Cmd_IsRecording);
	RegConsoleCmd("sm_demofile", Cmd_GetDemoFileName);
	RegConsoleCmd("sm_recordtick", Cmd_GetRecordTick);
	RegConsoleCmd("sm_specstatus", Cmd_SpecStatus);
	RegConsoleCmd("sm_democonsole", Cmd_PrintDemoConsole);
	RegConsoleCmd("sm_botcmd", Cmd_ExecuteStringCommand);
	RegConsoleCmd("sm_speckick", Cmd_KickClient);
}

public SourceTV_OnStartRecording(instance, const String:filename[])
{
	PrintToServer("Started recording sourcetv #%d demo to %s", instance, filename);
}

public SourceTV_OnStopRecording(instance, const String:filename[], recordingtick)
{
	PrintToServer("Stopped recording sourcetv #%d demo to %s (%d ticks)", instance, filename, recordingtick);
}

public bool:SourceTV_OnSpectatorPreConnect(const String:name[], String:password[255], const String:ip[], String:rejectReason[255])
{
	PrintToServer("SourceTV spectator is connecting! Name: %s, pw: %s, ip: %s", name, password, ip);
	if (StrEqual(password, "nope", false))
	{
		strcopy(rejectReason, 255, "Heh, that password sucks.");
		return false;
	}
	return true;
}

public SourceTV_OnServerStart(instance)
{
	PrintToServer("SourceTV instance %d started.", instance);
}

public SourceTV_OnServerShutdown(instance)
{
	PrintToServer("SourceTV instance %d shutdown.", instance);
}

public SourceTV_OnSpectatorConnected(client)
{
	PrintToServer("SourceTV client %d connected. (isconnected %d)", client, SourceTV_IsClientConnected(client));
}

public SourceTV_OnSpectatorPutInServer(client)
{
	PrintToServer("SourceTV client %d put in server.", client);
}

public SourceTV_OnSpectatorDisconnect(client, String:reason[255])
{
	PrintToServer("SourceTV client %d is disconnecting (isconnected %d) with reason -> %s.", client, SourceTV_IsClientConnected(client), reason);
}

public SourceTV_OnSpectatorDisconnected(client, const String:reason[255])
{
	PrintToServer("SourceTV client %d disconnected (isconnected %d) with reason -> %s.", client, SourceTV_IsClientConnected(client), reason);
}

public Action:Cmd_GetServerCount(client, args)
{
	ReplyToCommand(client, "SourceTV server count: %d", SourceTV_GetServerInstanceCount());
	return Plugin_Handled;
}

public Action:Cmd_SelectServer(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "Usage: sm_selectserver <instance id>");
		return Plugin_Handled;
	}
	
	new String:sArg[12];
	GetCmdArg(1, sArg, sizeof(sArg));
	new iInstance = StringToInt(sArg);
	
	SourceTV_SelectServerInstance(iInstance);
	ReplyToCommand(client, "SourceTV selecting server: %d", iInstance);
	return Plugin_Handled;
}

public Action:Cmd_GetSelectedServer(client, args)
{
	ReplyToCommand(client, "SourceTV selected server: %d", SourceTV_GetSelectedServerInstance());
	return Plugin_Handled;
}

public Action:Cmd_IsMasterProxy(client, args)
{
	ReplyToCommand(client, "SourceTV is master proxy: %d", SourceTV_IsMasterProxy());
	return Plugin_Handled;
}

public Action:Cmd_GetServerIP(client, args)
{
	new String:sIP[32];
	new bool:bSuccess = SourceTV_GetServerIP(sIP, sizeof(sIP));
	ReplyToCommand(client, "SourceTV server ip (ret %d): %s", bSuccess, sIP);
	return Plugin_Handled;
}

public Action:Cmd_GetServerPort(client, args)
{
	ReplyToCommand(client, "SourceTV server port: %d", SourceTV_GetServerPort());
	return Plugin_Handled;
}

public Action:Cmd_GetBotIndex(client, args)
{
	ReplyToCommand(client, "SourceTV bot index: %d", SourceTV_GetBotIndex());
	return Plugin_Handled;
}

public Action:Cmd_GetBroadcastTick(client, args)
{
	ReplyToCommand(client, "SourceTV broadcast tick: %d", SourceTV_GetBroadcastTick());
	return Plugin_Handled;
}

public Action:Cmd_Localstats(client, args)
{
	new proxies, slots, specs;
	if (!SourceTV_GetLocalStats(proxies, slots, specs))
	{
		ReplyToCommand(client, "SourceTV local stats: no server selected :(");
		return Plugin_Handled;
	}
	ReplyToCommand(client, "SourceTV local stats: proxies %d - slots %d - specs %d", proxies, slots, specs);
	return Plugin_Handled;
}

public Action:Cmd_Globalstats(client, args)
{
	new proxies, slots, specs;
	if (!SourceTV_GetGlobalStats(proxies, slots, specs))
	{
		ReplyToCommand(client, "SourceTV global stats: no server selected :(");
		return Plugin_Handled;
	}
	ReplyToCommand(client, "SourceTV global stats: proxies %d - slots %d - specs %d", proxies, slots, specs);
	return Plugin_Handled;
}

public Action:Cmd_GetDelay(client, args)
{
	ReplyToCommand(client, "SourceTV delay: %f", SourceTV_GetDelay());
	return Plugin_Handled;
}

public Action:Cmd_Spectators(client, args)
{
	ReplyToCommand(client, "SourceTV spectator count: %d/%d", SourceTV_GetSpectatorCount(), SourceTV_GetClientCount());
	new String:sName[64], String:sIP[16], String:sPassword[256];
	for (new i=1;i<=SourceTV_GetClientCount();i++)
	{
		if (!SourceTV_IsClientConnected(i))
			continue;
		
		SourceTV_GetClientName(i, sName, sizeof(sName));
		SourceTV_GetClientIP(i, sIP, sizeof(sIP));
		SourceTV_GetClientPassword(i, sPassword, sizeof(sPassword));
		ReplyToCommand(client, "Client %d%s: %s - %s (password: %s)", i, (SourceTV_IsClientProxy(i)?" (RELAY)":""), sName, sIP, sPassword);
	}
	return Plugin_Handled;
}

public Action:Cmd_SendHintMessage(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "Usage: sm_spechintmsg <message>");
		return Plugin_Handled;
	}
	
	new String:sMsg[1024];
	GetCmdArgString(sMsg, sizeof(sMsg));
	StripQuotes(sMsg);
	
	new bool:bSent = SourceTV_BroadcastScreenMessage(false, "%s", sMsg);
	ReplyToCommand(client, "SourceTV sending hint message (success %d): %s", bSent, sMsg);
	return Plugin_Handled;
}

public Action:Cmd_SendMessage(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "Usage: sm_specmsg <message>");
		return Plugin_Handled;
	}
	
	new String:sMsg[1024];
	GetCmdArgString(sMsg, sizeof(sMsg));
	StripQuotes(sMsg);
	
	new bool:bSent = SourceTV_BroadcastConsoleMessage("%s", sMsg);
	ReplyToCommand(client, "SourceTV sending console message (success %d): %s", bSent, sMsg);
	return Plugin_Handled;
}

public Action:Cmd_SendChatMessage(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "Usage: sm_specchat <message>");
		return Plugin_Handled;
	}
	
	new String:sMsg[128];
	GetCmdArgString(sMsg, sizeof(sMsg));
	StripQuotes(sMsg);
	
	new bool:bSent = SourceTV_BroadcastChatMessage(false, "%s", sMsg);
	ReplyToCommand(client, "SourceTV sending chat message to all spectators (including relays) (success %d): %s", bSent, sMsg);
	return Plugin_Handled;
}

public Action:Cmd_SendChatMessageLocal(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "Usage: sm_specchatlocal <message>");
		return Plugin_Handled;
	}
	
	new String:sMsg[128];
	GetCmdArgString(sMsg, sizeof(sMsg));
	StripQuotes(sMsg);
	
	new bool:bSent = SourceTV_BroadcastChatMessage(true, "%s", sMsg);
	ReplyToCommand(client, "SourceTV sending chat message to local spectators (success %d): %s", bSent, sMsg);
	return Plugin_Handled;
}

public Action:Cmd_GetViewEntity(client, args)
{
	ReplyToCommand(client, "SourceTV view entity: %d", SourceTV_GetViewEntity());
	return Plugin_Handled;
}

public Action:Cmd_GetViewOrigin(client, args)
{
	new Float:pos[3];
	SourceTV_GetViewOrigin(pos);
	ReplyToCommand(client, "SourceTV view origin: %f %f %f", pos[0], pos[1], pos[2]);
	return Plugin_Handled;
}

public Action:Cmd_ForceChaseCameraShot(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "Usage: sm_forcechasecam <target> <ineye>");
		return Plugin_Handled;
	}
	
	new String:sTarget[PLATFORM_MAX_PATH];
	GetCmdArg(1, sTarget, sizeof(sTarget));
	StripQuotes(sTarget);
	new iTarget = FindTarget(client, sTarget, false, false);
	if (iTarget == -1)
		return Plugin_Handled;
	
	new bool:bInEye;
	if (args >= 2)
	{
		new String:sInEye[16];
		GetCmdArg(2, sInEye, sizeof(sInEye));
		StripQuotes(sInEye);
		bInEye = sInEye[0] == '1';
	}
	
	SourceTV_ForceChaseCameraShot(iTarget, 0, 96, -20, (GetRandomFloat()>0.5)?30:-30, bInEye, 20.0);
	ReplyToCommand(client, "SourceTV forcing camera shot on %N.", iTarget);
	return Plugin_Handled;
}

public Action:Cmd_StartRecording(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "Usage: sm_startrecording <filename>");
		return Plugin_Handled;
	}
	
	new String:sFilename[PLATFORM_MAX_PATH];
	GetCmdArgString(sFilename, sizeof(sFilename));
	StripQuotes(sFilename);
	
	if (SourceTV_StartRecording(sFilename))
	{
		SourceTV_GetDemoFileName(sFilename, sizeof(sFilename));
		ReplyToCommand(client, "SourceTV started recording to: %s", sFilename);
	}
	else
		ReplyToCommand(client, "SourceTV failed to start recording to: %s", sFilename);
	return Plugin_Handled;
}

public Action:Cmd_StopRecording(client, args)
{
	ReplyToCommand(client, "SourceTV stopped recording %d", SourceTV_StopRecording());
	return Plugin_Handled;
}

public Action:Cmd_IsRecording(client, args)
{
	ReplyToCommand(client, "SourceTV is recording: %d", SourceTV_IsRecording());
	return Plugin_Handled;
}

public Action:Cmd_GetDemoFileName(client, args)
{
	new String:sFileName[PLATFORM_MAX_PATH];
	ReplyToCommand(client, "SourceTV demo file name (%d): %s", SourceTV_GetDemoFileName(sFileName, sizeof(sFileName)), sFileName);
	return Plugin_Handled;
}

public Action:Cmd_GetRecordTick(client, args)
{
	ReplyToCommand(client, "SourceTV recording tick: %d", SourceTV_GetRecordingTick());
	return Plugin_Handled;
}
	
public Action:Cmd_SpecStatus(client, args)
{
	new iSourceTV = SourceTV_GetBotIndex();
	if (!iSourceTV)
		return Plugin_Handled;
	FakeClientCommand(iSourceTV, "status");
	ReplyToCommand(client, "Sent status bot console.");
	return Plugin_Handled;
}

public Action:Cmd_PrintDemoConsole(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "Usage: sm_democonsole <message>");
		return Plugin_Handled;
	}
	
	new String:sMsg[1024];
	GetCmdArgString(sMsg, sizeof(sMsg));
	StripQuotes(sMsg);
	
	new bool:bSent = SourceTV_PrintToDemoConsole("%s", sMsg);
	ReplyToCommand(client, "SourceTV printing to demo console (success %d): %s", bSent, sMsg);
	return Plugin_Handled;
}

public Action:Cmd_ExecuteStringCommand(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "Usage: sm_botcmd <cmd>");
		return Plugin_Handled;
	}
	
	new String:sCmd[1024];
	GetCmdArgString(sCmd, sizeof(sCmd));
	StripQuotes(sCmd);
	
	new iSourceTV = SourceTV_GetBotIndex();
	if (!iSourceTV)
		return Plugin_Handled;
	FakeClientCommand(iSourceTV, sCmd);
	ReplyToCommand(client, "SourceTV executing command on bot: %s", sCmd);
	return Plugin_Handled;
}

public Action:Cmd_KickClient(client, args)
{
	if (args < 1)
	{
		ReplyToCommand(client, "Usage: sm_speckick <index> <reason>");
		return Plugin_Handled;
	}
	
	new String:sIndex[16], String:sMsg[1024];
	GetCmdArg(1, sIndex, sizeof(sIndex));
	StripQuotes(sIndex);
	GetCmdArg(2, sMsg, sizeof(sMsg));
	StripQuotes(sMsg);
	
	new iTarget = StringToInt(sIndex);
	SourceTV_KickClient(iTarget, sMsg);
	ReplyToCommand(client, "SourceTV kicking spectator %d with reason %s", iTarget, sMsg);
	return Plugin_Handled;
}