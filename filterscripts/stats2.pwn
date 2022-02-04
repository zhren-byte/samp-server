#include <a_samp>
#include <zcmd>

new PlayerText:txtKills[MAX_PLAYERS];
new PlayerText:txtDeaths[MAX_PLAYERS];
new bool:scoreactive[MAX_PLAYERS];
enum pScore
{
kills,
death,
}
new PlayerScore[MAX_PLAYERS][pScore];
public OnFilterScriptInit()
{
	print("     Player Information Filterscript Loaded.");
}
public OnPlayerConnect(playerid)
{
	Score_InitTextDraws(playerid);
 	return 1;
}
public OnPlayerSpawn(playerid)
{
	if(scoreactive[playerid] == true){
		return 1;
	}
	for(new i; i < MAX_PLAYERS; i++)
	{
	    Score_InitTextDraws(i);
	}
 	PlayerTextDrawShow(playerid,txtKills[playerid]);
	PlayerTextDrawShow(playerid,txtDeaths[playerid]);
	scoreactive[playerid] = true;
 	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
   if(killerid != INVALID_PLAYER_ID)
   {
       PlayerScore[killerid][kills]++;
	   tt(killerid);
       tt2(killerid);
       
   }
   PlayerScore[playerid][death]++;
   tt(playerid);
   tt2(playerid);
   return true;
}

forward tt(playerid);
public tt(playerid)
{
	new str[128];
	format(str, 128, "Kills: %d",PlayerScore[playerid][kills]);
	return PlayerTextDrawSetString(playerid,txtKills[playerid], str);
}

forward tt2(playerid);
public tt2(playerid)
{
	new str[128];
	format(str, 128, "Death: %d",PlayerScore[playerid][death]);
	return PlayerTextDrawSetString(playerid,txtDeaths[playerid], str);
}
forward Score_InitTextDraws(playerid);
public Score_InitTextDraws(playerid)
{
    txtKills[playerid] = CreatePlayerTextDraw(playerid,503,105,"Kills: 0");
    PlayerTextDrawFont(playerid,txtKills[playerid],2);
    PlayerTextDrawLetterSize(playerid,txtKills[playerid],0.320000,1.100000);
    PlayerTextDrawTextSize(playerid,txtKills[playerid],609.0,21.0);
    PlayerTextDrawColor(playerid,txtKills[playerid],0xFFFFFFFF);
    PlayerTextDrawSetShadow(playerid,txtKills[playerid],0);
    PlayerTextDrawSetOutline(playerid,txtKills[playerid],1);
    PlayerTextDrawUseBox(playerid,txtKills[playerid],1);
    PlayerTextDrawBoxColor(playerid,txtKills[playerid],0x222222BB);
    PlayerTextDrawBackgroundColor(playerid,txtKills[playerid],0x000000FF);

    txtDeaths[playerid] = CreatePlayerTextDraw(playerid,503.000000,119.000000,"Death: 0");
    PlayerTextDrawFont(playerid,txtDeaths[playerid],2);
    PlayerTextDrawLetterSize(playerid,txtDeaths[playerid],0.320000,1.100000);
    PlayerTextDrawTextSize(playerid,txtDeaths[playerid],609.0,21.0);
    PlayerTextDrawColor(playerid,txtDeaths[playerid],0xFFFFFFFF);
    PlayerTextDrawSetShadow(playerid,txtDeaths[playerid],0);
    PlayerTextDrawSetOutline(playerid,txtDeaths[playerid],1);
    PlayerTextDrawUseBox(playerid,txtDeaths[playerid],1);
    PlayerTextDrawBoxColor(playerid,txtDeaths[playerid],0x222222BB);
    PlayerTextDrawBackgroundColor(playerid,txtDeaths[playerid],0x000000FF);
}
CMD:stats(playerid){
    scoreactive[playerid] = false;
    return 1;
}
