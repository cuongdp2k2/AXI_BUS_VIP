`ifndef DRIVER_SV
`define DRIVER_SV

`include "package.sv"
`include "seq_item.sv"
`include "constraint.sv"
//================================================================================================
//======================================= Base Driver  ===========================================
//================================================================================================
//Driver 
class driver extends uvm_driver#(seq_item);

    //Declare virtual Interface
    virtual intf vif;

    `uvm_component_utils(driver)
    function new(string name = "b_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual intf) :: get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(),"Not set at top level");
    endfunction

    //Reset Interface Before drive
    task reset_phase(uvm_phase phase);

    endtask


    task run_phase(uvm_phase phase);

    endtask

endclass

//================================================================================================
//======================================= Driver Master ==========================================
//================================================================================================
//Driver Master
class m_driver extends uvm_driver#(seq_item);
    virtual intf vif ;
    bit [31:0] temp [];
    `uvm_component_utils(m_driver)
    function new(string name = "m_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual intf) :: get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(),"Not set at top level");
    endfunction

    //Reset Interface Before drive
    task reset_phase(uvm_phase phase);
        phase.raise_objection(this);
        //wait(vif.reset)
        `uvm_info(get_type_name(),"[ DRIVER MASTER ] ----- Reset Started -----", UVM_LOW);
        //AW channel
        vif.aw_valid    <=  0;
        vif.aw_addr     <=  0;
        vif.aw_len      <=  0;
        vif.aw_size     <=  0;
        vif.aw_burst    <=  0;

        //W channel
        vif.w_valid     <=  0;
        vif.w_data      <=  0;
        vif.w_last      <=  0;
        vif.w_strb      <=  0;

        //B channel
        vif.b_ready     <=  0;
        
        //AR channel
        vif.ar_valid    <=  0;
        vif.ar_addr     <=  0;
        vif.ar_len      <=  0;
        vif.ar_size     <=  0;
        vif.ar_burst    <=  0;

        //R channel
        vif.r_data      <=  0;
        vif.r_last      <=  0;
        vif.r_ready     <=  0;

        `uvm_info(get_type_name(),"[ DRIVER MASTER ] ----- Reset Ended -----", UVM_LOW);
        phase.drop_objection(this);
    endtask


    task run_phase(uvm_phase phase);
        forever begin
            wait(!vif.reset);
            seq_item_port.get_next_item(req);
            `uvm_info(get_type_name(),"[ DATA DRIVER ]", UVM_LOW);
            req.print();
            fork
                send_write_addr();
                send_write_data();
                receive_write_response();
                send_read_addr();
                receive_read_data();
            join
            seq_item_port.item_done(req);
        end
    endtask

    //AW channel
    task send_write_addr;
        `uvm_info("DEBUG", "Inside send_write_address", UVM_LOW)
        @(posedge vif.clk)
        vif.aw_addr     <= req.addr;
        vif.aw_len      <= req.len;
        vif.aw_size     <= req.size;
        vif.aw_burst    <= req.burst;
        `uvm_info("DEBUG", "Data Driven", UVM_LOW)

        @(posedge vif.clk)
        vif.aw_valid    <= 1'b1;
        `uvm_info("DEBUG", "Asserted AW_VALID", UVM_LOW)

        wait(vif.aw_ready)
        @(posedge vif.clk)
        vif.aw_valid    <= 1'b0;
        `uvm_info("DEBUG", "Desserted AW_VALID", UVM_LOW)

        wait(vif.b_valid);
    endtask
    
    //W channel
    task send_write_data;
        int  len = req.len + 1;
        int  check_strb, i;
        `uvm_info("DEBUG", "Inside send_write_data", UVM_LOW)
        
        //wait AW channel done
        wait(vif.aw_valid && vif.aw_ready);
        check_strb = req.addr%(2**req.size);
        if(check_strb == 0)
            req.strb = 4'hf;
        else begin
            for(i = 0; i < check_strb; i++) begin
                req.strb[i] = 1'b0;
            end
        end
        @(posedge vif.clk);
        
        //[start_bit +: width]
	    //[start_bit -: width]
	    //WSTRB[n] sẽ quản lý WDATA[(n*8)+7:(n*8)] với n = 0, 1, 2, 3, 4, ... 
        //[(i*8)+7:(i*8)] = [8*i +:8] 
	    //[7:0] | [15:8] | [23:16]  1001

        $display("[vy n?G??????]");

        //After AW channel done. Drive all signal to vif interface
        for(int i = 0; i < len; i++) begin
            `uvm_info("DEBUG", $sformatf("Inside loop: i = %0d", i), UVM_LOW)
            
            //Assert W_Valid
            vif.w_valid <=  1'b1;
            `uvm_info(get_type_name, $sformatf("DATA = %0h", req.data[i]), UVM_LOW)

            wait(vif.w_ready);
            vif.w_data  <=  req.data[i];
            vif.w_strb  <=  req.strb;
            vif.w_last  <=  (i == len - 1) ? 1'b1 : 1'b0;            
            @(posedge vif.clk);
            if(req.burst == `INCR)
                req.strb = 4'hf;
            else
                req.strb = req.strb;
        end
        
        vif.w_valid <=  1'b0;
        vif.w_last  <=  1'b0;
        `uvm_info("DEBUG", "Asserted B_READY", UVM_LOW)
        vif.b_ready <=  1'b1;
    endtask

    //B channel
    task receive_write_response;
        wait(vif.b_valid);

        @(posedge vif.clk);
        `uvm_info("DEBUG", "Desserted B_READY", UVM_LOW)
        vif.b_ready <=  1'b0;
    endtask

    //AR channel
    task send_read_addr;
        wait(vif.b_ready && vif.b_valid);
        `uvm_info("DEBUG", "Inside send_read_address", UVM_LOW)
        @(posedge vif.clk)
        vif.ar_addr     <= req.addr;
        vif.ar_len      <= req.len;
        vif.ar_size     <= req.size;
        vif.ar_burst    <= req.burst;
        `uvm_info("DEBUG", "Data Driven", UVM_LOW)

        @(posedge vif.clk)
        vif.ar_valid    <= 1'b1;
        `uvm_info("DEBUG", "Asserted AR_VALID", UVM_LOW)

        wait(vif.ar_ready)
        @(posedge vif.clk)
        vif.ar_valid    <= 1'b0;
        `uvm_info("DEBUG", "Desserted AR_VALID", UVM_LOW)
    endtask

    //R channel
    task receive_read_data;
        int len;
        wait(vif.ar_valid && vif.ar_ready);
        // can i add a random delay here, can't me ? 
        len = vif.ar_len + 1;
        vif.r_ready <= 1'b1;
        `uvm_info("DEBUG", "Asserted R_READY", UVM_LOW)

        //PERFECT CASE
        for(int i = 0; i < len; i++) begin
            wait(vif.r_valid);
            @(posedge vif.clk);
        end
        @(posedge vif.clk);
        vif.r_ready <= 1'b0;
        `uvm_info("DEBUG", "Desserted R_READY", UVM_LOW)
    endtask
endclass 

//================================================================================================
//======================================= Driver Slave ===========================================
//================================================================================================
//Driver Slave
class s_driver extends uvm_driver#(seq_item);
    //Declare virtual Interface
    virtual intf vif;
    `uvm_component_utils(s_driver)
    function new(string name = "s_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual intf) :: get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(),"Not set at top level");
    endfunction

    //Reset Interface Before drive
    task reset_phase(uvm_phase phase);
        phase.raise_objection(this);
        //wait(vif.reset) ;
        // AW Channel
        vif.aw_ready = 0 ;
        
        // W Channel
        vif.w_ready  = 0 ;
        
        // B Channel
        vif.b_resp   = 2'bxx ;
        vif.b_valid  = 0 ;

        //AR channel
        vif.ar_ready = 0 ;

        //R channel
        vif.r_data  =  0;
        vif.r_resp  =  2'bxx;
        `uvm_info(get_type_name(),"[ DRIVER SLAVE ] ----- Reset Ended -----", UVM_LOW);
        phase.drop_objection(this);
    endtask


    task run_phase(uvm_phase phase);
        forever begin
            //seq_item_port.get_next_item(req);
            //$display("asdsdasdsad");
            wait(!vif.reset);
            fork 
                receive_write_addr() ;
                receive_write_data() ;
                send_response()      ;
                receive_read_addr()  ;
                send_read_data()     ;
            join  
            //seq_item_port.item_done();
        end
    endtask

    // AW driver
    task receive_write_addr ;
        integer rand_value; 
        wait(vif.aw_valid);
        rand_value = {$random} % 5;
        $display(rand_value);
        repeat(rand_value) begin
            @(posedge vif.clk);
        end
        vif.aw_ready <= 1 ;

        @(posedge vif.clk) ;
        vif.aw_ready = 0  ;
        
        wait(vif.b_ready) ;
    endtask
    
    // W driver
    task receive_write_data ;
        int len = vif.aw_len + 1;
        wait(vif.w_valid)  ;
        @(posedge vif.clk);
        vif.w_ready  <= 1 ;
        wait(vif.w_last) ;
        @(posedge vif.clk) ;
        vif.w_ready <= 0 ;
    endtask

    // B driver
    task send_response() ;
        wait(vif.w_last) ;
        @(posedge vif.clk) ;
        seq_item_port.get(req);
        wait(vif.b_ready);
        vif.b_resp  <= req.resp;
        vif.b_valid <= 1 ;
        wait(!vif.b_ready) ;
        vif.b_valid = 0 ;
        vif.b_resp  = 2'bxx ;
    endtask

    //AR driver
    task receive_read_addr;
        integer rand_value; 
        wait(vif.ar_valid);
        rand_value = {$random} % 5;
        $display(rand_value);
        repeat(rand_value) begin
            @(posedge vif.clk);
        end
        wait(vif.ar_valid);
        vif.ar_ready <= 1 ;
        @(posedge vif.clk) ;
        vif.ar_ready = 0  ;
    endtask

    //R channel
    task send_read_data;
        int len;
        int size ;
        wait(vif.ar_valid && vif.ar_ready);
        len = vif.ar_len + 1;
        @(posedge vif.clk);
        //PERFECT CASE
        if( !uvm_config_db #(int) :: get(this,"","rd_data_size",size) )
            `uvm_fatal(get_type_name(),"Not set at top level");
        $display("[%0t] SIZE : 1asdasdasd => %0d",$time,size);
        for(int i = 0; i < len; i++) begin
            wait(vif.r_ready);
            vif.r_valid <=  1'b1;
            @(posedge vif.clk);
            vif.r_last  =  (i == len - 1) ? 1'b1 : 1'b0;
            //@(negedge vif.clk);
            vif.r_resp = ((vif.r_data >>> ((2**size)*8)) > 0) ? 1 : 0 ;
            //vif.r_resp =  0 ;
            //$display("[%0t] SIZE : 1asdasdasd => %0d",$time,size);
            $display("[%0t] DATA : 12312312312312312 => %0d",$time,vif.r_data);
            
        end
        
        @(posedge vif.clk);
        vif.r_resp  <= 2'bxx ;
        vif.r_valid <= 1'b0;
        vif.r_last  <= 1'b0;
        `uvm_info("DEBUG", "Desserted R_VALID", UVM_LOW)

    endtask

    
endclass

`endif

