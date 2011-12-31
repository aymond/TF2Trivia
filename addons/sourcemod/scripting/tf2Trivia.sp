/* TF2 Trivia
*
* Author: Aymon Delbridge (Hiveminded)
* Date: 25.12.2011
*
* This is my first mod. Please tolerate excessive commenting ;)
* 
*/
#include <sourcemod>
#define VERSION 			"0.0.1.0"
#define QUESTION_POOL_SIZE		10 // This should be dynamically loaded based on an external config/question file.

// Define some colours
#define cDefault				0x01
#define cLightGreen 			0x03
#define cGreen					0x04
#define cDarkGreen  			0x05

new Handle:QuestionPool = INVALID_HANDLE;

public Plugin:myinfo = 
{
	name = "[TF2] Trivia",
	author = "[JR] Hiveminded",
	description = "TF2 Trivia. Test your knowledge for quick buffs.",
	version = VERSION,
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
	// This makes the trigger available to the client in team chat and all chat.
	RegConsoleCmd("say", Command_trivia);
	RegConsoleCmd("say_team", Command_trivia);
	
	/* HookEvents? */
	HookEvent("teamplay_round_active", Event_RoundStart);
	
	ResetStatus();
	
	/* Load any translations? */
	
	/* Load the question pool */
	decl String:qPool[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, qPool, sizeof(qPool), "gamedata/tf2trivia.questionpool.txt");
	
	QuestionPool = CreateKeyValues("QuestionPool");
	if (FileToKeyValues(QuestionPool, qPool))
	{
		PrintToServer("Successfully loaded tf2trivia.questionpool.txt");
	}
	else {
		PrintToServer("Failed to load tf2trivia.questionpool.txt");
	}
	
	
	//RegConsoleCmd("menu_test1", Menu_Test1);
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

public Action:Command_trivia(client, args)
{
	// Check to see if request is from a valid client
	if(client <= 0 || !IsClientInGame(client) || !GetConVarInt(c_Enabled)) return Plugin_Continue;
	
	// Admin Flag cvars?
	
	// Create a new message string
	decl String:strMessage[128];
	GetCmdArgString(strMessage, sizeof(strMessage)); // This gets the args?
	
	// Check for any triggers in the message
	new startidx = 0; // Start of the index. Words are delimited by space automagically.
	if (strMessage[0] == '"'
	{
		// Strip the ending quote if there is one
		startidx = 1;
		new len = strlen(strMessage);		
		if (strMessage[len-1] == '"') 
		{
			strMessage[len-1] = '\0';
		}
	}
	
	// when bool is true, we've found a trigger
	new bool:cond = false;
	for (new i=9; i<g_iTriggers; i++)
	{
		if(StrEqual(chatTriggers[i], strMessage[startidx], false))
		{
			cond = true;
			continue;
		}
	}
	
	if(StrEqual("!trivia", strMessage[startidx], false)) cond = true;
	
	if(!cond) return Plugin_Continue;
	
	// Check to see if a game of trivia is already running.
	// TODO: How to do this? Perhaps set a variable to true if running?
	
	// When it's ok to start a new trivia game:
	new bool:success = Trivia();
	if (!success)
	{
		// What should we do if Trivia fails?
	}
	
	return Plugin_Continue;
	
}

bool:Trivia(client)
{	
	/**
	* bound 	- the size of the question pool.
	* question 	- the question in the pool to ask.
	* 
	*/
	new bound = QUESTION_POOL_SIZE;
	
	new question = GetRandomInt(0, bound-1);
	
	if (question)
	{		
		// Ask the question,
		// Find the question in the question pool based on the random number.
		/* Our question pool is loaded OnPluginStart. Questions are titled as a number.  */
		// Randomize the answer order. 1234 1243 1324 1342 1423 1432 etc where the number is the order of the answers.
		
		// Display the menu that contains the question as the header, and the answers as the menu text.
		// Answer "1" is always the correct answer. So if the menu item is this answer, then the player wins.
		// Correct answer: Give player a buff?		
		// Future: Allow rounds of (n) questions.
		// Future: Keep track of score across a round.
		// Future: Keep track of Red vs Blue
		// Future: Export to log and keep stats.
		// 
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