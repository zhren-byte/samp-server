#include <a_samp>
#include <streamer>
#include <sscanf2>
#include <zcmd>
main()
{
	print("\n----------------------------------");
	print("  Bare Script\n");
	print("----------------------------------\n");
}

public OnPlayerConnect(playerid)
{
	GameTextForPlayer(playerid,"~w~Hades: ~r~Server",5000,5);
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 0;
}

public OnPlayerSpawn(playerid)
{
	SetPlayerPos(playerid, 2502.0376,-1669.5127,13.3584);
	SetPlayerSkin(playerid, 240);
	GivePlayerWeapon(playerid, 24, 1000);
	SetPlayerArmour(playerid, 50);
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
    SetPlayerPos(playerid, 2502.0376,-1669.5127,13.3584);
   	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

public OnGameModeInit()
{
 	SetGameModeText("Hades");
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
	ShowNameTags(1);
	SetNameTagDrawDistance(70.0);
	EnableStuntBonusForAll(0);
	SetWeather(2);
	SetWorldTime(11);
	return 1;
}

CMD:guita(playerid, params[]) {
    GivePlayerMoney(playerid, params[1]);
    return 1;
}
