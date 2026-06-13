class darksocv_agent extends uvm_agent;

    `uvm_component_utils(darksocv_agent)

    darksocv_sequencer sequencer;
    darksocv_driver    driver;
    darksocv_monitor   monitor;

    function new(string name = "darksocv_agent", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        sequencer = darksocv_sequencer::type_id::create("sequencer", this);
        driver    = darksocv_driver::type_id::create("driver", this);
        monitor   = darksocv_monitor::type_id::create("monitor", this);

        `uvm_info("AGT", "Componentes del agente darksocv creados", UVM_MEDIUM)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        driver.seq_item_port.connect(sequencer.seq_item_export);

        `uvm_info("AGT", "Driver conectado al sequencer", UVM_MEDIUM)
    endfunction

endclass
