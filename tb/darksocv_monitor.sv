class darksocv_monitor extends uvm_monitor;

    `uvm_component_utils(darksocv_monitor)

    virtual ifc_darksocv vif;
    uvm_analysis_port #(darksocv_item) ap;

    function new(string name = "darksocv_monitor", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(virtual ifc_darksocv)::get(this, "", "vif", vif)) begin
            `uvm_fatal("MON", "No se pudo obtener vif desde uvm_config_db")
        end
    endfunction

    function bit decode_instr(input logic [31:0] instr, ref darksocv_item item);
        logic [6:0] opcode;
        logic [6:0] funct7;
        logic [2:0] funct3;
        logic [4:0] rd5;
        logic [4:0] rs1_5;
        logic [4:0] rs2_5;

        opcode = instr[6:0];
        rd5    = instr[11:7];
        funct3 = instr[14:12];
        rs1_5  = instr[19:15];
        rs2_5  = instr[24:20];
        funct7 = instr[31:25];

        item.instr_word = instr;
        item.imm        = 32'h00000000;
        item.rs1        = 4'h0;
        item.rs2        = 4'h0;

        case (opcode)
            7'b0110011: begin
                if (rd5[4] || rs1_5[4] || rs2_5[4]) begin
                    return 0;
                end

                item.instr_type = INSTR_R;
                item.rd         = rd5[3:0];
                item.rs1        = rs1_5[3:0];
                item.rs2        = rs2_5[3:0];

                case ({funct7, funct3})
                    {7'b0000000, 3'b000}: item.op = OP_ADD;
                    {7'b0100000, 3'b000}: item.op = OP_SUB;
                    {7'b0000000, 3'b111}: item.op = OP_AND;
                    {7'b0000000, 3'b110}: item.op = OP_OR;
                    {7'b0000000, 3'b100}: item.op = OP_XOR;
                    default: return 0;
                endcase
            end

            7'b0010011: begin
                if (funct3 != 3'b000 || rd5[4] || rs1_5[4]) begin
                    return 0;
                end

                item.instr_type = INSTR_I;
                item.op         = OP_ADDI;
                item.rd         = rd5[3:0];
                item.rs1        = rs1_5[3:0];
                item.rs2        = 4'h0;
                item.imm        = {{20{instr[31]}}, instr[31:20]};
            end

            7'b0110111: begin
                if (rd5[4]) begin
                    return 0;
                end

                item.instr_type = INSTR_U;
                item.op         = OP_LUI;
                item.rd         = rd5[3:0];
                item.rs1        = 4'h0;
                item.rs2        = 4'h0;
                item.imm        = {12'h000, instr[31:12]};
            end

            default: begin
                return 0;
            end
        endcase

        item.update_asm();
        return 1;
    endfunction

    task check_reg_changes(
        input int cycle_id,
        input logic [31:0] curr_iaddr,
        input logic [31:0] curr_instr_word,
        ref logic [31:0] prev_regs [0:15]
    );
        for (int r = 0; r < 16; r++) begin
            if (!$isunknown(vif.REGS[r]) &&
                !$isunknown(prev_regs[r]) &&
                (vif.REGS[r] !== prev_regs[r])) begin

                if (r == 0) begin
                    `uvm_error(
                        "MON_REG",
                        $sformatf(
                            "Cambio inesperado en x0: ciclo=%0d IADDR=0x%08h instr_word=0x%08h x0: 0x%08h -> 0x%08h",
                            cycle_id,
                            curr_iaddr,
                            curr_instr_word,
                            prev_regs[r],
                            vif.REGS[r]
                        )
                    )
                end
                else begin
                    `uvm_info(
                        "MON_REG",
                        $sformatf(
                            "Cambio de registro: ciclo=%0d IADDR=0x%08h instr_word=0x%08h x%0d: 0x%08h -> 0x%08h",
                            cycle_id,
                            curr_iaddr,
                            curr_instr_word,
                            r,
                            prev_regs[r],
                            vif.REGS[r]
                        ),
                        UVM_MEDIUM
                    )
                end
            end

            if (!$isunknown(vif.REGS[r])) begin
                prev_regs[r] = vif.REGS[r];
            end
        end
    endtask

    virtual task run_phase(uvm_phase phase);
        darksocv_item item;
        darksocv_item observed_q[$];

        logic [31:0] final_regs [0:15];
        logic [31:0] prev_regs  [0:15];
        logic [31:0] instr_word;

        bit jal_detected;
        bit seen_iaddr [0:63];

        int word_index;
        int cycle_count;
        int observed_count;
        int reg_cycle;

        cycle_count    = 0;
        observed_count = 0;
        reg_cycle      = 0;
        jal_detected   = 1'b0;

        for (int k = 0; k < 64; k++) begin
            seen_iaddr[k] = 1'b0;
        end

        wait (vif.XRES === 1'b0);

        for (int r = 0; r < 16; r++) begin
            prev_regs[r] = vif.REGS[r];
        end

        while (cycle_count < 5000) begin
            @(posedge vif.XCLK);
            cycle_count++;
            reg_cycle++;

            if (vif.RES !== 1'b0) begin
                continue;
            end

            if ($isunknown(vif.IADDR) || $isunknown(vif.IDATA)) begin
                continue;
            end

            if (vif.IADDR[1:0] != 2'b00) begin
                continue;
            end

            if (vif.IADDR >= 32'd256) begin
                continue;
            end

            word_index = vif.IADDR[7:2];
            instr_word = vif.MEM_WORD[word_index];

            check_reg_changes(reg_cycle, vif.IADDR, instr_word, prev_regs);

            if (seen_iaddr[word_index]) begin
                continue;
            end

            seen_iaddr[word_index] = 1'b1;

            if (instr_word == 32'h0000006F) begin
                jal_detected = 1'b1;
                `uvm_info("MON", "Detectado jal x0, 0 final. Monitor detenido.", UVM_MEDIUM)
                break;
            end

            item = darksocv_item::type_id::create(
                $sformatf("observed_item_%0d", observed_count),
                this
            );

            if (decode_instr(instr_word, item)) begin
                observed_q.push_back(item);

                `uvm_info(
                    "MON",
                    $sformatf(
                        "Instruccion soportada guardada: %s rd=x%0d",
                        item.asm_text,
                        item.rd
                    ),
                    UVM_MEDIUM
                )

                observed_count++;
            end
        end

        if (cycle_count >= 5000) begin
            `uvm_info("MON", "Timeout del monitor alcanzado antes de detectar jal final", UVM_MEDIUM)
        end

        if (observed_q.size() == 0) begin
            `uvm_error("MON", "No se observaron instrucciones soportadas")
        end

        if (jal_detected) begin
            `uvm_info("MON", "Esperando ciclos extra antes del snapshot final de REGS", UVM_MEDIUM)

            repeat (20) begin
                @(posedge vif.XCLK);
                reg_cycle++;

                if (!$isunknown(vif.IADDR) &&
                    (vif.IADDR[1:0] == 2'b00) &&
                    (vif.IADDR < 32'd256)) begin
                    instr_word = vif.MEM_WORD[vif.IADDR[7:2]];
                end
                else begin
                    instr_word = 32'h00000013;
                end

                check_reg_changes(reg_cycle, vif.IADDR, instr_word, prev_regs);
            end
        end

        for (int i = 0; i < 16; i++) begin
            final_regs[i] = vif.REGS[i];
        end

        foreach (observed_q[i]) begin
            observed_q[i].item_index         = i;
            observed_q[i].is_last            = (i == observed_q.size() - 1);
            observed_q[i].has_final_snapshot = 1'b0;
            observed_q[i].observed_value     = final_regs[observed_q[i].rd];

            if (observed_q[i].is_last) begin
                observed_q[i].has_final_snapshot = 1'b1;

                for (int r = 0; r < 16; r++) begin
                    observed_q[i].final_regs[r] = final_regs[r];
                end
            end

            ap.write(observed_q[i]);

            `uvm_info(
                "MON",
                $sformatf(
                    "Item publicado: %s rd=x%0d final_rd_value=0x%08h",
                    observed_q[i].asm_text,
                    observed_q[i].rd,
                    observed_q[i].observed_value
                ),
                UVM_MEDIUM
            )
        end
    endtask

endclass