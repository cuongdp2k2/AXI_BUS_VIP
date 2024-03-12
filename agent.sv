// UVM libs here =================================================================================================
`include "package.sv"
// parameter libs here ===========================================================================================
`include "constraint.sv"
// sequence item libs here =======================================================================================
`include "seq_item.sv"
// monitor libs here =============================================================================================
`include "monitor.sv"
// driver libs here ===============================================================================================
`include "driver.sv"
// sequencer libs here ============================================================================================
`include "sequencer.sv"

// A base agent =========================================================================================================
class agent extends uvm_agent  ;
    // declare local parameters
    driver   drv  ;
    monitor     mon  ;
    sequencer   sqcr ;
    // REGISTOR FACTORY ==========================================================================================
    `uvm_component_utils(agent);
    function new(string name="agent", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    // BUILD PHASE ================================================================================================
    function void build_phase(uvm_phase phase );
        super.build_phase(phase);
        // your code here
        drv  = driver::type_id::create("drv",this) ;
        mon  = monitor::type_id::create("mon",this) ;
        sqcr = sequencer::type_id::create("sqcr",this) ;
    endfunction
    
    // CONNECT PHASE ==============================================================================================
    function void connect_phase(uvm_phase phase);
        // connect your components inside agent
        drv.seq_item_port.connect(sqcr.seq_item_export);
    endfunction
endclass


// A Master agent =========================================================================================================
class m_agent extends uvm_agent;  
    // declare local parameters
    m_driver   m_drv  ;
    m_monitor   m_mon  ;
    sequencer   m_sqcr ;
    // REGISTOR FACTORY ==========================================================================================
    `uvm_component_utils(m_agent);
    function new(string name="m_agent", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    // BUILD PHASE ================================================================================================
    function void build_phase(uvm_phase phase );
        super.build_phase(phase);
        // your code here
        m_drv   = m_driver::type_id::create("m_drv", this);
        m_mon   = m_monitor::type_id::create("m_mon", this);
        m_sqcr  = sequencer::type_id::create("m_sqcr", this);
    endfunction
    
    // CONNECT PHASE ==============================================================================================
    function void connect_phase(uvm_phase phase);
        // connect your components inside agent
        m_drv.seq_item_port.connect(m_sqcr.seq_item_export);
    endfunction
endclass

// A Slave agent =========================================================================================================
class s_agent extends uvm_agent  ;
    // declare local parameters
    s_driver   s_drv  ;
    s_monitor   s_mon  ;
    sequencer   s_sqcr ;
    // REGISTOR FACTORY ==========================================================================================
    `uvm_component_utils(s_agent);
    function new(string name="s_agent", uvm_component parent=null);
        super.new(name,parent);
    endfunction

    // BUILD PHASE ================================================================================================
    function void build_phase(uvm_phase phase );
        super.build_phase(phase);
        // your code here
        s_drv   = s_driver::type_id::create("s_drv",this) ;
        s_mon  = s_monitor::type_id::create("s_mon",this) ;
        s_sqcr = sequencer::type_id::create("s_sqcr",this) ;
    endfunction
    
    // CONNECT PHASE ==============================================================================================
    function void connect_phase(uvm_phase phase);
        // connect your components inside agent
        s_drv.seq_item_port.connect(s_sqcr.seq_item_export);
    endfunction
endclass