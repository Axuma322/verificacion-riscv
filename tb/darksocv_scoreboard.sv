`uvm_analysis_imp_decl(_mon)

class darksocv_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(darksocv_scoreboard)

    uvm_analysis_imp_mon #(darksocv_item, darksocv_scoreboard) mon_imp;

    logic [31:0] ref_regs [0:15];

    int instr_count;
    int checks_executed;
    int checks_passed;
    int checks_failed;

    function new(string name = "darksocv_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        mon_imp = new("mon_imp", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        reset_model();
    endfunction

    function void reset_model();
        for (int i = 0; i < 16; i++) begin
            ref_regs[i] = 32'h00000000;
        end

        instr_count     = 0;
        checks_executed = 0;
        checks_passed   = 0;
        checks_failed   = 0;
    endfunction

    function logic [31:0] calc_result(darksocv_item item);
        case (item.op)
            OP_ADD: begin
                return ref_regs[item.rs1] + ref_regs[item.rs2];
            end

            OP_SUB: begin
                return ref_regs[item.rs1] - ref_regs[item.rs2];
            end

            OP_AND: begin
                return ref_regs[item.rs1] & ref_regs[item.rs2];
            end

            OP_OR: begin
                return ref_regs[item.rs1] | ref_regs[item.rs2];
            end

            OP_XOR: begin
                return ref_regs[item.rs1] ^ ref_regs[item.rs2];
            end

            OP_ADDI: begin
                return ref_regs[item.rs1] + item.imm;
            end

            OP_LUI: begin
                return {item.imm[19:0], 12'h000};
            end

            default: begin
                return 32'h00000000;
            end
        endcase
    endfunction

    function void write_mon(darksocv_item item);
        logic [31:0] expected;

        `uvm_info("SCB", $sformatf("Instruccion recibida: %s", item.convert2string()), UVM_MEDIUM)

        expected = calc_result(item);
        item.expected_value = expected;

        `uvm_info(
            "SCB",
            $sformatf(
                "Valor teorico calculado: instr=%s rd=x%0d expected=0x%08h",
                item.asm_text,
                item.rd,
                expected
            ),
            UVM_MEDIUM
        )

        if (item.rd != 0) begin
            ref_regs[item.rd] = expected;
        end

        ref_regs[0] = 32'h00000000;
        instr_count++;

        if (item.has_final_snapshot) begin
            compare_final_snapshot(item);
            print_summary();
        end
    endfunction

    function void compare_final_snapshot(darksocv_item item);
        for (int r = 0; r < 16; r++) begin
            checks_executed++;

            if (ref_regs[r] === item.final_regs[r]) begin
                checks_passed++;

                `uvm_info(
                    "SCB",
                    $sformatf(
                        "PASS x%0d: teorico=0x%08h experimental=0x%08h",
                        r,
                        ref_regs[r],
                        item.final_regs[r]
                    ),
                    UVM_MEDIUM
                )
            end
            else begin
                checks_failed++;

                `uvm_error(
                    "SCB",
                    $sformatf(
                        "FAIL x%0d: teorico=0x%08h experimental=0x%08h",
                        r,
                        ref_regs[r],
                        item.final_regs[r]
                    )
                )
            end
        end
    endfunction

    function void print_summary();
        `uvm_info(
            "SCB",
            $sformatf(
                "Resumen: instrucciones=%0d checks=%0d correctos=%0d fallidos=%0d",
                instr_count,
                checks_executed,
                checks_passed,
                checks_failed
            ),
            UVM_MEDIUM
        )

        if ((checks_executed == 16) && (checks_failed == 0)) begin
            `uvm_info("SCB", "Resultado final: PASS", UVM_MEDIUM)
        end
        else begin
            `uvm_error("SCB", "Resultado final: FAIL")
        end
    endfunction

endclass
