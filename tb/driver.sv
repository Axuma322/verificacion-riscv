class driver;

    virtual ifc_darksocv vif;
    scoreboard sb;
    stimulus stim;

    function new(virtual ifc_darksocv vif, scoreboard sb);
        this.vif  = vif;
        this.sb   = sb;
        this.stim = new();
    endfunction

    task reset();
        $display("Driver: aplicando reset externo XRES.");

        vif.UART_RXD = 1'b1;
        vif.XRES     = 1'b1;

        repeat (20) @(posedge vif.XCLK);

        $display("Driver: liberando reset externo XRES.");
        vif.XRES = 1'b0;
    endtask

    task configure_scoreboard();
        sb.reset();
        sb.set_expected_count(16);

        for (int i = 0; i < 16; i++) begin
            sb.set_expected_reg(i, stim.get_expected_reg(i));
        end
    endtask

    task generate_mem_file();
        int fd;
        int count;

        count = stim.get_count();

        $display("Driver: generando copia de darksocv.mem desde el testbench.");
        $display("Driver: NOTA: el RTL lee el darksocv.mem existente al arrancar la simulacion.");
        $display("Driver: por eso el archivo darksocv.mem tambien debe estar cargado como archivo del playground.");

        fd = $fopen("darksocv.mem", "w");

        if (fd == 0) begin
            $display("Driver: ERROR, no se pudo abrir darksocv.mem para escritura.");
            $finish;
        end

        for (int i = 0; i < count; i++) begin
            $fdisplay(fd, "%08h", stim.get_instr(i));
            $display("Driver: darksocv.mem[%0d] = %08h    // %s", i, stim.get_instr(i), stim.get_asm(i));
        end

        for (int i = count; i < 64; i++) begin
            $fdisplay(fd, "%08h", 32'h00000013);
        end

        $fclose(fd);
        $display("Driver: darksocv.mem generado. Palabras utiles = %0d", count);
    endtask

    task run();
        configure_scoreboard();
        generate_mem_file();
        reset();
    endtask

endclass
