#include <a_zones>
#include <a_samp>
#include <zcmd>
#include <sscanf2>
#include <streamer>
#include <YSI\y_hooks>
#include "../include/gl_common.inc"

#define COLOR_YELLOW 0xFFFF00FF
#define COLOR_ORANGE 0xFFA500FF
#define COLOR_RED 0xFF0000FF
#define COLOR_AZUL 0x0000FFFF
#define COLOR_GREEN 0x33AA33AA

forward GodMode(playerid);

enum DatosJugador
{
	LSPD,
	tranceunte,
	ladrones
}
new PlayerInfo[MAX_PLAYERS][DatosJugador];

new Arrest;
new Health;
new Weapons;

stock RadioPolicia(const string[])
{
	for(new i=0; i <MAX_PLAYERS; i++)
	{
		if (PlayerInfo[i][LSPD] >= 1)
		{
			SendClientMessage(i, COLOR_GREEN,string);
		}
	}
	return 1;
}

#define PROP_VW    		(10000)
#define MAX_INTERIORS	(146)
#define MAX_PROPERTIES  (1000)
#define MAX_SAFEZONES  4
#define MAX_MAPICONS    30 //'150' is the max number of map icons (limit), you can change it.
#define PROPERTY_FOLDER	"properties" // Location of properties file

#define MAX_TYPES       (5)
#define TYPE_EMPTY      (0)
#define TYPE_CLUCKING_BELL 		(1)
#define TYPE_247	(2)
#define TYPE_BANCOS	(3)
#define TYPE_CLUB	(4)

new Icon[MAX_MAPICONS];
enum safeZ{
	MapZone,
	DynamicZone
}
new safezone[MAX_SAFEZONES][safeZ];
new safeZoneActive[MAX_PLAYERS];


enum // Property Type Enum
	E_P_TYPES {
		tIcon,
		tName[32]
	}

enum // Uniq Interiors Enum
	E_INTERIORS {
		inIntID,
		Float:inExitX,
		Float:inExitY,
		Float:inExitZ,
		Float:inExitA,
		inName[64]
	};

enum // Properties Enum
	E_PROPERTIES {
		eInterior,
		eType,
		Float:eEntX,
		Float:eEntY,
		Float:eEntZ,
		Float:eEntA,
		eUniqIntId,
		eOwner,
		ePrice,
		ePname[64]
	};

//  [ uniq property id ]
new	unid;

//	[ Pickup array with property id assigned via array slot ( pickupid ) ]
new propPickups[MAX_PROPERTIES] = {-1};

// 	[ Mass array of all the properties and info about them ]
new properties[MAX_PROPERTIES][E_PROPERTIES];

new Text3D:propTextInfo[MAX_PROPERTIES];

new lastPickup[MAX_PLAYERS] = {-1};

new	propFile[MAX_TYPES][64] =   {
									{ "blank" },
		                            { "properties/robos/clukingbell.txt" },
		                            { "properties/robos/247.txt" },
		                            { "properties/robos/bancos.txt" },
		                            { "properties/robos/club.txt" }
							 	};

//  Keep track of what properties we've sent an /enter notification for
new gLastPropertyEnterNotification[MAX_PLAYERS];


public OnFilterScriptInit()
{
    Arrest = CreatePickup(1239, 0, 1530.6128,-1670.0073,6.2188, -1);
    Create3DTextLabel("/arrestar\n\nPara llevar al delicuente a la carcel!", 0xFF0000FF, 1530.6128,-1670.0073,6.2188, 60.0, 0, 0);
    Health = CreatePickup(1249, 2, 1532.0723,-1675.2760,5.8906, -1);
    Weapons = CreatePickup(1239, 0, 1528.2347,-1675.0225,5.8906, -1);
    safezone[0][MapZone] = GangZoneCreate(-133, -1193.5, -33, -1093.5);
	safezone[1][MapZone] = GangZoneCreate(1516, 722.5, 1616, 822.5);
	safezone[0][DynamicZone] = CreateDynamicRectangle(-133, -1193.5, -33, -1093.5);
	safezone[1][DynamicZone] = CreateDynamicRectangle(1516, 722.5, 1616, 822.5);
    return 1;
}

//-----------------------------MEMBER-------------------------------------------

CMD:esposar(playerid, params[])
{
	if(PlayerInfo[playerid][LSPD] >= 1)
	{
		new Float:X,Float:Y,Float:Z;
		GetPlayerPos(playerid, X, Y, Z);
        if(IsPlayerInRangeOfPoint(playerid, 4.0, X, Y, Z))
        {
			new ID, string[128], idname[MAX_PLAYER_NAME];
			GetPlayerName(ID, idname, 24);
            if(sscanf(params,"i", ID)) return SendClientMessage(playerid,-1,"{FF0000}USAGE: {15FF00}/esposar [ID]");
            SetPlayerSpecialAction(ID, SPECIAL_ACTION_CUFFED);
            format(string, sizeof(string), "{009BFF}[POLICIA]: {15FF00}Esposaste a:{FF0000} [%d] %s!", ID, idname);
            SendClientMessage(playerid, -1, string);
            format(string, sizeof(string), "{15FF00}Usted fue esposado!");
            SendClientMessage(playerid, -1, string);
		}
	}
	else
	{
		SendClientMessage(playerid, -1, "{FF0000}ERROR: {15FF00}No eres POLICIA");
	}
	return 1;
}
CMD:desposar(playerid, params[])
{
	if(PlayerInfo[playerid][LSPD] >= 1)
	{
		new Float:X;
		new Float:Y;
		new Float:Z;
		GetPlayerPos(playerid, X, Y, Z);
        if(IsPlayerInRangeOfPoint(playerid, 4.0, X, Y, Z))
        {
			new ID, string[128], name[MAX_PLAYER_NAME], nameE[MAX_PLAYER_NAME];
			GetPlayerName(playerid, name, 24);
			GetPlayerName(ID, name, 24);
            if(sscanf(params,"i", ID)) return SendClientMessage(playerid,-1,"{FF0000}USAGE: {15FF00}/desposar [PlayerID]");
            SetPlayerSpecialAction(ID, SPECIAL_ACTION_NONE);
            format(string, sizeof(string), "{009BFF}[POLICIA]: {15FF00}Le sacastes las esposas a: {FF0000}[%d] %s", ID, nameE);
            SendClientMessage(playerid, -1, string);
            format(string, sizeof(string), "{15FF00}Te sacaron las esposas, ten mas cuidado la proxima vez!");
            SendClientMessage(playerid, -1, string);
		}
	}
	else
	{
		SendClientMessage(playerid, -1, "{FF0000}ERROR: {15FF00}No eres SAPD!");
	}
	return 1;
}

CMD:r(playerid, params[])
{
  	if(PlayerInfo[playerid][LSPD] >= 1)
	{
    new nombre[MAX_PLAYER_NAME],rango[50],string[256], text[256];
    if(sscanf(params,"s",text)) return SendClientMessage(playerid,-1,"{FF0000}USO: {15FF00}/r [texto]");
    switch(PlayerInfo[playerid][LSPD])
	{
        case 1: rango = "Cadete";
        case 2: rango = "Cabo";
        case 3: rango = "Policia";
        case 4: rango = "Agente";
        case 5: rango = "Comisario";
    }
    GetPlayerName(playerid,nombre,sizeof(nombre));
    GetPlayerName(playerid, nombre, sizeof(nombre));
    format(string, sizeof(string), "{009BFF}[POLICIA] %s (%s):{FFFFFF} %s", nombre, rango, text);
    RadioPolicia(string);
	}
    return 1;
}

CMD:arrestar(playerid, params[])
{
    if(PlayerInfo[playerid][LSPD] >= 1)
	{
        if(IsPlayerInRangeOfPoint(playerid, 9.0, 1530.6128,-1670.0073,6.2188 ))
        {
	    	new ID, nameID[MAX_PLAYER_NAME], string[28], string1[128];
            if(sscanf(params,"i", ID)) return SendClientMessage(playerid,-1,"{FF0000}USAGE: {15FF00}/Arrestar [ID]");
            GetPlayerName(ID, nameID, MAX_PLAYER_NAME);
            SetPlayerPos(ID, 263.8321,86.7278,1001.0391);
            SetPlayerFacingAngle(ID, 269.1325);
            format(string1, sizeof(string1), "{FF0000}??Te arrestaron!");
			SendClientMessage(ID, -1, string1);
			format(string, sizeof(string), "{009BFF}[POLICE]: {FFFFFF}??Arrestaste a: %s!", nameID);
			SendClientMessage(playerid, -1, string);
		}
	}
	else
	{
		SendClientMessage(playerid, -1, "{FF0000}ERROR: {15FF00}No eres LSPD");
	}
	return 1;
}

CMD:c(playerid, params[])
{
    if(PlayerInfo[playerid][LSPD] >= 1)
	{
    	new ID;
		new LevelWan;
		if(sscanf(params,"ii", ID, LevelWan)) return SendClientMessage(playerid,-1,"{FF0000}USAGE: {15FF00}/c [ID] [niveldecargos]");
		SetPlayerWantedLevel(ID, LevelWan);
	}
	else
	{
		SendClientMessage(playerid, -1, "{FF0000}ERROR: {15FF00}Usted no es LSPD");
	}
	return 1;
}

//----------------------------RCON----------------------------------------------

CMD:contratar(playerid, params[])
{
	if(IsPlayerAdmin(playerid))
	{
		new ID, rango,rangoN[18], string[128], string1[128], idname[MAX_PLAYER_NAME];
		GetPlayerName(ID, idname, 24);
        if(sscanf(params,"ii", ID, rango)) return SendClientMessage(playerid,-1,"{FF0000}USAGE: {15FF00}/contratar [ID] [RANGO]");
        PlayerInfo[ID][LSPD] = rango;
        switch(rango)
		{
        	case 1: rangoN = "Cadete";
        	case 2: rangoN = "Cabo";
        	case 3: rangoN = "Policia";
        	case 4: rangoN = "Agente";
        	case 5: rangoN = "Comisario";
    	}
        format(string, sizeof(string), "{009BFF}[POLICIA]: {15FF00}Ahora eres {009BFF}%s{15FF00} de la {009BFF}POLICIA!", rangoN);
        SendClientMessage(ID, -1, string);
        format(string1, sizeof(string1), "{009BFF}[POLICIA]: {15FF00}Le diste {009BFF}%s {6CDA62}a:{FFFFFF} [%d] %s ", rangoN, ID, idname);
        SendClientMessage(playerid, -1, string1);
	}
	else{
		SendClientMessage(playerid, -1, "{FF0000}ERROR:{15FF00} No eres ADMIN!");
	}
	return 1;
}
CMD:ref(playerid, params[])
{
	if(PlayerInfo[playerid][LSPD] >= 1)
	{
	    new Float:X,Float:Y,Float:Z;
	    GetPlayerPos(playerid, X, Y, Z);
		new string[128],zone[MAX_ZONE_NAME];
		new Name[MAX_PLAYER_NAME];
		GetPlayerName(playerid, Name, 32);
		GetPlayer2DZone(playerid, zone, MAX_ZONE_NAME);
		format(string,128,"{009BFF}[Radio de Policia]{FFFFFF} %s dice: necesito refuerzos en %s", Name, zone);
		SendClientMessage(playerid, -1, string);
	}
	return 1;
}
CMD:subir(playerid, params[])
{
    new string[126];
	new ID,Lugar,patrulla,Float:x,Float:y,Float:z;
	new nombrepolicia[MAX_PLAYER_NAME];
	new nombrearrestado[MAX_PLAYER_NAME];
    if(PlayerInfo[playerid][LSPD] >= 1)
    {
	if(sscanf(params, "dd", ID,Lugar) )return SendClientMessage(playerid,-1,"Uso: /subir [ID] [Asiento 1-2]");
	if(!IsPlayerConnected(ID)) return SendClientMessage(playerid,-1,"Jugador desconectado o id incorrecta");
	patrulla = GetPlayerVehicleID(playerid);
	GetPlayerPos(ID, x,y,z);
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid,-1,"Debes estar en una patrulla para subir a alguien");
	if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER) return SendClientMessage(playerid,-1,"Debes estar conduciendo la patrulla");
	if(IsPlayerInRangeOfPoint(playerid, 20.0, x,y,z))
	{
		if(Lugar == 1)
		{
			SetPlayerArmedWeapon(ID, 0);
			PutPlayerInVehicle(ID, patrulla, 2);
			TogglePlayerControllable(ID, 0);
			GetPlayerName(playerid,nombrepolicia,sizeof(nombrepolicia));
            GetPlayerName(ID,nombrearrestado,sizeof(nombrearrestado));
			format(string,128,"El oficial %s sube a la patrulla a %s",nombrepolicia,nombrearrestado);
			SendClientMessage(playerid, COLOR_AZUL, string);
		}
		else if(Lugar == 2)
		{
			SetPlayerArmedWeapon(ID, 0);
			PutPlayerInVehicle(ID, patrulla, 3);
			TogglePlayerControllable(ID, 0);
			GetPlayerName(playerid,nombrepolicia,sizeof(nombrepolicia));
            GetPlayerName(ID,nombrearrestado,sizeof(nombrearrestado));
			format(string,128,"El oficial %s sube a la patrulla a %s",nombrepolicia,nombrearrestado);
			SendClientMessage(playerid, COLOR_AZUL, string);
		}
	}
	else SendClientMessage(playerid, -1, "No estas cerca de ese jugador");
	}
	return 1;
}
CMD:bajar(playerid, params[])
{
    new string[126];
	new ID;
	new nombrepolicia[MAX_PLAYER_NAME];
	new nombrecivil[MAX_PLAYER_NAME];
    if(PlayerInfo[playerid][LSPD] >= 1)
    {
		if(sscanf(params, "d", ID) )return SendClientMessage(playerid,-1,"Uso: /subir [ID]");
		if(!IsPlayerConnected(ID)) return SendClientMessage(playerid,-1,"Jugador desconectado o id incorrecta");
		if(!IsPlayerInAnyVehicle(ID)) return SendClientMessage(playerid,-1,"Debes estar en una patrulla para subir a alguien");
    	RemovePlayerFromVehicle(ID);
    	TogglePlayerControllable(ID, 1);
    	ApplyAnimation(ID,"PED","BIKE_fallR",4.0,0,1,1,1,0);//rodar//
    	GetPlayerName(ID,nombrecivil,sizeof(nombrecivil));
    	GetPlayerName(playerid,nombrepolicia,sizeof(nombrepolicia));
    	format(string,128,"El Oficial %s libera de la patrulla a %s",nombrepolicia,nombrecivil);
    	SendClientMessage(playerid, COLOR_AZUL, string);
	}
	return 1;
}
//------------------------------------------------------------------------------

public OnPlayerPickUpPickup(playerid, pickupid)
{
    //printf( "DEBUG: Player %d pickedup Pickup %d Prop Id %d", playerid, pickupid );
	lastPickup[playerid] = pickupid;
	new id = propPickups[pickupid];
	new pmsg[256];

	if( properties[id][eType] > 0 ){

	    if(gLastPropertyEnterNotification[playerid] != id){
	        gLastPropertyEnterNotification[playerid] = id;
          	switch( properties[id][eType] ){
		    	case TYPE_CLUCKING_BELL:{
		        	format(pmsg,256,"[!] Clucking Bell: Escribe /iniciar para empezar el robo");
		        	SendClientMessage( playerid, 0xFF55BBFF, pmsg );
		        	return 1;
				}

				case TYPE_247:{
			   		format(pmsg,256,"[!] 24/7: Escribe /iniciar para empezar el robo");
		        	SendClientMessage( playerid, 0xFF55BBFF, pmsg );
		        	return 1;
				}
				case TYPE_BANCOS:{
			   		format(pmsg,256,"[!] Banco: Escribe /iniciar para empezar el robo");
		        	SendClientMessage( playerid, 0xFF55BBFF, pmsg );
		        	return 1;
				}
				case TYPE_CLUB:{
			   		format(pmsg,256,"[!] CLUB: Escribe /iniciar para empezar el robo");
		        	SendClientMessage( playerid, 0xFF55BBFF, pmsg );
		        	return 1;
				}
		 	}
		}
	}
	else SendClientMessage( playerid, 0xFF9900FF, "This property doesn't exist :S" );

    if(pickupid == Arrest)
    {
        GameTextForPlayer(playerid, "~r~/~b~Arrestar~y~ !", 5000, 5);
    }
    else if(pickupid == Health)
    {
        SetPlayerHealth(playerid, 100);
        SetPlayerArmour(playerid, 100);
    }
    else if(pickupid == Weapons)
    {
        GivePlayerWeapon(playerid, 24, 300);
        GivePlayerWeapon(playerid, 28, 300);
        GivePlayerWeapon(playerid, 32, 300);
        GivePlayerWeapon(playerid, 34, 300);
    }
    return 1;
}
public OnPlayerUpdate(playerid){
	if(safeZoneActive[playerid] == 1) {
		if(IsPlayerInAnyDynamicArea(playerid) == 1) {
    		GodMode(playerid);
			return 1;
		}
	}
	return 1;
}
public OnPlayerEnterDynamicArea(playerid, areaid)
{
    if(safeZoneActive[playerid] == 1) {
		SendClientMessage(playerid, -1 , "{f59342}[INFO]: {FFFFFF}Entraste en la safezone");
	}
	return 1;
}
public OnPlayerLeaveDynamicArea(playerid, areaid)
{
    if(safeZoneActive[playerid] == 1) {
		SendClientMessage(playerid, -1 , "{f59342}[INFO]: {FFFFFF}Saliste de la safezone");
	}
	return 1;
}
public GodMode(playerid)
{
	SetPlayerHealth(playerid, 100);
	SetPlayerArmour(playerid, 100);
}
//-------------------------------------------------------
//
// GRAND LARCENY Property creation and management script
//
// by damospiderman 2008
//
//-------------------------------------------------------


/********************************
*   Interior Info Functions     *
********************************/
stock Float:GetPropertyEntrance( id, &Float:x, &Float:y, &Float:z ){
	if( id > MAX_PROPERTIES ) return 0.0;
	x = properties[id][eEntX];
	y = properties[id][eEntY];
	z = properties[id][eEntZ];
	return properties[id][eEntA];
}

stock Float:GetPropertyExit( id, &Float:x, &Float:y, &Float:z ){
	if( id > MAX_PROPERTIES ) return 0.0;
	return GetInteriorExit( properties[id][eUniqIntId], x, y, z );
}

stock GetPropertyInteriorFileId( id ){
	if( id > MAX_PROPERTIES ) return 0;
	else return properties[id][eUniqIntId];
}

stock GetPropertyInteriorId( id ){
	if( id > MAX_PROPERTIES ) return 0;
	else return GetInteriorIntID( properties[id][eUniqIntId] );
}

stock GetPropertyType( id ){
	if( id > MAX_PROPERTIES ) return 0;
	else return properties[id][eType];
}

stock GetPropertyOwner( id ){
	if( id > MAX_PROPERTIES ) return -1;
	else return properties[id][eOwner];
}

stock GetPropertyPrice( id ){
	if( id > MAX_PROPERTIES ) return -1;
	else return properties[id][ePrice];
}

stock GetPropertyName( id ){
	new tmp[64];
	if( id > MAX_PROPERTIES ) return tmp;
	else {
  		format( tmp, 64, "%s", properties[id][ePname] );
		return tmp;
	}
}

/********************************************************
********************************************************/

/*********************************
*   Property System Functions    *
*********************************/

ReadPropertyFile( fileName[] )
{
	new  File:file_ptr,
	    tmp[128],
		buf[256],
		idx,
		Float:enX,
		Float:enY,
		Float:enZ,
		Float:enA,
		uniqIntId,
		p_type,
		pIcon;

	printf("Reading File: %s",fileName);

	file_ptr = fopen( fileName, io_read );

	if(!file_ptr )return 0;

 	while( fread( file_ptr, buf, 256 ) > 0){
 	    idx = 0;

 	    idx = token_by_delim( buf, tmp, ',', idx );
		if(idx == (-1)) continue;
		pIcon = strval( tmp );

 	    idx = token_by_delim( buf, tmp, ',', idx+1 );
		if(idx == (-1)) continue;
		enX = floatstr( tmp );

  		idx = token_by_delim( buf, tmp, ',', idx+1 );
		if(idx == (-1)) continue;
		enY = floatstr( tmp );

		idx = token_by_delim( buf, tmp, ',', idx+1 );
		if(idx == (-1)) continue;
		enZ = floatstr( tmp );

 		idx = token_by_delim( buf, tmp, ',', idx+1 );
		if(idx == (-1)) continue;
		enA = floatstr( tmp );

		idx = token_by_delim( buf, tmp, ',', idx+1 );
		if(idx == (-1)) continue;
		uniqIntId = strval( tmp );

		idx = token_by_delim( buf, tmp, ';', idx+1 );
		if(idx == (-1)) continue;
		p_type = strval( tmp );

		CreateProperty( uniqIntId, pIcon, enX, enY, enZ, enA, p_type  );
	}
	fclose( file_ptr );
	return 1;
}


CreateProperty( uniqIntId, iconId,  Float:entX, Float:entY, Float:entZ, Float:entA, p_type, name[64]="", owner=-1, price=0 )
{
	if( (unid+1) < MAX_PROPERTIES ){
		new Id = CreatePickup( iconId ,23, entX, entY, entZ, 0 );
		//printf( "CreateProperty(%d, %d, %f, %f, %f, %f, %d)", uniqIntId, iconId, entX, entY, entZ, entA, p_type );
		propPickups[Id] = unid;
		properties[unid][eEntX] 	= entX;
		properties[unid][eEntY] 	= entY;
		properties[unid][eEntZ] 	= entZ;
		properties[unid][eEntA] 	= entA;
		properties[unid][eUniqIntId] = uniqIntId;
		properties[unid][eOwner] 	= owner;
		properties[unid][ePrice] 	= price;
		properties[unid][eType] 	= p_type;
		format( properties[unid][ePname], 64, "%s", name );

		new text_info[256];

		propTextInfo[unid] = Text3D:INVALID_3DTEXT_ID;

		if(p_type == TYPE_CLUCKING_BELL) {
		    format(text_info,256,"{FFFFFF}[{EEEE88}Clucking Bell{FFFFFF}]");
		    propTextInfo[unid] = Create3DTextLabel(text_info,0x88EE88FF,entX,entY,entZ+0.75,20.0,0,1);
		}
		else if(p_type == TYPE_247) {
		    format(text_info,256,"{FFFFFF}[{AAAAFF}24/7{FFFFFF}]");
		    propTextInfo[unid] = Create3DTextLabel(text_info,0xAAAAFFFF,entX,entY,entZ+0.75,20.0,0,1);
		}
		else if(p_type == TYPE_BANCOS) {
		    format(text_info,256,"{FFFFFF}[{EEEE88}Banco{FFFFFF}]");
		    propTextInfo[unid] = Create3DTextLabel(text_info,0xEEEE88FF,entX,entY,entZ+0.75,20.0,0,1);
		}
		else if(p_type == TYPE_CLUB) {
		    format(text_info,256,"{FFFFFF}[{EEEE88}Club{FFFFFF}]");
		    propTextInfo[unid] = Create3DTextLabel(text_info,0xEEEE88FF,entX,entY,entZ+0.75,20.0,0,1);
		}

		return unid++;
	}
	else print( "Property Limit Reached" );
	return -1;
}

LoadProperties()
{
	if( properties[0][eType] != TYPE_EMPTY ){
	    UnloadProperties();
	}
	unid = 0;
   	for( new i = 0; i < MAX_PROPERTIES; i++ ){
   	    properties[i][eType] = TYPE_EMPTY;
	}

	for( new i = 0; i < MAX_TYPES; i++ ){
   		ReadPropertyFile( propFile[i] );
	}
	return 1;
}

UnloadProperties()
{
	new
	    p;
	for( new i = 0; i < MAX_PROPERTIES; i++ ){
		if( propPickups[i] != -1 ){
			DestroyPickup( i );
			p = propPickups[i];
			propPickups[i] = -1;
			properties[p][eInterior] = -1;
			properties[p][eType] = TYPE_EMPTY;
			properties[p][eOwner] = -1;
			properties[p][ePrice] = 0;
			properties[p][ePname][0] = '\0';
		}
	}
}

/********************************************************
********************************************************/


/************************************
*   		Callbacks			    *
************************************/

public OnFilterScriptExit()
{
	UnloadProperties();
	return 1;
}

public OnGameModeInit()
{
	LoadProperties();
	return 1;
}

public OnGameModeExit()
{
	UnloadProperties();
	return 1;
}

public OnPlayerConnect( playerid )
{
	PlayerInfo[playerid][LSPD] = 0;
	PlayerInfo[playerid][tranceunte] = 1;
	PlayerInfo[playerid][ladrones] = 0;
	safeZoneActive[playerid] = 0;
	return 1;
}
public OnPlayerSpawn( playerid )
{
	gLastPropertyEnterNotification[playerid] = -1;
	PlayerInfo[playerid][LSPD] = 0;
	PlayerInfo[playerid][ladrones] = 0;
	PlayerInfo[playerid][tranceunte] = 1;
	safeZoneActive[playerid] = 0;
	return 1;
}

CMD:iniciar(playerid, params[]){
	if( lastPickup[playerid] != -1 || properties[lastPickup[playerid]][eType] > 0 ){
	if(PlayerInfo[playerid][ladrones] == 1){
		new id = propPickups[lastPickup[playerid]],Float:x,Float:y,Float:z;
		GetPropertyEntrance( id, x, y, z );
		if( IsPlayerInRangeOfPoint( playerid, 3.0, x, y, z )){
			new str[ 140 ],str1[ 140 ];
			GangZoneShowForAll(safezone[0][MapZone], 0xFF000090);
		 	GangZoneShowForAll(safezone[1][MapZone], 0xFF000090);
		 	/*format( str, sizeof str, "{f59342}[INFO]: {FFFFFF}Iniciaste el robo, la policia vendra pronto!" );
			SendClientMessage(playerid, -1, str );
			GangZoneFlashForPlayer(0xFFFFFFFF, playerid, safezone[0][MapZone]);
			GangZoneFlashForPlayer(0xFFFFFFFF, playerid, safezone[1][MapZone]);
			safeZoneActive[playerid] = 1;*/
			for(new i=0; i <MAX_PLAYERS; i++){
				if (PlayerInfo[i][LSPD] >= 1)
				{
				format( str1, sizeof str1, "{009BFF}[POLICIA]: {FFFFFF}Se inicio un robo en Clucking Bell/24-7");
				SendClientMessage( PlayerInfo[i][LSPD], -1, str1 );
				Icon[ params[0] ] = CreateDynamicMapIcon(x,y,z, 19, -1, 0, 0, -1, 300 );
				}else if(PlayerInfo[i][ladrones] == 1){
     				format( str, sizeof str, "{f59342}[INFO]: {FFFFFF}Iniciaste el robo, la policia vendra pronto!" );
					SendClientMessage(playerid, -1, str );
					GangZoneFlashForPlayer(0xFFFFFFFF, playerid, safezone[0][MapZone]);
					GangZoneFlashForPlayer(0xFFFFFFFF, playerid, safezone[1][MapZone]);
					safeZoneActive[playerid] = 1;
				}else{
				    continue;
				}
			}
	    	return 1;
		}
	}else{
		new str[ 140 ];
		format( str, sizeof str, "{f59342}[INFO]: {FFFFFF}Debes ser ladron primero");
		SendClientMessage( playerid, -1, str );
	}
	}
	return 1;
}
CMD:borrarrobos( playerid, params[] )
{
	if(!IsPlayerAdmin( playerid ) ) return SendClientMessage( playerid, -1,"{f59342}[ERROR]: {FFFFFF}You must be logged as RCON." );
 	new i, str[ 140 ];
 	if( sscanf( params,"i", i ) ) return SendClientMessage( playerid, -1,"{f59342}/delete {FFFFFF}[id]" );
	DestroyDynamicMapIcon( Icon[ i ] );
	format( str, sizeof( str ), "{f59342}[INFO]: {FFFFFF}You deleted Map Icon ID = %d.", i );
	SendClientMessage( playerid, -1, str );
	return 1;
}
CMD:pruebagang(playerid, params[]){
	GangZoneFlashForAll(0xFF0000FF, safezone[0][MapZone]);
	return 1;
}
CMD:ladron(playerid, params[]){
	new str[ 140 ],str1[ 140 ];
	if(PlayerInfo[playerid][LSPD] >= 1){
		format( str1, sizeof str1, "{f59342}[INFO]: {FFFFFF}Sos un policia");
		SendClientMessage(playerid, -1, str1 );
		return 1;
	}
	if(PlayerInfo[playerid][ladrones] == 1){
		format( str, sizeof str, "{f59342}[INFO]: {FFFFFF}Ya eres ladron!" );
		SendClientMessage( playerid, -1, str );
		return 1;
	}
 	PlayerInfo[playerid][ladrones] = 1;
 	PlayerInfo[playerid][tranceunte] = 0;
 	format( str, sizeof str, "{f59342}[INFO]: {FFFFFF}Eres un ladron");
	SendClientMessage(playerid, -1, str );
	return 1;
}
CMD:policia(playerid, params[]){
	new str1[ 140 ],str[ 140 ], rangoN[18], name[MAX_PLAYER_NAME], newName[MAX_PLAYER_NAME];
	GetPlayerName(playerid, name, MAX_PLAYER_NAME);
	if(PlayerInfo[playerid][ladrones] == 1){
		format( str, sizeof str, "{f59342}[INFO]: {FFFFFF}Sos un ladron!" );
		SendClientMessage( playerid, -1, str );
		return 1;
	}
	switch(PlayerInfo[playerid][LSPD])
	{
        case 1: rangoN = "Cadete";
        case 2: rangoN = "Cabo";
        case 3: rangoN = "Policia";
        case 4: rangoN = "Agente";
        case 5: rangoN = "Comisario";
    }
    if(PlayerInfo[playerid][LSPD] >= 1){
		format( str1, sizeof str1, "{009BFF}[POLICIA]: {FFFFFF}Tu rango es: {4260f5}%s",rangoN);
		SendClientMessage(playerid, -1, str1 );
		return 1;
	}
	PlayerInfo[playerid][LSPD] = 1;
	PlayerInfo[playerid][tranceunte] = 0;
	format( newName, sizeof newName, "%s {009BFF}[%s]", name, rangoN);
	SetPlayerName(playerid, newName);
	format( str1, sizeof str1, "{009BFF}[POLICIA]: {FFFFFF}Entraste en servicio de policia");
	SendClientMessage(playerid, -1, str1 );
	return 1;
}
CMD:tranceunte(playerid, params[])
{
    new str[ 140 ];
    if(PlayerInfo[playerid][tranceunte] == 1)return 1;
	PlayerInfo[playerid][LSPD] = 0;
	PlayerInfo[playerid][ladrones] = 0;
	PlayerInfo[playerid][tranceunte] = 1;
	format( str, sizeof str, "{f59342}[INFO]: {FFFFFF}Ya no cumples ningun rol");
	SendClientMessage(playerid, -1, str );
	return 1;
}
CMD:terminar_robo(playerid, params[])
{
    new str[ 140 ];
    if(PlayerInfo[playerid][tranceunte] == 1)return 1;
	PlayerInfo[playerid][LSPD] = 0;
	PlayerInfo[playerid][ladrones] = 0;
	PlayerInfo[playerid][tranceunte] = 1;
	safeZoneActive[playerid] = 0;
	format( str, sizeof str, "{009BFF}[POLICIA]: {FFFFFF}El robo termino, ya estas libre de cargos");
	SendClientMessage(playerid, -1, str );
	return 1;
}
CMD:checkrobos(playerid, params[]){
    new str[ 140 ];
    for(new i; i < MAX_MAPICONS; i++){
		format( str, sizeof( str ), "[INFO]: ID de iconos existentes %d.", Icon[i] );
		printf( str );
	}
	return 1;
}
CMD:checkrlspd(playerid, params[]){
	return 1;
}

/***********************************************************************
***********************************************************************/
	

