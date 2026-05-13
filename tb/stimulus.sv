class stimulus;

    localparam int MAX_WORDS = 64;

    logic [31:0] instr_mem [0:MAX_WORDS-1];
    string       asm_mem   [0:MAX_WORDS-1];
    logic [31:0] exp_regs  [0:15];
    int          instr_count;

    function new();
        build_default_sequence();
    endfunction

    function void clear();
        instr_count = 0;

        for (int i = 0; i < MAX_WORDS; i++) begin
            instr_mem[i] = 32'h00000013;
            asm_mem[i]   = "nop";
        end

        for (int i = 0; i < 16; i++) begin
            exp_regs[i] = 32'd0;
        end
    endfunction

    function void push_instr(input logic [31:0] instr, input string asm_text);
        if (instr_count < MAX_WORDS) begin
            instr_mem[instr_count] = instr;
            asm_mem[instr_count]   = asm_text;
            instr_count++;
        end
        else begin
            $display("Stimulus: ERROR, MAX_WORDS insuficiente.");
            $finish;
        end
    endfunction

    function void build_default_sequence();
        clear();

        push_instr(32'h00100093, "addi x1,  x0, 1");
        push_instr(32'h00200113, "addi x2,  x0, 2");
        push_instr(32'h00300193, "addi x3,  x0, 3");
        push_instr(32'h00400213, "addi x4,  x0, 4");
        push_instr(32'h00500293, "addi x5,  x0, 5");
        push_instr(32'h00600313, "addi x6,  x0, 6");
        push_instr(32'h00700393, "addi x7,  x0, 7");
        push_instr(32'h00800413, "addi x8,  x0, 8");
        push_instr(32'h00900493, "addi x9,  x0, 9");
        push_instr(32'h00A00513, "addi x10, x0, 10");
        push_instr(32'h00B00593, "addi x11, x0, 11");
        push_instr(32'h00C00613, "addi x12, x0, 12");
        push_instr(32'h00D00693, "addi x13, x0, 13");
        push_instr(32'h00E00713, "addi x14, x0, 14");
        push_instr(32'h00F00793, "addi x15, x0, 15");

        push_instr(32'h003100B3, "add  x1,  x2, x3");
        push_instr(32'h00628233, "add  x4,  x5, x6");
        push_instr(32'h009403B3, "add  x7,  x8, x9");
        push_instr(32'h00208533, "add  x10, x1, x2");

        push_instr(32'h0000006F, "jal  x0,  0");

        // Valores esperados luego de ejecutar las instrucciones anteriores.
        exp_regs[0]  = 32'd0;
        exp_regs[1]  = 32'd5;
        exp_regs[2]  = 32'd2;
        exp_regs[3]  = 32'd3;
        exp_regs[4]  = 32'd11;
        exp_regs[5]  = 32'd5;
        exp_regs[6]  = 32'd6;
        exp_regs[7]  = 32'd17;
        exp_regs[8]  = 32'd8;
        exp_regs[9]  = 32'd9;
        exp_regs[10] = 32'd7;
        exp_regs[11] = 32'd11;
        exp_regs[12] = 32'd12;
        exp_regs[13] = 32'd13;
        exp_regs[14] = 32'd14;
        exp_regs[15] = 32'd15;
    endfunction

    function int get_count();
        return instr_count;
    endfunction

    function logic [31:0] get_instr(input int idx);
        if (idx >= 0 && idx < MAX_WORDS) begin
            return instr_mem[idx];
        end
        return 32'h00000013;
    endfunction

    function string get_asm(input int idx);
        if (idx >= 0 && idx < MAX_WORDS) begin
            return asm_mem[idx];
        end
        return "nop";
    endfunction

    function logic [31:0] get_expected_reg(input int idx);
        if (idx >= 0 && idx < 16) begin
            return exp_regs[idx];
        end
        return 32'h0;
    endfunction

endclass
