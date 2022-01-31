#include <a_samp>
#pragma tabsize 0
//                variables clasificadas por "A Y B".
new Float:DmgA[MAX_PLAYERS],                Float:DmgB[MAX_PLAYERS],
    TiempoDmgA[MAX_PLAYERS],                TiempoDmgB[MAX_PLAYERS],
    PlayerText:IndiA[MAX_PLAYERS],          PlayerText:IndiB[MAX_PLAYERS];

new str[100];
new weaponNames[55][] = //Esto nos dira el nombre del arma.
{
    {"Punch"},{"Brass Knuckles"},{"Golf Club"},{"Nite Stick"},{"Knife"},{"Baseball Bat"},{"Shovel"},{"Pool Cue"},{"Katana"},{"Chainsaw"},{"Purple Dildo"},
    {"Smal White Vibrator"},{"Large White Vibrator"},{"Silver Vibrator"},{"Flowers"},{"Cane"},{"Grenade"},{"Tear Gas"},{"Molotov Cocktail"},
    {""},{""},{""},
    {"Colt"},{"Silenced 9mm"},{"Deagle"},{"Shotgun"},{"Sawn-off"},{"Combat"},{"Micro SMG"},{"MP5"},{"AK-47"},{"M4"},{"Tec9"},
    {"Rifle"},{"Sniper"},{"Rocket"},{"HS Rocket"},{"Flamethrower"},{"Minigun"},{"Satchel Charge"},{"Detonator"},
    {"Spraycan"},{"Fire Extinguisher"},{"Camera"},{"Nightvision Goggles"},{"Thermal Goggles"},{"Parachute"}, {"Fake Pistol"},{""}, {"Vehicle"}, {"Helicopter Blades"},
    {"Explosion"}, {""}, {"Drowned"}, {"Collision"}
};

public OnFilterScriptInit()
{
    print("*----------------------------------*");
    print("   DMG SYSTEM By: Zhren");
    print("*----------------------------------*");
    return 1;
}
public OnFilterScriptExit()
{
    print("*----------------------------------*");
    print("     OFF DMG SYSTEM                  ");
    print("*----------------------------------*");
    return 1;
}

public OnPlayerConnect(playerid)
{
    CText(playerid); //Cargar TextDraw's
    return 1;
}

public OnPlayerDisconnect(playerid)
{
    BText(playerid); //Borrar TextDraw's
    return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float: amount, weaponid)
{
    if(TiempoDmgA[playerid] != 0) KillTimer(TiempoDmgA[playerid]);
     DmgA[playerid] += amount;
      format(str,sizeof(str),"%s ~r~~h~~h~-%.0f dmg ~w~%s", Nombre(playerid), DmgA[playerid], weaponNames[weaponid]);
       PlayerTextDrawSetString(playerid, IndiA[playerid], str);

       TiempoDmgA[playerid] = SetTimerEx("RDDA", 3000, 0, "i", playerid);
    PlayerTextDrawShow(playerid, IndiA[playerid]);
    return 1;
}

public OnPlayerGiveDamage(playerid, damagedid, Float: amount, weaponid, bodypart)
{
    if(TiempoDmgB[playerid] != 0) KillTimer(TiempoDmgB[playerid]);
    DmgB[playerid] += amount;
    format(str,sizeof(str),"%s ~g~~h~~h~+%.0f dmg ~w~%s", Nombre(damagedid), DmgB[playerid], weaponNames[weaponid]);
    PlayerTextDrawSetString(playerid, IndiB[playerid], str);

    TiempoDmgB[playerid] = SetTimerEx("RDDB", 3000, 0, "i", playerid);
    PlayerTextDrawShow(playerid, IndiB[playerid]);
    return 1;
 }

forward RDDA(playerid); //RDDA: Reinicio De Daño A
public RDDA(playerid)
{
    DmgA[playerid] = 0;
    PlayerTextDrawHide(playerid, IndiA[playerid]);
    KillTimer(TiempoDmgA[playerid]);
    return 1;
}

forward RDDB(playerid); //RDDA: Reinicio De Daño B
public RDDB(playerid)
{
    DmgB[playerid] = 0;
    PlayerTextDrawHide(playerid, IndiB[playerid]);
    KillTimer(TiempoDmgB[playerid]);
    return 1;
}

stock CText(playerid)
{
    IndiA[playerid] = CreatePlayerTextDraw(playerid, 400.0,362.0, "");
    PlayerTextDrawLetterSize(playerid, IndiA[playerid], 0.23000, 1.0);
    PlayerTextDrawAlignment(playerid, IndiA[playerid], 1);
    PlayerTextDrawColor(playerid, IndiA[playerid], -1);
    PlayerTextDrawSetShadow(playerid, IndiA[playerid], 0);
    PlayerTextDrawSetOutline(playerid, IndiA[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, IndiA[playerid], 51);
    PlayerTextDrawFont(playerid, IndiA[playerid], 1);
    PlayerTextDrawSetProportional(playerid, IndiA[playerid], 1);

    IndiB[playerid] = CreatePlayerTextDraw(playerid, 180.0,362.0, "");
    PlayerTextDrawLetterSize(playerid, IndiB[playerid], 0.23000, 1.0);
    PlayerTextDrawAlignment(playerid, IndiB[playerid], 1);
    PlayerTextDrawColor(playerid, IndiB[playerid], -1);
    PlayerTextDrawSetShadow(playerid, IndiB[playerid], 0);
    PlayerTextDrawSetOutline(playerid, IndiB[playerid], 1);
    PlayerTextDrawBackgroundColor(playerid, IndiB[playerid], 51);
    PlayerTextDrawFont(playerid, IndiB[playerid], 1);
    PlayerTextDrawSetProportional(playerid, IndiB[playerid], 1);
     return 1;
}

stock BText(playerid)
{
    PlayerTextDrawHide(playerid,IndiA[playerid]);
    PlayerTextDrawHide(playerid,IndiB[playerid]);
    return 1;
}

Nombre(playerid)
{
    new NOMBRE[50];
    GetPlayerName(playerid,NOMBRE,sizeof(NOMBRE));
    return NOMBRE;
}

