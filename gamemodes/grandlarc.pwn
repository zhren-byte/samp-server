#include <a_samp>
#include <core>
#include <float>
#include <zcmd>
#include "../include/gl_common.inc"
#include "../include/gl_spawns.inc"
#include <streamer>
#include <sscanf2>
#pragma tabsize 0

//----------------------------------------------------------

#define COLOR_WHITE 		0xFFFFFFFF
#define COLOR_NORMAL_PLAYER 0xFFBB7777

#define CITY_LOS_SANTOS 	0
#define CITY_AIR_PORT 	1
#define CITY_POLICE_DEPARTMENT 	2
#define CITY_PROSTITUTION  3

//new total_vehicles_from_files=0;

// Class selection globals
new gPlayerCitySelection[MAX_PLAYERS];
new gPlayerHasCitySelected[MAX_PLAYERS];
new gPlayerLastCitySelectionTick[MAX_PLAYERS];
new vehicleColor;

new Text:txtClassSelHelper;
new Text:txtLosSantos;
new Text:txtAirPort;
new Text:txtPDLS;
new Text:txtProstitution;

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
	GameTextForPlayer(playerid,"~w~Hades: ~r~~k~~Server",3000,4);
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
	
	
	new ClientVersion[32];
	GetPlayerVersion(playerid, ClientVersion, 32);
	printf("Player %d reports client version: %s", playerid, ClientVersion);

 	return 1;
}

//----------------------------------------------------------

public OnPlayerSpawn(playerid)
{
	if(IsPlayerNPC(playerid)) return 1;
 	new plrIP[16];
    GetPlayerIp(playerid, plrIP, sizeof(plrIP));
    if (!strcmp(plrIP, "181.44.184.115"))
    {
        SendClientMessage(playerid, 0xFFFFFFFF, "Hola franco jijiji");
    }
    else if (!strcmp(plrIP, "200.125.116.176"))
    {
        SendClientMessage(playerid, 0xFFFFFFFF, "Hola Marcos jijiji");
    }
    else if (!strcmp(plrIP, "200.115.214.217"))
    {
        SendClientMessage(playerid, 0xFFFFFFFF, "Hola franco jijiji");
    }
    if (!strcmp(plrIP, "181.45.34.142"))
    {
        SendClientMessage(playerid, 0xFFFFFFFF, "Hola santi jijiji");
    }
    if (!strcmp(plrIP, "181.44.184.51"))
    {
        SendClientMessage(playerid, 0xFFFFFFFF, "Hola mufin jijiji");
    }
	new randSpawn = 0;
	
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
	else if(CITY_PROSTITUTION == gPlayerCitySelection[playerid]) {
	    vehicleColor = 4;
 	    randSpawn = random(sizeof(gRandomSpawns_Prostitution));
 	    SetPlayerPos(playerid,
		 gRandomSpawns_Prostitution[randSpawn][0],
		 gRandomSpawns_Prostitution[randSpawn][1],
		 gRandomSpawns_Prostitution[randSpawn][2]);
		SetPlayerFacingAngle(playerid,gRandomSpawns_Prostitution[randSpawn][3]);
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
    new playercash;
    
    // if they ever return to class selection make them city
	// select again first
	gPlayerHasCitySelected[playerid] = 0;
    
	if(killerid == INVALID_PLAYER_ID) {
        ResetPlayerMoney(playerid);
	} else {
		playercash = GetPlayerMoney(playerid);
		if(playercash > 0)  {
			GivePlayerMoney(killerid, playercash);
			ResetPlayerMoney(playerid);
		}
	}
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
	else if(gPlayerCitySelection[playerid] == CITY_PROSTITUTION) {
		SetPlayerInterior(playerid,3);
		SetPlayerPos(playerid,-2673.8381,1399.7424,918.3516);
		SetPlayerFacingAngle(playerid,181.0);
    	SetPlayerCameraPos(playerid,-2673.2776,1394.3859,918.3516);
		SetPlayerCameraLookAt(playerid,-2673.8381,1399.7424,918.3516);
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
	txtProstitution = TextDrawCreate(10.0, 380.0, "Prostitutas");
	ClassSel_InitCityNameText(txtProstitution);

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
		TextDrawHideForPlayer(playerid,txtProstitution);
	}
	else if(gPlayerCitySelection[playerid] == CITY_AIR_PORT) {
		SetPlayerInterior(playerid,0);
   		SetPlayerCameraPos(playerid, 1384.3622, -2629.1306, 45.1857);
		SetPlayerCameraLookAt(playerid, 1385.1813, -2628.5627, 44.9808);
		TextDrawHideForPlayer(playerid,txtLosSantos);
		TextDrawShowForPlayer(playerid,txtAirPort);
		TextDrawHideForPlayer(playerid,txtPDLS);
		TextDrawHideForPlayer(playerid,txtProstitution);
	}
	else if(gPlayerCitySelection[playerid] == CITY_POLICE_DEPARTMENT) {
		SetPlayerInterior(playerid,0);
   		SetPlayerCameraPos(playerid, 1480.8235, -1656.5042, 45.7119);
		SetPlayerCameraLookAt(playerid, 1481.7937, -1656.7469, 45.3818);
		TextDrawHideForPlayer(playerid,txtLosSantos);
		TextDrawHideForPlayer(playerid,txtAirPort);
		TextDrawShowForPlayer(playerid,txtPDLS);
		TextDrawHideForPlayer(playerid,txtProstitution);
	}
 	else if(gPlayerCitySelection[playerid] == CITY_PROSTITUTION) {
		SetPlayerInterior(playerid,0);
   		SetPlayerCameraPos(playerid, 1519.6682, -943.2454, 104.0302);
		SetPlayerCameraLookAt(playerid, 1518.9269, -942.5748, 103.9351);
		TextDrawHideForPlayer(playerid,txtLosSantos);
		TextDrawHideForPlayer(playerid,txtAirPort);
		TextDrawHideForPlayer(playerid,txtPDLS);
		TextDrawShowForPlayer(playerid,txtProstitution);
	}
}

//----------------------------------------------------------

ClassSel_SwitchToNextCity(playerid)
{
    gPlayerCitySelection[playerid]++;
	if(gPlayerCitySelection[playerid] > CITY_PROSTITUTION) {
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
	    gPlayerCitySelection[playerid] = CITY_PROSTITUTION;
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
		TextDrawHideForPlayer(playerid,txtProstitution);
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
	AddPlayerClass(0,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(162,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
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
	AddPlayerClass(171,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(165,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(146,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(138,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(92,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(85,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(82,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(61,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	AddPlayerClass(49,1759.0189,-1898.1260,13.5622,266.4503,-1,-1,-1,-1,-1,-1);
	/*
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
	*/
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

	// Don't allow minigun
	/*if(GetPlayerWeapon(playerid) == WEAPON_MINIGUN) {
	    Kick(playerid);
	    return 0;
	}*/
	
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
    SendClientMessage(playerid, 0xFFFF00FF, params[0]);
    return 1;
}
CMD:tp(playerid, params[]) {
	new Float:x, Float:y, Float:z;
	GetPlayerPos(params[0], x, y, z);
    // Create a cash pickup at the player's position
    CreateExplosion(x, y, z, 12, 10.0);
	//GetPlayerFacingAngle(params[0], a);
 	//SendClientMessage(playerid, 0xFFFF00FF, x);
 	//SendClientMessage(playerid, 0xFFFF00FF, y);
   	//SendClientMessage(playerid, 0xFFFF00FF, z);
    //SetPlayerPos( playerid, x, y, z );
	//SetPlayerFacingAngle( playerid, a );
    return 1;
}
CMD:kill(playerid, params[]) {
    SetPlayerHealth(playerid, 0);
    return 1;
}
CMD:activa(playerid, params[]) {
    SendClientMessage(playerid, 0xFFFF00FF, "Se activo iconos en el mapa");
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    return 1;
}
CMD:chabe(playerid, params[]) {
    SetPlayerArmour(playerid, 100.0);
	SetPlayerHealth(playerid, 100.0);
    return 1;
}
//gamemode
CMD:escondidas(playerid, params[]) {
    ShowPlayerDialog(playerid, 3, DIALOG_STYLE_LIST, "Hide and Seek", "Madd Dog Mansion\nPorta Aviones\nLimbo\nJefferson Motel\nCatigula Basement\nArea51", "Teleport", "Cancel");
	return 1;
}
//armas
CMD:ak(playerid, params[]) {
	ResetPlayerWeapons(playerid);
    GivePlayerWeapon(playerid,WEAPON_AK47,100);
    GivePlayerWeapon(playerid,WEAPON_SILENCED,1000);
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
CMD:vidaarmour(playerid, params[]) {
	SetPlayerArmour(playerid, 100.0);
	SetPlayerHealth(playerid, 100.0);
	return 1;
}
CMD:minigunn(playerid, params[]) {
 	GivePlayerWeapon(playerid, WEAPON_MINIGUN, 100);
    return 1;
}
//Autos
CMD:cars(playerid, params[])
{
    ShowPlayerDialog(playerid, 1, DIALOG_STYLE_LIST, "Spawnea un auto", "Oceanic\nSunrise\nBuccaneer\nFeltzer\nHustler\nMajestic\nBanshee\nSabre\nBullet\nHotKnife\nPhoenix\nStratum\nQuad\nBandito\nTaxi", "Spawn", "Cancel");
	return 1;
}
CMD:carreras(playerid, params[])
{
    ShowPlayerDialog(playerid, 4, DIALOG_STYLE_LIST, "Carreras", "8-Track\nDerby\nDirt track\nKickstart", "Spawn", "Cancel");
	return 1;
}
//Motos
CMD:motros(playerid, params[])
{
    ShowPlayerDialog(playerid, 2, DIALOG_STYLE_LIST, "Spawnea un auto", "BF-400\nBMX\nBici\nFreeway", "Spawn", "Cancel");
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
						CreateVehicle(467,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
    		        }
	        	    case 1:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						CreateVehicle(550,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
	        	    }
	        	    case 2:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						CreateVehicle(518,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
	        	    }
              		case 3:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						CreateVehicle(533,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
	        	    }
              		case 4:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						CreateVehicle(545,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
	        	    }
              		case 5:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						CreateVehicle(517,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
	        	    }case 6:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						CreateVehicle(429,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
	        	    }case 7:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						CreateVehicle(475,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
	        	    }case 8:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						CreateVehicle(541,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
	        	    }case 9:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						CreateVehicle(424,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
	        	    }case 10:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						CreateVehicle(603,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
	        	    }case 11:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						CreateVehicle(561,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
	        	    }case 12:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						CreateVehicle(471,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
	        	    }case 13:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						CreateVehicle(568,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
	        	    }case 14:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						CreateVehicle(420,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
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
						CreateVehicle(581,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
	        	    }
	        	    case 1:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						CreateVehicle(481,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
	        	    }
	        	    case 2:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						CreateVehicle(509,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
	        	    }
              		case 3:
	        	    {
	                    new Float:X;
						new Float:Y;
						new Float:Z;
						GetPlayerPos(playerid,X,Y,Z);
						CreateVehicle(463,X+5,Y,Z,1,vehicleColor,vehicleColor,90000);
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
              			SetPlayerPos( playerid, 1267.8407, -776.9587, 1091.9063 );
						SetPlayerFacingAngle( playerid, 283.7531 );
						SetPlayerInterior( playerid, 5);
						ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
    					return 1;
	        	    }
	        	    case 1:
	        	    {
              			SetPlayerPos( playerid, -1378.8417,509.1760,18.2344 );
						SetPlayerFacingAngle( playerid, 181.5594 );
						SetPlayerInterior( playerid, 0);
						ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
    					return 1;
	        	    }
	        	    case 2:
	        	    {
	                    SetPlayerPos( playerid, 130.7709,-66.7193,1.5781 );
						SetPlayerFacingAngle( playerid, 85.6357 );
						SetPlayerInterior( playerid, 5);
						ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    					return 1;
	        	    }
              		case 3:
	        	    {
	        	    	SetPlayerPos( playerid, 2226.8826, -1147.9552, 1026.8087 );
						SetPlayerFacingAngle( playerid, 85.6357 );
						SetPlayerInterior( playerid, 15);
						ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	                    return 1;
	        	    }
	        	    case 4:
	        	    {
	        	    	SetPlayerPos( playerid, 2226.8826, -1147.9552, 1026.8087 );
						SetPlayerFacingAngle( playerid, 85.6357 );
						SetPlayerInterior( playerid, 15);
						ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	                    return 1;
	        	    }
	        	    case 5:
	        	    {
	        	    	SetPlayerPos( playerid, 2206.9502, 1551.5504, 1008.9230 );
						SetPlayerFacingAngle( playerid, 85.6357 );
						SetPlayerInterior( playerid, 1);
						ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	                    return 1;
	        	    }
					case 6:
	        	    {
	        	    	SetPlayerPos( playerid, 213.7928, 1876.9717, 14.5176 );
						SetPlayerFacingAngle( playerid, 85.6357 );
						SetPlayerInterior( playerid, 0);
						ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
	                    return 1;
	        	    }
	        	    case 7:
	        	    {
	        	    	SetPlayerPos( playerid, 2526.5659, -1293.2012, 1031.7200 );
						SetPlayerFacingAngle( playerid, 85.6357 );
						SetPlayerInterior( playerid, 2);
						ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
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
              			SetPlayerPos( playerid, -1281.4999, -262.1028, 1050.4592 );
						SetPlayerFacingAngle( playerid, 283.7531 );
						SetPlayerInterior( playerid, 7);
						ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    					return 1;
	        	    }
	        	    case 1:
	        	    {
    					SetPlayerPos( playerid, -1462.6104, 1008.1122, 1031.0149 );
						SetPlayerFacingAngle( playerid, 283.7531 );
						SetPlayerInterior( playerid, 15);
						ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    					return 1;
	        	    }
	        	    case 2:
		    		{
    					SetPlayerPos( playerid, -1467.7676, -583.4044, 1061.0345 );
						SetPlayerFacingAngle( playerid, 283.7531 );
						SetPlayerInterior( playerid, 4);
						ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    					return 1;
	        	    }
	        	    case 3:
		    		{
    					SetPlayerPos( playerid, -1364.0387, 1580.5420, 1057.1305 );
						SetPlayerFacingAngle( playerid, 283.7531 );
						SetPlayerInterior( playerid, 14);
						ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    					return 1;
	        	    }
	        	}
		    }
		}
	}
	return 1;
}
