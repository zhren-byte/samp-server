// By Rajat

#include <a_samp>
#include <sscanf2>
#include <zcmd>

CMD:setname(playerid, params[]) {
	new
		id,
		name[128];
	if(sscanf(params, "is[128]", id, name)) return SendClientMessage(playerid, 0xFF00000FF, "/setname [id] [nombre]");
	else if(!IsPlayerConnected(id) || id == INVALID_PLAYER_ID) return SendClientMessage(playerid, 0xFF0000FF, "Jugador no conectado o no existente");
	if(!IsPlayerAdmin(playerid)) return SendClientMessage(playerid, 0xFF0000FF, "No eres admin");
	SetPlayerName(id, name);
	return 1;
}
CMD:activa(playerid, params[]) {
    SendClientMessage(playerid, 0xFFFF00FF, "Se activo iconos en el mapa");
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_GLOBAL);
    LimitPlayerMarkerRadius(1000.0);
    return 1;
}
CMD:desactiva(playerid, params[]) {
    SendClientMessage(playerid, 0xFFFF00FF, "Se desactivo iconos en el mapa");
    ShowPlayerMarkers(PLAYER_MARKERS_MODE_OFF);
    LimitPlayerMarkerRadius(1.0);
    return 1;
}
CMD:chabe(playerid, params[]) {
	if(sscanf(params, "u", params[0])){
		SetPlayerArmour(playerid, 100.0);
		SetPlayerHealth(playerid, 100.0);
	}
	SetPlayerArmour(params[0], 100.0);
	SetPlayerHealth(params[0], 100.0);
    return 1;
}
