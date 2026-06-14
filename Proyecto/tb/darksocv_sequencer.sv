class darksocv_sequencer extends uvm_sequencer #(darksocv_item);

    `uvm_component_utils(darksocv_sequencer)

    function new(string name = "darksocv_sequencer", uvm_component parent = null);
        super.new(name, parent);
    endfunction

endclass
