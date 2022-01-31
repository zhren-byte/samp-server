#include <a_samp>

new Text:velocimetro0         [ MAX_PLAYERS ];
new Text:velocimetro1         [ MAX_PLAYERS ];
new Text:velocimetro2         [ MAX_PLAYERS ];
new Text:velocimetro3         [ MAX_PLAYERS ];
new Text:velocimetro4         [ MAX_PLAYERS ];
new Text:velocimetro5         [ MAX_PLAYERS ];
new Text:velocimetro6         [ MAX_PLAYERS ];
new Text:velocimetro7         [ MAX_PLAYERS ];
new Text:velocimetro8         [ MAX_PLAYERS ];
new Text:velocimetro9         [ MAX_PLAYERS ];
new Text:velocimetro10        [ MAX_PLAYERS ];
new Text:velocimetro11        [ MAX_PLAYERS ];
new Text:velocimetro12        [ MAX_PLAYERS ];
new Text:velocimetro13        [ MAX_PLAYERS ];
new VelocimetroLigado         [ MAX_PLAYERS ];
new spawnado                  [ MAX_PLAYERS ];

enum SavePlayerPosEnum
{
    Float:LastX,
    Float:LastY,
    Float:LastZ
};
new SavePlayerPos[MAX_PLAYERS][SavePlayerPosEnum];

new VehicleNames[][] =
{
    "Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel",
    "Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
    "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
    "Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection",
    "Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus",
    "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
    "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral",
    "Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
    "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "Berkley's RC Van",
    "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale",
    "Oceanic","Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy",
    "Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX",
    "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper",
    "Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking",
    "Blista Compact", "Police Maverick", "Boxville", "Benson", "Mesa", "RC Goblin",
    "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher", "Super GT",
    "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt",
    "Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra",
    "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck", "Fortune",
    "Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer",
    "Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent",
    "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo",
    "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite",
    "Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratium",
    "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
    "Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper",
    "Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400",
    "News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
    "Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "Police Car",
    "Police Car", "Police Car", "Police Ranger", "Picador", "S.W.A.T", "Alpha",
    "Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs", "Boxville",
    "Tiller", "Utility Trailer"
};


public OnGameModeInit()
{
    SetTimer("VeloDiego", 1000, 1);

    for(new i=0; i<MAX_PLAYERS; i++)
    {
        velocimetro0[i] = TextDrawCreate(478.799804, 350.193267, "BOX_Direito");
        TextDrawLetterSize(velocimetro0[i], 0.000000, 9.067035);
        TextDrawTextSize(velocimetro0[i], 467.599914, 0.000000);
        TextDrawAlignment(velocimetro0[i], 1);
        TextDrawColor(velocimetro0[i], 0);
        TextDrawUseBox(velocimetro0[i], true);
        TextDrawBoxColor(velocimetro0[i], 16777215);
        TextDrawSetShadow(velocimetro0[i], 0);
        TextDrawSetOutline(velocimetro0[i], 0);
        TextDrawFont(velocimetro0[i], 0);

        velocimetro1[i] = TextDrawCreate(626.000000, 353.926666, "BOX_Centro");
        TextDrawLetterSize(velocimetro1[i], 0.000000, 8.720368);
        TextDrawTextSize(velocimetro1[i], 472.399993, 0.000000);
        TextDrawAlignment(velocimetro1[i], 1);
        TextDrawColor(velocimetro1[i], 0);
        TextDrawUseBox(velocimetro1[i], true);
        TextDrawBoxColor(velocimetro1[i], 102);
        TextDrawSetShadow(velocimetro1[i], 0);
        TextDrawSetOutline(velocimetro1[i], 0);
        TextDrawFont(velocimetro1[i], 0);

        velocimetro2[i] = TextDrawCreate(626.800109, 350.193328, "BOX_Cima");
        TextDrawLetterSize(velocimetro2[i], 0.000000, -0.227775);
        TextDrawTextSize(velocimetro2[i], 467.600036, 0.000000);
        TextDrawAlignment(velocimetro2[i], 1);
        TextDrawColor(velocimetro2[i], 0);
        TextDrawUseBox(velocimetro2[i], true);
        TextDrawBoxColor(velocimetro2[i], 16777215);
        TextDrawSetShadow(velocimetro2[i], 0);
        TextDrawSetOutline(velocimetro2[i], 0);
        TextDrawFont(velocimetro2[i], 0);
        
        velocimetro3[i] = TextDrawCreate(629.999938, 350.193298, "usebox");
        TextDrawLetterSize(velocimetro3[i], 0.000000, 9.072962);
        TextDrawTextSize(velocimetro3[i], 618.799987, 0.000000);
        TextDrawAlignment(velocimetro3[i], 1);
        TextDrawColor(velocimetro3[i], 0);
        TextDrawUseBox(velocimetro3[i], true);
        TextDrawBoxColor(velocimetro3[i], 16777215);
        TextDrawSetShadow(velocimetro3[i], 0);
        TextDrawSetOutline(velocimetro3[i], 0);
        TextDrawFont(velocimetro3[i], 0);

        velocimetro4[i] = TextDrawCreate(630.000000, 434.566650, "usebox");
        TextDrawLetterSize(velocimetro4[i], 0.000000, -0.144811);
        TextDrawTextSize(velocimetro4[i], 467.599975, 0.000000);
        TextDrawAlignment(velocimetro4[i], 1);
        TextDrawColor(velocimetro4[i], 0);
        TextDrawUseBox(velocimetro4[i], true);
        TextDrawBoxColor(velocimetro4[i], 16777215);
        TextDrawSetShadow(velocimetro4[i], 0);
        TextDrawSetOutline(velocimetro4[i], 0);
        TextDrawFont(velocimetro4[i], 0);

        velocimetro5[i] = TextDrawCreate(627.600097, 365.126617, "usebox");
        TextDrawLetterSize(velocimetro5[i], 0.000000, -0.307778);
        TextDrawTextSize(velocimetro5[i], 472.399993, 0.000000);
        TextDrawAlignment(velocimetro5[i], 1);
        TextDrawColor(velocimetro5[i], 0);
        TextDrawUseBox(velocimetro5[i], true);
        TextDrawBoxColor(velocimetro5[i], 16777215);
        TextDrawSetShadow(velocimetro5[i], 0);
        TextDrawSetOutline(velocimetro5[i], 0);
        TextDrawFont(velocimetro5[i], 0);

        velocimetro6[i] = TextDrawCreate(628.599975, 419.140258, "usebox");
        TextDrawLetterSize(velocimetro6[i], 0.000000, -0.307778);
        TextDrawTextSize(velocimetro6[i], 472.399841, 0.000000);
        TextDrawAlignment(velocimetro6[i], 1);
        TextDrawColor(velocimetro6[i], 0);
        TextDrawUseBox(velocimetro6[i], true);
        TextDrawBoxColor(velocimetro6[i], 16777215);
        TextDrawSetShadow(velocimetro6[i], 0);
        TextDrawSetOutline(velocimetro6[i], 0);
        TextDrawFont(velocimetro6[i], 0);

        velocimetro7[i] = TextDrawCreate(498.399902, 350.186798, "Velocimetro");
        TextDrawLetterSize(velocimetro7[i], 0.450000, 1.271466);
        TextDrawAlignment(velocimetro7[i], 1);
        TextDrawColor(velocimetro7[i], -1);
        TextDrawSetShadow(velocimetro7[i], 0);
        TextDrawSetOutline(velocimetro7[i], 1);
        TextDrawBackgroundColor(velocimetro7[i], 51);
        TextDrawFont(velocimetro7[i], 1);
        TextDrawSetProportional(velocimetro7[i], 1);

        velocimetro8[i] = TextDrawCreate(520.799987, 366.613281, "Vehiculo:");
        TextDrawLetterSize(velocimetro8[i], 0.346800, 1.107199);
        TextDrawAlignment(velocimetro8[i], 1);
        TextDrawColor(velocimetro8[i], -1);
        TextDrawSetShadow(velocimetro8[i], 0);
        TextDrawSetOutline(velocimetro8[i], 1);
        TextDrawBackgroundColor(velocimetro8[i], 51);
        TextDrawFont(velocimetro8[i], 1);
        TextDrawSetProportional(velocimetro8[i], 1);

        velocimetro9[i] = TextDrawCreate(505.599884, 376.319976, "~n~");
        TextDrawLetterSize(velocimetro9[i], 0.449999, 1.600000);
        TextDrawAlignment(velocimetro9[i], 1);
        TextDrawColor(velocimetro9[i], -1);
        TextDrawSetShadow(velocimetro9[i], 0);
        TextDrawSetOutline(velocimetro9[i], 1);
        TextDrawBackgroundColor(velocimetro9[i], 51);
        TextDrawFont(velocimetro9[i], 2);
        TextDrawSetProportional(velocimetro9[i], 1);

        velocimetro10[i] = TextDrawCreate(476.800109, 386.773254, "-");
        TextDrawLetterSize(velocimetro10[i], 10.202018, 1.092267);
        TextDrawAlignment(velocimetro10[i], 1);
        TextDrawColor(velocimetro10[i], -1);
        TextDrawSetShadow(velocimetro10[i], 0);
        TextDrawSetOutline(velocimetro10[i], 1);
        TextDrawBackgroundColor(velocimetro10[i], 51);
        TextDrawFont(velocimetro10[i], 1);
        TextDrawSetProportional(velocimetro10[i], 1);

        velocimetro11[i] = TextDrawCreate(491.199920, 393.493347, "~n~");
        TextDrawLetterSize(velocimetro11[i], 0.630800, 2.413865);
        TextDrawAlignment(velocimetro11[i], 1);
        TextDrawColor(velocimetro11[i], -1);
        TextDrawSetShadow(velocimetro11[i], 0);
        TextDrawSetOutline(velocimetro11[i], 2);
        TextDrawBackgroundColor(velocimetro11[i], 51);
        TextDrawFont(velocimetro11[i], 3);
        TextDrawSetProportional(velocimetro11[i], 1);

        velocimetro12[i] = TextDrawCreate(537.599914, 393.493225, "KM/H");
        TextDrawLetterSize(velocimetro12[i], 0.533200, 2.428801);
        TextDrawAlignment(velocimetro12[i], 1);
        TextDrawColor(velocimetro12[i], -1);
        TextDrawSetShadow(velocimetro12[i], 0);
        TextDrawSetOutline(velocimetro12[i], 1);
        TextDrawBackgroundColor(velocimetro12[i], 51);
        TextDrawFont(velocimetro12[i], 2);
        TextDrawSetProportional(velocimetro12[i], 1);

        velocimetro13[i] = TextDrawCreate(490.400024, 419.626678, "~n~");
        TextDrawLetterSize(velocimetro13[i], 0.414799, 1.293866);
        TextDrawAlignment(velocimetro13[i], 1);
        TextDrawColor(velocimetro13[i], -1);
        TextDrawSetShadow(velocimetro13[i], 0);
        TextDrawSetOutline(velocimetro13[i], 1);
        TextDrawBackgroundColor(velocimetro13[i], 51);
        TextDrawFont(velocimetro13[i], 1);
        TextDrawSetProportional(velocimetro13[i], 1);
    }
    return 1;
}

forward VeloDiego(playerid);
public VeloDiego(playerid)
{
    new String[256], String2[256], String3[256];

    new Float: Speedo_X, Float:Speedo_Y, Float:Speedo_Z;

    for(new i=0; i<MAX_PLAYERS; i++)
    {
        new vehicle = GetPlayerVehicleID(i);

        new ModeloVeiculo = GetVehicleModel(vehicle);

        if(IsPlayerConnected(i) && IsPlayerInAnyVehicle(i))
        {
            GetPlayerPos(i, Speedo_X, Speedo_Y, Speedo_Z);

            if(VelocimetroLigado[i] == 0)
            {
                TextDrawShowForPlayer(i, velocimetro0[i]);
                TextDrawShowForPlayer(i, velocimetro1[i]);
                TextDrawShowForPlayer(i, velocimetro2[i]);
                TextDrawShowForPlayer(i, velocimetro3[i]);
                TextDrawShowForPlayer(i, velocimetro4[i]);
                TextDrawShowForPlayer(i, velocimetro5[i]);
                TextDrawShowForPlayer(i, velocimetro6[i]);
                TextDrawShowForPlayer(i, velocimetro7[i]);
                TextDrawShowForPlayer(i, velocimetro8[i]);
                TextDrawShowForPlayer(i, velocimetro9[i]);
                TextDrawShowForPlayer(i, velocimetro10[i]);
                TextDrawShowForPlayer(i, velocimetro11[i]);
                TextDrawShowForPlayer(i, velocimetro12[i]);
                TextDrawShowForPlayer(i, velocimetro13[i]);
                VelocimetroLigado[i] = 1;
            }
            format(String, sizeof(String), "%s", VehicleNames[GetVehicleModel(vehicle) - 400]);
            TextDrawSetString(velocimetro9[i], String);

            format(String2, sizeof(String2),"%d", GetPlayerSpeed(i, true));
            TextDrawSetString(velocimetro11[i], String2);

            format(String3,sizeof(String3),"Veiculo ID: %d", ModeloVeiculo);
            TextDrawSetString(velocimetro13[i], String3);

        }
        SavePlayerPos[i][LastX] = Speedo_X, SavePlayerPos[i][LastY] = Speedo_Y, SavePlayerPos[i][LastZ] = Speedo_Z;
    }
    for(new i=0; i<MAX_PLAYERS; i++)
    {
        if(!IsPlayerInAnyVehicle(i))
        {
            TextDrawHideForPlayer(i, velocimetro0[i]);
            TextDrawHideForPlayer(i, velocimetro1[i]);
            TextDrawHideForPlayer(i, velocimetro2[i]);
            TextDrawHideForPlayer(i, velocimetro3[i]);
            TextDrawHideForPlayer(i, velocimetro4[i]);
            TextDrawHideForPlayer(i, velocimetro5[i]);
            TextDrawHideForPlayer(i, velocimetro6[i]);
            TextDrawHideForPlayer(i, velocimetro7[i]);
            TextDrawHideForPlayer(i, velocimetro8[i]);
            TextDrawHideForPlayer(i, velocimetro9[i]);
            TextDrawHideForPlayer(i, velocimetro10[i]);
            TextDrawHideForPlayer(i, velocimetro11[i]);
            TextDrawHideForPlayer(i, velocimetro12[i]);
            TextDrawHideForPlayer(i, velocimetro13[i]);
            VelocimetroLigado[i] = 0;

        }
        if(spawnado[i] == 1)
        {
            if(VelocimetroLigado[i] >= 1)
            {

            }

            if(VelocimetroLigado[i] <= 0)
            {

            }
        }
    }
}

stock GetVehicleName(vehicleid)
{
    format(String,sizeof(String),"%s",VehicleNames[GetVehicleModel(vehicleid) - 400]);
    return String;
}

stock GetPlayerSpeed(playerid,bool:kmh)
{
    new Float:Vx,Float:Vy,Float:Vz,Float:rtn;

    if(IsPlayerInAnyVehicle(playerid)) GetVehicleVelocity(GetPlayerVehicleID(playerid), Vx, Vy, Vz); else GetPlayerVelocity(playerid, Vx, Vy, Vz);

    rtn = floatsqroot(floatabs(floatpower(Vx + Vy + Vz,2)));

    return kmh?floatround(rtn * 100 * 1.61):floatround(rtn * 100);

}
