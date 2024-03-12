module checker_aw (
    // vif
    //global signal
    input           clk,
    input           reset,
    //AW channel
    input   [31:0]  aw_addr,
    input   [7:0]   aw_len,
    input   [2:0]   aw_size,
    input   [1:0]   aw_burst,
    input           aw_valid,
    input           aw_ready
);
    typedef enum bit [1:0] { RESET , IDLE , WAIT , HAND_SHAKE } aw_state ;
    
    aw_state currentState ;

    initial begin
        currentState = RESET ;
    end

    always @(posedge clk or posedge reset) begin
        case (currentState)
            RESET: begin
                // if reset then all properties are zero ;
                $display("[AW_CHECKER] AW channel currently in RESET state");
                if(!reset) currentState = IDLE ;
            end
            IDLE : begin
                $display("[AW_CHECKER] AW channel currently in IDLE state");
                if(reset) currentState = RESET ;
                if(aw_valid) currentState = WAIT ;
            end
            WAIT : begin
                $display("[AW_CHECKER] AW channel currently in WAIT state");
                if(reset) currentState = RESET ;
                if(aw_ready) currentState = HAND_SHAKE ;
            end

            HAND_SHAKE : begin
                $display("[AW_CHECKER] AW channel currently in WAIT state");
                if(reset) currentState = RESET ;
                if(!aw_valid & !aw_ready) currentState = IDLE ;
            end
            default : currentState = RESET ;
        endcase
    end
endmodule