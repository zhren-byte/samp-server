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
/*
#include <a_samp>
#include <dini>



enum pInfo
{
kills,
death,
}
new PlayerInfo[MAX_PLAYERS][pInfo];
// FPS
new pDrunkLevelLast[MAX_PLAYERS];
new pFPS[MAX_PLAYERS];

new Text:Textdraw0;
new Text:Textdraw1;
new Text:Textdraw3;
new Text:Textdraw4;
new Text:Textdraw6;

new Text:Score[MAX_PLAYERS];

new Text:Name[MAX_PLAYERS];

forward Infos(playerid);

public OnFilterScriptInit()
{
SetTimer("pScore", 1000, true);
SetTimer("pName", 1000, true);
SetTimer("Infos",1000,true);
SetTimer("tt",1000,1);
print("    StarPeens Player Information Filterscript Loaded.");

// Create the textdraws:
Textdraw0 = TextDrawCreate(504.000000, 102.000000, "--");
TextDrawBackgroundColor(Textdraw0, 255);
TextDrawFont(Textdraw0, 3);
TextDrawLetterSize(Textdraw0, 0.429999, 1.200000);
TextDrawColor(Textdraw0, 16711935);
TextDrawSetOutline(Textdraw0, 1);
TextDrawSetProportional(Textdraw0, 1);

Textdraw1 = TextDrawCreate(503.000000, 113.000000, "--");
TextDrawBackgroundColor(Textdraw1, 65535);
TextDrawFont(Textdraw1, 3);
TextDrawLetterSize(Textdraw1, 0.390000, 1.000000);
TextDrawColor(Textdraw1, -65281);
TextDrawSetOutline(Textdraw1, 1);
TextDrawSetProportional(Textdraw1, 1);

Textdraw3 = TextDrawCreate(503.000000, 134.000000, "_");
TextDrawBackgroundColor(Textdraw3, 255);
TextDrawFont(Textdraw3, 3);
TextDrawLetterSize(Textdraw3, 0.350000, 1.200000);
TextDrawColor(Textdraw3, 16777215);
TextDrawSetOutline(Textdraw3, 1);
TextDrawSetProportional(Textdraw3, 1);

Textdraw4 = TextDrawCreate(502.000000, 145.000000, "_");
TextDrawBackgroundColor(Textdraw4, 255);
TextDrawFont(Textdraw4, 3);
TextDrawLetterSize(Textdraw4, 0.250000, 1.300000);
TextDrawColor(Textdraw4, -16711681);
TextDrawSetOutline(Textdraw4, 1);
TextDrawSetProportional(Textdraw4, 1);

Textdraw6 = TextDrawCreate(556.000000, 49.000000, "--");
TextDrawBackgroundColor(Textdraw6, 65535);
TextDrawFont(Textdraw6, 3);
TextDrawLetterSize(Textdraw6, 0.200000, 1.300000);
TextDrawColor(Textdraw6, -1);
TextDrawSetOutline(Textdraw6, 1);
TextDrawSetProportional(Textdraw6, 1);

return 1;
}

public OnFilterScriptExit()
{
TextDrawHideForAll(Textdraw0);
TextDrawDestroy(Textdraw0);
TextDrawHideForAll(Textdraw1);
TextDrawDestroy(Textdraw1);
TextDrawHideForAll(Textdraw3);
TextDrawDestroy(Textdraw3);
TextDrawHideForAll(Textdraw4);
TextDrawDestroy(Textdraw4);
TextDrawHideForAll(Textdraw6);
TextDrawDestroy(Textdraw6);
return 1;
}
forward pScore(playerid);
public pScore(playerid)
{
  new Str[256];
  format(Str, sizeof(Str), "Score: %d", GetPlayerScore(playerid));
  TextDrawSetString(Score[playerid], Str);
  return 1;
}
forward pName(playerid);
public pName(playerid)
{
  new Str[256];
  new ppName[MAX_PLAYER_NAME];
  GetPlayerName(playerid, ppName, sizeof(ppName));
  format(Str, sizeof(Str), "Name: %s", ppName);
  TextDrawSetString(Name[playerid], Str);
  return 1;
}
public Infos(playerid)
{
	new string[256],year,month,day;
	getdate(year, month, day);
    format(string, sizeof string, "~r~Ping: ~w~%d", GetPlayerPing(playerid));
    TextDrawSetString(Textdraw1, string);
    format(string, sizeof string, "~r~FPS: ~w~%d", GetPlayerFPS(playerid));
    TextDrawSetString(Textdraw0, string);
    format(string, sizeof string, "%d/%s%d/%s%d", day, ((month < 10) ? ("0") : ("")), month, (year < 10) ? ("0") : (""), year);
    TextDrawSetString(Textdraw6, string);
}
stock GetPlayerFPS(playerid)
{
   SetPVarInt(playerid, "DrunkL", GetPlayerDrunkLevel(playerid));
   if(GetPVarInt(playerid, "DrunkL") < 100)
   {
       SetPlayerDrunkLevel(playerid, 2000);
   }
   else
   {
       if(GetPVarInt(playerid, "LDrunkL") != GetPVarInt(playerid, "DrunkL"))
       {
           SetPVarInt(playerid, "FPS", (GetPVarInt(playerid, "LDrunkL") - GetPVarInt(playerid, "DrunkL")));
           SetPVarInt(playerid, "LDrunkL", GetPVarInt(playerid, "DrunkL"));
           if((GetPVarInt(playerid, "FPS") > 0) && (GetPVarInt(playerid, "FPS") < 256))
           {
               return GetPVarInt(playerid, "FPS") - 1;
           }
       }
   }
   return 0;
}
public OnPlayerDisconnect(playerid, reason)
{
Save(playerid);
return 1;
}
stock Load(playerid)
{
   new file[128];
   new name[MAX_PLAYER_NAME];
   GetPlayerName(playerid, name, sizeof(name));
   format(file,sizeof(file),"/%s.ini",name);
   if(!fexist(file))
{
   dini_Create(file);
   dini_IntSet(file,"kills", PlayerInfo[playerid][kills]);
   dini_IntSet(file,"death", PlayerInfo[playerid][death]);
}
   if(fexist(file))
   {
PlayerInfo[playerid][kills] = dini_Int(file,"kills");
PlayerInfo[playerid][death] = dini_Int(file,"kills");
   }
}
stock Save(playerid)
{
   new file[128];
   new name[MAX_PLAYER_NAME];
   GetPlayerName(playerid, name, sizeof(name));
   format(file,sizeof(file),"%s.ini",name);
   if(fexist(file))
   {
   dini_IntSet(file,"kills", PlayerInfo[playerid][kills]);
   dini_IntSet(file,"death", PlayerInfo[playerid][death]);
   }
}
public OnPlayerUpdate(playerid) {

   // handle fps counters.
   new drunknew;
   drunknew = GetPlayerDrunkLevel(playerid);

   if (drunknew < 100) { // go back up, keep cycling.
       SetPlayerDrunkLevel(playerid, 2000);
   } else {

       if (pDrunkLevelLast[playerid] != drunknew) {

           new wfps = pDrunkLevelLast[playerid] - drunknew;

           if ((wfps > 0) && (wfps < 200))
               pFPS[playerid] = wfps;

           pDrunkLevelLast[playerid] = drunknew;
       }

   }

}
public OnPlayerDeath(playerid, killerid, reason)
{
   if(killerid != INVALID_PLAYER_ID)
   {
       tt(killerid);
       tt2(killerid);
       PlayerInfo[killerid][kills]++;
   }
   tt(playerid);
   tt2(playerid);
   PlayerInfo[playerid][death]++;
   return true;
}

forward tt(playerid);
public tt(playerid)
{
new str[128];
format(str, 128, "Kills: %d",PlayerInfo[playerid][kills]);
return TextDrawSetString(Text:Textdraw3, str);
}

forward tt2(playerid);
public tt2(playerid)
{
new str[128];
format(str, 128, "Death: %d",PlayerInfo[playerid][death]);
return TextDrawSetString(Text:Textdraw4, str);
}
public OnPlayerConnect(playerid)
{
Load(playerid);

Score[playerid] = TextDrawCreate(502.000000, 122.000000, " ");
TextDrawBackgroundColor(Score[playerid], -16776961);
TextDrawFont(Score[playerid], 3);
TextDrawLetterSize(Score[playerid], 0.290000, 1.300000);
TextDrawColor(Score[playerid], 255);
TextDrawSetOutline(Score[playerid], 1);
TextDrawSetProportional(Score[playerid], 0);

Name[playerid] = TextDrawCreate(501.000000, 156.000000, " ");
TextDrawBackgroundColor(Name[playerid], -16776961);
TextDrawFont(Name[playerid], 3);
TextDrawLetterSize(Name[playerid], 0.350000, 1.200000);
TextDrawColor(Name[playerid], 16711935);
TextDrawSetOutline(Name[playerid], 1);
TextDrawSetProportional(Name[playerid], 1);
return 1;
}
public OnPlayerSpawn(playerid)
{
TextDrawShowForPlayer(playerid, Textdraw6),TextDrawShowForPlayer(playerid, Textdraw4),TextDrawShowForPlayer(playerid, Textdraw3), TextDrawShowForPlayer(playerid, Name[playerid]),TextDrawShowForPlayer(playerid, Score[playerid]), TextDrawShowForPlayer(playerid, Textdraw1), TextDrawShowForPlayer(playerid, Textdraw0);
return 1;
}*/
