// UVM libs here =================================================================================================
`include "package.sv"
// agent libs here ===============================================================================================
`include "agent.sv"
// scoreboard libs here ==========================================================================================
`include "scoreboard.sv"
// coverage libs here ============================================================================================

class environment extends uvm_env ;
    // declare local parameters here 
    agent agt ;
    scoreboard scb ;
    // REGISTOR FACTORY ==========================================================================================
    `uvm_component_utils(environment) ;
    function new(string name= "environment" , uvm_component parent = null);
        super.new(name,parent) ;
    endfunction //new()

    // BUILD PHASE ================================================================================================
    function void build_phase(uvm_phase phase) ;
        super.build_phase(phase) ;
        // your code here
        agt = agent::type_id::create("agt",this);
        scb = scoreboard::type_id::create("scb",this);
    endfunction

    // CONNECT PHASE ==============================================================================================
    function void connect_phase(uvm_phase phase);
        // connect your components inside agent
    endfunction
endclass

//================================================================================================
//======================================= Environment Slave ======================================
//================================================================================================
//Driver Slave
class s_environment extends uvm_env ;
    // declare local parameters here 
    s_agent s_agt ;
    s_scoreboard s_scb ;
    // REGISTOR FACTORY ==========================================================================================
    `uvm_component_utils(s_environment) ;
    function new(string name= "s_environment" , uvm_component parent = null);
        super.new(name,parent) ;
    endfunction //new()

    // BUILD PHASE ================================================================================================
    function void build_phase(uvm_phase phase) ;
        super.build_phase(phase) ;
        // your code here
        s_agt = s_agent::type_id::create("s_agt",this);
        s_scb = s_scoreboard::type_id::create("s_scb",this);
    endfunction

    // CONNECT PHASE ==============================================================================================
    function void connect_phase(uvm_phase phase);
        s_agt.s_mon.slave_mon2scb.connect(s_scb.s_mon2scb);
    endfunction
endclass

//================================================================================================
//======================================= Environment Master =====================================
//================================================================================================
//Driver Master
class m_environment extends uvm_env ;
    // declare local parameters here 
    m_agent m_agt ;
    m_scoreboard m_scb ;
    // REGISTOR FACTORY ==========================================================================================
    `uvm_component_utils(m_environment) ;
    function new(string name= "m_environment" , uvm_component parent = null);
        super.new(name,parent) ;
    endfunction //new()

    // BUILD PHASE ================================================================================================
    function void build_phase(uvm_phase phase) ;
        super.build_phase(phase) ;
        // your code here
        m_agt = m_agent::type_id::create("m_agt",this);
        m_scb = m_scoreboard::type_id::create("m_scb",this);
    endfunction

    // CONNECT PHASE ==============================================================================================
    function void connect_phase(uvm_phase phase);
        // connect your components inside agent
	m_agt.m_mon.master_mon2scb.connect(m_scb.m_mon2scb);
    endfunction
endclass