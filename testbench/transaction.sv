class transaction;
  // Campos de una instrucción tipo R
  rand logic [6:0] opcode;
  rand logic [4:0] rd;
  rand logic [2:0] funct3;
  rand logic [4:0] rs1;
  rand logic [4:0] rs2;
  rand logic [6:0] funct7;

  // La instrucción ensamblada de 32 bits
  logic [31:0] instr;

  // Regla para forzar que sea una suma válida
  constraint c_add_inst {
    opcode == 7'b0110011; // Opcode para suma (ADD)
    funct3 == 3'b000;     
    funct7 == 7'b0000000; 
    rd != 5'd0;           // x0 está cableado a cero, no se debe sobreescribir
  }

  // Se ejecuta automáticamente después del randomize() para ensamblar la palabra
  function void post_randomize();
    instr = {funct7, rs2, rs1, funct3, rd, opcode};
  endfunction
endclass