class monitor;
  virtual dut_if _if;
  scoreboard scb_obj;
  transaction trans;

  function new(virtual dut_if _if, scoreboard scb_obj);
    this._if = _if;
    this.scb_obj = scb_obj;
  endfunction

  task run();
    forever begin
      @(posedge _if.clk);
      // Muestrear idata si no hay reset y la instrucción no es vacía o desconocida
      if (_if.res == 0 && _if.idata !== 32'hxxxxxxxx && _if.idata !== 32'h0) begin
        $display("Monitor: Instruccion extraida del bus IDATA: %h", _if.idata);
        trans = new();
        trans.instr = _if.idata;
        
        // Decodificación de la instrucción extraída del bus físico
        trans.opcode = _if.idata[6:0];
        trans.rd     = _if.idata[11:7];
        trans.funct3 = _if.idata[14:12];
        trans.rs1    = _if.idata[19:15];
        trans.rs2    = _if.idata[24:20];
        trans.funct7 = _if.idata[31:25];

        // Enviar la transacción reconstruida al modelo de referencia
        scb_obj.check_instruction(trans);
      end
    end
  endtask
endclass