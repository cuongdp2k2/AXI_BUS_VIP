`ifndef MON_SV
`define MON_SV

`include "package.sv"
`include "seq_item.sv"
`include "constraint.sv"

//==================================================================================================
//======================================= Monitor Master ===========================================
//==================================================================================================
//Monitor Master
class m_monitor extends uvm_monitor;

    virtual intf vif;
    seq_item mon_item;
    seq_item r_mon_item;

    //Declare port to connect with Scoreboard
    uvm_analysis_port #(seq_item) master_mon2scb;

    `uvm_component_utils(m_monitor)
    
    function new(string name = "m_monitor", uvm_component parent = null);
        super.new(name, parent);  
    endfunction 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        master_mon2scb = new("master_mon2scb", this);
        if(!uvm_config_db#(virtual intf) :: get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(),"Not set at top level");
    endfunction
    
    task run_phase(uvm_phase phase);
         forever begin
            //wait (!vif.reset);
            fork
                write_monitor();
                read_monitor();
            join
        end
    endtask
    
     task write_monitor;
            int len;
            `uvm_info("DEBUG", "Inside Monitor Master", UVM_LOW)
            wait(vif.aw_valid && vif.aw_ready);
            @(negedge vif.clk);
            mon_item         =  seq_item::type_id::create("mon_item");
            mon_item.addr    =  vif.aw_addr;
            mon_item.len     =  vif.aw_len;
            mon_item.size    =  vif.aw_size;
            mon_item.burst   =  vif.aw_burst;
            len = mon_item.len + 1;
            mon_item.data = new[len];
            //mon_item.strb = new[len];
            for(int i = 0; i < len;  i++) begin
                wait(vif.w_valid && vif.w_ready);
                @(negedge vif.clk);
                mon_item.strb = vif.w_strb;
                mon_item.data[i] = vif.w_data;
                $display("DATA = %0h, TIME_DATA = %0t", mon_item.data[i], $time);
            end
            mon_item.last = vif.w_last;
            wait(mon_item.last);
            $display("last = %0d, MONITOR TIME = %0t",mon_item.last, $time);
            mon_item.print(uvm_default_table_printer);
            master_mon2scb.write(mon_item);

            wait(vif.b_valid && vif.b_ready);
            `uvm_info("DEBUG", "End Monitor Master", UVM_LOW)
    endtask

    task read_monitor;
        int len;
        `uvm_info("DEBUG", "Inside Monitor Master", UVM_LOW)

        //AR channel
        wait(vif.ar_valid && vif.ar_ready);
        @(negedge vif.clk);
        r_mon_item         =  seq_item::type_id::create("r_mon_item");
        r_mon_item.addr    =  vif.ar_addr;
        r_mon_item.len     =  vif.ar_len;
        r_mon_item.size    =  vif.ar_size;
        r_mon_item.burst   =  vif.ar_burst;
        len = r_mon_item.len + 1;
        r_mon_item.data = new[len];


        //R channel
        for(int i = 0; i < len; i++) begin
            wait(vif.r_valid && vif.r_ready);
            @(negedge vif.clk);

            r_mon_item.data[i]= vif.r_data;
            r_mon_item.resp = vif.r_resp;
            $display("DATA in  = %0h, TIME_DATA = %0t", r_mon_item.data[i], $time);
            $display("RESPONSE in  = %0h, TIME_DATA = %0t", r_mon_item.resp, $time);
        end
        r_mon_item.last = vif.r_last;
        $display("Monitor Master last = %0d, MONITOR_TIME = %0t", r_mon_item.last, $time);
        r_mon_item.print(uvm_default_table_printer);
        wait(r_mon_item.last);
        master_mon2scb.write(r_mon_item);
    endtask

endclass 

//=================================================================================================
//======================================= Monitor Slave ===========================================
//=================================================================================================
//Monitor Slave
class s_monitor extends uvm_monitor;
    virtual intf vif;
    seq_item mon_item;
    seq_item r_mon_item;
    //Declare port to connect with Scoreboard
    uvm_analysis_port #(seq_item) slave_mon2scb;

    `uvm_component_utils(s_monitor)
    
    function new(string name = "s_monitor", uvm_component parent = null);
        super.new(name, parent);  
    endfunction 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        slave_mon2scb = new("slave_mon2scb", this);
        if(!uvm_config_db#(virtual intf) :: get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(),"Not set at top level");
    endfunction
    
    task run_phase(uvm_phase phase);
        forever begin
            //wait(!vif.reset);
            fork
                write_monitor();
                read_monitor();
            join
        end
    endtask

    
    task write_monitor;
        int len;
        int wr_check = 0;
        int ck;
        `uvm_info("DEBUG", "Inside Monitor Slave", UVM_LOW)
        wait(vif.aw_valid && vif.aw_ready);
        @(negedge vif.clk);
        mon_item         =  seq_item::type_id::create("mon_item");
        mon_item.addr    =  vif.aw_addr;
        mon_item.len     =  vif.aw_len;
        mon_item.size    =  vif.aw_size;
        mon_item.burst   =  vif.aw_burst;
        len = mon_item.len + 1;
        mon_item.data = new[len];
        //mon_item.strb = new[len];
        for(int i = 0; i < len; i++) begin
            wait(vif.w_valid && vif.w_ready);
            @(negedge vif.clk);
            mon_item.strb = vif.w_strb;
            mon_item.data[i] = vif.w_data;
            $display("DATA = %0h, TIME_DATA = %0t", mon_item.data[i], $time);
        end

        //Check DATA
        if(mon_item.addr > 255) wr_check++;
        foreach (mon_item.data[i]) begin
            // size 1 -> 2*1 = 2  byte
            // 00001111
            // 0000
            // Note
            if((mon_item.data[i] >>> ((2**mon_item.size)*8)) > 0)
                wr_check++;
        end
        $display("CHECK asdsadsa = %0d", wr_check);
        uvm_config_db #(int)::set(null, "*", "wr_check", wr_check);

        mon_item.last = vif.w_last;
        $display("last = %0d, MONITOR_TIME = %0t", mon_item.last, $time);
        mon_item.print(uvm_default_table_printer);
        wait(mon_item.last)
        slave_mon2scb.write(mon_item);

        wait(vif.b_ready && vif.b_valid);
        `uvm_info("DEBUG", "End Monitor Slave", UVM_LOW)
    endtask

    task read_monitor;
        int len;
        `uvm_info("DEBUG", "Inside Monitor Slave", UVM_LOW)

        //AR channel
        wait(vif.ar_valid & vif.ar_ready);
        @(negedge vif.clk);
        r_mon_item         =  seq_item::type_id::create("r_mon_item");
        r_mon_item.addr    =  vif.ar_addr;
        r_mon_item.len     =  vif.ar_len;
        r_mon_item.size    =  vif.ar_size;
        r_mon_item.burst   =  vif.ar_burst;
        len = r_mon_item.len + 1;
        r_mon_item.data = new[len];
        $display("[%0t] SIZE inside MONITOR : klnkjnkjn => %0d",$time,r_mon_item.size);
        uvm_config_db #(int) :: set(null , "uvm_test_top.s_env.*", "rd_data_size" , r_mon_item.size) ;

        //R channel
        for(int i = 0; i < len; i++) begin
            wait(vif.r_valid && vif.r_ready);
            @(posedge vif.clk);
            @(negedge vif.clk);
            r_mon_item.last = vif.r_last;
              
            r_mon_item.data[i]= vif.r_data;
            $display("DATA = %0h, TIME_DATA = %0t", r_mon_item.data[i], $time);
            
        end
        
        $display("Monitor Slave last = %0d, MONITOR_TIME = %0t", r_mon_item.last, $time);
        r_mon_item.print(uvm_default_table_printer);
        wait(vif.r_last);
        slave_mon2scb.write(r_mon_item);
        $display("asdsaddasdsadsad");
    endtask
endclass

//=================================================================================================
//======================================= Base Monitor ============================================
//=================================================================================================
//Monitor
class monitor extends uvm_monitor;

    virtual intf vif;

    //Declare port to connect with Scoreboard

    `uvm_component_utils(monitor)
    
    function new(string name = "monitor", uvm_component parent = null);
        super.new(name, parent);  
    endfunction 

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual intf) :: get(this, "", "vif", vif))
            `uvm_fatal(get_type_name(),"Not set at top level");
    endfunction
    
    task run_phase(uvm_phase phase);
       
    endtask

   

endclass

`endif