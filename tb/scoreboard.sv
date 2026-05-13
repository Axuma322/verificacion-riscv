class scoreboard;

    logic [31:0] expected_regs [0:15];
    int checks_expected;
    int checks_executed;
    int checks_passed;
    int checks_failed;
    bit done;

    function new();
        reset();
    endfunction

    function void reset();
        for (int i = 0; i < 16; i++) begin
            expected_regs[i] = 32'd0;
        end

        checks_expected = 0;
        checks_executed = 0;
        checks_passed   = 0;
        checks_failed   = 0;
        done            = 1'b0;
    endfunction

    function void set_expected_reg(input int idx, input logic [31:0] value);
        if (idx >= 0 && idx < 16) begin
            expected_regs[idx] = value;
        end
    endfunction

    function void set_expected_count(input int value);
        checks_expected = value;
    endfunction

    function void check_regs(input logic [31:0] observed_regs [0:15]);
        $display("============================================================");
        $display("Scoreboard: comparando banco de registros RV32E observado.");

        for (int i = 0; i < 16; i++) begin
            checks_executed++;

            if (observed_regs[i] === expected_regs[i]) begin
                checks_passed++;
                $display("Checker: OK    x%0d esperado=%08h observado=%08h", i, expected_regs[i], observed_regs[i]);
            end
            else begin
                checks_failed++;
                $display("Checker: ERROR x%0d esperado=%08h observado=%08h", i, expected_regs[i], observed_regs[i]);
            end
        end

        done = 1'b1;
    endfunction

    function void report();
        $display("============================================================");
        $display("REPORTE FINAL SCOREBOARD");
        $display("Checks esperados : %0d", checks_expected);
        $display("Checks ejecutados: %0d", checks_executed);
        $display("Checks correctos : %0d", checks_passed);
        $display("Checks fallidos  : %0d", checks_failed);

        if (checks_executed == checks_expected && checks_failed == 0) begin
            $display("RESULTADO FINAL: PASS");
        end
        else begin
            $display("RESULTADO FINAL: FAIL");
        end

        $display("============================================================");
    endfunction

endclass
