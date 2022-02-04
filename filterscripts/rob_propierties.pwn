//-------------------------------------------------------
//
// GRAND LARCENY Property creation and management script
//
// by damospiderman 2008
//
//-------------------------------------------------------

#include <a_samp>
#include <zcmd>
#include <streamer>
#include <sscanf2>
#include <YSI\y_hooks>
#include "../include/gl_common.inc"

#define FILTERSCRIPT
//#define USE_SQLITE

#define PROP_VW    		(10000)
#define MAX_INTERIORS	(146)
#define MAX_PROPERTIES  (1000)
#define MAX_SAFEZONES  4

#define MAX_MAPICONS    150 //'150' is the max number of map icons (limit), you can change it.

new Icon[MAX_MAPICONS];
new safezone[MAX_SAFEZONES];
enum DatosJugador
{
	LSPD,
	pNoPolicia,
}
new PlayerInfo[MAX_PLAYERS][DatosJugador];
new bool:ladrones[MAX_PLAYERS];
#define PROPERTY_FOLDER	"properties" // Location of properties file
#define PROPERTY_UNIQID_FILE    "properties/uniqId.txt" // Location of Uniq Interior Info

#define MAX_TYPES       (5)
#define TYPE_EMPTY      (0)
#define TYPE_CLUCKING_BELL 		(1)
#define TYPE_247	(2)
#define TYPE_BANCOS	(3)
#define TYPE_CLUB	(4)

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

//	[ Array of all the property interior info ]
new interiorInfo[MAX_INTERIORS][E_INTERIORS];

//	[ Pickup array with property id assigned via array slot ( pickupid ) ]
new propPickups[MAX_PROPERTIES] = {-1};

//	[ Handles for 3D text displayed at property entrances ]
new Text3D:propTextInfo[MAX_PROPERTIES];

// 	[ Mass array of all the properties and info about them ]
new properties[MAX_PROPERTIES][E_PROPERTIES];

//	[ The last pickup the player went through so they can do /enter command ]
new lastPickup[MAX_PLAYERS] = {-1};

//	[ Current property Unique Interior the player is in.. defaults to -1 when not in any property ]
new currentInt[MAX_PLAYERS] = {-1};

//  [ Array of property type iconid's and strings for property type ]
										
new	propFile[MAX_TYPES][64] =   {
									{ "blank" },
		                            { "properties/robos/clukingbell.txt" },
		                            { "properties/robos/247.txt" },
		                            { "properties/robos/bancos.txt" },
		                            { "properties/robos/club.txt" }
							 	};
							 	
//  Keep track of what properties we've sent an /enter notification for
new gLastPropertyEnterNotification[MAX_PLAYERS];


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

ReadInteriorInfo( fileName[] )
{
	new
	    File:file_ptr,
	    buf[256],
	    tmp[64],
	    idx,
		uniqId;


	file_ptr = fopen( fileName, io_read );
	if( file_ptr ){
		while( fread( file_ptr, buf, 256 ) > 0){
		    idx = 0;

     		idx = token_by_delim( buf, tmp, ' ', idx );
			if(idx == (-1)) continue;
			uniqId = strval( tmp );

			if( uniqId >= MAX_INTERIORS ) return 0;

			idx = token_by_delim( buf, tmp, ' ', idx+1 );
		    if(idx == (-1)) continue;
		 	interiorInfo[uniqId][inIntID] = strval( tmp );

			idx = token_by_delim( buf, tmp, ' ', idx+1 );
		    if(idx == (-1)) continue;
			interiorInfo[uniqId][inExitX] = floatstr( tmp );

			idx = token_by_delim( buf, tmp, ' ', idx+1 );
		    if(idx == (-1)) continue;
			interiorInfo[uniqId][inExitY] = floatstr( tmp );

			idx = token_by_delim( buf, tmp, ' ', idx+1);
		    if(idx == (-1)) continue;
			interiorInfo[uniqId][inExitZ] = floatstr( tmp );

			idx = token_by_delim( buf, tmp, ' ', idx+1 );
		    if(idx == (-1)) continue;
			interiorInfo[uniqId][inExitA] = floatstr( tmp );

			idx = token_by_delim( buf, interiorInfo[uniqId][inName], ';', idx+1 );
		    if(idx == (-1)) continue;

			/*
			printf( "ReadInteriorInfo(%d, %d, %f, %f, %f, %f ( %s ))",
					uniqId,
					interiorInfo[uniqId][inIntID],
					interiorInfo[uniqId][inExitX],
					interiorInfo[uniqId][inExitY],
					interiorInfo[uniqId][inExitZ],
					interiorInfo[uniqId][inExitA],
					interiorInfo[uniqId][inName] );*/

		}
		//printf( "Interiors File read successfully" );
		fclose( file_ptr );
		return 1;
	}
	printf( "Could Not Read Interiors file ( %s )", fileName );
	return 0;
}

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

	ReadInteriorInfo( "properties/interiors.txt" );

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


public OnFilterScriptInit()
{
	print("\n-----------------------------------");
	print("Robos de lugares filtescript		");
	print("-----------------------------------\n");
	safezone[0] = GangZoneCreate(-133, -1193.5, -33, -1093.5);
	safezone[1] = GangZoneCreate(1516, 722.5, 1616, 822.5);
	return 1;
}

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

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	if( newinteriorid == 0 ){
		currentInt[playerid] = -1;
		SetPlayerVirtualWorld( playerid, 0 );
	}
	return 1;
}
public OnPlayerConnect( playerid )
{
	PlayerInfo[playerid][LSPD] = 1;
	return 1;
}
public OnPlayerSpawn( playerid )
{
	gLastPropertyEnterNotification[playerid] = -1;
	return 1;
}

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

	return 1;
}
CMD:iniciar(playerid, params[]){
	if( lastPickup[playerid] != -1 || properties[lastPickup[playerid]][eType] > 0 ){
		new id = propPickups[lastPickup[playerid]],Float:x,Float:y,Float:z;
		GetPropertyEntrance( id, x, y, z );
		if( IsPlayerInRangeOfPoint( playerid, 3.0, x, y, z )){
			new str[ 140 ],str1[ 140 ];
			GangZoneShowForAll(safezone[0], 0xFF0000FF);
		 	GangZoneShowForAll(safezone[1], 0xFF0000FF);
		 	format( str, sizeof str, "{f59342}[INFO]: {FFFFFF}Iniciaste el robo, la policia vendra pronto!" );
			SendClientMessage(playerid, -1, str );
			GangZoneFlashForPlayer(0xFFFFFFFF, playerid, safezone[0]);
			GangZoneFlashForPlayer(0xFFFFFFFF, playerid, safezone[1]);
			format( str1, sizeof str1, "{4260f5}[LSPD]: {FFFFFF}Se inicio un robo en Clucking Bell/24-7");
			SendClientMessageToAll(-1, str1 );
			Icon[ params[0] ] = CreateDynamicMapIcon(x,y,z, 19, -1, 0, 0, -1, 300 );
			/*for(new i; i < MAX_PLAYERS; i++)
			{
			    if(ladrones[playerid] == true){
					format( str, sizeof str, "{f59342}[INFO]: {FFFFFF}Iniciaste el robo, la policia vendra pronto!" );
					SendClientMessage(ladrones[i], -1, str );
					GangZoneFlashForPlayer(0xFFFFFFFF, playerid, safezone[0]);
					GangZoneFlashForPlayer(0xFFFFFFFF, playerid, safezone[1]);
				}
	    		if(LSPD[playerid] == true){
					format( str1, sizeof str1, "{4260f5}[LSPD]: {FFFFFF}Se inicio un robo en Clucking Bell/24-7");
					SendClientMessage( LSPD[i], -1, str1 );
					Icon[ 1 ] = CreateDynamicMapIcon(x,y,z, 19, -1, 0, 0, -1, 300 );
				}
				format( str1, sizeof str1, "{4260f5}[LSPD]: {FFFFFF}Se inicio un robo en Clucking Bell/24-7");
				SendClientMessage( LSPD[i], -1, str1 );
				Icon[params[0]] = CreateDynamicMapIcon(x,y,z, 19, -1, 0, 0, -1, 300 );
	    		return 1;
			}*/
	    	return 1;
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
	GangZoneFlashForAll(0xFF0000FF, safezone[0]);
	return 1;
}
CMD:ladron(playerid, params[]){
	new str[ 140 ],str1[ 140 ];
	if(PlayerInfo[playerid][LSPD] == 1){
		format( str1, sizeof str1, "{f59342}[INFO]: {FFFFFF}Sos un policia");
		SendClientMessage(playerid, -1, str1 );
		return 1;
	}
	if(ladrones[playerid] == true){
		format( str, sizeof str, "{f59342}[INFO]: {FFFFFF}Ya eres ladron!" );
		SendClientMessage( playerid, -1, str );
		return 1;
	}
 	ladrones[playerid] = true;
 	format( str, sizeof str, "{4260f5}[LSPD]: {FFFFFF}Eres un ladron"/*,GetPropertyName(id)*/);
	SendClientMessage(playerid, -1, str );
	return 1;
}
CMD:policia(playerid, params[]){
	new str1[ 140 ],str[ 140 ];
	if(ladrones[playerid] == true){
		format( str, sizeof str, "{f59342}[INFO]: {FFFFFF}Sos un ladron!" );
		SendClientMessage( playerid, -1, str );
		return 1;
	}
    if(PlayerInfo[playerid][LSPD] == 1){
		format( str1, sizeof str1, "{f59342}[INFO]: {FFFFFF}Ya estas en servicio");
		SendClientMessage(playerid, -1, str1 );
		return 1;
	}
	PlayerInfo[playerid][LSPD] = 1;
	format( str1, sizeof str1, "{4260f5}[LSPD]: {FFFFFF}Entraste en servicio de policia");
	SendClientMessage(playerid, -1, str1 );
	return 1;
}
CMD:checkrobos(playerid, params[]){
    new str[ 140 ];
    for(new i; i < MAX_MAPICONS; i++){
		format( str, sizeof( str ), "{f59342}[INFO]: {FFFFFF}ID de iconos existentes %d.", Icon[i] );
		SendClientMessage( playerid, -1, str );
	}
	return 1;
}
CMD:checkrlspd(playerid, params[]){
	return 1;
}

/***********************************************************************
***********************************************************************/
