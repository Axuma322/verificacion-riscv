class generator;
  transaction trans;
  transaction mbx_gen_drv[$]; // Cola (queue) que actúa como mailbox hacia el driver

  task create_instructions(int cantidad);
    for (int i = 0; i < cantidad; i++) begin
      trans = new();
      if (!trans.randomize()) $display("Error en aleatorización");
      $display("Generador: Transaccion creada -> rs1:%0d, rs2:%0d, rd:%0d", trans.rs1, trans.rs2, trans.rd);
      mbx_gen_drv.push_back(trans); // Almacena la instrucción en la cola
    end
  endtask
endclass