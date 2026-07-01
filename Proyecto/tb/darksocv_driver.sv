class darksocv_driver extends uvm_driver #(darksocv_item);

    `uvm_component_utils(darksocv_driver)

    virtual ifc_darksocv vif;
    int fd;
    int item_count;
    int mem_file_words;

    function new(string name = "darksocv_driver", uvm_component parent = null);
        super.new(name, parent);
        mem_file_words = 1024;
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if (!uvm_config_db #(virtual ifc_darksocv)::get(this, "", "vif", vif)) begin
            `uvm_fatal("DRV", "No se pudo obtener vif desde uvm_config_db")
        end
    endfunction

    task open_mem_file();
        fd = $fopen("darksocv.mem", "w");

        if (fd == 0) begin
            `uvm_fatal("DRV", "No se pudo abrir darksocv.mem para escritura")
        end

        item_count = 0;
        `uvm_info("DRV", "Archivo darksocv.mem abierto para escritura", UVM_MEDIUM)
    endtask

    task write_instr(darksocv_item item);
        if (item_count >= 511) begin
            `uvm_fatal("DRV", "Demasiadas instrucciones: no queda espacio para jal final")
        end

        $fdisplay(fd, "%08h", item.instr_word);

        `uvm_info(
            "DRV",
            $sformatf(
                "Escribiendo instruccion %0d: word=0x%08h asm=\"%s\"",
                item.item_index,
                item.instr_word,
                item.asm_text
            ),
            UVM_MEDIUM
        )

        item_count++;
    endtask

    task close_mem_file();
        int i;

        $fdisplay(fd, "%08h", 32'h0000006F);

        for (i = item_count + 1; i < mem_file_words; i = i + 1) begin
            $fdisplay(fd, "%08h", 32'h00000013);
        end

        $fclose(fd);

        `uvm_info(
            "DRV",
            $sformatf("Archivo darksocv.mem cerrado. Instrucciones randomizadas escritas: %0d", item_count),
            UVM_MEDIUM
        )
    endtask

    task apply_reset();
        `uvm_info("DRV", "Aplicando reset externo al DUT", UVM_MEDIUM)

        vif.UART_RXD = 1'b1;
        vif.XRES     = 1'b1;

        repeat (20) @(posedge vif.XCLK);

        vif.XRES = 1'b0;

        `uvm_info("DRV", "Reset externo liberado", UVM_MEDIUM)
    endtask

    virtual task run_phase(uvm_phase phase);
        // El driver genera darksocv.mem antes de liberar reset.
        open_mem_file();

        vif.XRES     = 1'b1;
        vif.UART_RXD = 1'b1;

        forever begin
            seq_item_port.get_next_item(req);
            write_instr(req);

            if (req.is_last) begin
                close_mem_file();
                apply_reset();
                seq_item_port.item_done();
                break;
            end

            seq_item_port.item_done();
        end
    endtask

endclass
