Unit lp_io_access;

{ diese Unit stellt Funktionen zum I/O Access auf den LPT Port zur Verfügung 	}
{ Attention: its just a raw hack - not finished					}

INTERFACE

function read_ports(io_port:longint):byte;
function write_ports(io_port:longint;byte_value:byte):byte;


implementation

const IOFile='/dev/port';

function read_ports(io_port:longint):byte;
var byte_value : byte;
    F     : file;
begin
	assign(F,IOFile);
	reset(F,Sizeof(byte_value));
	seek(F,io_port);
	blockread(F,byte_value,1);
	close(F);
	{ invert the MSB  }
	if byte_value >= 128 then 
		byte_value:=byte_value - 128
	else 	
		byte_value:=byte_value + 128;		
	read_ports:=byte_value;
end;
	
function write_ports(io_port:longint;byte_value:byte):byte;	
var F     : file of byte;
begin
	assign(F,IOFile);
	reset(F,Sizeof(byte_value));
	seek(F,io_port);
	blockwrite(F,byte_value,1);
	close(F);
	write_ports:=byte_value;
end;



begin

end.
