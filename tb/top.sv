module top;

    logic XCLK;

    initial begin
        XCLK = 1'b0;
        forever #5 XCLK = ~XCLK;
    end

    ifc_darksocv ifc_darksocv_obj(XCLK);

    darksocv dut (
        .XCLK     (XCLK),
        .XRES     (ifc_darksocv_obj.XRES),
        .UART_RXD (ifc_darksocv_obj.UART_RXD),
        .UART_TXD (ifc_darksocv_obj.UART_TXD),
        .LED      (ifc_darksocv_obj.LED),
        .DEBUG    (ifc_darksocv_obj.DEBUG)
    );

    always_comb begin
        ifc_darksocv_obj.CLK   = dut.CLK;
        ifc_darksocv_obj.RES   = dut.RES;
        ifc_darksocv_obj.HLT   = dut.HLT;
        ifc_darksocv_obj.IADDR = dut.IADDR;
        ifc_darksocv_obj.DADDR = dut.DADDR;
        ifc_darksocv_obj.IDATA = dut.IDATA;
        ifc_darksocv_obj.DATAO = dut.DATAO;
        ifc_darksocv_obj.DATAI = dut.DATAI;
        ifc_darksocv_obj.WR    = dut.WR;
        ifc_darksocv_obj.RD    = dut.RD;
        ifc_darksocv_obj.BE    = dut.BE;

        for (int i = 0; i < 16; i++) begin
            ifc_darksocv_obj.REGS[i] = dut.core0.REGS[i];
        end

        for (int i = 0; i < 20; i++) begin
            ifc_darksocv_obj.MEM_WORD[i] = dut.MEM[i];
        end
    end

    testcase test_obj;

    initial begin
        ifc_darksocv_obj.XRES     = 1'b1;
        ifc_darksocv_obj.UART_RXD = 1'b1;

        $dumpfile("dump.vcd");
        $dumpvars(0, top);

        #1;
        $display("Top: lectura inicial de memoria cargada por el RTL.");
        $display("Top: MEM[0]=%08h MEM[1]=%08h MEM[15]=%08h MEM[19]=%08h",
                 dut.MEM[0], dut.MEM[1], dut.MEM[15], dut.MEM[19]);

        test_obj = new(ifc_darksocv_obj);
        test_obj.run();
    end

endmodule
