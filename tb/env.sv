class env;

    scoreboard sb;
    driver     drv;
    monitor    mon;

    function new(virtual ifc_darksocv vif);
        $display("Env: construyendo scoreboard, driver y monitor.");
        sb  = new();
        drv = new(vif, sb);
        mon = new(vif, sb);
    endfunction

    task run();
        fork
            mon.run();
        join_none

        drv.run();
    endtask

endclass
