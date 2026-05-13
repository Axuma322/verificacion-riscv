class driver;
  virtual dut_if _if;
  generator gen_obj;
  int file_id;
  transaction trans;

  function new(virtual dut_if _if, generator gen_obj);
    this._if = _if;
    this.gen_obj = gen_obj;
  endfunction

  // Escribe las instrucciones aleatorias en el disco duro
  task load_memory();
    file_id = $fopen("../RTL/darksocv.mem", "w");
    while (gen_obj.mbx_gen_drv.size() > 0) begin
      trans = gen_obj.mbx_gen_drv.pop_front();
      $fdisplay(file_id, "%h", trans.instr); 
    end
    $fclose(file_id);
    $display("Driver: Memoria darksocv.mem reescrita con exito.");
  endtask

  // Secuencia de arranque del procesador
  task reset_dut();
    _if.res = 1;
    repeat(15) @(posedge _if.clk); // Mantener en reset unos ciclos
    _if.res = 0;
    $display("Driver: Reset liberado, procesador en ejecucion.");
  endtask
endclass