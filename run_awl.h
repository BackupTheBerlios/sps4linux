{ these are the global vars and constants needed to run an awl }

const  power             : array[0..7] of byte =(1,2,4,8,16,32,64,128);

var    extern,grafik,
       hard_copy         : boolean;
       std,min,sec,ms    : integer;
       x                 : word;
       tasten,
       maxaus            : byte;
       watchdog          : word;
       t,z               : array[1..8]  of word;
       marker            : array[1..64] of boolean;
       eingang,ausgang,
       ein_alt,aus_alt,
       timer,zahler,e,a,
       lastakku          : array[1..16] of boolean;
       analog_in	 : array[1..16] of word;     
       zust              : array[1..8]  of boolean;
       zeit              : string[5];
       time1,time2       : real;
