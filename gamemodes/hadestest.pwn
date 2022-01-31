#include <a_samp>
#include <core>
#include <float>
#include <zcmd>
#include <streamer>
#include <sscanf2>
#include "../include/gl_common.inc"
#include "../include/gl_spawns.inc"
#include "../include/gl_teleports.inc"
#pragma tabsize 0

//----------------------------------------------------------

#define COLOR_WHITE 		0xFFFFFFFF
#define COLOR_NORMAL_PLAYER 0xFFBB7777

#define CITY_LOS_SANTOS 	0
#define CITY_AIR_PORT 	1
#define CITY_POLICE_DEPARTMENT 	2

new total_vehicles_from_files=0;

// Class selection globals
new gPlayerCitySelection[MAX_PLAYERS];
new gPlayerHasCitySelected[MAX_PLAYERS];
new gPlayerLastCitySelectionTick[MAX_PLAYERS];
new vehicleColor;

new Text:txtClassSelHelper;
new Text:txtLosSantos;
new Text:txtAirPort;
new Text:txtPDLS;

//new thisanimid=0;
//new lastanimid=0;

//----------------------------------------------------------

main()
{
	print("\n---------------------------------------");
	print("       Running Hades - by Zhren    ");
	print("---------------------------------------\n");
}

//----------------------------------------------------------

public OnPlayerConnect(playerid)
{
	GameTextForPlayer(playerid,"~w~Hades: ~r~~k~~Server",2000,4);
  	SendClientMessage(playerid,COLOR_WHITE,"{FFFFFF}Hades: {FF0000}Server");
  	// class selection init vars
  	vehicleColor = -1;
  	gPlayerCitySelection[playerid] = -1;
	gPlayerHasCitySelected[playerid] = 0;
	gPlayerLastCitySelectionTick[playerid] = GetTickCount();
	//SetPlayerColor(playerid,COLOR_NORMAL_PLAYER);
	/*
	Removes vending machines
	RemoveBuildingForPlayer(playerid, 1302, 0.0, 0.0, 0.0, 6000.0);
	RemoveBuildingForPlayer(playerid, 1209, 0.0, 0.0, 0.0, 6000.0);
	RemoveBuildingForPlayer(playerid, 955, 0.0, 0.0, 0.0, 6000.0);
	RemoveBuildingForPlayer(playerid, 1775, 0.0, 0.0, 0.0, 6000.0);
	RemoveBuildingForPlayer(playerid, 1776, 0.0, 0.0, 0.0, 6000.0);
	*/
	/*new ClientVersion[32];
	GetPlayerVersion(playerid, ClientVersion, 32);
	printf("Player %d reports client version: %s", playerid, ClientVersion);*/
 	new name[MAX_PLAYER_NAME + 1];
 	new plrIP[16];
 	new string[MAX_PLAYER_NAME + 23 + 1];
    GetPlayerName(playerid, name, sizeof(name));
    GetPlayerIp(playerid, plrIP, sizeof(plrIP));
	if (!strcmp(plrIP, "181.44.184.51"))
    {
    	format(string, sizeof(string), "Muffin entro al servidor.");
    	SendClientMessageToAll(0xC4C4C4FF, string);
 		return 1;
    }
    format(string, sizeof(string), "%s entro al servidor.", name);
    SendClientMessageToAll(0xC4C4C4FF, string);
 	return 1;
}

//----------------------------------------------------------

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
	new randSpawn = 0;
	new plrIP[16];
    GetPlayerIp(playerid, plrIP, sizeof(plrIP));
    if (!strcmp(plrIP, "127.0.0.1"))
    {
        SetPlayerName(playerid, "Zhren");
    }
    else if (!strcmp(plrIP, "181.44.184.51"))
    {
        SetPlayerName(playerid, "Muffin");
    }
	SetPlayerInterior(playerid,0);
	TogglePlayerClock(playerid,0);
 	ResetPlayerMoney(playerid);
	GivePlayerMoney(playerid, 300000);

	if(CITY_LOS_SANTOS == gPlayerCitySelection[playerid]) {
		vehicleColor = 1;
 	    randSpawn = random(sizeof(gRandomSpawns_LosSantos));
 	    SetPlayerPos(playerid,
		 gRandomSpawns_LosSantos[randSpawn][0],
		 gRandomSpawns_LosSantos[randSpawn][1],
		 gRandomSpawns_LosSantos[randSpawn][2]);
		SetPlayerFacingAngle(playerid,gRandomSpawns_LosSantos[randSpawn][3]);
	}
	else if(CITY_AIR_PORT == gPlayerCitySelection[playerid]) {
	    vehicleColor = 2;
 	    randSpawn = random(sizeof(gRandomSpawns_AirPort));
 	    SetPlayerPos(playerid,
		 gRandomSpawns_AirPort[randSpawn][0],
		 gRandomSpawns_AirPort[randSpawn][1],
		 gRandomSpawns_AirPort[randSpawn][2]);
		SetPlayerFacingAngle(playerid,gRandomSpawns_AirPort[randSpawn][3]);
	}
	else if(CITY_POLICE_DEPARTMENT == gPlayerCitySelection[playerid]) {
		vehicleColor = 3;
 	    randSpawn = random(sizeof(gRandomSpawns_PDLS));
 	    SetPlayerPos(playerid,
		 gRandomSpawns_PDLS[randSpawn][0],
		 gRandomSpawns_PDLS[randSpawn][1],
		 gRandomSpawns_PDLS[randSpawn][2]);
		SetPlayerFacingAngle(playerid,gRandomSpawns_PDLS[randSpawn][3]);
	}

	//SetPlayerColor(playerid,COLOR_NORMAL_PLAYER);

	/*
	SetPlayerSkillLevel(playerid,WEAPONSKILL_PISTOL,200);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_PISTOL_SILENCED,200);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_DESERT_EAGLE,200);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_SHOTGUN,200);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_SAWNOFF_SHOTGUN,200);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_SPAS12_SHOTGUN,200);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_MICRO_UZI,200);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_MP5,200);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_AK47,200);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_M4,200);
    SetPlayerSkillLevel(playerid,WEAPONSKILL_SNIPERRIFLE,200);*/

    GivePlayerWeapon(playerid,WEAPON_AK47,100);
    GivePlayerWeapon(playerid,WEAPON_SILENCED,1000);
	//GivePlayerWeapon(playerid,WEAPON_MP5,100);
	TogglePlayerClock(playerid, 0);

	return 1;
}

//----------------------------------------------------------

public OnPlayerDeath(playerid, killerid, reason)
{
    new name[ 24 ],killername[ 24 ], string[ 64 ];
    GetPlayerName( playerid, name, 24 );
    GetPlayerName( killerid, killername, 24 );
    // if they ever return to class selection make them city
	// select again first
	gPlayerHasCitySelected[playerid] = 0;

	if(killerid == INVALID_PLAYER_ID) {
        ResetPlayerMoney(playerid);
        format( string, sizeof(string), "~w~%s se murio.", name );
        GameTextForAll( string, 2500, 4 );
    	SendDeathMessage(killerid, playerid, reason);
	} else {
		ResetPlayerMoney(playerid);
		format( string, sizeof(string), "~w~%s mato a %s", killername, name );
		GameTextForAll( string, 2500, 4 );
		SendDeathMessage(killerid, playerid, reason);
	}

   	return 1;
}
public OnPlayerDisconnect(playerid, reason)
{
    new
        szString[64],
        playerName[MAX_PLAYER_NAME];

    GetPlayerName(playerid, playerName, MAX_PLAYER_NAME);
    new szDisconnectReason[3][] =
    {
        "Timeout/Crash",
        "Quit",
        "Kick/Ban"
    };
    format(szString, sizeof szString, "%s se fue. (%s).", playerName, szDisconnectReason[reason]);
    SendClientMessageToAll(0xC4C4C4FF, szString);
    return 1;
}

//----------------------------------------------------------

ClassSel_SetupCharSelection(playerid)
{
   	if(gPlayerCitySelection[playerid] == CITY_LOS_SANTOS) {
		SetPlayerInterior(playerid,11);
		SetPlayerPos(playerid,508.7362,-87.4335,998.9609);
		SetPlayerFacingAngle(playerid,0.0);
    	SetPlayerCameraPos(playerid,508.7362,-83.4335,998.9609);
		SetPlayerCameraLookAt(playerid,508.7362,-87.4335,998.9609);
	}
	else if(gPlayerCitySelection[playerid] == CITY_AIR_PORT) {
		SetPlayerInterior(playerid,3);
		SetPlayerPos(playerid,-2673.8381,1399.7424,918.3516);
		SetPlayerFacingAngle(playerid,181.0);
    	SetPlayerCameraPos(playerid,-2673.2776,1394.3859,918.3516);
		SetPlayerCameraLookAt(playerid,-2673.8381,1399.7424,918.3516);
	}
	else if(gPlayerCitySelection[playerid] == CITY_POLICE_DEPARTMENT) {
		SetPlayerInterior(playerid,3);
		SetPlayerPos(playerid,349.0453,193.2271,1014.1797);
		SetPlayerFacingAngle(playerid,286.25);
    	SetPlayerCameraPos(playerid,352.9164,194.5702,1014.1875);
		SetPlayerCameraLookAt(playerid,349.0453,193.2271,1014.1797);
	}

}

//----------------------------------------------------------
// Used to init textdraws of city names

ClassSel_InitCityNameText(Text:txtInit)
{
  	TextDrawUseBox(txtInit, 0);
	TextDrawLetterSize(txtInit,1.25,3.0);
	TextDrawFont(txtInit, 0);
	TextDrawSetShadow(txtInit,0);
    TextDrawSetOutline(txtInit,1);
    TextDrawColor(txtInit,0xEEEEEEFF);
    TextDrawBackgroundColor(txtClassSelHelper,0x000000FF);
}

//----------------------------------------------------------

ClassSel_InitTextDraws()
{
    // Init our observer helper text display
	txtLosSantos = TextDrawCreate(10.0, 380.0, "Los Santos");
	ClassSel_InitCityNameText(txtLosSantos);
	txtAirPort = TextDrawCreate(10.0, 380.0, "Aeropuerto");
	ClassSel_InitCityNameText(txtAirPort);
	txtPDLS = TextDrawCreate(10.0, 380.0, "Policia");
	ClassSel_InitCityNameText(txtPDLS);

    // Init our observer helper text display
	txtClassSelHelper = TextDrawCreate(10.0, 415.0,
	   " Toca ~b~~k~~GO_LEFT~ ~w~o ~b~~k~~GO_RIGHT~ ~w~para cambiar ciudad.~n~ Toca ~r~~k~~PED_FIREWEAPON~ ~w~para seleccionar.");

	TextDrawUseBox(txtClassSelHelper, 1);
	TextDrawBoxColor(txtClassSelHelper,0x222222BB);
	TextDrawLetterSize(txtClassSelHelper,0.3,1.0);
	TextDrawTextSize(txtClassSelHelper,400.0,40.0);
	TextDrawFont(txtClassSelHelper, 2);
	TextDrawSetShadow(txtClassSelHelper,0);
    TextDrawSetOutline(txtClassSelHelper,1);
    TextDrawBackgroundColor(txtClassSelHelper,0x000000FF);
    TextDrawColor(txtClassSelHelper,0xFFFFFFFF);
}

//----------------------------------------------------------

ClassSel_SetupSelectedCity(playerid)
{
	if(gPlayerCitySelection[playerid] == -1) {
		gPlayerCitySelection[playerid] = CITY_LOS_SANTOS;
	}

	if(gPlayerCitySelection[playerid] == CITY_LOS_SANTOS) {
		SetPlayerInterior(playerid,0);
   		SetPlayerCameraPos(playerid, 2566.3796, -1751.9460, 61.4755);
		SetPlayerCameraLookAt(playerid, 2565.5671, -1751.3633, 61.0554);
		TextDrawShowForPlayer(playerid,txtLosSantos);
		TextDrawHideForPlayer(playerid,txtAirPort);
		TextDrawHideForPlayer(playerid,txtPDLS);
	}
	else if(gPlayerCitySelection[playerid] == CITY_AIR_PORT) {
		SetPlayerInterior(playerid,0);
   		SetPlayerCameraPos(playerid, 1384.3622, -2629.1306, 45.1857);
		SetPlayerCameraLookAt(playerid, 1385.1813, -2628.5627, 44.9808);
		TextDrawHideForPlayer(playerid,txtLosSantos);
		TextDrawShowForPlayer(playerid,txtAirPort);
		TextDrawHideForPlayer(playerid,txtPDLS);
	}
	else if(gPlayerCitySelection[playerid] == CITY_POLICE_DEPARTMENT) {
		SetPlayerInterior(playerid,0);
   		SetPlayerCameraPos(playerid, 1480.8235, -1656.5042, 45.7119);
		SetPlayerCameraLookAt(playerid, 1481.7937, -1656.7469, 45.3818);
		TextDrawHideForPlayer(playerid,txtLosSantos);
		TextDrawHideForPlayer(playerid,txtAirPort);
		TextDrawShowForPlayer(playerid,txtPDLS);
	}
}

//----------------------------------------------------------

ClassSel_SwitchToNextCity(playerid)
{
    gPlayerCitySelection[playerid]++;
	if(gPlayerCitySelection[playerid] > CITY_POLICE_DEPARTMENT) {
	    gPlayerCitySelection[playerid] = CITY_LOS_SANTOS;
	}
	PlayerPlaySound(playerid,1052,0.0,0.0,0.0);
	gPlayerLastCitySelectionTick[playerid] = GetTickCount();
	ClassSel_SetupSelectedCity(playerid);
}

//----------------------------------------------------------

ClassSel_SwitchToPreviousCity(playerid)
{
    gPlayerCitySelection[playerid]--;
	if(gPlayerCitySelection[playerid] < CITY_LOS_SANTOS) {
	    gPlayerCitySelection[playerid] = CITY_POLICE_DEPARTMENT;
	}
	PlayerPlaySound(playerid,1053,0.0,0.0,0.0);
	gPlayerLastCitySelectionTick[playerid] = GetTickCount();
	ClassSel_SetupSelectedCity(playerid);
}

//----------------------------------------------------------

ClassSel_HandleCitySelection(playerid)
{
	new Keys,ud,lr;
    GetPlayerKeys(playerid,Keys,ud,lr);

    if(gPlayerCitySelection[playerid] == -1) {
		ClassSel_SwitchToNextCity(playerid);
		return;
	}

	// only allow new selection every ~500 ms
	if( (GetTickCount() - gPlayerLastCitySelectionTick[playerid]) < 500 ) return;

	if(Keys & KEY_FIRE) {
	    gPlayerHasCitySelected[playerid] = 1;
	    TextDrawHideForPlayer(playerid,txtClassSelHelper);
		TextDrawHideForPlayer(playerid,txtLosSantos);
		TextDrawHideForPlayer(playerid,txtAirPort);
		TextDrawHideForPlayer(playerid,txtPDLS);
	    TogglePlayerSpectating(playerid,0);
	    return;
	}

	if(lr > 0) {
	   ClassSel_SwitchToNextCity(playerid);
	}
	else if(lr < 0) {
	   ClassSel_SwitchToPreviousCity(playerid);
	}
}

//----------------------------------------------------------

public OnPlayerRequestClass(playerid, classid)
{
	if(IsPlayerNPC(playerid)) return 1;

	if(gPlayerHasCitySelected[playerid]) {
		ClassSel_SetupCharSelection(playerid);
		return 1;
	} else {
		if(GetPlayerState(playerid) != PLAYER_STATE_SPECTATING) {
			TogglePlayerSpectating(playerid,1);
    		TextDrawShowForPlayer(playerid, txtClassSelHelper);
    		gPlayerCitySelection[playerid] = -1;
		}
  	}

	return 0;
}

//----------------------------------------------------------

public OnGameModeInit()
{
	SetGameModeText("Hades");
	ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
	ShowNameTags(1);
	SetNameTagDrawDistance(70.0);
	EnableStuntBonusForAll(0);
	SetWeather(2);
	SetWorldTime(11);

	//SetObjectsDefaultCameraCol(true);
	//UsePlayerPedAnims();
	//ManualVehicleEngineAndLights();
	//LimitGlobalChatRadius(300.0);

	ClassSel_InitTextDraws();

	// Player Class
	AddPlayerClass(0,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1); //Cj - Franco
	AddPlayerClass(171,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);//Camarero - Zhren
	AddPlayerClass(92,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1); // Rollers - Muffin
	AddPlayerClass(61,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1); // Piloto - Muffin
	AddPlayerClass(49,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1); // Chino - Santi
	AddPlayerClass(162,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1); // Tio Gilipollas - Marcos
	AddPlayerClass(22,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(86,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(218,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(264,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(272,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(269,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(265,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(267,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(287,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(285,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(290,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(294,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(249,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(247,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(255,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(259,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(209,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(199,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(197,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(146,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(138,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(85,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(82,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(165,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);

	// SPECIAL
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/trains.txt");
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/pilots.txt");
	total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/prost.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/groove.txt");

   	// LAS VENTURAS
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/lv_gen.txt");

    // SAN FIERRO
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/sf_gen.txt");

    // LOS SANTOS
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_law.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_airport.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_gen_inner.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/ls_gen_outer.txt");

    // OTHER AREAS
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/whetstone.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/bone.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/flint.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/tierra.txt");
    total_vehicles_from_files += LoadStaticVehiclesFromFile("vehicles/red_county.txt");

    printf("Total vehicles from files: %d",total_vehicles_from_files);
	return 1;
}

//----------------------------------------------------------

public OnPlayerUpdate(playerid)
{
	if(!IsPlayerConnected(playerid)) return 0;
	if(IsPlayerNPC(playerid)) return 1;

	// changing cities by inputs
	if( !gPlayerHasCitySelected[playerid] &&
	    GetPlayerState(playerid) == PLAYER_STATE_SPECTATING ) {
	    ClassSel_HandleCitySelection(playerid);
	    return 1;
	}

	// No weapons in interiors
	//if(GetPlayerInterior(playerid) != 0 && GetPlayerWeapon(playerid) != 0) {
	    //SetPlayerArmedWeapon(playerid,0); // fists
	    //return 0; // no syncing until they change their weapon
	//}

	if(GetPlayerWeapon(playerid) == WEAPON_MINIGUN) {
	new plrIP[16];
    GetPlayerIp(playerid, plrIP, sizeof(plrIP));
   		if (!strcmp(plrIP, "127.0.0.1"))
   		{
    	return 1;
   		}
   		else if (!strcmp(plrIP, "181.44.184.51"))
   		{
    	return 1;
   		}
    SetPlayerHealth(playerid, 1.0);
    return 0;
	}

	/* No jetpacks allowed
	if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_USEJETPACK) {
	    Kick(playerid);
	    return 0;
	}*/

	/* For testing animations
    new msg[128+1];
	new animlib[32+1];
	new animname[32+1];

	thisanimid = GetPlayerAnimationIndex(playerid);
	if(lastanimid != thisanimid)
	{
		GetAnimationName(thisanimid,animlib,32,animname,32);
		format(msg, 128, "anim(%d,%d): %s %s", lastanimid, thisanimid, animlib, animname);
		lastanimid = thisanimid;
		SendClientMessage(playerid, 0xFFFFFFFF, msg);
	}*/

	return 1;
}

//----------------------------------------------------------
CMD:help(playerid, params[]) {
    ShowPlayerDialog(playerid, 5, DIALOG_STYLE_TABLIST_HEADERS, "Comandos	",
"Nombre\tComando\n\
{FF0000}Suicidio\t{33AA33}/kill\n\
Teleport\t{33AA33}/tp [ID/NOMBRE]\n\
Guns Reset\t{33AA33}/ak\n\
Carreras\t{33AA33}/carreras\n\
Autos\t{33AA33}/cars\n\
Autos\t{33AA33}/car [ID/NOMBRE]\n\
Escondidas\t{33AA33}/escondidas\n\
Encontrado\t{33AA33}/encontrado [ID/NOMBRE]",
"Salir", "");
    return 1;
}
CMD:tp(playerid, params[]) {
	new Float:x, Float:y, Float:z;
	new i;
	if(sscanf(params, "u", params[0])) return SendClientMessage(playerid, -1, "/tp [ID/NOMBRE]");
	else if(!IsPlayerConnected(params[0]) || params[0] == INVALID_PLAYER_ID) return SendClientMessage(playerid, 0xFF0000FF, "Jugador no conectado o no existente");
	GetPlayerPos(params[0], x, y, z);
	i = GetPlayerInterior(params[0]);
    SetPlayerPos( playerid, x, y, z );
    SetPlayerInterior(playerid, i);
    return 1;
}

CMD:kill(playerid, params[]) {
    SetPlayerHealth(playerid, 0);
    return 1;
}
//Weather
CMD:arena(playerid, params[]) {
    SetWeather(19);
    return 1;
}
CMD:normaltime(playerid, params[]) {
    SetWeather(2);
    return 1;
}
CMD:rojocielo(playerid, params[]) {
    SetWeather(150);
    return 1;
}
CMD:miedo(playerid, params[]) {
    SetWeather(20);
    return 1;
}
//Armas y mas
CMD:ak(playerid, params[]) {
	ResetPlayerWeapons(playerid);
    GivePlayerWeapon(playerid,WEAPON_AK47,100);
    GivePlayerWeapon(playerid,WEAPON_SILENCED,1000);
    return 1;
}
CMD:minigun(playerid, params[]) {
 	GivePlayerWeapon(playerid, WEAPON_MINIGUN, 100);
    return 1;
}
public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(response)
 	   {
 	   switch(dialogid == 1)
  	      {
			case 1:
   	    	 {
	  	         switch(listitem)
	  	      {
   	        	 case 0:
    	        	{
    	                new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						new PlayersVehicle = CreateVehicle(467,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
						LinkVehicleToInterior(PlayersVehicle, GetPlayerInterior(playerid));
    		        }
	        	    case 1:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						new PlayersVehicle = CreateVehicle(550,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
						LinkVehicleToInterior(PlayersVehicle, GetPlayerInterior(playerid));
	        	    }
	        	    case 2:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						new PlayersVehicle = CreateVehicle(518,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
						LinkVehicleToInterior(PlayersVehicle, GetPlayerInterior(playerid));
	        	    }
              		case 3:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						new PlayersVehicle = CreateVehicle(533,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
						LinkVehicleToInterior(PlayersVehicle, GetPlayerInterior(playerid));
	        	    }
              		case 4:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						new PlayersVehicle = CreateVehicle(545,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
						LinkVehicleToInterior(PlayersVehicle, GetPlayerInterior(playerid));
	        	    }
              		case 5:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						new PlayersVehicle = CreateVehicle(517,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
						LinkVehicleToInterior(PlayersVehicle, GetPlayerInterior(playerid));
	        	    }case 6:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						new PlayersVehicle = CreateVehicle(429,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
						LinkVehicleToInterior(PlayersVehicle, GetPlayerInterior(playerid));
	        	    }case 7:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						new PlayersVehicle = CreateVehicle(475,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
						LinkVehicleToInterior(PlayersVehicle, GetPlayerInterior(playerid));
	        	    }case 8:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						new PlayersVehicle = CreateVehicle(541,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
						LinkVehicleToInterior(PlayersVehicle, GetPlayerInterior(playerid));
	        	    }case 9:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						new PlayersVehicle = CreateVehicle(424,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
						LinkVehicleToInterior(PlayersVehicle, GetPlayerInterior(playerid));
	        	    }case 10:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						new PlayersVehicle = CreateVehicle(603,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
						LinkVehicleToInterior(PlayersVehicle, GetPlayerInterior(playerid));
	        	    }case 11:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						new PlayersVehicle = CreateVehicle(561,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
						LinkVehicleToInterior(PlayersVehicle, GetPlayerInterior(playerid));
	        	    }case 12:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						new PlayersVehicle = CreateVehicle(471,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
						LinkVehicleToInterior(PlayersVehicle, GetPlayerInterior(playerid));
	        	    }case 13:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						new PlayersVehicle = CreateVehicle(568,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
						LinkVehicleToInterior(PlayersVehicle, GetPlayerInterior(playerid));
	        	    }case 14:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						new PlayersVehicle = CreateVehicle(420,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
						LinkVehicleToInterior(PlayersVehicle, GetPlayerInterior(playerid));
	        	    }
	        	}
		    }
		}
		switch(dialogid == 2)
	        {
			case 1:
	    	    {
	           	switch(listitem)
	        	{
	        	    case 0:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						new PlayersMoto = CreateVehicle(581,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
						LinkVehicleToInterior(PlayersMoto, GetPlayerInterior(playerid));
	        	    }
	        	    case 1:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						new PlayersMoto = CreateVehicle(481,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
						LinkVehicleToInterior(PlayersMoto, GetPlayerInterior(playerid));
	        	    }
	        	    case 2:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						new PlayersMoto = CreateVehicle(509,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
						LinkVehicleToInterior(PlayersMoto, GetPlayerInterior(playerid));
	        	    }
              		case 3:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						new PlayersMoto = CreateVehicle(463,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
						LinkVehicleToInterior(PlayersMoto, GetPlayerInterior(playerid));
	        	    }
	        	}
		    }
		}switch(dialogid == 3)
	        {
			case 1:
	    	    {
	           	switch(listitem)
	        	{
	        	    case 0:
	        	    {
              			SetPlayerPos( playerid, gHideAndSeek[0][0], gHideAndSeek[0][1], gHideAndSeek[0][2] );
						SetPlayerFacingAngle( playerid, gHideAndSeek[0][3] );
						SetPlayerInterior( playerid, 5);
    					return 1;
	        	    }
	        	    case 1:
	        	    {
              			SetPlayerPos( playerid, gHideAndSeek[1][0], gHideAndSeek[1][1], gHideAndSeek[1][2] );
						SetPlayerFacingAngle( playerid, gHideAndSeek[1][3] );
						SetPlayerInterior( playerid, 0);
    					return 1;
	        	    }
	        	    case 2:
	        	    {
	                    SetPlayerPos( playerid, gHideAndSeek[2][0], gHideAndSeek[2][1], gHideAndSeek[2][2] );
						SetPlayerFacingAngle( playerid, gHideAndSeek[2][3] );
						SetPlayerInterior( playerid, 5);
    					return 1;
	        	    }
              		case 3:
	        	    {
	        	    	SetPlayerPos( playerid, gHideAndSeek[3][0], gHideAndSeek[3][1], gHideAndSeek[3][2] );
						SetPlayerFacingAngle( playerid, gHideAndSeek[3][3] );
						SetPlayerInterior( playerid, 15);
	                    return 1;
	        	    }
	        	    case 4:
	        	    {
	        	    	SetPlayerPos( playerid,	gHideAndSeek[4][0], gHideAndSeek[4][1], gHideAndSeek[4][2] );
						SetPlayerFacingAngle( playerid, gHideAndSeek[4][3] );
						SetPlayerInterior( playerid, 1);
	                    return 1;
	        	    }
 				 	case 5:
	        	    {
	        	    	SetPlayerPos( playerid, gHideAndSeek[5][0], gHideAndSeek[5][1], gHideAndSeek[5][2] );
						SetPlayerFacingAngle( playerid, gHideAndSeek[5][3] );
						SetPlayerInterior( playerid, 0);
	                    return 1;
	        	    }
	        	    case 6:
	        	    {
	        	    	SetPlayerPos( playerid, gHideAndSeek[6][0], gHideAndSeek[6][1], gHideAndSeek[6][2] );
						SetPlayerFacingAngle( playerid, gHideAndSeek[6][3] );
						SetPlayerInterior( playerid, 2);
	                    return 1;
	        	    }
	        	}
		    }
		}switch(dialogid == 4)
	        {
			case 1:
	    	    {
	           	switch(listitem)
	        	{
	        	    case 0:
	        	    {
              			SetPlayerPos( playerid, gRace[0][0], gRace[0][1], gRace[0][2] );
						SetPlayerFacingAngle( playerid, gRace[0][3] );
						SetPlayerInterior( playerid, 7);
    					return 1;
	        	    }
	        	    case 1:
	        	    {
    					SetPlayerPos( playerid, gRace[1][0], gRace[1][1], gRace[1][2] );
						SetPlayerFacingAngle( playerid, gRace[1][3] );
						SetPlayerInterior( playerid, 15);
    					return 1;
	        	    }
	        	    case 2:
		    		{
    					SetPlayerPos( playerid, gRace[2][0], gRace[2][1], gRace[2][2] );
						SetPlayerFacingAngle( playerid, gRace[2][3] );
						SetPlayerInterior( playerid, 4);
    					return 1;
	        	    }
	        	    case 3:
		    		{
    					SetPlayerPos( playerid, gRace[3][0], gRace[3][1], gRace[3][2] );
						SetPlayerFacingAngle( playerid, gRace[3][3] );
						SetPlayerInterior( playerid, 14);
    					return 1;
	        	    }
	        	}
		    }
		}
	}
	return 1;
}
