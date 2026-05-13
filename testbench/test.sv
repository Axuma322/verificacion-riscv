program testcase(dut_if _if);
  env env_obj;

  initial begin
    env_obj = new(_if);
    env_obj.run(50);
  end
endprogram