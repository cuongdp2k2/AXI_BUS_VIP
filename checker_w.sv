module checker_w (
    input           clk,
    input           reset,

    input   [31:0]  w_data,
    input   [3:0]   w_strb,
    input           w_last,
    input           w_valid,
    input           w_ready
);
    typedef enum bit [2:0] { RESET , IDLE , TRANS , COMPLETE } w_state;
    w_state currentState ;

    initial begin
        currentState =  RESET ;
    end

    always @(posedge clk or posedge reset ) begin
        case (currentState)
            RESET : begin
                $display("[W_CHECKER] W channel currently in RESET state");
                if(!reset) currentState = IDLE ;
            end 
            IDLE  : begin
                $display("[W_CHECKER] W channel currently in IDLE state");
                if(w_ready & w_valid) currentState = TRANS ; 
            end 
            TRANS : begin
                $display("[W_CHECKER] W channel currently in TRANS state");
                if(!w_valid) begin
                    $warning("[W_CHECKER] W_VALID loss during the transfer process");
                end
                if(w_last) currentState = COMPLETE ;
            end
            COMPLETE : begin
                $display("[W_CHECKER] W channel currently in COMPLETE state");
                $display("[W_CHECKER] All data have been transfered successfully") ;
                if(!w_last) currentState = IDLE ;
            end
            default: currentState = RESET ;
        endcase
    end

endmodule : checker_w