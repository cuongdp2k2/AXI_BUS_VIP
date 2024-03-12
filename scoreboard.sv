// UVM libs here =================================================================================================
`include "package.sv"
// parameter libs here ===========================================================================================

// sequence item libs here =======================================================================================
`include "seq_item.sv"
// monitor libs here =============================================================================================
`include "monitor.sv"
`uvm_analysis_imp_decl (_PORT_MASTER)
`uvm_analysis_imp_decl (_PORT_SLAVE)

class scoreboard extends uvm_scoreboard;
    // declare local parameters
	
    // delcare virtual interface

    // delare port
	
    // REGISTOR FACTORY ==========================================================================================
    `uvm_component_utils(scoreboard) ;
    function new(string name="scoreboard", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    // BUILD PHASE ================================================================================================
    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        // check exist virtual interface
        // your code here
    endfunction

    task run_phase(uvm_phase phase);
    endtask

endclass 

class m_scoreboard extends uvm_scoreboard;
    uvm_analysis_imp_PORT_MASTER#(seq_item, m_scoreboard) m_mon2scb;
  
     seq_item m_item[$];
     `uvm_component_utils(m_scoreboard) ;
     function new(string name= "m_scoreboard", uvm_component parent=null);
        super.new(name,parent); 
    endfunction


    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        m_mon2scb = new("m_mon2scb", this);
    endfunction

    virtual function void write_PORT_MASTER(seq_item req);
	    $display("Push data to Master_Queue");
        m_item.push_back(req);
    endfunction

    task compare_item_m;
    seq_item item_read;
	seq_item item_write;
	item_read = seq_item::type_id::create("item_read", this); 
	item_write = seq_item::type_id::create("item_write", this); 
        forever begin
            wait(m_item.size > 1);
            if(m_item.size == 2) begin
                item_write = m_item.pop_front();
                item_read = m_item.pop_front();
            end

            if(item_read.compare(item_write)) begin
            `uvm_info(get_full_name(), "SB CHECK MASTER DATA PASSED", UVM_LOW);
            end
            else begin
            `uvm_info(get_full_name(), "SB CHECK MASTER DATA FAILED", UVM_LOW); 
            end
	    end
    endtask



	task run_phase(uvm_phase phase);
		forever begin
			compare_item_m();
		end
	endtask
endclass

class s_scoreboard extends uvm_scoreboard;

    uvm_analysis_imp_PORT_SLAVE#(seq_item, s_scoreboard) s_mon2scb;

    seq_item s_item[$];

    `uvm_component_utils(s_scoreboard) ;
    function new(string name="s_scoreboard", uvm_component parent=null);
        super.new(name,parent);
    endfunction
    
 
    function void build_phase (uvm_phase phase);
        super.build_phase(phase);
        s_mon2scb = new("s_mon2scb", this);
    endfunction


   virtual function void write_PORT_SLAVE(seq_item req);
	$display("Push data to Slave_Queue");
        s_item.push_back(req);
    endfunction
	
	
    task compare_item_s;
        seq_item item_read;
	seq_item item_write;
	item_read = seq_item::type_id::create("item_read", this); 
	item_write = seq_item::type_id::create("item_write", this); 
        forever begin
                wait(s_item.size > 1);
                if(s_item.size == 2)
		begin
	           item_write = s_item.pop_front();
		   item_read = s_item.pop_front();
		end

		if(item_read.compare(item_write)) begin
		  `uvm_info(get_full_name(), "SB CHECK SLAVE DATA PASSED", UVM_LOW);
		end
		else begin
		   `uvm_info(get_full_name(), "SB CHECK SLAVE DATA FAILED", UVM_LOW); 
		end
	end
    endtask



	task run_phase(uvm_phase phase);
		forever begin
			compare_item_s();
		end
	endtask
endclass