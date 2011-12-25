/* TF2 Trivia
*
*
*
*

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
	RegConsoleCmd("menu_test1", Menu_Test1);
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