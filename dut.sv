`include "constraint.sv"
module dut#(
	parameter	DATA_WIDTH = 32,
	parameter	ADDR_WIDTH = 8,
	parameter	STRB_WIDTH = DATA_WIDTH/8
)(
    //global signal
    input           clk,
    input           reset,
    //AW channel
    input   [31:0]  aw_addr,
    input   [7:0]   aw_len,
    input   [2:0]   aw_size,
    input   [1:0]   aw_burst,
    input           aw_valid,
    input           aw_ready,

    //W channel
    input   [31:0]  w_data,
    input   [3:0]   w_strb,
    input           w_last,
    input           w_valid,
    input           w_ready,

    //B channel  
    input           b_valid,
    input           b_ready,
    input   [1:0]   b_resp,

    //AR channel
    input   [31:0]  ar_addr,
    input   [7:0]   ar_len,
    input   [2:0]   ar_size,
    input   [1:0]   ar_burst,
    input           ar_valid,
    input           ar_ready,

    //R channel
    output  [31:0]  r_data,
    input           r_last,
    input           r_valid,
    input           r_ready,
    input   [1:0]   r_resp
);

    reg	[7 : 0] mem [2**ADDR_WIDTH - 1 : 0];

    reg [31:0]  wr_addr, rd_addr, wr_addr_reg, rd_addr_reg;

    reg [31:0]  rd_data;

    integer i, j;
    always @(posedge clk) begin
        if(aw_ready & aw_valid) begin
            wr_addr =  (aw_addr%2**aw_size == 0) ? aw_addr : (aw_addr - (aw_addr%(2**aw_size)));
            wr_addr_reg = wr_addr;
        end

		if(w_ready & w_valid) begin
            for(i = 0; i < 2**aw_size; i++) begin
                if(w_strb[i])
                    mem[wr_addr] = w_data[8*i +: 8];
                wr_addr = wr_addr + 1;
            end
            wr_addr = (aw_burst == `INCR) ? wr_addr : wr_addr_reg;
		end
	end
	
	always @(posedge clk) begin
        if(ar_ready & ar_valid) begin
            rd_addr =  (ar_addr%2**ar_size == 0) ? ar_addr : (ar_addr - (ar_addr%(2**ar_size)));
            rd_addr_reg = rd_addr;
        end

		if(r_ready & r_valid) begin
			for(i = 0; i < 2**ar_size; i++) begin
                rd_data[8*i +: 8] = mem[rd_addr];
                rd_addr = rd_addr + 1;
            end
            rd_addr = (ar_burst == `INCR) ? rd_addr : rd_addr_reg;
	    end
    end
    assign  r_data  =    rd_data;
endmodule