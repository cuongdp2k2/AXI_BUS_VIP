// UVM libs here =================================================================================================
`include "package.sv"
// base test libs here =========================================================================================
`include "base_test.sv"
// interface libs here ==========================================================================================
`include "interface.sv"
// DUT libs
`include "dut.sv"

module top;
    // delare local parameters
    bit clk   ;
    bit reset ;

    // generate clock here
    always #2 clk = ~clk ;

    // Interface connection
    intf vif(clk,reset) ;
    // DUT connection
    dut DUT(
        .clk     (vif.clk     ) ,
        .reset   (vif.reset   ) ,
    //AW channel signal
        .aw_addr (vif.aw_addr ) ,
        .aw_len  (vif.aw_len  ) ,
        .aw_size (vif.aw_size ) ,
        .aw_burst(vif.aw_burst) ,
        .aw_valid(vif.aw_valid) ,
        .aw_ready(vif.aw_ready) ,
    //W channel signal
        .w_data  (vif.w_data  ) ,
        .w_strb  (vif.w_strb  ) ,
        .w_last  (vif.w_last  ) ,
        .w_valid (vif.w_valid ) ,
        .w_ready (vif.w_ready ) ,
    //B channel signal 
        .b_valid (vif.b_valid ) ,
        .b_ready (vif.b_ready ) ,
        .b_resp  (vif.b_resp  ) ,
    //AR channel signal
        .ar_addr (vif.ar_addr ) ,
        .ar_len  (vif.ar_len  ) ,
        .ar_size (vif.ar_size ) ,
        .ar_burst(vif.ar_burst) ,
        .ar_valid(vif.ar_valid) ,
        .ar_ready(vif.ar_ready) ,
    //R channel signal
        .r_data  (vif.r_data  ) ,
        .r_last  (vif.r_last  ) ,
        .r_valid (vif.r_valid ) ,
        .r_ready (vif.r_ready ) ,
        .r_resp  (vif.r_resp  ) 
    );
    // checker
    checker_aw AW_Checker (
        .clk     (vif.clk     ) ,
        .reset   (vif.reset   ) ,

        .aw_addr (vif.aw_addr ) ,
        .aw_len  (vif.aw_len  ) ,
        .aw_size (vif.aw_size ) ,
        .aw_burst(vif.aw_burst) ,
        .aw_valid(vif.aw_valid) ,
        .aw_ready(vif.aw_ready) 
    ) ;

    checker_w W_Checker (
        .clk     (vif.clk     ) ,
        .reset   (vif.reset   ) ,
        .w_data  (vif.w_data  ) ,
        .w_strb  (vif.w_strb  ) ,
        .w_last  (vif.w_last  ) ,
        .w_valid (vif.w_valid ) ,
        .w_ready (vif.w_ready ) 
    ) ;
    
    // init 
    initial begin
        clk = 0 ;
        reset = 1 ;
        #15; reset = 0 ;
    end

    // data base + dump file
    initial begin
        // set interface in config_db
        uvm_config_db#(virtual intf)::set(uvm_root::get(), "*", "vif", vif);
        // Dump waves
        $dumpfile("dump.vcd");
        $dumpvars(0);
    end

    // run environment
    initial begin
        run_test("base_test");
    end
endmodule