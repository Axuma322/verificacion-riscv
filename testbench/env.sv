class env;
  generator gen_obj;
  driver drv_obj;
  monitor mon_obj;
  scoreboard scb_obj;
  virtual dut_if _if;

  function new(virtual dut_if _if);
    this._if = _if;
    gen_obj = new();
    drv_obj = new(_if, gen_obj);
    scb_obj = new();
    mon_obj = new(_if, scb_obj);
  endfunction

  task run(int cantidad_instrucciones);
    gen_obj.create_instructions(cantidad_instrucciones);
    drv_obj.load_memory();
    
    fork
      mon_obj.run();
    join_none
    
    drv_obj.reset_dut();
    
    repeat(cantidad_instrucciones * 5) @(posedge _if.clk);
    $display("Tiempo %0t | Entorno: Simulacion finalizada.", $time);
    $finish;
  endtask
endclass