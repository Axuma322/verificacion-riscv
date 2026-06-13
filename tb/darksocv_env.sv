class darksocv_env extends uvm_env;

    `uvm_component_utils(darksocv_env)

    darksocv_agent      agent;
    darksocv_scoreboard scoreboard;
    darksocv_subscriber subscriber;

    function new(string name = "darksocv_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    virtual function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        agent      = darksocv_agent::type_id::create("agent", this);
        scoreboard = darksocv_scoreboard::type_id::create("scoreboard", this);
        subscriber = darksocv_subscriber::type_id::create("subscriber", this);

        `uvm_info("ENV", "Componentes del environment darksocv creados", UVM_MEDIUM)
    endfunction

    virtual function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);

        agent.monitor.ap.connect(scoreboard.mon_imp);
        agent.monitor.ap.connect(subscriber.analysis_export);

        `uvm_info("ENV", "Monitor conectado a scoreboard y subscriber", UVM_MEDIUM)
    endfunction

endclass
