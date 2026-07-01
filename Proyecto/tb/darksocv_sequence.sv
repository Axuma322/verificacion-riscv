class darksocv_sequence extends uvm_sequence #(darksocv_item);

    `uvm_object_utils(darksocv_sequence)

    int num_items = 2;
    int seq_mode = 0;

    localparam int MODE_MIXED  = 0;
    localparam int MODE_R      = 1;
    localparam int MODE_I      = 2;
    localparam int MODE_U      = 3;
    localparam int MODE_LOAD   = 4;
    localparam int MODE_STORE  = 5;
    localparam int MODE_BRANCH = 6;
    localparam int MODE_JUMP   = 7;

    function new(string name = "darksocv_sequence");
        super.new(name);
    endfunction

    task body();
        darksocv_item item;

        for (int i = 0; i < num_items; i++) begin
            item = darksocv_item::type_id::create($sformatf("item_%0d", i));

            start_item(item);

            if (i == 0) begin
                if (!item.randomize() with {
                    instr_type == INSTR_I;
                    op == OP_ADDI;
                    rd inside {[1:15]};
                    rs1 == 0;
                    imm inside {[1:15]};
                }) begin
                    `uvm_fatal("SEQ", "No se pudo randomizar darksocv_item")
                end
            end
            else begin
                case (seq_mode)
                    MODE_R: begin
                        if (!item.randomize() with { instr_type == INSTR_R; }) begin
                            `uvm_fatal("SEQ", "No se pudo randomizar instruccion R")
                        end
                    end

                    MODE_I: begin
                        if (!item.randomize() with { instr_type == INSTR_I; }) begin
                            `uvm_fatal("SEQ", "No se pudo randomizar instruccion I")
                        end
                    end

                    MODE_U: begin
                        if (!item.randomize() with { instr_type == INSTR_U; }) begin
                            `uvm_fatal("SEQ", "No se pudo randomizar instruccion U")
                        end
                    end

                    MODE_LOAD: begin
                        if (!item.randomize() with { instr_type == INSTR_LOAD; }) begin
                            `uvm_fatal("SEQ", "No se pudo randomizar instruccion LOAD")
                        end
                    end

                    MODE_STORE: begin
                        if (!item.randomize() with { instr_type == INSTR_STORE; }) begin
                            `uvm_fatal("SEQ", "No se pudo randomizar instruccion STORE")
                        end
                    end

                    MODE_BRANCH: begin
                        if (!item.randomize() with { instr_type == INSTR_BRANCH; }) begin
                            `uvm_fatal("SEQ", "No se pudo randomizar instruccion BRANCH")
                        end
                    end

                    MODE_JUMP: begin
                        if (!item.randomize() with { instr_type == INSTR_JUMP; }) begin
                            `uvm_fatal("SEQ", "No se pudo randomizar instruccion JUMP")
                        end
                    end

                    default: begin
                        if (!item.randomize()) begin
                            `uvm_fatal("SEQ", "No se pudo randomizar darksocv_item")
                        end
                    end
                endcase
            end

            item.item_index = i;
            item.is_last    = (i == num_items - 1);

            finish_item(item);

            `uvm_info(
                "SEQ",
                $sformatf("Instruccion randomizada %0d: %s", i, item.convert2string()),
                UVM_MEDIUM
            )
        end
    endtask

endclass
