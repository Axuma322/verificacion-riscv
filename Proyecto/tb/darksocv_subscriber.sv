class darksocv_subscriber extends uvm_subscriber #(darksocv_item);

    `uvm_component_utils(darksocv_subscriber)

    darksocv_item item;

    // Variables espejo usadas por el covergroup.
    instr_type_e cov_instr_type;
    alu_op_e     cov_op;
    logic [3:0]  cov_rd;
    logic [3:0]  cov_rs1;
    logic [3:0]  cov_rs2;
    logic [31:0] cov_imm;
    logic [31:0] cov_observed_value;
    bit          cov_rd_is_zero;
    bit          cov_rs1_is_zero;
    bit          cov_result_is_zero;

    covergroup instr_cg;
        option.per_instance = 1;

        cp_instr_type: coverpoint cov_instr_type {
            bins r_type      = {INSTR_R};
            bins i_type      = {INSTR_I};
            bins u_type      = {INSTR_U};
            bins load_type   = {INSTR_LOAD};
            bins store_type  = {INSTR_STORE};
            bins branch_type = {INSTR_BRANCH};
            bins jump_type   = {INSTR_JUMP};
        }

        cp_op: coverpoint cov_op {
            bins r_ops[]      = {OP_ADD, OP_SUB, OP_SLL, OP_SLT, OP_SLTU, OP_XOR, OP_SRL, OP_SRA, OP_OR, OP_AND};
            bins i_ops[]      = {OP_ADDI, OP_SLTI, OP_SLTIU, OP_XORI, OP_ORI, OP_ANDI, OP_SLLI, OP_SRLI, OP_SRAI};
            bins u_ops[]      = {OP_LUI, OP_AUIPC};
            bins load_ops[]   = {OP_LW};
            bins store_ops[]  = {OP_SW};
            bins branch_ops[] = {OP_BEQ, OP_BNE, OP_BLT, OP_BGE, OP_BLTU, OP_BGEU};
            bins jump_ops[]   = {OP_JAL, OP_JALR};
        }

        cp_rd: coverpoint cov_rd {
            bins x0     = {4'd0};
            bins bajos  = {[4'd1:4'd7]};
            bins altos  = {[4'd8:4'd15]};
        }

        cp_rs1: coverpoint cov_rs1 {
            bins x0     = {4'd0};
            bins bajos  = {[4'd1:4'd7]};
            bins altos  = {[4'd8:4'd15]};
        }

        cp_rs2: coverpoint cov_rs2 {
            bins x0     = {4'd0};
            bins bajos  = {[4'd1:4'd7]};
            bins altos  = {[4'd8:4'd15]};
        }

        cp_rd_is_zero: coverpoint cov_rd_is_zero {
            bins si = {1'b1};
            bins no = {1'b0};
        }

        cp_rs1_is_zero: coverpoint cov_rs1_is_zero {
            bins si = {1'b1};
            bins no = {1'b0};
        }

        cp_imm_range: coverpoint cov_imm {
            bins cero  = {32'd0};
            bins bajo  = {[32'd1:32'd15]};
            bins medio = {[32'd16:32'd255]};
            bins alto  = {[32'd256:32'd4095]};
        }

        cp_result_is_zero: coverpoint cov_result_is_zero {
            bins si = {1'b1};
            bins no = {1'b0};
        }

        cross_type_op: cross cp_instr_type, cp_op {
            ignore_bins r_invalid      = binsof(cp_instr_type.r_type)      && !binsof(cp_op.r_ops);
            ignore_bins i_invalid      = binsof(cp_instr_type.i_type)      && !binsof(cp_op.i_ops);
            ignore_bins u_invalid      = binsof(cp_instr_type.u_type)      && !binsof(cp_op.u_ops);
            ignore_bins load_invalid   = binsof(cp_instr_type.load_type)   && !binsof(cp_op.load_ops);
            ignore_bins store_invalid  = binsof(cp_instr_type.store_type)  && !binsof(cp_op.store_ops);
            ignore_bins branch_invalid = binsof(cp_instr_type.branch_type) && !binsof(cp_op.branch_ops);
            ignore_bins jump_invalid   = binsof(cp_instr_type.jump_type)   && !binsof(cp_op.jump_ops);
        }
        cross_type_rd: cross cp_instr_type, cp_rd;
        cross_op_result_zero: cross cp_op, cp_result_is_zero;
    endgroup

    function new(string name = "darksocv_subscriber", uvm_component parent = null);
        super.new(name, parent);
        instr_cg = new();
    endfunction

    virtual function void write(darksocv_item t);
        item = t;

        cov_instr_type     = item.instr_type;
        cov_op             = item.op;
        cov_rd             = item.rd;
        cov_rs1            = item.rs1;
        cov_rs2            = item.rs2;
        cov_imm            = item.imm;
        cov_observed_value = item.observed_value;
        cov_rd_is_zero     = (item.rd == 4'd0);
        cov_rs1_is_zero    = (item.rs1 == 4'd0);
        cov_result_is_zero = (item.observed_value == 32'h00000000);

        instr_cg.sample();

        `uvm_info(
            "SUB",
            $sformatf(
                "Cobertura sampleada: instr=%s cobertura=%0.2f%%",
                item.asm_text,
                instr_cg.get_inst_coverage()
            ),
            UVM_MEDIUM
        )
    endfunction

    virtual function void report_phase(uvm_phase phase);
        super.report_phase(phase);

        `uvm_info(
            "SUB",
            $sformatf("Cobertura final subscriber = %0.2f%%", instr_cg.get_inst_coverage()),
            UVM_MEDIUM
        )
    endfunction

endclass
