// UVM libs here =================================================================================================
`include "package.sv"
// environment libs here =========================================================================================
`include "env.sv"
// sequence libs here ==========================================================================================
`include "base_seq.sv"

class base_test extends uvm_test;
    // declare local parameters here 
    s_environment s_env ; 
    m_environment m_env ;
    s_sequence    s_seq ;
    m_sequence    m_seq ;
    // REGISTOR FACTORY ==========================================================================================
    `uvm_component_utils(base_test) ;
    function new(string name= "base_test" , uvm_component parent = null);
        super.new(name,parent) ;
    endfunction //new()

    // BUILD PHASE ================================================================================================
    function void build_phase(uvm_phase phase) ;
        super.build_phase(phase) ;
        // your code here
        s_env = s_environment::type_id::create("s_env", this);
        m_env = m_environment::type_id::create("m_env", this);
    endfunction

    // RUN PHASE ==================================================================================================
    task run_phase(uvm_phase phase);
        phase.raise_objection(this);
        m_seq = m_sequence::type_id::create("m_seq");
        s_seq = s_sequence::type_id::create("s_seq");
        uvm_config_db #(int)::set(null, "*", "wr_check", 100);
        uvm_config_db #(int)::set(null, "*", "rd_check", 123);
        repeat(6) begin
            fork
            m_seq.start(m_env.m_agt.m_sqcr);
            s_seq.start(s_env.s_agt.s_sqcr);
            join
        end
        phase.drop_objection(this);
        `uvm_info("DEBUG", "End Test", UVM_LOW)
    endtask

    // REPORT PHASE ===============================================================================================
    function void report_phase(uvm_phase phase );
        super.report_phase(phase);
        uvm_top.print_topology() ;
    endfunction



endclass