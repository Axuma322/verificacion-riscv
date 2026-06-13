class darksocv_test extends uvm_test;

    `uvm_component_utils(darksocv_test)

    darksocv_env      env;
    darksocv_sequence seq;

    function new(string name = "darksocv_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        env = darksocv_env::type_id::create("env", this);
    endfunction

    virtual task run_phase(uvm_phase phase);
        super.run_phase(phase);

        `uvm_info("TEST", "Inicio de darksocv_test", UVM_MEDIUM)
        phase.raise_objection(this);

        seq = darksocv_sequence::type_id::create("seq");
        seq.num_items = 15;

        `uvm_info("TEST", "Se generaran dos instrucciones aleatorias", UVM_MEDIUM)

        seq.start(env.agent.sequencer);

        repeat (6000) @(posedge env.agent.driver.vif.XCLK);

        `uvm_info("TEST", "Fin de darksocv_test", UVM_MEDIUM)
        phase.drop_objection(this);
    endtask

endclass
