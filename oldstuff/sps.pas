program sps_simulator;
 
uses dos,porting,mouse,linux,crt,printer,popmenu,ports;

{ Linux Portierung							}

{ unit environ entfernt			 				}

{ write(ord(eingang[4]):1,ord(eingang[5]):1,ord(eingang[6]):1); 	}
{ in obiger zeile erzeugt ord(...) die Fehlermeldung: Internal Error 12	}
{ siehe run_awl.pas procedure print_in_out				}

{ graph,intzeit,getgraph,autograf  entfernt 				}



{ folgende defines führen zu sonderversionen                             }
{ Handler  = version mit Fenster bei Progstart mit Hinweis Händlertest   }
{            darf nicht verkauft werden                                  }
{ Demo     = Demoversion mit kleinen einschränkungen                     }
{ aktivieren der Defines einfach $ voranstellen                          }


{$M 16384,0,100000}
{DEFINE Handler}
{DEFINE Demo}

type  string12=string[12];
      string3 =string[3];
      string80=string[80];
      doc_pointer = ^doc_record;
      doc_record = record
                     zeil : string[76];
                     nach,
                     vor  : doc_pointer;
                   end;

   

const awl_max     =500;
      version     ='V 1.7 Linux ß 0.4';
      datum       ='15.06.99';
      anweisung   : array[1..20] of string3
                  = ('O  ','ON ','O( ','ON(','U  ',
                     'UN ','U( ','UN(',')  ','=  ',
                     '=N ','S  ','R  ','J  ','JI ',
                     'K  ','TE ','ZR ','NOP','EN ');

var  znr               : array[1..awl_max] of integer;
     operation         : array[1..awl_max] of string3;
     operand           : array[1..awl_max] of char;
     par               : array[1..awl_max] of word;
     comment           : array[1..awl_max] of string[22];
     programm,sicher   : boolean;
     graphdriver,
     graphmode,
     grapherror        : integer;
     taste             : char;
     i                 : Word;
     name              : string;
     pio_use,pio       : boolean;
     control_port,
     port_a,
     port_b,
     port_c            : word;
     zeilenvorschub,
     Grosschrift,
     seitenlaenge,
     formfeed          : byte;
     balken_pkte       : balken_choice;
     copy_right        : string15;
     start_pfad        : string80;
     doc_start         : doc_pointer;
{     regs              : registers;}
     erfolg            : byte;
     dummy_string      : string;

procedure configuration;

var  f                 : text;
     zeile,conf_path,
     help_path         : string80;
     befehl            : char;
     gleich,i          : byte;
     error             : integer;
     zahl              : byte;
     z1,z2             : doc_pointer;

begin
     i:=0;
     if length(start_pfad)=3 then conf_path:=start_pfad+'sps.cfg'
     else conf_path:=start_pfad+'/sps.cfg';
     assign(f,conf_path);
     {$I-} reset(f); {$I+}
     if ioresult <> 0 then begin
        writeln (#7,'ERROR reading config file');
        writeln ('Configfile not found');
        halt(1);
     end
     else begin
        while not eof(f) do begin
           readln(f,zeile);
           inc(i);
           befehl:=upcase(zeile[1]);
           dummy_string:=copy(zeile,2,length(zeile));
           val(dummy_string,zahl);
           case befehl of
                'C'  : begin
                          if (error > 0) or (zahl=1023) then pio:=false
                          else control_port   :=zahl;
                       end;
                'E'  : if error = 0 then port_a :=zahl;
                'A'  : if error = 0 then port_b :=zahl;
                'Z'  : if error = 0 then port_c :=zahl;
                'V'  : zeilenvorschub :=zahl;
                'G'  : grosschrift    :=zahl;
                'L'  : seitenlaenge   :=zahl;
                'F'  : formfeed       :=zahl;

           else begin
                window(1,1,25,80);
                textbackground(black);
                textcolor(lightgray);
                clrscr;
                writeln(#7,'Error reading Config file');
                writeln('in line ',i,' unknown command');
                halt(1);
             end;
           end;
        end;
        close (f);
     end;
     if length(start_pfad)=3 then conf_path:=start_pfad+'sps.doc'
     else conf_path:=start_pfad+'/sps.doc';
     assign(f,conf_path);
     {$I-} reset(f); {$I+}
     if ioresult <> 0 then begin
        writeln (#7,'Error reading  DOCfiles');
        writeln ('DOCfile not found');
        halt(1);
     end
     else begin
        new(z1);
        doc_start:=z1;
        readln(f,z1^.zeil);
        z1^.vor:=nil;
        while not eof(f) do begin
           new(z2);
           z1^.nach:=z2;
           readln(f,z2^.zeil);
           z2^.vor:=z1;
           z1:=z2;
        end;
        z1^.nach:=nil;
        close(f);
     end;
end;

{$i ./hardcopy.pas}
{$i ./fileserv.pas}
{$i ./edit.pas}
{$i ./run_awl.pas}
{$i ./info.pas}

            
procedure menu;                    { Hauptmenu }

var   Auswahl      : char;

begin
     balken_pkte[1]:='File';
     balken_pkte[2]:='Edit';
     balken_pkte[3]:='Run';
     balken_pkte[4]:='Docu';
     balken_pkte[5]:='Quit';
     copy_right:='(c) H. Eilers';
     repeat
           BackGround:=lightgray;ForeGround:=blue;
	   Highlighted:=red;
           balken(balken_pkte,5,copy_right,auswahl);
           case Auswahl of
               'F' : fileservice;
               'E' : edit;
               'R' : run_awl;
               'D' : info(doc_start);
               'Q' : ;
           else begin
                  sound(220); delay(200); nosound;
              end;
           end;
     until auswahl='Q';
     if sicher then begin
        save_screen;
        textbackground(red);textcolor(lightgray);
        my_wwindow(28,11,64,15,'','',true);
        writeln ('Attention, AWL not saved ');
        write ('Save ? (y/n)');
        cursor_on;
        repeat
           repeat

           until keypressed;
           taste:=upcase(readkey);
        until (taste='Y') or (taste='N');
        cursor_off;
        restore_screen;
        if taste='Y' then menu;
     end;
end;                               {**** ENDE  HAUPTMENU **** }

begin                              { SPS_SIMULATION }
     textcolor(lightgray);textbackground(black); clrscr;
{     if mem[0:$4fe]=1 then}         { wird PIO schon benutzt ? }
{        pio_use:=true}
{     else begin}
{        mem[0:$4fe]:=1;}
        pio_use:=false;
{     end;}
     {$ifdef Demo}
        TextBackGround(lightgray);TextColor(Blue);
        my_wwindow(5,2,77,23,'INFO','Enter',true);
        writeln('    Demo der SPS Software (c) by Hartmut Eilers');
        writeln;
        writeln;
        writeln('    Diese Demo ist in Ihrem Funktionsumfang eingeschränkt.');
        writeln('    Folgende Funktionen sind in der Demo nicht möglich:');
        writeln('         - echte I/O Steuerung mit einer PIO');
        writeln('         - Steuerung im Hintergrund mit RUN_SPS');
        writeln;
        writeln(' Auf Grund dieser Einschränkungen ist es also nicht möglich echte');
        writeln(' Steuerungen aufzubauen. Sie können sich jedoch in die');
        writeln(' Programmierung von SPS -Anlagen einarbeiten und Ihre selbst-');
        writeln(' entwickelten SPS - Programme in der Simulation austesten.');
        writeln(' Die Einschränkungen liegen im Moment noch an der Portierung');
        writeln(' von DOS nach Linux...; Echte Steuerungen sind für die nächste');
        writeln(' Beta Version eingeplant! Viel Spass .....');
        write('              ------ Weiter mit ENTER -------');
        readln;
        window (1,1,80,25);
        TextColor(lightgray);TextBackground(Black);
     {$endif}
     {$ifdef Handler}
        cursor_off;
        TextBackGround(lightgray);TextColor(RED);
        my_wwindow(28,9,60,15,'','ENTER',true);
        writeln ('  Testversion für Händler');
        writeln ('  Weitergabe oder Verkauf an');
        Writeln ('  Dritte ist verboten');
        readln;
        window(1,1,80,25);
        TextBackGround(black);TextColor(lightgray);
        clrscr;
        Cursor_on;
     {$endif}
     cursor_off;
     clrscr;
     textbackground(lightgray);textcolor(blue);
     my_wwindow(25,11,62,15,'','',true);
     writeln(' SPS SIMULATOR ',version);
     write(' (c) ',datum,' by H. Eilers ');
{     regs.ax:=$160a;}          { check for windows }
{     intr($2f,regs);}
{     if regs.ax = 0 then begin}
{        textbackground(lightgray);textcolor(red);}
{        wwindow(10,17,71,21,'[ACHTUNG]','[ENTER]',true);}
{        writeln(' Der Simulator wird unter Windows ausgefuehrt.  Beachten ');}
{        write(' Sie die Hinweise in der Dokumentation zum Thema WINDOWS !');}
{        readln;}
{        textbackground(black);textcolor(lightgray);}
{        window(10,17,71,21);}
{        clrscr;}
{     end;}
     getdir(0,start_pfad);
     start_pfad:='.';
{     erfolg:=delstring('PROMPT=');		}
{     erfolg:=addstring('PROMPT= [SPS] $P$G');	}
     configuration;
     directvideo:=false;
{     graphdriver:=ord(graph_mode);}
     programm:=false;
     sicher:=false;
     name:='NONAME.SPS';
     if pio and (not(pio_use)) then port[control_port]:=$99;  { ports programmieren    }
     delay(4000);
     window(10,11,71,21);
     textbackground(black);textcolor(black);clrscr;
     menu;
{     closegraph;}
     window (1,1,80,25);
     textcolor(white);textbackground(black); clrscr;
     cursor_on;
     normvideo;
{     if not(pio_use) then mem[0:$4fe]:=0;}

end. 









