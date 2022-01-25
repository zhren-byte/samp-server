// By Rajat

#include <a_samp>
#include <sscanf2>
#include <zcmd>

CMD:murder(playerid, params[]) {
	if(sscanf(params, "ud", params[0])) return SendClientMessage(playerid, -1, "/murder [ID/NOMBRE]");
	ResetPlayerWeapons(params[0]);
	GivePlayerWeapon(params[0], 9,100);
	return 1;
}
CMD:encontrado(playerid, params[]) {
    new name[ 24 ], string[ 64 ];
 	if(sscanf(params, "ud", params[0])) return SendClientMessage(playerid, -1, "/encontrado [ID/NOMBRE]");
	GetPlayerName( params[0], name, 24 );
    format( string, sizeof(string), "~w~%s fue encontrado.", name );
    GameTextForAll( string, 5000, 3 );
    return 1;
}
CMD:escondidas(playerid, params[]) {
    ShowPlayerDialog(playerid, 3, DIALOG_STYLE_LIST, "Hide and Seek", "Madd Dog Mansion\nPorta Aviones\nLimbo\nJefferson Motel\nCatigula Hotel\nArea51\nCrack Factory", "Teleport", "Cancel");
	return 1;
}
