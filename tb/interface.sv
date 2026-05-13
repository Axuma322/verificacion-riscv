interface ifc_darksocv(input logic XCLK);

    logic XRES;

    logic UART_RXD;
    logic UART_TXD;
    logic [3:0] LED;
    logic [3:0] DEBUG;

    // Señales internas observadas desde darksocv.
    logic CLK;
    logic RES;
    logic HLT;
    logic [31:0] IADDR;
    logic [31:0] DADDR;
    logic [31:0] IDATA;
    logic [31:0] DATAO;
    logic [31:0] DATAI;
    logic WR;
    logic RD;
    logic [3:0] BE;

    // Banco de registros observado desde core0.
    logic [31:0] REGS [0:15];

    // Copia de las primeras palabras de MEM, solo para diagnostico/lectura.
    logic [31:0] MEM_WORD [0:19];

endinterface
