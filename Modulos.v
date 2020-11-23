//Proyecto uP - Jose Vanegas - 19125
//-------------------Contador 12 Bits-------------Lab 8 / Ejercicio 1 ------------------
module Contador12bits(input wire  load,enable,clock,reset, input wire [11:0]valueLoad, output reg [11:0] out );
    always @ (posedge clock, posedge reset) begin
        if (load) out <= valueLoad;
        else begin
            if (reset) out <= 0;
            else if(enable) out <= out + 1;    
        end
    end
endmodule
//---------------------Memoria--------------------Lab 8 / Ejercicio 2 -----------------
module Memory(input wire [11:0] address, output wire [7:0] data );

    reg[7:0] memoria[4095:0];

    initial begin
        $readmemh("memory.list",memoria);
    end
    assign  data = memoria[address];
endmodule
//-------------------------Alu-----------------------Lab 8 / Ejercicio 3-------------
module ALU(input wire[3:0] A,B,input [2:0] control , output wire [3:0] out, output wire C, Z );
    reg[4:0] resultado; 
    assign Z = ~(resultado[0] | resultado[1] | resultado[2] | resultado[3]); 
    assign out = resultado[4:0]; 
    assign C = resultado[4] ;
    always @ (A,B,control) begin  
        case(control)
            3'b000: resultado <= A; 
            3'b001: resultado <= A -B;   
            3'b010: resultado <= B; 
            3'b011: resultado <= A + B;
            3'b100: resultado <={1'b0, ~(A&B)}; 
            default: resultado <= 0; 
        endcase
    end
endmodule
//-------Sección de Flip Flops tipo D y tipo T---------Lab 9 / Ejercicio 1-------------
module  FFD1b(input d,enable,reset,clk,output reg q);
    always @(posedge clk, posedge reset) begin //Reset
        if (reset) q = 0; //Si se activa el reset, la salida es 0
        else if (enable) q = d; //si el enable esta en 1, y el reset en 0, D pasa a Q
    end

endmodule

module FFD2b(input wire [1:0] d, input wire enable, reset, clk, output wire [1:0] q );

    FFD1b FF1(d[0], enable, reset,clk, q[0]);
    FFD1b FF2(d[1], enable, reset,clk, q[1]);
    //Flip flop 1 y 2

endmodule

module FFD4b(input [3:0] d, input wire enable, reset, clk, output wire [3:0] q );

    FFD2b FF1(d[1:0], enable, reset,clk, q[1:0]); 
    FFD2b FF2(d[3:2], enable, reset,clk, q[3:2]); 
    //Flip Flops de los bits 0 y 1, 2 y 3
endmodule

//-------Flip Flop tipo T-------------Lab 9 / Ejercicio 2-------------------------------
module  FlipFlopD1b(input d,enable,reset,clk,output reg q); //Mismo FF que en el ejercicio 1
    always @(posedge clk, posedge reset) begin  //Reset asincronico
        if (reset) q = 0; //si el reset esta en 0, la salida se coloca en 0
        else if (enable) q = d; //si reset esta en 0 y ademas esta enable en 1, entonces deja pasar d a q
    end
endmodule

module FlipFlopT(input enable, reset, clk, output wire q );

    FlipFlopD1b FF(~q,enable, reset,clk,q); //Ecuacion obtenida de LogicFriday
endmodule

//---------------Buffer Tri-estado------------Lab 9 / Ejercicio 4 ----------------------
module Tris(input [3:0] in,input enable, output wire [3:0] y );
    assign y[0] = (enable? in[0] : 1'bz );
    assign y[1] = (enable? in[1] : 1'bz );
    assign y[2] = (enable? in[2] : 1'bz );
    assign y[3] = (enable? in[3] : 1'bz );
endmodule

//--------------------------------Rom---------------- Lab 9 / Ejercicio 5 --------------
module Decode(input[6:0] address,output reg [12:0] value );
always @(address) begin
    
    casez(address)
      7'b??????0 : value <= 13'b1000000001000;
      7'b00001?1 : value <= 13'b0100000001000;
      7'b00000?1 : value <= 13'b1000000001000;
      7'b00011?1 : value <= 13'b1000000001000;
      7'b00010?1 : value <= 13'b0100000001000;
      7'b0010??1 : value <= 13'b0001001000010;
      7'b0011??1 : value <= 13'b1001001100000;
      7'b0100??1 : value <= 13'b0011010000010;
      7'b0101??1 : value <= 13'b0011010000100;
      7'b0110??1 : value <= 13'b1011010100000;
      7'b0111??1 : value <= 13'b1000000111000;
      7'b1000?11 : value <= 13'b0100000001000;
      7'b1000?01 : value <= 13'b1000000001000;
      7'b1001?11 : value <= 13'b1000000001000;
      7'b1001?01 : value <= 13'b0100000001000;
      7'b1010??1 : value <= 13'b0011011000010;
      7'b1011??1 : value <= 13'b1011011100000;
      7'b1100??1 : value <= 13'b0100000001000;
      7'b1101??1 : value <= 13'b0000000001001;
      7'b1110??1 : value <= 13'b0011100000010;
      7'b1111??1 : value <= 13'b1011100100000;
      default : value <= 0; 
    endcase
end
endmodule

//---------------------------Fetch------------------------------------------------------
module Fetch(input wire[7:0] D,input wire enabled, reset, clk, output reg[3:0] instr, operand);

    always @ (posedge clk, posedge reset) begin
        
        if (reset) begin  
            instr <= 0;  
            operand <= 0;
        end
        else if (enabled) begin 
            instr <= D[7:4];
            operand <= D[3:0];
        end
    end
endmodule

module ModuloInstruccion(input wire [11:0] valueLoad, input load, reset, enableCounter, enableFetch, clk,
                         output wire [3:0] instr, operand, output wire [7:0] programByte);
    wire [11:0] valueCounter; //valor del contador
    
    Contador12bits programCounter(load ,enableCounter, clk, reset, valueLoad, valueCounter);  
    Memory rom(valueCounter, programByte); 
    Fetch   fetch(programByte, enableFetch, reset, clk, instr , operand); 

endmodule

//------------------------------Modulo de la RAM-----------------------------------------
module RAM(input [11:0] address, input cs, input we, inout[3:0] data );
    reg [3:0] dataOut;
    reg [3:0] ram[4095:0];

    assign data = (cs & ~we) ? dataOut : 4'bzzzz;
// Aqui si CS es 1 & WE es 0 asignamos el valor de dataOut de lo contrario esta en z 
    always @(address, cs, we, data) begin
        if(cs & ~we) dataOut = ram[address];
//si esta seleccionado pero no habilitado para escritura coloca enla salida lo de la direccion 
        else if(cs & we) ram[address] = data;
    end
endmodule