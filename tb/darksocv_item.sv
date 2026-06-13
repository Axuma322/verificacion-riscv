typedef enum {INSTR_R, INSTR_I, INSTR_U} instr_type_e;
typedef enum {OP_ADD, OP_SUB, OP_AND, OP_OR, OP_XOR, OP_ADDI, OP_LUI} alu_op_e;

class darksocv_item extends uvm_sequence_item;

    rand instr_type_e instr_type;
    rand alu_op_e     op;
    rand logic [3:0]  rd;
    rand logic [3:0]  rs1;
    rand logic [3:0]  rs2;
    rand logic [31:0] imm;

    logic [31:0] instr_word;
    string       asm_text;
    logic [31:0] observed_value;
    logic [31:0] expected_value;
    int          item_index;
    bit          is_last;
    bit          has_final_snapshot;
    logic [31:0] final_regs [0:15];

    `uvm_object_utils_begin(darksocv_item)
        `uvm_field_enum(instr_type_e, instr_type, UVM_ALL_ON)
        `uvm_field_enum(alu_op_e, op, UVM_ALL_ON)
        `uvm_field_int(rd, UVM_ALL_ON)
        `uvm_field_int(rs1, UVM_ALL_ON)
        `uvm_field_int(rs2, UVM_ALL_ON)
        `uvm_field_int(imm, UVM_ALL_ON)
        `uvm_field_int(instr_word, UVM_ALL_ON)
        `uvm_field_string(asm_text, UVM_ALL_ON)
        `uvm_field_int(observed_value, UVM_ALL_ON)
        `uvm_field_int(expected_value, UVM_ALL_ON)
        `uvm_field_int(item_index, UVM_ALL_ON)
        `uvm_field_int(is_last, UVM_ALL_ON)
        `uvm_field_int(has_final_snapshot, UVM_ALL_ON)
    `uvm_object_utils_end

    constraint c_instr_type_dist {
        instr_type dist {
            INSTR_R := 45,
            INSTR_I := 45,
            INSTR_U := 10
        };
    }

    constraint c_op_by_type {
        (instr_type == INSTR_R) -> (op inside {OP_ADD, OP_SUB, OP_AND, OP_OR, OP_XOR});
        (instr_type == INSTR_I) -> (op == OP_ADDI);
        (instr_type == INSTR_U) -> (op == OP_LUI);
    }

    constraint c_reg_range {
        rd  inside {[0:15]};
        rs1 inside {[0:15]};
        rs2 inside {[0:15]};
    }

    constraint c_imm_range {
        (op == OP_ADDI) -> (imm inside {[0:15]});
        (op == OP_LUI)  -> (imm inside {[0:255]});
        (instr_type == INSTR_R) -> (imm == 0);
    }

    function new(string name = "darksocv_item");
        super.new(name);
    endfunction

    function void post_randomize();
        encode();
        update_asm();
    endfunction

    function void encode();
        logic [4:0] rd5;
        logic [4:0] rs1_5;
        logic [4:0] rs2_5;

        rd5   = {1'b0, rd};
        rs1_5 = {1'b0, rs1};
        rs2_5 = {1'b0, rs2};

        instr_word = 32'h00000013;

        case (op)
            OP_ADD: begin
                instr_word = {7'b0000000, rs2_5, rs1_5, 3'b000, rd5, 7'b0110011};
            end

            OP_SUB: begin
                instr_word = {7'b0100000, rs2_5, rs1_5, 3'b000, rd5, 7'b0110011};
            end

            OP_AND: begin
                instr_word = {7'b0000000, rs2_5, rs1_5, 3'b111, rd5, 7'b0110011};
            end

            OP_OR: begin
                instr_word = {7'b0000000, rs2_5, rs1_5, 3'b110, rd5, 7'b0110011};
            end

            OP_XOR: begin
                instr_word = {7'b0000000, rs2_5, rs1_5, 3'b100, rd5, 7'b0110011};
            end

            OP_ADDI: begin
                instr_word = {imm[11:0], rs1_5, 3'b000, rd5, 7'b0010011};
            end

            OP_LUI: begin
                instr_word = {imm[19:0], rd5, 7'b0110111};
            end

            default: begin
                instr_word = 32'h00000013;
            end
        endcase
    endfunction

    function void update_asm();
        case (op)
            OP_ADD: begin
                asm_text = $sformatf("add x%0d, x%0d, x%0d", rd, rs1, rs2);
            end

            OP_SUB: begin
                asm_text = $sformatf("sub x%0d, x%0d, x%0d", rd, rs1, rs2);
            end

            OP_AND: begin
                asm_text = $sformatf("and x%0d, x%0d, x%0d", rd, rs1, rs2);
            end

            OP_OR: begin
                asm_text = $sformatf("or x%0d, x%0d, x%0d", rd, rs1, rs2);
            end

            OP_XOR: begin
                asm_text = $sformatf("xor x%0d, x%0d, x%0d", rd, rs1, rs2);
            end

            OP_ADDI: begin
                asm_text = $sformatf("addi x%0d, x%0d, %0d", rd, rs1, imm[11:0]);
            end

            OP_LUI: begin
                asm_text = $sformatf("lui x%0d, 0x%0h", rd, imm[19:0]);
            end

            default: begin
                asm_text = "unknown";
            end
        endcase
    endfunction

    function string instr_type_to_string();
        case (instr_type)
            INSTR_R: return "INSTR_R";
            INSTR_I: return "INSTR_I";
            INSTR_U: return "INSTR_U";
            default: return "INSTR_UNKNOWN";
        endcase
    endfunction

    function string op_to_string();
        case (op)
            OP_ADD:  return "OP_ADD";
            OP_SUB:  return "OP_SUB";
            OP_AND:  return "OP_AND";
            OP_OR:   return "OP_OR";
            OP_XOR:  return "OP_XOR";
            OP_ADDI: return "OP_ADDI";
            OP_LUI:  return "OP_LUI";
            default: return "OP_UNKNOWN";
        endcase
    endfunction

    function string convert2string();
        return $sformatf(
            "tipo=%s operacion=%s rd=x%0d rs1=x%0d rs2=x%0d imm=0x%0h item_index=%0d is_last=%0d has_final_snapshot=%0d instr_word=0x%08h asm_text=\"%s\"",
            instr_type_to_string(),
            op_to_string(),
            rd,
            rs1,
            rs2,
            imm,
            item_index,
            is_last,
            has_final_snapshot,
            instr_word,
            asm_text
        );
    endfunction

endclass
