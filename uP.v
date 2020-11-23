//Proyecto uP - Jose Vanegas - 19125
module uP(input clock, reset, input[3:0] pushbuttons, output [11:0] PC, address_RAM, output [7:0] program_byte,
    output [3:0] instr, oprnd, data_bus, FF_out, accu, output phase, c_flag, z_flag);

// En esta parte se definen los cables que se usaran para conectar las salidas del decode------------------------
wire incPC;
wire loadPC;
wire loadA;
wire loadFlags;
wire [2:0] s;
wire csRAM;
wire weRAM;
wire oeALU;
wire oeIN;
wire oeOprnd;
wire loadOut;


wire [6:0] entradaDec;
assign entradaDec = {instr,c_flag,z_flag,phase};
wire [12:0] salidaDec;
//decode
Decode dec(entradaDec, salidaDec);
// asignar valores del decode
assign incPC = salidaDec[12];
assign loadPC = salidaDec[11];
assign loadA = salidaDec[10];
assign loadFlags = salidaDec[9];
assign s = salidaDec[8:6];
assign csRAM = salidaDec[5];
assign weRAM = salidaDec[4];
assign oeALU = salidaDec[3];
assign oeIN = salidaDec[2];
assign oeOprnd = salidaDec[1];
assign loadOut = salidaDec[0];
//------------- Control del programa----------------
Contador12bits programCounter(loadPC, incPC, clock, reset, address_RAM, PC);
Memory programROM(PC, program_byte);
FFD4b fetchOprn(program_byte[3:0],~phase, reset, clock, oprnd);
FFD4b fetchints(program_byte[7:4],~phase, reset, clock, instr);
// -----------------Manejo de datos ----------------
wire c;
wire z;
assign address_RAM = {oprnd,program_byte};
RAM memoriaRAM(address_RAM,csRAM,weRAM,data_bus);
FlipFlopT pase(1'b1, reset, clock,phase);
FFD1b banderas1( c,loadFlags,reset, clock, c_flag);
FFD1b banderas2( z,loadFlags,reset, clock, z_flag);


wire[3:0] oALU;

Tris bufOp(oprnd,oeOprnd,data_bus);
Tris bufALu(oALU,oeALU,data_bus);
Tris bufIn(pushbuttons,oeIN,data_bus);
//--------------Alu----------------------------
FFD4b acumulador(oALU,loadA,reset,clock,accu);

ALU aritmetica(accu, data_bus,s,oALU,c,z);

// -----------Salida---------------------------
FFD4b sali(data_bus,loadOut,reset,clock,FF_out);

endmodule
