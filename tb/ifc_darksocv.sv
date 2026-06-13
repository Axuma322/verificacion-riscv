interface ifc_darksocv(input logic XCLK);

    // La interfaz agrupa senales externas e internas observadas del DUT.
    // El driver controla senales externas como XRES y UART_RXD.
    logic XRES;
    logic UART_RXD;
    logic UART_TXD;
    logic [3:0] LED;
    logic [3:0] DEBUG;

    // El monitor observa senales internas como IADDR, IDATA, REGS y MEM_WORD.
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

    logic [31:0] REGS [0:15];

    // Programas aleatorios de hasta 64 instrucciones/palabras.
    logic [31:0] MEM_WORD [0:63];

    // Las aserciones revisan propiedades basicas del core durante la simulacion.
    property p_x0_constante;
        @(posedge XCLK) disable iff (XRES || RES || $isunknown(REGS[0]))
            REGS[0] == 32'h00000000;
    endproperty

    property p_iaddr_alineado;
        @(posedge XCLK) disable iff (XRES || RES || $isunknown(IADDR))
            IADDR[1:0] == 2'b00;
    endproperty

    property p_no_rd_wr_simultaneo;
        @(posedge XCLK) disable iff (XRES || RES || $isunknown(RD) || $isunknown(WR))
            !(RD && WR);
    endproperty

    a_x0_constante: assert property (p_x0_constante)
        else $error("ASSERTION FAILED: x0 cambio de cero fuera de reset");

    a_iaddr_alineado: assert property (p_iaddr_alineado)
        else $error("ASSERTION FAILED: IADDR no esta alineado a 4 bytes fuera de reset");

    a_no_rd_wr_simultaneo: assert property (p_no_rd_wr_simultaneo)
        else $error("ASSERTION FAILED: RD y WR activos simultaneamente fuera de reset");

endinterface
