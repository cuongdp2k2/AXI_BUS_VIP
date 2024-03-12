`ifndef SEQUENCE_ITEM
`define SEQUENCE_ITEM
`include "package.sv"

class seq_item extends uvm_sequence_item;

    //AW & AR channel
    rand bit [31:0] addr;
    rand bit [7:0]  len;
    rand bit [2:0]  size;
         bit [1:0]  burst  = 1;

    //W & R channel
    rand bit [31:0] data [];
    bit      [3:0]  strb = 4'hf;
    bit             last;

    //B & R channel  
    rand bit [2:0]       resp;
    
    `uvm_object_utils_begin(seq_item)
        `uvm_field_int(addr, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(len,  UVM_ALL_ON)
        `uvm_field_int(size, UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(burst,UVM_ALL_ON | UVM_HEX)
        `uvm_field_int(last,  UVM_ALL_ON)
        `uvm_field_int(strb,  UVM_ALL_ON | UVM_BIN)
        `uvm_field_array_int(data, UVM_ALL_ON)
        `uvm_field_int(resp,  UVM_ALL_ON)
    `uvm_object_utils_end

    function new(string name = "seq_item");
        super.new(name);
    endfunction 


    //DATA_WIDTH = 32 bit = 4 byte = 2
    constraint size_value {
        size <= 2;
    }

    constraint addr_value {
        addr <= 10;
    }

    constraint len_value {
        len == 5;
    }


    //Constraint DATA base on len and size
    constraint data_size {
        solve len    before    data;
        solve size   before    data;
        data.size == len + 1;
        // foreach(data[i]) 
        //     data[i].size == 2**size;
    }

    //Constraint Write Strobe
    // constraint strobe_size{
    //     solve len   before strb;
    //     strb.size == len + 1;
    //     foreach(strb[i])
    //         strb[i] inside {[1:13]};
    // }
endclass 

`endif