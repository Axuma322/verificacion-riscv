class testcase;

    virtual ifc_darksocv vif;
    env env_obj;

    function new(virtual ifc_darksocv vif);
        this.vif = vif;
    endfunction

    task run();
        env_obj = new(vif);
        env_obj.run();

        fork
            begin
                wait (env_obj.sb.done == 1'b1);
                env_obj.sb.report();
                #20;
                $finish;
            end

            begin
                repeat (12000) @(posedge vif.XCLK);
                $display("Test: TIMEOUT antes de completar los checks.");
                env_obj.sb.report();
                $finish;
            end
        join_any

        disable fork;
    endtask

endclass
