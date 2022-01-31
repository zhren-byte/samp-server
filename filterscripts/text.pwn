// Inicio del archivo
/*
Zamaroht's TextDraw Editor Version 1.0RC2.
Diseñado para SA-MP 0.3.
Versión en español.

Autor: Zamaroht (Nicolás Laurito)

Inicio del Desarrollo: 25 Diciembre 2009, 22:16 (GMT-3)
Fin del Desarrollo: 01 Enero 2010, 23:31 (GMT-3)
Fin de la Traducción: 03 Enero 2010, 15:19 (GMT-3)

Licencia:
Puedes redistribuir este archivo como quieras, pero SIEMPRE manteniento el
nombre del autor y un link de regreso a
http://forum.sa-mp.com/index.php?topic=143025.0 junto con el medio de
distrubución.
Por ejemplo, el link con el nombre del autór en un hilo de un foro público, o
un archivo README por separado en un archivo .zip, etc.
Si modificas este archivo, los mismos términos se aplican. Tienes que incluir
el autor original (Zamaroht) y un link de regreso a la página mencionada.
*/

#include <a_samp>
#include <dini>
#include <zcmd>
#pragma tabsize 0

// =============================================================================
// Declaraciones Internas.
// =============================================================================

#define MAX_TEXTDRAWS       90			// La cantidad máxima en la pantalla del cliente es de 92. Usamos 90 para estar seguros.
#define MSG_COLOR           0xFAF0CEFF	// Color en que se muestran los mensajes.
#define PREVIEW_CHARS       35			// Cantidad de carácteres que se pueden llegar a mostrar en la preview del textdraw.


// Usado con P_Aux
#define DELETING 0
#define LOADING 1

// Usado con P_KeyEdition
#define EDIT_NONE       0
#define EDIT_POSITION   1
#define EDIT_SIZE       2
#define EDIT_BOX        3

// Usado con P_ColorEdition
#define COLOR_TEXT      0
#define COLOR_OUTLINE   1
#define COLOR_BOX       2

enum enum_tData // Datos de los textdraws.
{
	bool:T_Created,			// Si el textdraw está creado o no.
	Text:T_Handler,         // Donde el textdraw está guardado.
	T_Text[1024],           // El texto del textdraw.
	Float:T_X,
	Float:T_Y,
	T_Alignment,
	T_BackColor,
	T_BoxColor,
	T_Color,
	T_Font,
	Float:T_XSize,
	Float:T_YSize,
	T_Outline,
	T_Proportional,
	T_Shadow,
	Float:T_TextSizeX,
	Float:T_TextSizeY,
	T_UseBox
};

enum enum_pData // Datos del jugador.
{
	bool:P_Editing,         // Si el jugador está editando o no en el momento (permitir /text).
	P_DialogPage,           // Página del menu de selección de textdraw en la que se encuentran.
	P_CurrentTextdraw,      // Textdraw ID que está siendo editada en el momento.
	P_CurrentMenu,          // Solo usado al comiendo, para saber si el jugador esta LOADING o DELETING.
	P_KeyEdition,           // Usado para saber que edición se está haciendo con teclado. Revisar #defines.
	P_Aux,      		    // Variable auxiliar. Usada como temporal en varios casos.
	P_ColorEdition,         // Usada para saber a QUE le está cambiando el color el jugador. Revisar #defines.
	P_Color[4],             // Contiene RGBA cuando se usa el combinador de colores.
	P_ExpCommand[128],      // Cntiene temporalmente el comando que será usado en un filterscript autogenerado en modo comando.
	P_Aux2                  // Solo usado en algunos casos especiales de export.
};

new tData[MAX_TEXTDRAWS][enum_tData],
	pData[MAX_PLAYERS][enum_pData];
	
new CurrentProject[128];  // Strint que contiene donde se ecuentra el archivo actualmente abierto.

// =============================================================================
// Callbacks.
// =============================================================================

public OnFilterScriptInit()
{
	print("\n--------------------------------------");
	print(" Text Draw Editor 1.0RC2 por Zamaroht para SA-MP 0.3 Cargado.");
	print(" -- Versión en español.");
	print("--------------------------------------\n");
	for(new i; i < MAX_PLAYERS; i ++) if(IsPlayerConnected(i)) ResetPlayerVars(i);
	for(new i; i < MAX_TEXTDRAWS; i ++)
	{
	    tData[i][T_Handler] = TextDrawCreate(0.0, 0.0, " ");
	}
	return 1;
}

public OnFilterScriptExit()
{
    for(new i; i < MAX_TEXTDRAWS; i ++)
	{
	    TextDrawHideForAll(tData[i][T_Handler]);
	    TextDrawDestroy(tData[i][T_Handler]);
	}
	return 1;
}

public OnPlayerConnect(playerid)
{
	for(new i; i < MAX_TEXTDRAWS; i ++)
	{
	    if(tData[i][T_Created])
	        TextDrawShowForPlayer(playerid, tData[i][T_Handler]);
	}
}

public OnPlayerSpawn(playerid)
{
	SendClientMessage(playerid, MSG_COLOR, "Usar /text para mostrar el Menu de Edición.");
	
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
    ResetPlayerVars(playerid);
	return 1;
}

CMD:text(playerid,params[0]){
	if(pData[playerid][P_Editing]) return SendClientMessage(playerid, MSG_COLOR, "[ERROR] Termina la edición actual antes de usar /text!");
	else if(!strlen(CurrentProject) || !strcmp(CurrentProject, " "))
	{
		if(IsPlayerMinID(playerid))
		{
			ShowTextDrawDialog(playerid, 0);
   			pData[playerid][P_Editing] = true;
   		}else
     		SendClientMessage(playerid, MSG_COLOR, "Solo la ID menor del servidor puede manejar proyectos. Pídele que abra uno.");
		    return 1;
		}
		else
		{
		    ShowTextDrawDialog(playerid, 4, 0);
		    pData[playerid][P_Editing] = true;
		    return 1;
		}
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    if(response == 1) 	PlayerPlaySound(playerid, 1083, 0.0, 0.0, 0.0); // Sonido de confirmacion
    else 				PlayerPlaySound(playerid, 1084, 0.0, 0.0, 0.0); // Sonido de cancelacion
    
    switch(dialogid)
    {
        case 0: // Primer dialogo
        {
            if(response) // Si apreta aceptar
            {
                strmid(CurrentProject, "", 0, 1, 128);
                
                if(listitem == 0) // Apret nuevo proyecto
                    ShowTextDrawDialog(playerid, 1);
                else if(listitem == 1) // Apret cargar proyecto
                    ShowTextDrawDialog(playerid, 2, 1);
                else if(listitem == 2) // Apretó eliminar proyecto
                    ShowTextDrawDialog(playerid, 2, 2);
            }
            else pData[playerid][P_Editing] = false;
        }
        
        case 1: // Nuevo Project
        {
            if(response)
            {
                if(strlen(inputtext) > 120) ShowTextDrawDialog(playerid, 1, 1); // Muy largo.
                
                else if(
					strfind(inputtext, "/") != -1 || strfind(inputtext, "\\") != -1 ||
					strfind(inputtext, ":") != -1 || strfind(inputtext, "*") != -1 ||
					strfind(inputtext, "?") != -1 || strfind(inputtext, "\"") != -1 ||
					strfind(inputtext, "<") != -1 || strfind(inputtext, ">") != -1 ||
					strfind(inputtext, "|") != -1 || !strlen(inputtext) ||
					inputtext[0] == ' ' )
						ShowTextDrawDialog(playerid, 1, 3); // Caracteres ilegales
						
                else // Esta bien, crear nuevo archivo
                {
                    new filename[128];
                    format(filename, sizeof(filename), "%s.tde", inputtext);
                    if(fexist(filename)) ShowTextDrawDialog(playerid, 1, 2); // Ya existe.
                    else
                    {
	                    CreateNewProject(filename);
	                    strmid(CurrentProject, filename, 0, strlen(inputtext), 128);
	                    
	                    new tmpstr[128];
	                    format(tmpstr, sizeof(tmpstr), "You are now working on the '%s' project.", filename);
	                    SendClientMessage(playerid, MSG_COLOR, tmpstr);
	                    
	                    ShowTextDrawDialog(playerid, 4); // Mostrar el menu principal de edicion
			 		}
                }
            }
            else
                ShowTextDrawDialog(playerid, 0);
        }
        
        case 2: // Cargar/Eliminar proyecto
        {
            if(response)
            {
                if(listitem == 0) // Nombre de archivo especifico
                {
                    if(pData[playerid][P_CurrentMenu] == LOADING)		ShowTextDrawDialog(playerid, 3);
                    else if(pData[playerid][P_CurrentMenu] == DELETING)	ShowTextDrawDialog(playerid, 0);
				}
				else
				{
				    if(pData[playerid][P_CurrentMenu] == DELETING)
				    {
				        pData[playerid][P_Aux] = listitem - 1;
				        ShowTextDrawDialog(playerid, 6);
					}
					else if(pData[playerid][P_CurrentMenu] == LOADING)
					{
					    new filename[135];
					    format(filename, sizeof(filename), "%s", GetFileNameFromLst("tdlist.lst", listitem - 1));
					    LoadProject(playerid, filename);
					}
                }
            }
            else
                ShowTextDrawDialog(playerid, 0);
        }
        
        case 3: // Cargar proyecto especifico
        {
			if(response)
			{
				new ending[5];
				strmid(ending, inputtext, strlen(inputtext) - 4, strlen(inputtext));
				if(strcmp(ending, ".tde") != 0)
				{
				    new filename[128];
				    format(filename, sizeof(filename), "%s.tde", inputtext);
				    LoadProject(playerid, filename);
				}
				else LoadProject(playerid, inputtext);
			}
			else
			{
			    if(pData[playerid][P_CurrentMenu] == DELETING)		ShowTextDrawDialog(playerid, 2, 2);
			    else if(pData[playerid][P_CurrentMenu] == LOADING)	ShowTextDrawDialog(playerid, 2);
			}
        }
        
        case 4: // Seleccion de textdraw
        {
            if(response)
            {
                if(listitem == 0) // Seleccionaron nuevo TD
                {
                    pData[playerid][P_CurrentTextdraw] = -1;
                    for(new i; i < MAX_TEXTDRAWS; i++)
                    {
                        if(!tData[i][T_Created]) // Si todavia no esta creado, usarlo.
                        {
                            ClearTextdraw(i);
                            CreateDefaultTextdraw(i);
                            pData[playerid][P_CurrentTextdraw] = i;
                            ShowTextDrawDialog(playerid, 4, pData[playerid][P_DialogPage]);
                            break;
                        }
					}
					if(pData[playerid][P_CurrentTextdraw] == -1)
					{
					    SendClientMessage(playerid, MSG_COLOR, "No puedes crear más textdraws!");
					    ShowTextDrawDialog(playerid, 4, pData[playerid][P_DialogPage]);
					}
					else
					{
						new string[128];
	                    format(string, sizeof(string), "Textdraw #%d exitosamente creado.", pData[playerid][P_CurrentTextdraw]);
	                    SendClientMessage(playerid, MSG_COLOR, string);
					}
                }
                else if(listitem == 1) // Eligieron exportar
                {
                    ShowTextDrawDialog(playerid, 25);
                }
                else if(listitem == 2) // Eligieron cerrar proyecto
                {
                    if(IsPlayerMinID(playerid))
                    {
	                    for(new i; i < MAX_TEXTDRAWS; i ++)
	                    {
	                        ClearTextdraw(i);
	                    }

	                    new string[128];
	                    format(string, sizeof(string), "Proyecto '%s' cerrado.", CurrentProject);
	                    SendClientMessage(playerid, MSG_COLOR, string);

	                    strmid(CurrentProject, " ", 128, 128);
	                    ShowTextDrawDialog(playerid, 0);
					}
					else
					{
					    SendClientMessage(playerid, MSG_COLOR, "Solo la ID menor del servidor puede manejar proyectos. Pídele que abra uno.");
					    ShowTextDrawDialog(playerid, 4);
					}
                }
                else if(listitem <= 10) // Seleccionaron un TD
                {
                    new id = 3;
                    for(new i = pData[playerid][P_DialogPage]; i < MAX_TEXTDRAWS; i ++)
                    {
                        if(tData[i][T_Created])
                        {
							if(id == listitem)
							{
							    // Lo encontramos
							    pData[playerid][P_CurrentTextdraw] = i;
							    ShowTextDrawDialog(playerid, 5);
								break;
							}
							id ++;
						}
                    }
                    new string[128];
                    format(string, sizeof(string), "Ahora estás editando el textdraw #%d", pData[playerid][P_CurrentTextdraw]);
                    SendClientMessage(playerid, MSG_COLOR, string);
                }
                else
                {
                    new BiggestID, itemcount;
                    for(new i = pData[playerid][P_DialogPage]; i < MAX_TEXTDRAWS; i ++)
                    {
                        if(tData[i][T_Created])
                        {
							itemcount ++;
							BiggestID = i;
							if(itemcount == 9) break;
						}
                    }
                    ShowTextDrawDialog(playerid, 4, BiggestID);
				}
            }
            else
            {
                pData[playerid][P_Editing] = false;
                pData[playerid][P_DialogPage] = 0;
            }
        }
        
        case 5: // Menu principal de edicion
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: // Cambiar texto
	                {
                        ShowTextDrawDialog(playerid, 8);
	                }
	                case 1: // Cambiar posicion
	                {
	                    ShowTextDrawDialog(playerid, 9);
	                }
	                case 2: // Cambiar alineacion
	                {
	                    ShowTextDrawDialog(playerid, 11);
	                }
	                case 3: // Cambiar color de fuente
	                {
	                    pData[playerid][P_ColorEdition] = COLOR_TEXT;
	                    ShowTextDrawDialog(playerid, 13);
	                }
	                case 4: // Cambiar fuente
	                {
	                    ShowTextDrawDialog(playerid, 17);
	                }
	                case 5: // Cambiar proporcionalidad
	                {
	                    ShowTextDrawDialog(playerid, 12);
	                }
	                case 6: // Cambiar tamaño de letra
	                {
	                    ShowTextDrawDialog(playerid, 18);
	                }
	                case 7: // Editar contorno
	                {
	                    ShowTextDrawDialog(playerid, 20);
	                }
	                case 8: // Editar box
	                {
	                    if(tData[pData[playerid][P_CurrentTextdraw]][T_UseBox] == 0)		ShowTextDrawDialog(playerid, 23);
	                    else if(tData[pData[playerid][P_CurrentTextdraw]][T_UseBox] == 1)	ShowTextDrawDialog(playerid, 24);
	                }
	                case 9: // Duplicar textdraw
	                {
	                    new from, to;
	                    for(new i; i < MAX_TEXTDRAWS; i++)
	                    {
	                        if(!tData[i][T_Created]) // Si no ha sido creado, usarlo
	                        {
	                            ClearTextdraw(i);
	                            CreateDefaultTextdraw(i);
	                            from = pData[playerid][P_CurrentTextdraw];
	                            to = i;
	                            DuplicateTextdraw(pData[playerid][P_CurrentTextdraw], i);
	                            pData[playerid][P_CurrentTextdraw] = -1;
	                            ShowTextDrawDialog(playerid, 4);
	                            break;
	                        }
						}
						if(pData[playerid][P_CurrentTextdraw] != -1)
						{
						    SendClientMessage(playerid, MSG_COLOR, "No puedes crear más textdraws!");
						    ShowTextDrawDialog(playerid, 5);
						}
						else
						{
							new string[128];
		                    format(string, sizeof(string), "Textdraw #%d exitosamente copiado a Textdraw #%d.", from, to);
		                    SendClientMessage(playerid, MSG_COLOR, string);
						}
	                }
	                case 10: // Eliminar textdraw
	                {
                        ShowTextDrawDialog(playerid, 7);
	                }
				}
            }
            else
			{
			    ShowTextDrawDialog(playerid, 4, 0);
			}
        }
        
        case 6: // Confirmacion: eliminar proyecto
        {
            if(response)
            {
                new filename[128];
                format(filename, sizeof(filename), "%s", GetFileNameFromLst("tdlist.lst", pData[playerid][P_Aux]));
	            fremove(filename);
				DeleteLineFromFile("tdlist.lst", pData[playerid][P_Aux]);
				
				format(filename, sizeof(filename), "El proyecto guardado como '%s' ha sido borrado.", filename);
				SendClientMessage(playerid, MSG_COLOR, filename);
				
				ShowTextDrawDialog(playerid, 0);
			}
			else
			{
			    ShowTextDrawDialog(playerid, 0);
			}
        }
        
        case 7: // Confirmacion: Eliminar TD
        {
            if(response)
            {
                DeleteTDFromFile(pData[playerid][P_CurrentTextdraw]);
				ClearTextdraw(pData[playerid][P_CurrentTextdraw]);
                
                new string[128];
                format(string, sizeof(string), "Eliminaste el textdraw #%d", pData[playerid][P_CurrentTextdraw]);
                SendClientMessage(playerid, MSG_COLOR, string);
                
                pData[playerid][P_CurrentTextdraw] = 0;
                ShowTextDrawDialog(playerid, 4);
            }
            else
            {
                ShowTextDrawDialog(playerid, 5);
            }
        }
        
        case 8: // Cambiar texto del textdraw
        {
            if(response)
            {
                if(!strlen(inputtext)) ShowTextDrawDialog(playerid, 8);
                else
                {
	                format(tData[pData[playerid][P_CurrentTextdraw]][T_Text], 1024, "%s", inputtext);
	                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
	                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Text");
	                ShowTextDrawDialog(playerid, 5);
				}
            }
            else
            {
                ShowTextDrawDialog(playerid, 5);
            }
        }
        
        case 9: // Cambiar posicion del textdraw: Exacta o mover
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: // Posicion exacta
                    {
                        pData[playerid][P_Aux] = 0;
                        ShowTextDrawDialog(playerid, 10, 0, 0);
                    }
                    case 1: // Moverlo
                    {
                        new string[512];
                        string = "~n~~n~~n~~n~~n~~n~~n~~n~~w~";
                        if(!IsPlayerInAnyVehicle(playerid))	format(string, sizeof(string), "%s~k~~GO_FORWARD~, ~k~~GO_BACK~, ~k~~GO_LEFT~, ~k~~GO_RIGHT~~n~", string);
						else								format(string, sizeof(string), "%s~k~~VEHICLE_STEERUP~, ~k~~VEHICLE_STEERDOWN~, ~k~~VEHICLE_STEERLEFT~, ~k~~VEHICLE_STEERRIGHT~~n~", string);
						format(string, sizeof(string), "%sy ~k~~PED_SPRINT~ para mover. ", string);
						if(!IsPlayerInAnyVehicle(playerid))	format(string, sizeof(string), "%s~k~~VEHICLE_ENTER_EXIT~", string);
						else								format(string, sizeof(string), "%s~k~~VEHICLE_FIREWEAPON_ALT~", string);
						format(string, sizeof(string), "%s para terminar.~n~", string);
						
						GameTextForPlayer(playerid, string, 9999999, 3);
						SendClientMessage(playerid, MSG_COLOR, "Usa [arriba], [abajo], [izq] y [der] para actualizar. [correr] para acelerar y [entrar coche] para terminar.");
						
						TogglePlayerControllable(playerid, 0);
						pData[playerid][P_KeyEdition] = EDIT_POSITION;
						SetTimerEx("KeyEdit", 200, 0, "i", playerid);
                    }
                }
            }
            else
            {
                ShowTextDrawDialog(playerid, 5);
            }
        }
        
        case 10: // Cambiar posición a mano
        {
            if(response)
            {
                if(!IsNumeric2(inputtext)) ShowTextDrawDialog(playerid, 10, pData[playerid][P_Aux], 1);
                else
                {
                    if(pData[playerid][P_Aux] == 0) // Si editó X
                    {
                        tData[pData[playerid][P_CurrentTextdraw]][T_X] = floatstr(inputtext);
                        UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                        SaveTDData(pData[playerid][P_CurrentTextdraw], "T_X");
                        ShowTextDrawDialog(playerid, 10, 1, 0);
                    }
                    else if(pData[playerid][P_Aux] == 1) // Si editó Y
                    {
                        tData[pData[playerid][P_CurrentTextdraw]][T_Y] = floatstr(inputtext);
                        UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                        SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Y");
                        ShowTextDrawDialog(playerid, 5);
                        
						SendClientMessage(playerid, MSG_COLOR, "Textdraw exitosamente movido.");
                    }
                }
            }
            else
            {
                if(pData[playerid][P_Aux] == 1) // Si estaba editando Y, moverlo a X
                {
                    pData[playerid][P_Aux] = 0;
                    ShowTextDrawDialog(playerid, 10, 0, 0);
                }
                else // Si estaba editando X, moverlo al menu de seleccion
                {
                    ShowTextDrawDialog(playerid, 9);
                }
            }
        }
        
        case 11: // Cambiar alineacion
        {
            if(response)
            {
                tData[pData[playerid][P_CurrentTextdraw]][T_Alignment] = listitem+1;
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Alignment");
                
                new string[128];
                format(string, sizeof(string), "Alineación del Textdraw #%d cambiada a %d.", pData[playerid][P_CurrentTextdraw], listitem+1);
                SendClientMessage(playerid, MSG_COLOR, string);
                
                ShowTextDrawDialog(playerid, 5);
            }
            else
            {
                ShowTextDrawDialog(playerid, 5);
            }
        }
        
        case 12: // Cambiar proporcionalidad del textdraw
        {
            if(response)
            {
                tData[pData[playerid][P_CurrentTextdraw]][T_Proportional] = listitem;
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Proportional");

                new string[128];
                format(string, sizeof(string), "Proporcionalidad del Textdraw #%d cambiada a %d.", pData[playerid][P_CurrentTextdraw], listitem);
                SendClientMessage(playerid, MSG_COLOR, string);

                ShowTextDrawDialog(playerid, 5);
            }
            else
            {
                ShowTextDrawDialog(playerid, 5);
            }
        }
        
        case 13: // Cambiar color
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: // Escribir hex
                    {
                        ShowTextDrawDialog(playerid, 14);
                    }
                    case 1: // Combinador de colores
                    {
                        ShowTextDrawDialog(playerid, 15, 0, 0);
                    }
                    case 2: // Color prehecho
                    {
                        ShowTextDrawDialog(playerid, 16);
                    }
                }
            }
            else
            {
                if(pData[playerid][P_ColorEdition] == COLOR_TEXT)			ShowTextDrawDialog(playerid, 5);
                else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE)   ShowTextDrawDialog(playerid, 20);
                else if(pData[playerid][P_ColorEdition] == COLOR_BOX)		ShowTextDrawDialog(playerid, 24);
            }
        }
        
        case 14: // Color del textdraw: hex
        {
        	if(response)
            {
                new red[3], green[3], blue[3], alpha[3];
                
                if(inputtext[0] == '0' && inputtext[1] == 'x') // Esta usando el formato 0xFFFFFF
                {
                    if(strlen(inputtext) != 8 && strlen(inputtext) != 10) return ShowTextDrawDialog(playerid, 14, 1);
                    else
                    {
	                    format(red, sizeof(red), "%c%c", inputtext[2], inputtext[3]);
	                    format(green, sizeof(green), "%c%c", inputtext[4], inputtext[5]);
	                    format(blue, sizeof(blue), "%c%c", inputtext[6], inputtext[7]);
	                    if(inputtext[8] != '\0')
	                        format(alpha, sizeof(alpha), "%c%c", inputtext[8], inputtext[9]);
						else
						    alpha = "FF";
					}
                }
                else if(inputtext[0] == '#') // Esta usando el formato #FFFFFF
                {
                    if(strlen(inputtext) != 7 && strlen(inputtext) != 9) return ShowTextDrawDialog(playerid, 14, 1);
                    else
                    {
	                    format(red, sizeof(red), "%c%c", inputtext[1], inputtext[2]);
	                    format(green, sizeof(green), "%c%c", inputtext[3], inputtext[4]);
	                    format(blue, sizeof(blue), "%c%c", inputtext[5], inputtext[6]);
	                    if(inputtext[7] != '\0')
	                        format(alpha, sizeof(alpha), "%c%c", inputtext[7], inputtext[8]);
						else
						    alpha = "FF";
					}
                }
                else // Esta usando el formato FFFFFF
                {
                    if(strlen(inputtext) != 6 && strlen(inputtext) != 8) return ShowTextDrawDialog(playerid, 14, 1);
                    else
                    {
	                    format(red, sizeof(red), "%c%c", inputtext[0], inputtext[1]);
	                    format(green, sizeof(green), "%c%c", inputtext[2], inputtext[3]);
	                    format(blue, sizeof(blue), "%c%c", inputtext[4], inputtext[5]);
	                    if(inputtext[6] != '\0')
	                        format(alpha, sizeof(alpha), "%c%c", inputtext[6], inputtext[7]);
						else
						    alpha = "FF";
					}
                }
                // Tenemos el color
                if(pData[playerid][P_ColorEdition] == COLOR_TEXT)
                	tData[pData[playerid][P_CurrentTextdraw]][T_Color] = RGB(HexToInt(red), HexToInt(green), HexToInt(blue), HexToInt(alpha));
				else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE)
				    tData[pData[playerid][P_CurrentTextdraw]][T_BackColor] = RGB(HexToInt(red), HexToInt(green), HexToInt(blue), HexToInt(alpha));
                else if(pData[playerid][P_ColorEdition] == COLOR_BOX)
				    tData[pData[playerid][P_CurrentTextdraw]][T_BoxColor] = RGB(HexToInt(red), HexToInt(green), HexToInt(blue), HexToInt(alpha));
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Color");
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_BackColor");
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_BoxColor");
                
                new string[128];
                format(string, sizeof(string), "Color del Textdraw #%d ha sido cambiado.", pData[playerid][P_CurrentTextdraw]);
                SendClientMessage(playerid, MSG_COLOR, string);

                if(pData[playerid][P_ColorEdition] == COLOR_TEXT) 			ShowTextDrawDialog(playerid, 5);
                else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE)   ShowTextDrawDialog(playerid, 20);
                else if(pData[playerid][P_ColorEdition] == COLOR_BOX)		ShowTextDrawDialog(playerid, 24);
            }
            else
            {
                ShowTextDrawDialog(playerid, 13);
            }
		}
		
		case 15: // Color de Textdraw: Combinador de colores
        {
            if(response)
            {
                if(!IsNumeric2(inputtext)) ShowTextDrawDialog(playerid, 15, pData[playerid][P_Aux], 2);
                else if(strval(inputtext) < 0 || strval(inputtext) > 255) ShowTextDrawDialog(playerid, 15, pData[playerid][P_Aux], 1);
                else
                {
                    pData[playerid][P_Color][pData[playerid][P_Aux]] = strval(inputtext);
             	    
                    if(pData[playerid][P_Aux] == 3) // Terminó de editar alpha, por lo que ya tiene el resto
                    {
                        // Tenemos el color
                        if(pData[playerid][P_ColorEdition] == COLOR_TEXT)
		                	tData[pData[playerid][P_CurrentTextdraw]][T_Color] = RGB(pData[playerid][P_Color][0], pData[playerid][P_Color][1], \
																				 pData[playerid][P_Color][2], pData[playerid][P_Color][3] );
						else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE)
						    tData[pData[playerid][P_CurrentTextdraw]][T_BackColor] = RGB(pData[playerid][P_Color][0], pData[playerid][P_Color][1], \
																				 pData[playerid][P_Color][2], pData[playerid][P_Color][3] );
		                else if(pData[playerid][P_ColorEdition] == COLOR_BOX)
						    tData[pData[playerid][P_CurrentTextdraw]][T_BoxColor] = RGB(pData[playerid][P_Color][0], pData[playerid][P_Color][1], \
																				 pData[playerid][P_Color][2], pData[playerid][P_Color][3] );
		                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
		                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Color");
		                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_BackColor");
		                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_BoxColor");

		                new string[128];
		                format(string, sizeof(string), "Color del Textdraw #%d ha sido cambiado.", pData[playerid][P_CurrentTextdraw]);
		                SendClientMessage(playerid, MSG_COLOR, string);

		                if(pData[playerid][P_ColorEdition] == COLOR_TEXT) 			ShowTextDrawDialog(playerid, 5);
               			else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE)   ShowTextDrawDialog(playerid, 20);
               			else if(pData[playerid][P_ColorEdition] == COLOR_BOX)		ShowTextDrawDialog(playerid, 24);
                    }
                    else
                    {
                        pData[playerid][P_Aux] += 1;
	                    ShowTextDrawDialog(playerid, 15, pData[playerid][P_Aux], 0);
					}
                }
            }
            else
            {
                if(pData[playerid][P_Aux] >= 1) // Si esta editando alpha, azul, etc.
                {
                    pData[playerid][P_Aux] -= 1;
                    ShowTextDrawDialog(playerid, 15, pData[playerid][P_Aux], 0);
                }
                else // Si editaba rojo, moverlo a seleccion de color menu.
                {
                    ShowTextDrawDialog(playerid, 13);
                }
            }
        }
        
        case 16: // Color de Textdraw: colores prehechos
        {
            if(response)
            {
                new col;
                switch(listitem)
                {
                    case 0: col = 0xff0000ff;
                    case 1: col = 0x00ff00ff;
                    case 2: col = 0x0000ffff;
                    case 3: col = 0xffff00ff;
                    case 4: col = 0xff00ffff;
                    case 5: col = 0x00ffffff;
                    case 6: col = 0xffffffff;
                    case 7: col = 0x000000ff;
                }
                if(pData[playerid][P_ColorEdition] == COLOR_TEXT)
                	tData[pData[playerid][P_CurrentTextdraw]][T_Color] = col;
				else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE)
				    tData[pData[playerid][P_CurrentTextdraw]][T_BackColor] = col;
                else if(pData[playerid][P_ColorEdition] == COLOR_BOX)
				    tData[pData[playerid][P_CurrentTextdraw]][T_BoxColor] = col;
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Color");
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_BackColor");
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_BoxColor");

                new string[128];
                format(string, sizeof(string), "Color del Textdraw #%d ha sido cambiado.", pData[playerid][P_CurrentTextdraw]);
                SendClientMessage(playerid, MSG_COLOR, string);
                
                if(pData[playerid][P_ColorEdition] == COLOR_TEXT) 			ShowTextDrawDialog(playerid, 5);
                else if(pData[playerid][P_ColorEdition] == COLOR_OUTLINE)   ShowTextDrawDialog(playerid, 20);
                else if(pData[playerid][P_ColorEdition] == COLOR_BOX)		ShowTextDrawDialog(playerid, 24);
            }
            else
            {
                ShowTextDrawDialog(playerid, 13);
            }
        }
        
        case 17: // Cambiar fuente
        {
            if(response)
            {
                tData[pData[playerid][P_CurrentTextdraw]][T_Font] = listitem;
                UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Font");

                new string[128];
                format(string, sizeof(string), "Fuente del Textdraw #%d cambiada a %d.", pData[playerid][P_CurrentTextdraw], listitem);
                SendClientMessage(playerid, MSG_COLOR, string);

                ShowTextDrawDialog(playerid, 5);
            }
            else
            {
                ShowTextDrawDialog(playerid, 5);
            }
        }
        
        case 18: // Cambiar tamaño de letra del textdraw: exacto o mover
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: // Tamaño exacto
                    {
                        pData[playerid][P_Aux] = 0;
                        ShowTextDrawDialog(playerid, 19, 0, 0);
                    }
                    case 1: // Cambiar tamaño
                    {
                        new string[512];
                        string = "~n~~n~~n~~n~~n~~n~~n~~n~~w~";
                        if(!IsPlayerInAnyVehicle(playerid))	format(string, sizeof(string), "%s~k~~GO_FORWARD~, ~k~~GO_BACK~, ~k~~GO_LEFT~, ~k~~GO_RIGHT~~n~", string);
						else								format(string, sizeof(string), "%s~k~~VEHICLE_STEERUP~, ~k~~VEHICLE_STEERDOWN~, ~k~~VEHICLE_STEERLEFT~, ~k~~VEHICLE_STEERRIGHT~~n~", string);
						format(string, sizeof(string), "%sy ~k~~PED_SPRINT~ para actualizar. ", string);
						if(!IsPlayerInAnyVehicle(playerid))	format(string, sizeof(string), "%s~k~~VEHICLE_ENTER_EXIT~", string);
						else								format(string, sizeof(string), "%s~k~~VEHICLE_FIREWEAPON_ALT~", string);
						format(string, sizeof(string), "%s para terminar.~n~", string);

						GameTextForPlayer(playerid, string, 9999999, 3);
						SendClientMessage(playerid, MSG_COLOR, "Usa [arriba], [abajo], [izq] y [der] para actualizar. [correr] para acelerar y [entrar coche] para terminar.");

						TogglePlayerControllable(playerid, 0);
						pData[playerid][P_KeyEdition] = EDIT_SIZE;
						SetTimerEx("KeyEdit", 200, 0, "i", playerid);
                    }
                }
            }
            else
            {
                ShowTextDrawDialog(playerid, 5);
            }
        }
        
        case 19: // Cambiar manualmente tamaño de letra
        {
            if(response)
            {
                if(!IsNumeric2(inputtext)) ShowTextDrawDialog(playerid, 19, pData[playerid][P_Aux], 1);
                else
                {
                    if(pData[playerid][P_Aux] == 0) // Si editó X
                    {
                        tData[pData[playerid][P_CurrentTextdraw]][T_XSize] = floatstr(inputtext);
                        UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                        SaveTDData(pData[playerid][P_CurrentTextdraw], "T_XSize");
                        ShowTextDrawDialog(playerid, 19, 1, 0);
                    }
                    else if(pData[playerid][P_Aux] == 1) // Si editó Y
                    {
                        tData[pData[playerid][P_CurrentTextdraw]][T_YSize] = floatstr(inputtext);
                        UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                        SaveTDData(pData[playerid][P_CurrentTextdraw], "T_YSize");
                        ShowTextDrawDialog(playerid, 5);

						SendClientMessage(playerid, MSG_COLOR, "Tamaño exitosamente cambiado.");
                    }
                }
            }
            else
            {
                if(pData[playerid][P_Aux] == 1) // Si esta editando Y, moverlo a X
                {
                    pData[playerid][P_Aux] = 0;
                    ShowTextDrawDialog(playerid, 19, 0, 0);
                }
                else // Si estaba editando X, volver al menu de seleccion
                {
                    ShowTextDrawDialog(playerid, 18);
                }
            }
        }
        
        case 20: // menu principal contorno
        {
            if(response)
            {
				switch(listitem)
				{
				    case 0: // Togglear contorno
				    {
				        if(tData[pData[playerid][P_CurrentTextdraw]][T_Outline])	tData[pData[playerid][P_CurrentTextdraw]][T_Outline] = 0;
				        else                                                        tData[pData[playerid][P_CurrentTextdraw]][T_Outline] = 1;
				        UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
				        SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Outline");
				        ShowTextDrawDialog(playerid, 20);
				        
				        SendClientMessage(playerid, MSG_COLOR, "Contorno del textdraw cambiado.");
				    }
					case 1: // Cambiar sombra
					{
                        ShowTextDrawDialog(playerid, 21);
					}
					case 2: // Cambiar color
					{
		                pData[playerid][P_ColorEdition] = COLOR_OUTLINE;
                        ShowTextDrawDialog(playerid, 13);
					}
					case 3: // Terminar
	                {
	                    SendClientMessage(playerid, MSG_COLOR, "Terminada edición del contorno.");
	                    ShowTextDrawDialog(playerid, 5);
	                }
				}
            }
            else
            {
                ShowTextDrawDialog(playerid, 5);
            }
        }
        
        case 21: // Sombra de contorno
        {
            if(response)
            {
                if(listitem == 6) // Personalizado ha sido elegido
                {
                    ShowTextDrawDialog(playerid, 22);
                }
                else
                {
                    tData[pData[playerid][P_CurrentTextdraw]][T_Shadow] = listitem;
                    UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                    SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Shadow");
                    ShowTextDrawDialog(playerid, 20);

					new string[128];
	                format(string, sizeof(string), "Sombra de contorno del Textdraw #%d's cambiada a %d.", pData[playerid][P_CurrentTextdraw], listitem);
	                SendClientMessage(playerid, MSG_COLOR, string);
                }
            }
            else
            {
                ShowTextDrawDialog(playerid, 20);
            }
        }
        
        case 22: // sombra de contorno personalizada
        {
            if(response)
            {
                if(!IsNumeric2(inputtext)) ShowTextDrawDialog(playerid, 22, 1);
                else
                {
                    tData[pData[playerid][P_CurrentTextdraw]][T_Shadow] = strval(inputtext);
                    UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
                    SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Shadow");
                    ShowTextDrawDialog(playerid, 20);

					new string[128];
	                format(string, sizeof(string), "Sombre del contorno del Textdraw #%d's cambiada a %d.", pData[playerid][P_CurrentTextdraw], strval(inputtext));
	                SendClientMessage(playerid, MSG_COLOR, string);
                }
            }
            else
            {
                ShowTextDrawDialog(playerid, 21);
            }
        }
        
        case 23: // Box on - off
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: // Box encendida
                    {
                        tData[pData[playerid][P_CurrentTextdraw]][T_UseBox] = 1;
						UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
						SaveTDData(pData[playerid][P_CurrentTextdraw], "T_UseBox");

						SendClientMessage(playerid, MSG_COLOR, "Box del Textdraw activada. Procediendo a la edición...");

						ShowTextDrawDialog(playerid, 24);
                    }
                    case 1: // La desactivo, nada mas que editar.
                    {
						tData[pData[playerid][P_CurrentTextdraw]][T_UseBox] = 0;
						UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
						SaveTDData(pData[playerid][P_CurrentTextdraw], "T_UseBox");
						
						SendClientMessage(playerid, MSG_COLOR, "Box del Textdraw desactivada.");
						
						ShowTextDrawDialog(playerid, 5);
                    }
                }
            }
            else
            {
                ShowTextDrawDialog(playerid, 5);
            }
        }
        
        case 24: // menu principal de box
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: // box apagada
                    {
                        tData[pData[playerid][P_CurrentTextdraw]][T_UseBox] = 0;
						UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
						SaveTDData(pData[playerid][P_CurrentTextdraw], "T_UseBox");

						SendClientMessage(playerid, MSG_COLOR, "Box del Textdraw desactivada.");

						ShowTextDrawDialog(playerid, 23);
                    }
                    case 1: // tamaño de box
                    {
						new string[512];
                        string = "~n~~n~~n~~n~~n~~n~~n~~n~~w~";
                        if(!IsPlayerInAnyVehicle(playerid))	format(string, sizeof(string), "%s~k~~GO_FORWARD~, ~k~~GO_BACK~, ~k~~GO_LEFT~, ~k~~GO_RIGHT~~n~", string);
						else								format(string, sizeof(string), "%s~k~~VEHICLE_STEERUP~, ~k~~VEHICLE_STEERDOWN~, ~k~~VEHICLE_STEERLEFT~, ~k~~VEHICLE_STEERRIGHT~~n~", string);
						format(string, sizeof(string), "%sy ~k~~PED_SPRINT~ para actualizar. ", string);
						if(!IsPlayerInAnyVehicle(playerid))	format(string, sizeof(string), "%s~k~~VEHICLE_ENTER_EXIT~", string);
						else								format(string, sizeof(string), "%s~k~~VEHICLE_FIREWEAPON_ALT~", string);
						format(string, sizeof(string), "%s para terminar.~n~", string);

						GameTextForPlayer(playerid, string, 9999999, 3);
						SendClientMessage(playerid, MSG_COLOR, "Usa [arriba], [abajo], [izq] y [der] para cambiar tamaño de box. [correr] para acelerar y [entrar coche] para terminar.");

						TogglePlayerControllable(playerid, 0);
						pData[playerid][P_KeyEdition] = EDIT_BOX;
						SetTimerEx("KeyEdit", 200, 0, "i", playerid);
                    }
                    case 2: // color de box
                    {
                        pData[playerid][P_ColorEdition] = COLOR_BOX;
                        ShowTextDrawDialog(playerid, 13);
                    }
                }
            }
            else
            {
                ShowTextDrawDialog(playerid, 5);
            }
        }
        
        case 25: // menu de export
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: // modo clasico
                    {
                        ExportProject(playerid, 0);
                    }
                    case 1: // filterscript autogenerado
                    {
						ShowTextDrawDialog(playerid, 26);
                    }
                }
            }
            else
            {
                ShowTextDrawDialog(playerid, 4);
            }
        }
        
        case 26: // Exportar a un filterscript autogenerado
        {
            if(response)
            {
                switch(listitem)
                {
                    case 0: // Mostrar todo el tiempo
                    {
                        ExportProject(playerid, 1);
                    }
                    case 1: // Mostrar en class selection
                    {
                        ExportProject(playerid, 2);
                    }
                    case 2: // Mostrar en vehiculo
                    {
                        ExportProject(playerid, 3);
                    }
                    case 3: // Mostrar con comando
                    {
                        ShowTextDrawDialog(playerid, 27);
                    }
                    case 4: // Mostrar automaticamente cada X tiempo
                    {
                        ShowTextDrawDialog(playerid, 29);
                    }
                    case 5: // Mostrar despues que el jugador mato a alguien
                    {
                        ShowTextDrawDialog(playerid, 31);
                    }
                }
            }
            else
            {
                ShowTextDrawDialog(playerid, 25);
            }
        }

		case 27: // Escribir comando para export
		{
		    if(response)
		    {
		        if(!strlen(inputtext)) ShowTextDrawDialog(playerid, 27);
		        else
		        {
		            if(inputtext[0] != '/')
		                format(pData[playerid][P_ExpCommand], 128, "/%s", inputtext);
		            else
		                format(pData[playerid][P_ExpCommand], 128, "%s", inputtext);
		                
					ShowTextDrawDialog(playerid, 28);
		        }
		    }
		    else
		    {
		        ShowTextDrawDialog(playerid, 26);
		    }
		}
		
		case 28: // Tiempo despues de comando para export
		{
		    if(response)
		    {
				if(!IsNumeric2(inputtext)) ShowTextDrawDialog(playerid, 28);
				else if(strval(inputtext) < 0) ShowTextDrawDialog(playerid, 28);
				else
				{
				    pData[playerid][P_Aux] = strval(inputtext);
				    ExportProject(playerid, 4);
				}
		    }
		    else
		    {
		        ShowTextDrawDialog(playerid, 27);
		    }
		}
		
		case 29: // Tiempo en segundos a aparecer para export
		{
		    if(response)
		    {
		        if(!IsNumeric2(inputtext)) ShowTextDrawDialog(playerid, 29);
				else if(strval(inputtext) < 0) ShowTextDrawDialog(playerid, 29);
				else
				{
				    pData[playerid][P_Aux] = strval(inputtext);
				    ShowTextDrawDialog(playerid, 30);
				}
		    }
		    else
		    {
		        ShowTextDrawDialog(playerid, 26);
		    }
		}

		case 30: // Tiempo a desaparecer despues de aparecido para export
		{
		    if(response)
		    {
				if(!IsNumeric2(inputtext)) ShowTextDrawDialog(playerid, 30);
				else if(strval(inputtext) < 0) ShowTextDrawDialog(playerid, 30);
				else
				{
				    pData[playerid][P_Aux2] = strval(inputtext);
				    ExportProject(playerid, 5);
				}
		    }
		    else
		    {
		        ShowTextDrawDialog(playerid, 29);
		    }
		}
		
		case 31: // Desaparecer despues de X despues de aparecer, en export modo kill
		{
		    if(response)
		    {
				if(!IsNumeric2(inputtext)) ShowTextDrawDialog(playerid, 31);
				else if(strval(inputtext) < 0) ShowTextDrawDialog(playerid, 31);
				else
				{
				    pData[playerid][P_Aux] = strval(inputtext);
				    ExportProject(playerid, 6);
				}
		    }
		    else
		    {
		        ShowTextDrawDialog(playerid, 26);
		    }
		}
    }
    
	return 1;
}

// =============================================================================
// Funciones.
// =============================================================================

forward ShowTextDrawDialogEx( playerid, dialogid );
public ShowTextDrawDialogEx( playerid, dialogid ) ShowTextDrawDialog( playerid, dialogid );

stock ShowTextDrawDialog( playerid, dialogid, aux=0, aux2=0 )
{
    /*	Muestra un diálogo específico a un jugador específico
	    @playerid:      ID del jugador al cual mostrar el diálogo.
	    @dialogid:      ID del diálogo a mostrar.
	    @aux:           Variable auxiliar. Sirve para hacer variaciones en ciertos diálogos.
	    @aux2:          Variable auxiliar. Sirve para hacer variaciones en ciertos diálogos.

	    -Returns:
	    true si la operación es exitosa, false si no.
	*/

	switch(dialogid)
	{
	    case 0: // Seleccionar proyecto.
	    {
            new info[256];
		    format(info, sizeof(info), "%sNuevo Proyecto\n", info);
		    format(info, sizeof(info), "%sCargar Proyecto\n", info);
		    format(info, sizeof(info), "%sEliminar Proyecto", info);
		    ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Inicio"), info, "Aceptar", "Cancelar");
		    return true;
	    }
	    
	    case 1:
	    {
	        new info[256];
	        if(!aux) 			info = "Escribe el nombre del nuevo archivo de proyecto.\n";
	        else if(aux == 1)   info = "ERROR: El nombre es muy largo, intenta nuevamente.\n";
	        else if(aux == 2)   info = "ERROR: Ese nombre de archivo ya existe, intenta nuevamente.\n";
	        else if(aux == 3)   info = "ERROR: Ese nombre de archivo contiene carácteres inválidos. No se te permite\ncrear subdirectorios. Intenta nuevamente.";
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Nuevo proyecto"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 2:
	    {
	        // Guardar en una variable si está eliminando o cargando.
	        if(aux == 2) 	pData[playerid][P_CurrentMenu] = DELETING;
	        else            pData[playerid][P_CurrentMenu] = LOADING;
	        
			new info[1024];
			if(fexist("tdlist.lst"))
	        {
				if(aux != 2)	info = "Archivo específico...";
				else    		info = "<< Volver";
		        new File:tdlist = fopen("tdlist.lst", io_read),
					line[128];
                while(fread(tdlist, line))
                {
		            format(info, sizeof(info), "%s\n%s", info, line);
		        }
		        
		        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Cargar proyecto"), info, "Aceptar", "Volver");
		        fclose(tdlist);
	        }
	        else
	        {
	            if(aux) format(info, sizeof(info), "%sNo se puede encontrar tdlist.lst.\n", info);
			    format(info, sizeof(info), "%sEscribe manualmente el nombre del archivo que quieres\n", info);
			    if(aux != 2) 	format(info, sizeof(info), "%sabrir:\n", info);
			    else            format(info, sizeof(info), "%seliminar:\n", info);
			    
			    if(aux != 2)	ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Cargar proyecto"), info, "Aceptar", "Volver");
			    else            ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Eliminar proyecto"), info, "Aceptar", "Volver");
		    }
	        return true;
	    }
	    
	    case 3:
	    {
			ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Cargar proyecto"), \
		 		"Escribe manualmente el nombre del archivo de\nproyecto que quieres cargar:\n", "Aceptar", "Volver");
			return true;
	    }
	    
	    case 4: // Main edition menu (shows all the textdraws and lets you create a new one).
	    {
	        new info[1024],
				shown;
	        format(info, sizeof(info), "%sCrear nuevo Textdraw...", info);
	        shown ++;
	        format(info, sizeof(info), "%s\nExportar proyecto...", info);
	        shown ++;
	        format(info, sizeof(info), "%s\nCerrar proyecto...", info);
	        shown ++;
	        // Aux here is used to indicate from which TD show the list from.
	        pData[playerid][P_DialogPage] = aux;
	        for(new i=aux; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
	            {
	                shown ++;
					if(shown == 12)
					{
						format(info, sizeof(info), "%s\nMás >>", info);
						break;
					}
					
	                new PieceOfText[PREVIEW_CHARS];
	                if(strlen(tData[i][T_Text]) > sizeof(PieceOfText))
	                {
	                    strmid(PieceOfText, tData[i][T_Text], 0, PREVIEW_CHARS, PREVIEW_CHARS);
	                    format(info, sizeof(info), "%s\nTDraw %d: '%s [...]'", info, i, PieceOfText);
	                }
					else
					{
					    format(info, sizeof(info), "%s\nTDraw %d: '%s'", info, i, tData[i][T_Text]);
					}
	            }
	        }
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Selección de Textdraw"), info, "Aceptar", "Cancelar");
	        return true;
	    }
	    
	    case 5:
	    {
	        new info[1024];
	        format(info, sizeof(info), "%sCambiar texto\n", info);
	        format(info, sizeof(info), "%sCambiar posición\n", info);
	        format(info, sizeof(info), "%sCambiar alineación\n", info);
	        format(info, sizeof(info), "%sCambiar color de texto\n", info);
	        format(info, sizeof(info), "%sCambiar fuente\n", info);
	        format(info, sizeof(info), "%sCambiar proporcionalidad\n", info);
	        format(info, sizeof(info), "%sCambiar tamaño de fuente\n", info);
	        format(info, sizeof(info), "%sEditar contorno\n", info);
	        format(info, sizeof(info), "%sEditar box\n", info);
	        format(info, sizeof(info), "%sDuplicar Textdraw...\n", info);
	        format(info, sizeof(info), "%sEliminar Textdraw...", info);
	        
	        new title[40];
	        format(title, sizeof(title), "Textdraw %d", pData[playerid][P_CurrentTextdraw]);
	        
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, title), info, "Aceptar", "Cancelar");
	        return true;
	    }
	    
	    case 6:
	    {
	        new info[256];
	        format(info, sizeof(info), "%sEstás seguro de querer borrar el\n", info);
	        format(info, sizeof(info), "%sproyecto %s?\n\n", info, GetFileNameFromLst("tdlist.lst", pData[playerid][P_Aux]));
	        format(info, sizeof(info), "%sADVERTENCIA: No hay forma de deshacer esta operación.", info);
	        
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, CreateDialogTitle(playerid, "Confirmar eliminación"), info, "Si", "No");
	        return true;
	    }
	    
	    case 7:
	    {
	        new info[256];
	        format(info, sizeof(info), "%sEstás seguro que quieres eliminar el\n", info);
	        format(info, sizeof(info), "%sTextdraw número %d?\n\n", info, pData[playerid][P_CurrentTextdraw]);
	        format(info, sizeof(info), "%sADVERTENCIA: No hay forma de deshacer esta operación.", info);
	        
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_MSGBOX, CreateDialogTitle(playerid, "Confirmar eliminación"), info, "Si", "No");
	        return true;
	    }
	    
	    case 8:
	    {
	        new info[1024];
	        info = "Escribe el nuevo texto del textdraw. El texto actual es:\n\n";
	        format(info, sizeof(info), "%s%s\n\n", info, tData[pData[playerid][P_CurrentTextdraw]][T_Text]);
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Texto del Textdraw"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 9:
	    {
	        new info[256];
	        info = "Escribir posición exacta\n";
	        format(info, sizeof(info), "%sMover el Textdraw", info);
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Posición del Textdraw"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 10:
	    {
	        // aux es 0 para X, 1 para Y.
	        // aux2 es el tipo de mensaje de error, 0 para sin error.
	        new info[256];
	        if(aux2 == 1) info = "ERROR: Tienes que escribir un número.\n\n";
	        
	        format(info, sizeof(info), "%sEscribe en números la nueva coordenada ", info);
	        if(aux == 0) 		format(info, sizeof(info), "%sX", info);
	        else if(aux == 1)   format(info, sizeof(info), "%sY", info);
         	format(info, sizeof(info), "%s del Textdraw\n", info);
         	
        	pData[playerid][P_Aux] = aux; // Para saber si está editando X o Y.
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Posición del Textdraw"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 11:
	    {
	        new info[256];
	        info = "Izquierda (tipo 1)\nCentrado (tipo 2)\nDerecha (tipo 3)";
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Alineación del Textdraw"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 12:
	    {
	        new info[256];
	        info = "Proporcionalidad Activada\nProporcionalidad Desactivada";
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Proporcionalidad del Textdraw"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 13:
	    {
	        new info[256];
	        info = "Escribir número hexadecimal\nUsar combinador de colores\nElegir un color prehecho";
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Color del Textdraw"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 14:
	    {
	        new info[256];
	        if(aux) info = "ERROR: Escribiste un número hexadecimal inválido.\n\n";
	        format(info, sizeof(info), "%sEscribe el número hexadecimal que quieres:\n", info);
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Color del Textdraw"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 15:
	    {
	        // aux es 0 para rojo, 1 para verde, 2 para azul y 3 para alpha.
	        // aux2 es el tipo de mensaje de error, 0 para sin error.
	        new info[256];
	        if(aux2 == 1) 		info = "ERROR: El número tiene que estar entre 0 y 255.\n\n";
	        else if(aux2 == 2) 	info = "ERROR: Tienes que escribir un número.\n\n";

	        format(info, sizeof(info), "%sEscribe la cantidad de ", info);
	        if(aux == 0) 		format(info, sizeof(info), "%sROJO", info);
	        else if(aux == 1)   format(info, sizeof(info), "%sVERDE", info);
	        else if(aux == 2)   format(info, sizeof(info), "%sAZUL", info);
	        else if(aux == 3)   format(info, sizeof(info), "%sOPACIDAD", info);
         	format(info, sizeof(info), "%s que quieres.\n", info);
         	format(info, sizeof(info), "%sEl número debe estar en un rango entre 0 y 255.", info);

        	pData[playerid][P_Aux] = aux; // Para saber que color está editando.
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Color del Textdraw"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 16:
	    {
	        new info[256];
	        info = "Rojo\nVerde\nAzul\nAmarillo\nRosa\nCeleste\nBlanco\nNegro";
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Color del Textdraw"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 17:
	    {
	        new info[256];
	        info = "Fuente tipo 0\nFuente tipo 1\nFuente tipo 2\nFuente tipo 3";
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Fuente del Textdraw"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 18:
	    {
	        new info[256];
	        info = "Escribir el tamaño exacto\n";
	        format(info, sizeof(info), "%sReajustar el Textdraw", info);
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Tamaño de fuente del Textdraw"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 19:
	    {
	        // aux es 0 para X, 1 para Y.
	        // aux2 es el tipo de mensaje de error, 0 para no error.
	        new info[256];
	        if(aux2 == 1) info = "ERROR: Tienes que escribir un número.\n\n";

	        format(info, sizeof(info), "%sEscribe en números la nueva coordenada ", info);
	        if(aux == 0) 		format(info, sizeof(info), "%sX", info);
	        else if(aux == 1)   format(info, sizeof(info), "%sY", info);
         	format(info, sizeof(info), "%s para el tamaño de la fuente.\n", info);

        	pData[playerid][P_Aux] = aux; // Para saber si está editando X o Y.
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Tamaño del Textdraw"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 20:
	    {
	        new info[256];
	        if(tData[pData[playerid][P_CurrentTextdraw]][T_Outline] == 1)	info = "Outline Off";
	        else                                                            info = "Outline On";
	        format(info, sizeof(info), "%s\nTamaño de sombra\nColor de la sombra/contorno\nTerminar edición de contorno...", info);
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Contorno del Textdraw"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 21:
	    {
	        new info[256];
	        info = "Sombra de contorno 0\nSombra de contorno 1\nSombra de contorno 2\nSombra de contorno 3\nSombra de contorno 4\nSombra de contorno 5\nPersonalizar...";
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Sombra del Textdraw"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 22:
	    {
	        new info[256];
	        if(aux) info = "ERROR: Escribiste un número inválido.\n\n";
	        format(info, sizeof(info), "%sEscribe el número indicanto el tamaño de la sombra:\n", info);
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Sombra del Textdraw"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 23:
	    {
	        new info[256];
	        info = "Usar box\nNo usar box";
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Box del Textdraw"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 24:
	    {
	        new info[256];
	        info = "No usar box\nTamaño del box\nColor del box";
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Box del Textdraw"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 25:
	    {
	        new info[256];
	        info = "Modo de exportación clásico\nFilterscript autogenerado";
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Exportar proyecto"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 26:
	    {
	        new info[512];
	        info = "FScript: Mostrar textdraw todo el tiempo\nFScript: Mostrar textdraw durante la selección del clase\nFScript: Mostrar textdraw mientras en vehículo\n\
					FScript: Mostrar textdraw con comando\nFScript: Mostrar cada X cantidad de tiempo\nFScript: Mostrar después de matar a alguien";
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_LIST, CreateDialogTitle(playerid, "Exportar proyecto"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 27:
	    {
	        new info[128];
	        info = "Escribe el comando que quieres que muestre el textdraw.\n";
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Exportar proyecto"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 28:
	    {
	        new info[128];
	        info = "Cuanto permanecerá en la pantalla? (EN SEGUNDOS)\n";
	        format(info, sizeof(info), "%sEscribe 0 si quieres ocultarlo tipeando otra vez el comando.\n", info);
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Exportar proyecto"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 29:
	    {
	        new info[128];
	        info = "Cada cuanto quieres que aparezcan los textdraws?\nEscribe la cantidad de tiempo en SEGUNDOS:\n";
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Exportar proyecto"), info, "Aceptar", "Volver");
	        return true;
	    }

	    case 30:
	    {
	        new info[128];
	        info = "Una vez que apareció, cuanto permanecerá en la pantalla?\nEscribe la cantidad de tiempo en SEGUNDOS:\n";
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Exportar proyecto"), info, "Aceptar", "Volver");
	        return true;
	    }
	    
	    case 31:
	    {
	        new info[128];
	        info = "Una vez que apareció, cuanto permanecerá en la pantalla?\nEscribe la cantidad de tiempo en SEGUNDOS:\n";
	        ShowPlayerDialog(playerid, dialogid, DIALOG_STYLE_INPUT, CreateDialogTitle(playerid, "Exportar proyecto"), info, "Aceptar", "Volver");
	        return true;
	    }
	}
	return false;
}

stock CreateDialogTitle( playerid, text[] )
{
    /*	Crea un título por defecto para los diálogos.
        @playerid:      ID del jugador al cual se le está generando el título.
	    @text[]:	    Texto a ser añadido al título.
	*/
	#pragma unused playerid
	
	new string[128];
	if(!strlen(CurrentProject) || !strcmp(CurrentProject, " "))
		format(string, sizeof(string), "Zamaroht's Textdraw Editor: %s", text);
	else
	    format(string, sizeof(string), "%s - Zamaroht's Textdraw Editor: %s", CurrentProject, text);
	return string;
}

stock ResetPlayerVars( playerid )
{
	/*	Resetea los datos en pData de un jugador específico.
	    @playerid:      ID del jugador del cual resetear datos.
	*/
	
	pData[playerid][P_Editing] = false;
	strmid(CurrentProject, "", 0, 1, 128);
}

forward KeyEdit( playerid );
public KeyEdit( playerid )
{
	/*  Se encarga de la edición por teclado.
		@playerid:          	El jugador que está editando.
	*/
	if(pData[playerid][P_KeyEdition] == EDIT_NONE) return 0;
	
	new string[256]; // Buffer para todos los GameTexts y otros mensajes.
	new keys, updown, leftright;
	GetPlayerKeys(playerid, keys, updown, leftright);

	if(updown < 0) // Está apretando arriba
	{
	    switch(pData[playerid][P_KeyEdition])
	    {
	        case EDIT_POSITION:
	        {
				if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_Y] -= 10.0;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_Y] -= 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Posicion: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_X], tData[pData[playerid][P_CurrentTextdraw]][T_Y]);
	        }
	        
	        case EDIT_SIZE:
	        {
	            if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_YSize] -= 1.0;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_YSize] -= 0.1;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Tamano: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_XSize], tData[pData[playerid][P_CurrentTextdraw]][T_YSize]);
	        }
	        
	        case EDIT_BOX:
	        {
	            if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeY] -= 10.0;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeY] -= 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Tamano: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeX], tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeY]);
	        }
	    }
	}
	else if(updown > 0) // Está apretando abajo
	{
	    switch(pData[playerid][P_KeyEdition])
	    {
	        case EDIT_POSITION:
	        {
                if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_Y] += 10.0;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_Y] += 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Posicion: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_X], tData[pData[playerid][P_CurrentTextdraw]][T_Y]);
	        }
	        
	        case EDIT_SIZE:
	        {
	            if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_YSize] += 1.0;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_YSize] += 0.1;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Tamano: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_XSize], tData[pData[playerid][P_CurrentTextdraw]][T_YSize]);
	        }
	        
	        case EDIT_BOX:
	        {
	            if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeY] += 10.0;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeY] += 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Tamano: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeX], tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeY]);
	        }
	    }
	}

	if(leftright < 0) // Está apretando izquierda
	{
        switch(pData[playerid][P_KeyEdition])
	    {
	        case EDIT_POSITION:
	        {
                if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_X] -= 10.0;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_X] -= 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Posicion: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_X], tData[pData[playerid][P_CurrentTextdraw]][T_Y]);
	        }
	        
	        case EDIT_SIZE:
	        {
	            if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_XSize] -= 0.1;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_XSize] -= 0.01;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Tamano: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_XSize], tData[pData[playerid][P_CurrentTextdraw]][T_YSize]);
	        }
	        
	        case EDIT_BOX:
	        {
	            if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeX] -= 10.0;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeX] -= 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Tamano: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeX], tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeY]);
	        }
	    }
	}
	else if(leftright > 0) // Está apretando derecha
	{
        switch(pData[playerid][P_KeyEdition])
	    {
	        case EDIT_POSITION:
	        {
                if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_X] += 10.0;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_X] += 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Posicion: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_X], tData[pData[playerid][P_CurrentTextdraw]][T_Y]);
	        }
	        
	        case EDIT_SIZE:
	        {
	            if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_XSize] += 0.1;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_XSize] += 0.01;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Tamano: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_XSize], tData[pData[playerid][P_CurrentTextdraw]][T_YSize]);
	        }
	        
	        case EDIT_BOX:
	        {
	            if(keys == KEY_SPRINT)	tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeX] += 10.0;
				else                    tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeX] += 1.0;

				format(string, sizeof(string), "~n~~n~~n~~n~~n~~n~~n~~n~~n~~n~~y~~h~Tamano: ~b~X: ~w~%.4f ~r~- ~b~Y: ~w~%.4f", \
			        tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeX], tData[pData[playerid][P_CurrentTextdraw]][T_TextSizeY]);
	        }
	    }
	}

	GameTextForPlayer(playerid, string, 999999999, 3);
	UpdateTextdraw(pData[playerid][P_CurrentTextdraw]);
	if(pData[playerid][P_KeyEdition] == EDIT_POSITION)
	{
		SaveTDData(pData[playerid][P_CurrentTextdraw], "T_X");
		SaveTDData(pData[playerid][P_CurrentTextdraw], "T_Y");
	}
	else if(pData[playerid][P_KeyEdition] == EDIT_SIZE)
	{
		SaveTDData(pData[playerid][P_CurrentTextdraw], "T_XSize");
		SaveTDData(pData[playerid][P_CurrentTextdraw], "T_YSize");
	}
	else if(pData[playerid][P_KeyEdition] == EDIT_BOX)
	{
		SaveTDData(pData[playerid][P_CurrentTextdraw], "T_TextSizeX");
		SaveTDData(pData[playerid][P_CurrentTextdraw], "T_TextSizeY");
	}
    SetTimerEx("KeyEdit", 200, 0, "i", playerid);
    return 1;
}

public OnPlayerKeyStateChange( playerid, newkeys, oldkeys )
{
    if(pData[playerid][P_KeyEdition] != EDIT_NONE && newkeys == KEY_SECONDARY_ATTACK)
	{
	    GameTextForPlayer(playerid, " ", 100, 3);
	    TogglePlayerControllable(playerid, 1);

        new string[128];
	    switch(pData[playerid][P_KeyEdition])
	    {
	        case EDIT_POSITION:
	        {
				format(string, sizeof(string), "Textdraw #%d correctamente movido.", pData[playerid][P_CurrentTextdraw]);
	        }
	        case EDIT_SIZE:
	        {
				format(string, sizeof(string), "Textdraw #%d correctamente actualizado.", pData[playerid][P_CurrentTextdraw]);
	        }
	        case EDIT_BOX:
	        {
				format(string, sizeof(string), "La box del Textdraw #%d's box ha sido correctamente actualizada.", pData[playerid][P_CurrentTextdraw]);
	        }
	    }

        if(pData[playerid][P_KeyEdition] == EDIT_BOX)   SetTimerEx("ShowTextDrawDialogEx", 500, 0, "ii", playerid, 24);
		else 											SetTimerEx("ShowTextDrawDialogEx", 500, 0, "ii", playerid, 5);
	    SendClientMessage(playerid, MSG_COLOR, string);
	    pData[playerid][P_KeyEdition] = EDIT_NONE;
	}
	return 1;
}

stock CreateNewProject( name[] )
{
    /*	Crea un nuevo proyecto .tde.
	    @name[]:		Nombre a ser usado en el archivo.
	*/

	new string[128], File:File;

	// Agregarlo a la lista.
	format(string, sizeof(string), "%s\r\n", name);
	File = fopen("tdlist.lst", io_append);
	fwrite(File, string);
	fclose(File);

	// Crear el archivo en blanco.
	File = fopen(name, io_write);
	fwrite(File, "TDFile=yes");
	fclose(File);
}

stock ClearTextdraw( tdid )
{
	/*	Resetea las variables de un textdraw y lo destruye.
	    @tdid:          Textdraw ID
	*/
	TextDrawHideForAll(tData[tdid][T_Handler]);
	tData[tdid][T_Created] = false;
	strmid(tData[tdid][T_Text], "", 0, 1, 2);
    tData[tdid][T_X] = 0.0;
    tData[tdid][T_Y] = 0.0;
    tData[tdid][T_Alignment] = 0;
    tData[tdid][T_BackColor] = 0;
    tData[tdid][T_UseBox] = 0;
    tData[tdid][T_BoxColor] = 0;
    tData[tdid][T_TextSizeX] = 0.0;
    tData[tdid][T_TextSizeY] = 0.0;
    tData[tdid][T_Color] = 0;
    tData[tdid][T_Font] = 0;
    tData[tdid][T_XSize] = 0.0;
    tData[tdid][T_YSize] = 0.0;
    tData[tdid][T_Outline] = 0;
    tData[tdid][T_Proportional] = 0;
    tData[tdid][T_Shadow] = 0;
}

stock CreateDefaultTextdraw( tdid, save = 1 )
{
	/*  Crea un nuevo textdraw con su configuración por defecto.
		@tdid:          Textdraw ID
	*/
	tData[tdid][T_Created] = true;
	format(tData[tdid][T_Text], 1024, "Nuevo Textdraw", 1);
    tData[tdid][T_X] = 250.0;
    tData[tdid][T_Y] = 10.0;
    tData[tdid][T_Alignment] = 0;
    tData[tdid][T_BackColor] = RGB(0, 0, 0, 255);
    tData[tdid][T_UseBox] = 0;
    tData[tdid][T_BoxColor] = RGB(0, 0, 0, 255);
    tData[tdid][T_TextSizeX] = 0.0;
    tData[tdid][T_TextSizeY] = 0.0;
    tData[tdid][T_Color] = RGB(255, 255, 255, 255);
    tData[tdid][T_Font] = 1;
    tData[tdid][T_XSize] = 0.5;
    tData[tdid][T_YSize] = 1.0;
    tData[tdid][T_Outline] = 0;
    tData[tdid][T_Proportional] = 1;
    tData[tdid][T_Shadow] = 1;

    UpdateTextdraw(tdid);
    if(save) SaveTDData(tdid, "T_Created");
}

stock DuplicateTextdraw( source, to )
{
	/*  Duplica un textdraw a partir de otro. Actualiza al nuevo.
	    @source:            De donde copiar el textdraw.
	    @to:                A donde copiar el textdraw.
	*/
	tData[to][T_Created] = tData[source][T_Created];
	format(tData[to][T_Text], 1024, "%s", tData[source][T_Text]);
    tData[to][T_X] = tData[source][T_X];
    tData[to][T_Y] = tData[source][T_Y];
    tData[to][T_Alignment] = tData[source][T_Alignment];
    tData[to][T_BackColor] = tData[source][T_BackColor];
    tData[to][T_UseBox] = tData[source][T_UseBox];
    tData[to][T_BoxColor] = tData[source][T_BoxColor];
    tData[to][T_TextSizeX] = tData[source][T_TextSizeX];
    tData[to][T_TextSizeY] = tData[source][T_TextSizeY];
    tData[to][T_Color] = tData[source][T_Color];
    tData[to][T_Font] = tData[source][T_Font];
    tData[to][T_XSize] = tData[source][T_XSize];
    tData[to][T_YSize] = tData[source][T_YSize];
    tData[to][T_Outline] = tData[source][T_Outline];
    tData[to][T_Proportional] = tData[source][T_Proportional];
    tData[to][T_Shadow] = tData[source][T_Shadow];
	
	UpdateTextdraw(to);
	SaveTDData(to, "T_Created");
	SaveTDData(to, "T_Text");
	SaveTDData(to, "T_X");
	SaveTDData(to, "T_Y");
	SaveTDData(to, "T_Alignment");
	SaveTDData(to, "T_BackColor");
	SaveTDData(to, "T_UseBox");
	SaveTDData(to, "T_BoxColor");
    SaveTDData(to, "T_TextSizeX");
    SaveTDData(to, "T_TextSizeY");
    SaveTDData(to, "T_Color");
    SaveTDData(to, "T_Font");
    SaveTDData(to, "T_XSize");
    SaveTDData(to, "T_YSize");
    SaveTDData(to, "T_Outline");
    SaveTDData(to, "T_Proportional");
    SaveTDData(to, "T_Shadow");
}

stock UpdateTextdraw( tdid )
{
	/*  Actualiza un textdraw que está siendo mostrado en la pantalla con sus respectivos valores.
	    @tdid:          Textdraw ID
	*/
	if(!tData[tdid][T_Created]) return false;
	TextDrawHideForAll(tData[tdid][T_Handler]);
	TextDrawDestroy(tData[tdid][T_Handler]);
	
	// Recrearlo
	tData[tdid][T_Handler] = TextDrawCreate(tData[tdid][T_X], tData[tdid][T_Y], tData[tdid][T_Text]);
	TextDrawAlignment(tData[tdid][T_Handler], tData[tdid][T_Alignment]);
	TextDrawBackgroundColor(tData[tdid][T_Handler], tData[tdid][T_BackColor]);
	TextDrawColor(tData[tdid][T_Handler], tData[tdid][T_Color]);
	TextDrawFont(tData[tdid][T_Handler], tData[tdid][T_Font]);
	TextDrawLetterSize(tData[tdid][T_Handler], tData[tdid][T_XSize], tData[tdid][T_YSize]);
	TextDrawSetOutline(tData[tdid][T_Handler], tData[tdid][T_Outline]);
	TextDrawSetProportional(tData[tdid][T_Handler], tData[tdid][T_Proportional]);
	TextDrawSetShadow(tData[tdid][T_Handler], tData[tdid][T_Shadow]);
	if(tData[tdid][T_UseBox])
	{
		TextDrawUseBox(tData[tdid][T_Handler], tData[tdid][T_UseBox]);
		TextDrawBoxColor(tData[tdid][T_Handler], tData[tdid][T_BoxColor]);
		TextDrawTextSize(tData[tdid][T_Handler], tData[tdid][T_TextSizeX], tData[tdid][T_TextSizeY]);
	}

	TextDrawShowForAll(tData[tdid][T_Handler]);

	return true;
}

stock DeleteTDFromFile( tdid )
{
    /*  Elimina un textdraw específico de su archivo .tde.
	    @tdid:              Textdraw ID.
	*/
	new string[128], filename[135];
	format(filename, sizeof(filename), "%s.tde", CurrentProject);
	
	format(string, sizeof(string), "%dT_Created", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_Text", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_X", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_Y", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_Alignment", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_BackColor", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_UseBox", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_BoxColor", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_TextSizeX", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_TextSizeY", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_Color", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_Font", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_XSize", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_YSize", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_Outline", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_Proportional", tdid);
	dini_Unset(filename, string);
	format(string, sizeof(string), "%dT_Shadow", tdid);
	dini_Unset(filename, string);
}

stock SaveTDData( tdid, data[] )
{
	/*  Guarda datos específicos de un textdraw específico en un archivo de proyecto.
	    @tdid:              Textdraw ID.
	    @data[]:            Dato a ser guardado.
	*/
	new string[128], filename[135];
	format(string, sizeof(string), "%d%s", tdid, data);
	format(filename, sizeof(filename), "%s.tde", CurrentProject);
	
	if(!strcmp("T_Created", data))
        dini_IntSet(filename, string, 1);
	else if(!strcmp("T_Text", data))
		dini_Set(filename, string, tData[tdid][T_Text]);
	else if(!strcmp("T_X", data))
		dini_FloatSet(filename, string, tData[tdid][T_X]);
	else if(!strcmp("T_Y", data))
		dini_FloatSet(filename, string, tData[tdid][T_Y]);
	else if(!strcmp("T_Alignment", data))
		dini_IntSet(filename, string, tData[tdid][T_Alignment]);
	else if(!strcmp("T_BackColor", data))
		dini_IntSet(filename, string, tData[tdid][T_BackColor]);
	else if(!strcmp("T_UseBox", data))
		dini_IntSet(filename, string, tData[tdid][T_UseBox]);
	else if(!strcmp("T_BoxColor", data))
		dini_IntSet(filename, string, tData[tdid][T_BoxColor]);
    else if(!strcmp("T_TextSizeX", data))
		dini_FloatSet(filename, string, tData[tdid][T_TextSizeX]);
    else if(!strcmp("T_TextSizeY", data))
		dini_FloatSet(filename, string, tData[tdid][T_TextSizeY]);
    else if(!strcmp("T_Color", data))
		dini_IntSet(filename, string, tData[tdid][T_Color]);
    else if(!strcmp("T_Font", data))
		dini_IntSet(filename, string, tData[tdid][T_Font]);
    else if(!strcmp("T_XSize", data))
		dini_FloatSet(filename, string, tData[tdid][T_XSize]);
    else if(!strcmp("T_YSize", data))
		dini_FloatSet(filename, string, tData[tdid][T_YSize]);
    else if(!strcmp("T_Outline", data))
		dini_IntSet(filename, string, tData[tdid][T_Outline]);
    else if(!strcmp("T_Proportional", data))
		dini_IntSet(filename, string, tData[tdid][T_Proportional]);
    else if(!strcmp("T_Shadow", data))
		dini_IntSet(filename, string, tData[tdid][T_Shadow]);
	else
	    SendClientMessageToAll(MSG_COLOR, "Datos incorrectos fueron requeridos, guardado automático ha fallado");
}

stock LoadProject( playerid, filename[] )
{
	/*  Carga un proyecto para su edición.
	    @filename[]:            Nombre del archivo donde el proyecto está guardado.
	*/
	new string[128];
	if(!dini_Isset(filename, "TDFile"))
	{
	    SendClientMessage(playerid, MSG_COLOR, "Archivo de Textdraws inválido.");
	    ShowTextDrawDialog(playerid, 0);
	}
	else
	{
		for(new i; i < MAX_TEXTDRAWS; i ++)
		{
		    format(string, sizeof(string), "%dT_Created", i);
		    if(dini_Isset(filename, string))
		    {
		        CreateDefaultTextdraw(i, 0); // Create but don't save.

		        format(string, sizeof(string), "%dT_Text", i);
		        if(dini_Isset(filename, string))
					format(tData[i][T_Text], 1024, "%s", dini_Get(filename, string));

	            format(string, sizeof(string), "%dT_X", i);
				if(dini_Isset(filename, string))
					tData[i][T_X] = dini_Float(filename, string);

	            format(string, sizeof(string), "%dT_Y", i);
				if(dini_Isset(filename, string))
					tData[i][T_Y] = dini_Float(filename, string);

	            format(string, sizeof(string), "%dT_Alignment", i);
				if(dini_Isset(filename, string))
					tData[i][T_Alignment] = dini_Int(filename, string);

	            format(string, sizeof(string), "%dT_BackColor", i);
				if(dini_Isset(filename, string))
					tData[i][T_BackColor] = dini_Int(filename, string);

	            format(string, sizeof(string), "%dT_UseBox", i);
				if(dini_Isset(filename, string))
					tData[i][T_UseBox] = dini_Int(filename, string);

	            format(string, sizeof(string), "%dT_BoxColor", i);
				if(dini_Isset(filename, string))
					tData[i][T_BoxColor] = dini_Int(filename, string);

	            format(string, sizeof(string), "%dT_TextSizeX", i);
			    if(dini_Isset(filename, string))
					tData[i][T_TextSizeX] = dini_Float(filename, string);

	            format(string, sizeof(string), "%dT_TextSizeY", i);
			    if(dini_Isset(filename, string))
					tData[i][T_TextSizeY] = dini_Float(filename, string);

	            format(string, sizeof(string), "%dT_Color", i);
			    if(dini_Isset(filename, string))
					tData[i][T_Color] = dini_Int(filename, string);

	            format(string, sizeof(string), "%dT_Font", i);
			    if(dini_Isset(filename, string))
					tData[i][T_Font] = dini_Int(filename, string);

	            format(string, sizeof(string), "%dT_XSize", i);
				if(dini_Isset(filename, string))
					tData[i][T_XSize] = dini_Float(filename, string);

	            format(string, sizeof(string), "%dT_YSize", i);
				if(dini_Isset(filename, string))
					tData[i][T_YSize] = dini_Float(filename, string);

	            format(string, sizeof(string), "%dT_Outline", i);
			    if(dini_Isset(filename, string))
					tData[i][T_Outline] = dini_Int(filename, string);

	            format(string, sizeof(string), "%dT_Proportional", i);
			    if(dini_Isset(filename, string))
					tData[i][T_Proportional] = dini_Int(filename, string);

	            format(string, sizeof(string), "%dT_Shadow", i);
			    if(dini_Isset(filename, string))
					tData[i][T_Shadow] = dini_Int(filename, string);

		        UpdateTextdraw(i);
		    }
		}
		strmid(CurrentProject, filename, 0, strlen(filename) - 4, 128);
		ShowTextDrawDialog(playerid, 4);
	}
}

stock ExportProject( playerid, type )
{
	/*  Exporta un proyecto.
	    @playerid:          ID del jugador que exporta el proyecto.
	    @type:              Tipo de exportación pedida:
	        - Type 0:       Modo de exportación clásico.
 	*/
 	SendClientMessage(playerid, MSG_COLOR, "El proyecto está siendo exportado, espera...");
 	
 	new filename[135], tmpstring[1152];
 	if(type == 0)	format(filename, sizeof(filename), "%s.txt", CurrentProject);
 	else		  	format(filename, sizeof(filename), "%s.pwn", CurrentProject);
 	new File:File = fopen(filename, io_write);
	switch(type)
	{
	    case 0: // Classic export.
	    {
	        fwrite(File, "// TextDraw desarrollado utilizando Zamaroht's Textdraw Editor 1.0\r\n\r\n");
	        fwrite(File, "// Arriba de todo del script:\r\n");
	        for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
	        fwrite(File, "\r\n// En OnGameModeInit preferentemente, procedemos a crear nuestros textdraws:\r\n");
	        for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "Textdraw%d = TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);
					if(tData[i][T_Alignment] != 0 && tData[i][T_Alignment] != 1)
					{
						format(tmpstring, sizeof(tmpstring), "TextDrawAlignment(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
						fwrite(File, tmpstring);
					}
					format(tmpstring, sizeof(tmpstring), "TextDrawBackgroundColor(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawFont(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawLetterSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_XSize], tData[i][T_YSize]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawColor(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawSetOutline(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "TextDrawSetProportional(Textdraw%d, %d);\r\n", i, tData[i][T_Proportional]);
					fwrite(File, tmpstring);
					if(tData[i][T_Outline] == 0)
					{
					    format(tmpstring, sizeof(tmpstring), "TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
						fwrite(File, tmpstring);
					}
					if(tData[i][T_UseBox] == 1)
					{
					    format(tmpstring, sizeof(tmpstring), "TextDrawUseBox(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSizeX], tData[i][T_TextSizeY]);
						fwrite(File, tmpstring);
					}
					fwrite(File, "\r\n");
				}
	        }
	        fwrite(File, "// Ahora puedes usar TextDrawShowForPlayer(-ForAll), TextDrawHideForPlayer(-ForAll) y\r\n");
	        fwrite(File, "// TextDrawDestroy para mostrar, esconder y destruir el textdraw.");

			format(tmpstring, sizeof(tmpstring), "Proyecto exportado a %s.txt en el directorio scriptfiles.", CurrentProject);
	        SendClientMessage(playerid, MSG_COLOR, tmpstring);
	    }
	    
	    case 1: // Show all the time
	    {
	        fwrite(File, "/*\r\n");
	        fwrite(File, "Filterscript generado utilizando Zamaroht's TextDraw Editor Version 1.0.\r\n");
	        fwrite(File, "Diseñado para SA-MP 0.3a.\r\n\r\n");
	        new ye,mo,da,ho,mi,se;
	        getdate(ye,mo,da);
	        gettime(ho,mi,se);
			format(tmpstring, sizeof(tmpstring), "Hora y Fecha: %d-%d-%d @ %d:%d:%d\r\n\r\n", ye, mo, da, ho, mi, se);
			fwrite(File, tmpstring);
			fwrite(File, "Instrucciones:\r\n");
			fwrite(File, "1- Compilar este archivo utilizando el compilador provisto por el pack de server de sa-mp.\r\n");
			fwrite(File, "2- Copiar el archivo .amx generado al directorio filterscripts.\r\n");
			fwrite(File, "3- Añadir el filterscript al archivo server.cfg (más información aquí:\r\n");
			fwrite(File, "http://wiki.sa-mp.com/wiki/Server.cfg)\r\n");
			fwrite(File, "4- Ejecutar el servidor!\r\n\r\n");
			fwrite(File, "Licencia:\r\n");
			fwrite(File, "Tienes derechos completos sobre este archivo. Pueeds distribuirlo, modificarlo y\r\n");
			fwrite(File, "cambiarlo tanto como quieras, sin tener que dar ningún credito en especial.\r\n");
			fwrite(File, "*/\r\n\r\n");
			fwrite(File, "#include <a_samp>\r\n\r\n");
            for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
			fwrite(File, "\r\npublic OnFilterScriptInit()\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	print(\"Archivo de Textdraws generado utilizando\");\r\n");
			fwrite(File, "	print(\"    Zamaroht's textdraw editor fue exitosamente cargado.\");\r\n\r\n");
			fwrite(File, "	// Crear los textdraws:\r\n");
			for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "	Textdraw%d = TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);
					if(tData[i][T_Alignment] != 0 && tData[i][T_Alignment] != 1)
					{
						format(tmpstring, sizeof(tmpstring), "	TextDrawAlignment(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
						fwrite(File, tmpstring);
					}
					format(tmpstring, sizeof(tmpstring), "	TextDrawBackgroundColor(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawFont(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawLetterSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_XSize], tData[i][T_YSize]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawColor(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetOutline(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %d);\r\n", i, tData[i][T_Proportional]);
					fwrite(File, tmpstring);
					if(tData[i][T_Outline] == 0)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
						fwrite(File, tmpstring);
					}
					if(tData[i][T_UseBox] == 1)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSizeX], tData[i][T_TextSizeY]);
						fwrite(File, tmpstring);
					}
					fwrite(File, "\r\n");
				}
	        }
	        fwrite(File, "	for(new i; i < MAX_PLAYERS; i ++)\r\n");
	        fwrite(File, "	{\r\n");
	        fwrite(File, "		if(IsPlayerConnected(i))\r\n");
	        fwrite(File, "		{\r\n");
	        for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "			TextDrawShowForPlayer(i, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "		}\r\n");
			fwrite(File, "	}\r\n");
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnFilterScriptExit()\r\n");
			fwrite(File, "{\r\n");
            for(new i; i < MAX_TEXTDRAWS; i ++)
            {
                if(tData[i][T_Created])
                {
					format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawDestroy(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
                }
            }
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerConnect(playerid)\r\n");
			fwrite(File, "{\r\n");
			for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawShowForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n");
			
			format(tmpstring, sizeof(tmpstring), "Proyecto exportado a %s.pwn en el directorio scriptfiles como un filterscript.", CurrentProject);
	        SendClientMessage(playerid, MSG_COLOR, tmpstring);
	    }
	    
	    case 2: // Show on class selection
	    {
            fwrite(File, "/*\r\n");
	        fwrite(File, "Filterscript generado utilizando Zamaroht's TextDraw Editor Version 1.0.\r\n");
	        fwrite(File, "Diseñado para SA-MP 0.3a.\r\n\r\n");
	        new ye,mo,da,ho,mi,se;
	        getdate(ye,mo,da);
	        gettime(ho,mi,se);
			format(tmpstring, sizeof(tmpstring), "Hora y Fecha: %d-%d-%d @ %d:%d:%d\r\n\r\n", ye, mo, da, ho, mi, se);
			fwrite(File, tmpstring);
			fwrite(File, "Instrucciones:\r\n");
			fwrite(File, "1- Compilar este archivo utilizando el compilador provisto por el pack de server de sa-mp.\r\n");
			fwrite(File, "2- Copiar el archivo .amx generado al directorio filterscripts.\r\n");
			fwrite(File, "3- Añadir el filterscript al archivo server.cfg (más información aquí:\r\n");
			fwrite(File, "http://wiki.sa-mp.com/wiki/Server.cfg)\r\n");
			fwrite(File, "4- Ejecutar el servidor!\r\n\r\n");
			fwrite(File, "Licencia:\r\n");
			fwrite(File, "Tienes derechos completos sobre este archivo. Pueeds distribuirlo, modificarlo y\r\n");
			fwrite(File, "cambiarlo tanto como quieras, sin tener que dar ningún credito en especial.\r\n");
			fwrite(File, "*/\r\n\r\n");
			fwrite(File, "#include <a_samp>\r\n\r\n");
            for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
			fwrite(File, "\r\npublic OnFilterScriptInit()\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	print(\"Archivo de Textdraws generado utilizando\");\r\n");
			fwrite(File, "	print(\"    Zamaroht's textdraw editor fue exitosamente cargado.\");\r\n\r\n");
			fwrite(File, "	// Crear los textdraws:\r\n");
			for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "	Textdraw%d = TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);
					if(tData[i][T_Alignment] != 0 && tData[i][T_Alignment] != 1)
					{
						format(tmpstring, sizeof(tmpstring), "	TextDrawAlignment(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
						fwrite(File, tmpstring);
					}
					format(tmpstring, sizeof(tmpstring), "	TextDrawBackgroundColor(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawFont(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawLetterSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_XSize], tData[i][T_YSize]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawColor(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetOutline(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %d);\r\n", i, tData[i][T_Proportional]);
					fwrite(File, tmpstring);
					if(tData[i][T_Outline] == 0)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
						fwrite(File, tmpstring);
					}
					if(tData[i][T_UseBox] == 1)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSizeX], tData[i][T_TextSizeY]);
						fwrite(File, tmpstring);
					}
					fwrite(File, "\r\n");
				}
	        }
	        fwrite(File, "	return 1;\r\n");
	        fwrite(File, "}\r\n\r\n");
	        fwrite(File, "public OnFilterScriptExit()\r\n");
			fwrite(File, "{\r\n");
            for(new i; i < MAX_TEXTDRAWS; i ++)
            {
                if(tData[i][T_Created])
                {
					format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawDestroy(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
                }
            }
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerRequestClass(playerid, classid)\r\n");
			fwrite(File, "{\r\n");
			for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawShowForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerSpawn(playerid)\r\n");
			fwrite(File, "{\r\n");
			for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawHideForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			
			format(tmpstring, sizeof(tmpstring), "Proyecto exportado a %s.pwn en el directorio scriptfiles como un filterscript.", CurrentProject);
	        SendClientMessage(playerid, MSG_COLOR, tmpstring);
	    }
	    
	    case 3: // Show while in vehicle
	    {
	        fwrite(File, "/*\r\n");
	        fwrite(File, "Filterscript generado utilizando Zamaroht's TextDraw Editor Version 1.0.\r\n");
	        fwrite(File, "Diseñado para SA-MP 0.3a.\r\n\r\n");
	        new ye,mo,da,ho,mi,se;
	        getdate(ye,mo,da);
	        gettime(ho,mi,se);
			format(tmpstring, sizeof(tmpstring), "Hora y Fecha: %d-%d-%d @ %d:%d:%d\r\n\r\n", ye, mo, da, ho, mi, se);
			fwrite(File, tmpstring);
			fwrite(File, "Instrucciones:\r\n");
			fwrite(File, "1- Compilar este archivo utilizando el compilador provisto por el pack de server de sa-mp.\r\n");
			fwrite(File, "2- Copiar el archivo .amx generado al directorio filterscripts.\r\n");
			fwrite(File, "3- Añadir el filterscript al archivo server.cfg (más información aquí:\r\n");
			fwrite(File, "http://wiki.sa-mp.com/wiki/Server.cfg)\r\n");
			fwrite(File, "4- Ejecutar el servidor!\r\n\r\n");
			fwrite(File, "Licencia:\r\n");
			fwrite(File, "Tienes derechos completos sobre este archivo. Pueeds distribuirlo, modificarlo y\r\n");
			fwrite(File, "cambiarlo tanto como quieras, sin tener que dar ningún credito en especial.\r\n");
			fwrite(File, "*/\r\n\r\n");
			fwrite(File, "#include <a_samp>\r\n\r\n");
            for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
			fwrite(File, "\r\npublic OnFilterScriptInit()\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	print(\"Archivo de Textdraws generado utilizando\");\r\n");
			fwrite(File, "	print(\"    Zamaroht's textdraw editor fue exitosamente cargado.\");\r\n\r\n");
			fwrite(File, "	// Crear los textdraws:\r\n");
			for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "	Textdraw%d = TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);
					if(tData[i][T_Alignment] != 0 && tData[i][T_Alignment] != 1)
					{
						format(tmpstring, sizeof(tmpstring), "	TextDrawAlignment(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
						fwrite(File, tmpstring);
					}
					format(tmpstring, sizeof(tmpstring), "	TextDrawBackgroundColor(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawFont(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawLetterSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_XSize], tData[i][T_YSize]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawColor(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetOutline(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %d);\r\n", i, tData[i][T_Proportional]);
					fwrite(File, tmpstring);
					if(tData[i][T_Outline] == 0)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
						fwrite(File, tmpstring);
					}
					if(tData[i][T_UseBox] == 1)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSizeX], tData[i][T_TextSizeY]);
						fwrite(File, tmpstring);
					}
					fwrite(File, "\r\n");
				}
	        }
	        fwrite(File, "	return 1;\r\n");
	        fwrite(File, "}\r\n\r\n");
	        fwrite(File, "public OnFilterScriptExit()\r\n");
			fwrite(File, "{\r\n");
            for(new i; i < MAX_TEXTDRAWS; i ++)
            {
                if(tData[i][T_Created])
                {
					format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawDestroy(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
                }
            }
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerStateChange(playerid, newstate, oldstate)\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	if(newstate == PLAYER_STATE_DRIVER || newstate == PLAYER_STATE_PASSENGER)\r\n");
			fwrite(File, "	{\r\n");
			for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "		TextDrawShowForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "	}\r\n");
			fwrite(File, "	else if(oldstate == PLAYER_STATE_DRIVER || oldstate == PLAYER_STATE_PASSENGER)\r\n");
			fwrite(File, "	{\r\n");
			for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "		TextDrawHideForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "	}\r\n");
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n");
			
			format(tmpstring, sizeof(tmpstring), "Proyecto exportado a %s.pwn en el directorio scriptfiles como un filterscript.", CurrentProject);
	        SendClientMessage(playerid, MSG_COLOR, tmpstring);
	    }
	    
	    case 4: // Use command
	    {
	        fwrite(File, "/*\r\n");
	        fwrite(File, "Filterscript generado utilizando Zamaroht's TextDraw Editor Version 1.0.\r\n");
	        fwrite(File, "Diseñado para SA-MP 0.3a.\r\n\r\n");
	        new ye,mo,da,ho,mi,se;
	        getdate(ye,mo,da);
	        gettime(ho,mi,se);
			format(tmpstring, sizeof(tmpstring), "Hora y Fecha: %d-%d-%d @ %d:%d:%d\r\n\r\n", ye, mo, da, ho, mi, se);
			fwrite(File, tmpstring);
			fwrite(File, "Instrucciones:\r\n");
			fwrite(File, "1- Compilar este archivo utilizando el compilador provisto por el pack de server de sa-mp.\r\n");
			fwrite(File, "2- Copiar el archivo .amx generado al directorio filterscripts.\r\n");
			fwrite(File, "3- Añadir el filterscript al archivo server.cfg (más información aquí:\r\n");
			fwrite(File, "http://wiki.sa-mp.com/wiki/Server.cfg)\r\n");
			fwrite(File, "4- Ejecutar el servidor!\r\n\r\n");
			fwrite(File, "Licencia:\r\n");
			fwrite(File, "Tienes derechos completos sobre este archivo. Pueeds distribuirlo, modificarlo y\r\n");
			fwrite(File, "cambiarlo tanto como quieras, sin tener que dar ningún credito en especial.\r\n");
			fwrite(File, "*/\r\n\r\n");
			fwrite(File, "#include <a_samp>\r\n\r\n");
			fwrite(File, "new Showing[MAX_PLAYERS];\r\n\r\n");
            for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
	        fwrite(File, "\r\npublic OnFilterScriptInit()\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	print(\"Archivo de Textdraws generado utilizando\");\r\n");
			fwrite(File, "	print(\"    Zamaroht's textdraw editor fue exitosamente cargado.\");\r\n\r\n");
			fwrite(File, "	// Crear los textdraws:\r\n");
			for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "	Textdraw%d = TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);
					if(tData[i][T_Alignment] != 0 && tData[i][T_Alignment] != 1)
					{
						format(tmpstring, sizeof(tmpstring), "	TextDrawAlignment(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
						fwrite(File, tmpstring);
					}
					format(tmpstring, sizeof(tmpstring), "	TextDrawBackgroundColor(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawFont(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawLetterSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_XSize], tData[i][T_YSize]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawColor(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetOutline(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %d);\r\n", i, tData[i][T_Proportional]);
					fwrite(File, tmpstring);
					if(tData[i][T_Outline] == 0)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
						fwrite(File, tmpstring);
					}
					if(tData[i][T_UseBox] == 1)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSizeX], tData[i][T_TextSizeY]);
						fwrite(File, tmpstring);
					}
					fwrite(File, "\r\n");
				}
	        }
	        fwrite(File, "	return 1;\r\n");
	        fwrite(File, "}\r\n\r\n");
	        fwrite(File, "public OnFilterScriptExit()\r\n");
			fwrite(File, "{\r\n");
            for(new i; i < MAX_TEXTDRAWS; i ++)
            {
                if(tData[i][T_Created])
                {
					format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawDestroy(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
                }
            }
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerConnect(playerid)\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	Showing[playerid] = 0;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerCommandText(playerid, cmdtext[])\r\n");
			fwrite(File, "{\r\n");
			if(pData[playerid][P_Aux] != 0)
			{
			    format(tmpstring, sizeof(tmpstring), "	if(!strcmp(cmdtext, \"%s\") && Showing[playerid] == 0)\r\n", pData[playerid][P_ExpCommand]);
			    fwrite(File, tmpstring);
			}
			else
			{
			    format(tmpstring, sizeof(tmpstring), "	if(!strcmp(cmdtext, \"%s\"))\r\n", pData[playerid][P_ExpCommand]);
			    fwrite(File, tmpstring);
			}
			fwrite(File, "	{\r\n");
			fwrite(File, "		if(Showing[playerid] == 1)\r\n");
			fwrite(File, "		{\r\n");
			fwrite(File, "			Showing[playerid] = 0;\r\n");
			for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "			TextDrawHideForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "		}\r\n");
			fwrite(File, "		else\r\n");
			fwrite(File, "		{\r\n");
			fwrite(File, "			Showing[playerid] = 1;\r\n");
			for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "			TextDrawShowForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			if(pData[playerid][P_Aux] != 0)
			{
			    format(tmpstring, sizeof(tmpstring), "			SetTimerEx(\"HideTextdraws\", %d, 0, \"i\", playerid);\r\n", pData[playerid][P_Aux]*1000);
				fwrite(File, tmpstring);
			}
			fwrite(File, "		}\r\n");
			fwrite(File, "	}\r\n");
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n");
            if(pData[playerid][P_Aux] != 0)
			{
			    fwrite(File, "\r\n");
			    fwrite(File, "forward HideTextdraws(playerid);\r\n");
			    fwrite(File, "public HideTextdraws(playerid)\r\n");
			    fwrite(File, "{\r\n");
			    fwrite(File, "	Showing[playerid] = 0;\r\n");
			    for(new i; i < MAX_TEXTDRAWS; i ++)
				{
				    if(tData[i][T_Created])
				    {
				        format(tmpstring, sizeof(tmpstring), "	TextDrawHideForPlayer(playerid, Textdraw%d);\r\n", i);
						fwrite(File, tmpstring);
				    }
				}
				fwrite(File, "}\r\n");
			}
			
			format(tmpstring, sizeof(tmpstring), "Proyecto exportado a %s.pwn en el directorio scriptfiles como un filterscript.", CurrentProject);
	        SendClientMessage(playerid, MSG_COLOR, tmpstring);
	    }
	    
	    case 5: // Every X time
	    {
	        fwrite(File, "/*\r\n");
	        fwrite(File, "Filterscript generado utilizando Zamaroht's TextDraw Editor Version 1.0.\r\n");
	        fwrite(File, "Diseñado para SA-MP 0.3a.\r\n\r\n");
	        new ye,mo,da,ho,mi,se;
	        getdate(ye,mo,da);
	        gettime(ho,mi,se);
			format(tmpstring, sizeof(tmpstring), "Hora y Fecha: %d-%d-%d @ %d:%d:%d\r\n\r\n", ye, mo, da, ho, mi, se);
			fwrite(File, tmpstring);
			fwrite(File, "Instrucciones:\r\n");
			fwrite(File, "1- Compilar este archivo utilizando el compilador provisto por el pack de server de sa-mp.\r\n");
			fwrite(File, "2- Copiar el archivo .amx generado al directorio filterscripts.\r\n");
			fwrite(File, "3- Añadir el filterscript al archivo server.cfg (más información aquí:\r\n");
			fwrite(File, "http://wiki.sa-mp.com/wiki/Server.cfg)\r\n");
			fwrite(File, "4- Ejecutar el servidor!\r\n\r\n");
			fwrite(File, "Licencia:\r\n");
			fwrite(File, "Tienes derechos completos sobre este archivo. Pueeds distribuirlo, modificarlo y\r\n");
			fwrite(File, "cambiarlo tanto como quieras, sin tener que dar ningún credito en especial.\r\n");
			fwrite(File, "*/\r\n\r\n");
			fwrite(File, "#include <a_samp>\r\n\r\n");
			fwrite(File, "new Timer;\r\n\r\n");
			for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
	        fwrite(File, "\r\npublic OnFilterScriptInit()\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	print(\"Archivo de Textdraws generado utilizando\");\r\n");
			fwrite(File, "	print(\"    Zamaroht's textdraw editor fue exitosamente cargado.\");\r\n\r\n");
			fwrite(File, "	// Crear los textdraws:\r\n");
			for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "	Textdraw%d = TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);
					if(tData[i][T_Alignment] != 0 && tData[i][T_Alignment] != 1)
					{
						format(tmpstring, sizeof(tmpstring), "	TextDrawAlignment(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
						fwrite(File, tmpstring);
					}
					format(tmpstring, sizeof(tmpstring), "	TextDrawBackgroundColor(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawFont(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawLetterSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_XSize], tData[i][T_YSize]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawColor(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetOutline(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %d);\r\n", i, tData[i][T_Proportional]);
					fwrite(File, tmpstring);
					if(tData[i][T_Outline] == 0)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
						fwrite(File, tmpstring);
					}
					if(tData[i][T_UseBox] == 1)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSizeX], tData[i][T_TextSizeY]);
						fwrite(File, tmpstring);
					}
					fwrite(File, "\r\n");
				}
	        }
	        format(tmpstring, sizeof(tmpstring), "	Timer = SetTimer(\"ShowMessage\", %d, 1);\r\n", pData[playerid][P_Aux]*1000);
	        fwrite(File, tmpstring);
	        fwrite(File, "	return 1;\r\n");
	        fwrite(File, "}\r\n\r\n");
	        fwrite(File, "public OnFilterScriptExit()\r\n");
			fwrite(File, "{\r\n");
            for(new i; i < MAX_TEXTDRAWS; i ++)
            {
                if(tData[i][T_Created])
                {
					format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawDestroy(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
                }
            }
            fwrite(File, "	KillTimer(Timer);\r\n");
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
	        fwrite(File, "forward ShowMessage( );\r\n");
	        fwrite(File, "public ShowMessage( )\r\n");
	        fwrite(File, "{\r\n");
	        for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawShowForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			format(tmpstring, sizeof(tmpstring), "	SetTimer(\"HideMessage\", %d, 1);\r\n", pData[playerid][P_Aux2]*1000);
			fwrite(File, tmpstring);
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "forward HideMessage( );\r\n");
	        fwrite(File, "public HideMessage( )\r\n");
	        fwrite(File, "{\r\n");
	        for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
	        fwrite(File, "}");
	        
	        format(tmpstring, sizeof(tmpstring), "Proyecto exportado a %s.pwn en el directorio scriptfiles como un filterscript.", CurrentProject);
	        SendClientMessage(playerid, MSG_COLOR, tmpstring);
	    }
	    
	    case 6: // After kill
	    {
	        fwrite(File, "/*\r\n");
	        fwrite(File, "Filterscript generado utilizando Zamaroht's TextDraw Editor Version 1.0.\r\n");
	        fwrite(File, "Diseñado para SA-MP 0.3a.\r\n\r\n");
	        new ye,mo,da,ho,mi,se;
	        getdate(ye,mo,da);
	        gettime(ho,mi,se);
			format(tmpstring, sizeof(tmpstring), "Hora y Fecha: %d-%d-%d @ %d:%d:%d\r\n\r\n", ye, mo, da, ho, mi, se);
			fwrite(File, tmpstring);
			fwrite(File, "Instrucciones:\r\n");
			fwrite(File, "1- Compilar este archivo utilizando el compilador provisto por el pack de server de sa-mp.\r\n");
			fwrite(File, "2- Copiar el archivo .amx generado al directorio filterscripts.\r\n");
			fwrite(File, "3- Añadir el filterscript al archivo server.cfg (más información aquí:\r\n");
			fwrite(File, "http://wiki.sa-mp.com/wiki/Server.cfg)\r\n");
			fwrite(File, "4- Ejecutar el servidor!\r\n\r\n");
			fwrite(File, "Licencia:\r\n");
			fwrite(File, "Tienes derechos completos sobre este archivo. Pueeds distribuirlo, modificarlo y\r\n");
			fwrite(File, "cambiarlo tanto como quieras, sin tener que dar ningún credito en especial.\r\n");
			fwrite(File, "*/\r\n\r\n");
			fwrite(File, "#include <a_samp>\r\n\r\n");
            for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "new Text:Textdraw%d;\r\n", i);
					fwrite(File, tmpstring);
				}
	        }
			fwrite(File, "\r\npublic OnFilterScriptInit()\r\n");
			fwrite(File, "{\r\n");
			fwrite(File, "	print(\"Archivo de Textdraws generado utilizando\");\r\n");
			fwrite(File, "	print(\"    Zamaroht's textdraw editor fue exitosamente cargado.\");\r\n\r\n");
			fwrite(File, "	// Crear los textdraws:\r\n");
			for(new i; i < MAX_TEXTDRAWS; i++)
	        {
	            if(tData[i][T_Created])
				{
					format(tmpstring, sizeof(tmpstring), "	Textdraw%d = TextDrawCreate(%f, %f, \"%s\");\r\n", i, tData[i][T_X], tData[i][T_Y], tData[i][T_Text]);
					fwrite(File, tmpstring);
					if(tData[i][T_Alignment] != 0 && tData[i][T_Alignment] != 1)
					{
						format(tmpstring, sizeof(tmpstring), "	TextDrawAlignment(Textdraw%d, %d);\r\n", i, tData[i][T_Alignment]);
						fwrite(File, tmpstring);
					}
					format(tmpstring, sizeof(tmpstring), "	TextDrawBackgroundColor(Textdraw%d, %d);\r\n", i, tData[i][T_BackColor]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawFont(Textdraw%d, %d);\r\n", i, tData[i][T_Font]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawLetterSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_XSize], tData[i][T_YSize]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawColor(Textdraw%d, %d);\r\n", i, tData[i][T_Color]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetOutline(Textdraw%d, %d);\r\n", i, tData[i][T_Outline]);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawSetProportional(Textdraw%d, %d);\r\n", i, tData[i][T_Proportional]);
					fwrite(File, tmpstring);
					if(tData[i][T_Outline] == 0)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawSetShadow(Textdraw%d, %d);\r\n", i, tData[i][T_Shadow]);
						fwrite(File, tmpstring);
					}
					if(tData[i][T_UseBox] == 1)
					{
					    format(tmpstring, sizeof(tmpstring), "	TextDrawUseBox(Textdraw%d, %d);\r\n", i, tData[i][T_UseBox]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawBoxColor(Textdraw%d, %d);\r\n", i, tData[i][T_BoxColor]);
						fwrite(File, tmpstring);
						format(tmpstring, sizeof(tmpstring), "	TextDrawTextSize(Textdraw%d, %f, %f);\r\n", i, tData[i][T_TextSizeX], tData[i][T_TextSizeY]);
						fwrite(File, tmpstring);
					}
					fwrite(File, "\r\n");
				}
	        }
	        fwrite(File, "	return 1;\r\n");
	        fwrite(File, "}\r\n\r\n");
	        fwrite(File, "public OnFilterScriptExit()\r\n");
			fwrite(File, "{\r\n");
            for(new i; i < MAX_TEXTDRAWS; i ++)
            {
                if(tData[i][T_Created])
                {
					format(tmpstring, sizeof(tmpstring), "	TextDrawHideForAll(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
					format(tmpstring, sizeof(tmpstring), "	TextDrawDestroy(Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
                }
            }
			fwrite(File, "	return 1;\r\n");
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "public OnPlayerDeath(playerid, killerid, reason)\r\n");
			fwrite(File, "{\r\n");
			for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawShowForPlayer(killerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			format(tmpstring, sizeof(tmpstring), "	SetTimerEx(\"HideMessage\", %d, 0, \"i\", killerid);\r\n", pData[playerid][P_Aux]*1000);
			fwrite(File, tmpstring);
			fwrite(File, "}\r\n\r\n");
			fwrite(File, "forward HideMessage(playerid);\r\n");
			fwrite(File, "public HideMessage(playerid)\r\n");
			fwrite(File, "{\r\n");
			for(new i; i < MAX_TEXTDRAWS; i ++)
			{
			    if(tData[i][T_Created])
			    {
			        format(tmpstring, sizeof(tmpstring), "	TextDrawHideForPlayer(playerid, Textdraw%d);\r\n", i);
					fwrite(File, tmpstring);
			    }
			}
			fwrite(File, "}");
			
		    format(tmpstring, sizeof(tmpstring), "Proyecto exportado a %s.pwn en el directorio scriptfiles como un filterscript.", CurrentProject);
	        SendClientMessage(playerid, MSG_COLOR, tmpstring);
	    }
	}
	fclose(File);
	
	ShowTextDrawDialog(playerid, 4);
}

// ================================================================================================================================
// ------------------------------------------------------- FUNCIONES AUXILIARES ---------------------------------------------------
// ================================================================================================================================


stock GetFileNameFromLst( file[], line )
{
	/*  Pasa por return la línea en la línea especificada del archivo especificado.
	    @file[]:            Archivo del cual obtener la línea.
	    @line:              Número de línea a pasar por return.
	*/
	new string[150];

	new CurrLine,
		File:Handler = fopen(file, io_read);

	if(line >= 0 && CurrLine != line)
	{
        while(CurrLine != line)
        {
			fread(Handler, string);
            CurrLine ++;
        }
	}

	// Eliminar la siguiente línea, que es la pedida.
	fread(Handler, string);
	fclose(Handler);

	// Eliminar los últimos dos caractéres (\n)
	strmid(string, string, 0, strlen(string) - 2, 150);

	return string;
}

stock DeleteLineFromFile( file[], line )
{
	/*  Elimina una linea específica de un archivo específico.
	    @file[]:        Archivo del cual eliminar la línea.
	    @line:          Número de la línea a borrar.
	*/

	if(line < 0) return false;

	new tmpfile[140];
	format(tmpfile, sizeof(tmpfile), "%s.tmp", file);
	fcopytextfile(file, tmpfile);
	// Copiado a un archivo temporal, ahora hay que volver a pasarlo.

	new CurrLine,
		File:FileFrom 	= fopen(tmpfile, io_read),
		File:FileTo		= fopen(file, io_write);

	new tmpstring[200];
	if(CurrLine != line)
	{
		while(CurrLine != line)
		{
		    fread(FileFrom, tmpstring);
			fwrite(FileTo, tmpstring);
			CurrLine ++;
		}
	}

	// Saltear una linea
	fread(FileFrom, tmpstring);

	// Escribir el resto
	while(fread(FileFrom, tmpstring))
	{
	    fwrite(FileTo, tmpstring);
	}

	fclose(FileTo);
	fclose(FileFrom);
	// Remover archivo temporal.
	fremove(tmpfile);
	return true;
}

/** POR DRACOBLUE
 *  Strips Newline from the end of a string.
 *  Idea: Y_Less, Bugfixing (when length=1) by DracoBlue
 *  @param   string
 */
stock StripNewLine(string[])
{
	new len = strlen(string);
	if (string[0]==0) return ;
	if ((string[len - 1] == '\n') || (string[len - 1] == '\r')) {
		string[len - 1] = 0;
		if (string[0]==0) return ;
		if ((string[len - 2] == '\n') || (string[len - 2] == '\r')) string[len - 2] = 0;
	}
}

/** POR DRACOBLUE
 *  Copies a textfile (Source file won't be deleted!)
 *  @param   oldname
 *           newname
 */
stock fcopytextfile(oldname[],newname[]) {
	new File:ohnd,File:nhnd;
	if (!fexist(oldname)) return false;
	ohnd=fopen(oldname,io_read);
	nhnd=fopen(newname,io_write);
	new tmpres[256];
	while (fread(ohnd,tmpres)) {
		StripNewLine(tmpres);
		format(tmpres,sizeof(tmpres),"%s\r\n",tmpres);
		fwrite(nhnd,tmpres);
	}
	fclose(ohnd);
	fclose(nhnd);
	return true;
}

stock RGB( red, green, blue, alpha )
{
	/*  Combina un color y lo pasa a return, así puede ser usado en distintas funciones.
	    @red:           Cantidad de color rojo.
	    @green:         Cantidad de color verde.
	    @blue:          Cantidad de color azul.
	    @alpha:         Cantidad de transparencia en canal alpha.

		-Returns:
		Un entero (int) con el color formado.
	*/
	return (red * 16777216) + (green * 65536) + (blue * 256) + alpha;
}

IsNumeric2(const string[])
{
    // Is Numeric Check 2
	// ------------------
	// Por DracoBlue... handles negative numbers

	new length=strlen(string);
	if (length==0) return false;
	for (new i = 0; i < length; i++)
	{
	  if((string[i] > '9' || string[i] < '0' && string[i]!='-' && string[i]!='+' && string[i]!='.') // Not a number,'+' or '-' or '.'
	         || (string[i]=='-' && i!=0)                                             // A '-' but not first char.
	         || (string[i]=='+' && i!=0)                                             // A '+' but not first char.
	     ) return false;
	}
	if (length==1 && (string[0]=='-' || string[0]=='+' || string[0]=='.')) return false;
	return true;
}

/** POR DRACOBLUE
 *  Devuelve el valor de una string que estaba en hexadecimal
 *  @param string
 */
stock HexToInt(string[]) {
  if (string[0]==0) return 0;
  new i;
  new cur=1;
  new res=0;
  for (i=strlen(string);i>0;i--) {
    if (string[i-1]<58) res=res+cur*(string[i-1]-48); else res=res+cur*(string[i-1]-65+10);
    cur=cur*16;
  }
  return res;
}

stock IsPlayerMinID(playerid)
{
	/*  Checkea si el jugador es la mínima ID del servidor.
	    @playerid:              ID a checkear.
	    
	    -Returns:
	    true si lo es, false si no lo es.
	*/
	for(new i; i < playerid; i ++)
	{
	    if(IsPlayerConnected(i))
	    {
		    if(IsPlayerNPC(i)) continue;
		    else return false;
		}
	}
	return true;
}
// ================================================================================================================================
// --------------------------------------------------- FINAL DE FUNCIONES AUXILIARES ----------------------------------------------
// ================================================================================================================================

// Fin de archivo
