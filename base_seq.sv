`ifndef SEQUENCE_SV
`define SEQUENCE_SV

`include "package.sv"
`include "seq_item.sv"

//===================================================================================================
//======================================= Sequence Master ===========================================
//===================================================================================================
//Sequence Master
class m_sequence extends uvm_sequence#(seq_item);
    //Declare seq_item for send
    seq_item req;
    `uvm_object_utils(m_sequence)
    function new(string name = "m_sequence");
        super.new(name);
    endfunction 

    task body();
        //Random and send sequence item to Driver Master
        `uvm_info(get_type_name(),"[Master] Inside body",UVM_NONE)
        
        //use method
        //create item
        req = seq_item::type_id::create("req");
        
        //wait_for_grant
        wait_for_grant();

        //randomize()
        assert(req.randomize());

        //send to req fifo in Sequencer
        send_request(req);
        req.print();

        //wait done from Driver
        `uvm_info(get_type_name(), "Before wait_for_item_done", UVM_LOW);
        wait_for_item_done();
        `uvm_info(get_type_name(), "After wait_for_item_done", UVM_LOW);

    endtask

endclass

//===================================================================================================
//======================================= Sequence Slave ============================================
//===================================================================================================
//Sequence Slave
class s_sequence extends uvm_sequence#(seq_item);
    seq_item req;
    int ck;
    `uvm_object_utils(s_sequence)
    function new(string name = "s_sequence");
        super.new(name);
    endfunction 
    
    task body();
        // Compare data for Driver Slave send back response
        `uvm_info(get_type_name(),"[Slave] Inside body",UVM_NONE)
        
        //use method
        //create item
        req = seq_item::type_id::create("req");
        
        //wait_for_grant
        wait_for_grant();

        //randomize()
        if(!uvm_config_db #(int)::get(null, "*", "wr_check", ck))
        `uvm_fatal(get_type_name(), "get failed for resource in this scope");
        $display("check = %0d", ck);
        if(ck > 0) 
            assert(req.randomize() with {resp == 2'b01;});
        else 
            assert(req.randomize() with {resp == 2'b00;});

        //send to req fifo in Sequencer
        send_request(req);
        req.print();

        //wait done from Driver
        `uvm_info(get_type_name(), "Before wait_for_item_done", UVM_LOW);
        wait_for_item_done();
        `uvm_info(get_type_name(), "After wait_for_item_done", UVM_LOW);

    endtask

endclass

`endif