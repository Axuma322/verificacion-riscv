class darksocv_sequence extends uvm_sequence #(darksocv_item);

    `uvm_object_utils(darksocv_sequence)

    int num_items = 2;

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
                if (!item.randomize()) begin
                    `uvm_fatal("SEQ", "No se pudo randomizar darksocv_item")
                end
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
