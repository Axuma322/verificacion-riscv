class scoreboard;
  // Memoria simulada del banco de registros (modelo de referencia)
  logic [31:0] sim_reg_file [0:31];

  function new();
    // Inicializar todos los registros en 0 (comportamiento de hardware)
    foreach(sim_reg_file[i]) sim_reg_file[i] = 32'd0;
  endfunction

  // Evalúa matemáticamente la transacción
  task check_instruction(transaction trans);
    logic [31:0] expected_result;
    
    // Verificar si es instrucción tipo R (Suma)
    if (trans.opcode == 7'b0110011 && trans.funct3 == 3'b000 && trans.funct7 == 7'b0000000) begin
      expected_result = sim_reg_file[trans.rs1] + sim_reg_file[trans.rs2];
      
      // Actualizar registro destino si no es x0
      if (trans.rd != 5'd0) sim_reg_file[trans.rd] = expected_result;
      
      $display("Tiempo %0t | Scoreboard [ADD]: rs1(%0d)=%0d + rs2(%0d)=%0d -> Esperado en rd(%0d)=%0d", 
                $time, trans.rs1, sim_reg_file[trans.rs1], 
                trans.rs2, sim_reg_file[trans.rs2], 
                trans.rd, expected_result);
    end
  endtask
endclass