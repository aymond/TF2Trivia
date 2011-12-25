/* TF2 Trivia
*
* Author: Aymon Delbridge (Hiveminded)
* Date: 25.12.2011
*
*/
#include <sourcemod>
#define PLUGIN_VERSION "0.0.1.0"

public Plugin:myinfo = 
{
	name = "[TF2] Trivia",
	author = "[JR] Hiveminded",
	description = "TF2 Trivia. Test your knowledge for quick buffs.",
	version = PLUGIN_VERSION,
	url = "http://www.jrtf2.com"
}

public OnPluginStart()
{
	/* Initialisation */
	c_Enabled	= CreateConVar("sm_trivia_enable",		"1",	"<0/1> Enable Trivia");
	c_TimeLimit = CreateConVar("sm_trivia_timelimit",	"120", 	"<0-x> Time in seconds between Trivia Rounds");
	c_EDuration = CreateConVar("sm_trivia_eduration",	"10",	"<0.1-x> Time in seconds that the Trivia effects last");
	c_QDuration = CreateConVar("sm_trivia_qduration",	"20",	"<1-x> Time in seconds given to answer Trivia question");
	c_trigger	= CreateConVar("sm_trivia_trigger",		"trivia,triv",	"Trivia triggers - separated by commas");
	
	/* Register Console Commands */
	RegConsoleCmd("say", Command_trivia);
	RegConsoleCmd("say_team", Command_trivia);
	
	/* HookEvents? */
	HookEvent("teamplay_round_active", Event_RoundStart);
	
	ResetStatus();
	
	/* Load any translations? */
	
	RegConsoleCmd("menu_test1", Menu_Test1);
}
 
public OnMapStart()
{
	ResetStatus();
}

public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast)
{
	if (GetConVarInt(c_Enabled))
		printToChatAll("%c[TF2Trivia]%c%T", cGreen, cDefault, "Announcement_Message", LANG_SERVER, cGreen, cDefault);
}

public Parse_Chat_Triggers(const String:strStriggers[])
{
	g_iTriggers = ExplodeString(strTriggers, ",", chatTriggers, MAX_CHAT_TRIGGERS, MAX_CHAT_TRIGGER_LENGTH);
}
	
public ResetStatus()
{
	for (new i=0;i<MAXPLAYERS+1;i++)
	{
		CleanPlayer(i);
		TrackPlayers[i][PLAYER_FLAG] = 0;
	}
}

public MenuHandler1(Handle:menu, MenuAction:action, param1, param2)
{
	/* If an option was selected, tell the client about the item. */
	if (action == MenuAction_Select)
	{
		new String:info[32];
		new bool:found = GetMenuItem(menu, param2, info, sizeof(info));
		PrintToConsole(param1, "You selected item: %d (found? %d info: %s)", param2, found, info);
	}
	/* If the menu was cancelled, print a message to the server about it. */
	else if (action == MenuAction_Cancel)
	{
		PrintToServer("Client %d's menu was cancelled.  Reason: %d", param1, param2);
	}
	/* If the menu has ended, destroy it */
	else if (action == MenuAction_End)
	{
		CloseHandle(menu);
	}
}
 
public Action:Menu_Test1(client, args)
{
	new Handle:menu = CreateMenu(MenuHandler1);
	SetMenuTitle(menu, "Do you like apples?");
	AddMenuItem(menu, "yes", "Yes");
	AddMenuItem(menu, "no", "No");
	SetMenuExitButton(menu, false);
	DisplayMenu(menu, client, 20);
 
	return Plugin_Handled;
}