class monitor;

    virtual ifc_darksocv vif;
    scoreboard sb;

    localparam logic [31:0] EXPECT_MEM0  = 32'h00100093;
    localparam logic [31:0] EXPECT_MEM19 = 32'h0000006F;

    function new(virtual ifc_darksocv vif, scoreboard sb);
        this.vif = vif;
        this.sb  = sb;
    endfunction

    task print_probe(input string tag);
        $display("Monitor[%s]: XRES=%0b CLK=%0b RES=%0b HLT=%0b IADDR=%08h IDATA=%08h LED=%h DEBUG=%h",
                 tag, vif.XRES, vif.CLK, vif.RES, vif.HLT, vif.IADDR, vif.IDATA, vif.LED, vif.DEBUG);
        $display("Monitor[%s]: MEM[0]=%08h MEM[15]=%08h MEM[16]=%08h MEM[17]=%08h MEM[18]=%08h MEM[19]=%08h",
                 tag, vif.MEM_WORD[0], vif.MEM_WORD[15], vif.MEM_WORD[16],
                 vif.MEM_WORD[17], vif.MEM_WORD[18], vif.MEM_WORD[19]);
    endtask

    task run();
        logic [31:0] observed_regs [0:15];
        int post_reset_cycles;

        $display("Monitor: esperando que el driver libere XRES.");

        wait (vif.XRES === 1'b0);
        repeat (5) @(posedge vif.XCLK);

        print_probe("post-XRES");

        if (vif.MEM_WORD[0] !== EXPECT_MEM0 || vif.MEM_WORD[19] !== EXPECT_MEM19) begin
            $display("Monitor: ADVERTENCIA: el contenido leido en dut.MEM no coincide con el programa esperado.");
            $display("Monitor: revise que darksocv.mem este cargado como archivo independiente antes de correr la simulacion.");
        end

        post_reset_cycles = 0;

        // Espera acotada usando XCLK, no CLK, para evitar quedarse bloqueado si el PLL/reloj interno no avanza.
        while (post_reset_cycles < 5000) begin
            @(posedge vif.XCLK);
            post_reset_cycles++;

            if ((post_reset_cycles % 500) == 0) begin
                print_probe($sformatf("cycle_%0d", post_reset_cycles));
            end
        end

        print_probe("final");
        $display("Monitor: tomando snapshot final de REGS[0:15].");

        for (int i = 0; i < 16; i++) begin
            observed_regs[i] = vif.REGS[i];
        end

        sb.check_regs(observed_regs);
    endtask

endclass
