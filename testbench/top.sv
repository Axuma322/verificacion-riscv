module top;
  // 1. Generador de reloj (100 MHz aprox)
  bit clk;
  always #5 clk = ~clk;

  // 2. Generador de reset
  bit res;

  // 3. Instancia de la interfaz
  dut_if _if();

  // Conexión de señales de control al bus
  assign _if.clk = clk;
  assign _if.res = res;

  // 4. Instancia del DUT (Sistema Completo)
  darksocv dut (
    .XCLK(clk),
    .XRES(res),
    .UART_RXD(_if.uart_rxd),
    .UART_TXD(_if.uart_txd),
    .LED(_if.led),
    .DEBUG(_if.debug)
  );

  // 5. Asignaciones jerárquicas (Conexión a señales internas)
  assign _if.idata = dut.core0.IDATA;
  assign _if.iaddr = dut.core0.IADDR;
  assign _if.datai = dut.core0.DATAI;
  assign _if.datao = dut.core0.DATAO;
  assign _if.daddr = dut.core0.DADDR;
  assign _if.wr    = dut.core0.WR;
  assign _if.rd    = dut.core0.RD;

  // 6. Bloque inicial de simulación
  initial begin
    $dumpfile("dump.vcd"); // Nombre estándar usado por EPWave en EDAPlayground
    $dumpvars(0, top);

    clk = 0;
    res = 1; 
    #25 res = 0; // Liberar reset después de unos ciclos
  end

  testcase test_inst(_if);

endmodule