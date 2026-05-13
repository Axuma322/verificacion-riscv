interface dut_if;
  // Señales físicas externas
  logic clk;
  logic res;
  logic uart_rxd;
  logic uart_txd;
  logic [3:0] led;
  logic [3:0] debug;

  // Señales internas del procesador (espionaje pasivo)
  logic [31:0] idata; // Bus de datos de instrucción
  logic [31:0] iaddr; // Bus de dirección de instrucción
  logic [31:0] datai; // Bus de datos (entrada al core)
  logic [31:0] datao; // Bus de datos (salida del core)
  logic [31:0] daddr; // Bus de direcciones de datos
  logic wr;           // Habilitación de escritura
  logic rd;           // Habilitación de lectura
endinterface