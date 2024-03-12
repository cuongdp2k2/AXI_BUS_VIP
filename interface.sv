interface intf(input logic clk, reset);

    //AW channel
    logic           aw_valid;
    logic           aw_ready;
    logic [31:0]    aw_addr;
    logic [7:0]     aw_len;
    logic [2:0]     aw_size;
    logic [1:0]     aw_burst;
    
    //W channel
    logic           w_valid;
    logic           w_ready;
    logic           w_last;
    logic [31:0]    w_data;
    logic [3:0]     w_strb;

    //B channel  
    logic           b_ready;
    logic           b_valid;
    logic [1:0]     b_resp;

    //AR channel
    logic           ar_valid;
    logic           ar_ready;
    logic [31:0]    ar_addr;
    logic [7:0]     ar_len;
    logic [2:0]     ar_size;
    logic [1:0]     ar_burst;

    //R channel
    logic           r_valid;
    logic           r_ready;
    logic           r_last;
    logic [31:0]    r_data;
    logic [1:0]     r_resp;
    

//========================WRITE CHENNEL================//
//CHECK AW_VALIDE NOI CHANGE
    property aw_valid_stable;
        @(posedge vif.clk) disable iff(vif.reset)
        aw_valid & !aw_ready |-> aw_valid;
    endproperty
    
//CHECK AW_READY NOI CHANGE
    property aw_ready_stable;
        @(posedge vif.clk) disable iff(vif.reset)
        !aw_valid & aw_ready |-> aw_ready;
    endproperty

//CHECK UNKNOWN AW CHENNEL
    property aw_addr_x;
        @(posedge vif.clk) disable iff(vif.reset)
        aw_valid |-> ! $isunknown (aw_addr);
    endproperty

    property aw_len_x;
        @(posedge vif.clk) disable iff(vif.reset)
        aw_valid |-> ! $isunknown (aw_len);
    endproperty

    property aw_size_x;
        @(posedge vif.clk) disable iff(vif.reset)
        aw_valid |-> ! $isunknown (aw_size);
    endproperty

    property aw_burst_x;
        @(posedge vif.clk) disable iff(vif.reset)
        aw_valid |-> ! $isunknown (aw_burst);
    endproperty


//CHECK W_VALIDE NOI CHANGE
    property w_valid_stable;
        @(posedge vif.clk) disable iff(vif.reset)
        w_valid & !w_ready |-> w_valid;
    endproperty
    
//CHECK W_READY NOI CHANGE
    property w_ready_stable;
        @(posedge vif.clk) disable iff(vif.reset)
        !w_valid & w_ready |-> w_ready;
    endproperty
    
//CHECK UNKNOWN W CHENNEL
    property w_data_x;
        @(posedge vif.clk) disable iff(vif.reset)
        w_valid |-> !$isunknown(w_data);
    endproperty

    property w_last_x;
        @(posedge vif.clk) disable iff(vif.reset)
        w_valid |-> !$isunknown(w_last);
    endproperty

    property w_strb_x;
        @(posedge vif.clk) disable iff(vif.reset)
        w_valid |-> !$isunknown(w_strb);
    endproperty

// CHECK HANDSHAKE AW-W
    property handshake_aw_w;
        @(posedge vif.clk) disable iff(vif.reset)
        aw_valid & aw_ready |=> (w_valid | w_ready);
    endproperty
    
//CHECK HANDSHAKE W_DATA - B_RESP
    property handshake_w_b;
        @(posedge vif.clk) disable iff(vif.reset)
        w_last |=> (b_valid | b_ready);
    endproperty
    
//CHECK B_RESP
    property check_b_resp;
        @(posedge vif.clk) disable iff(vif.reset)
        b_valid & b_ready |-> !$isunknown(b_resp);
    endproperty
//========================READ CHENNEL================//
//CHECK AR_CHENNEL
     property ar_valid_stable;
        @(posedge vif.clk) disable iff(vif.reset)
        ar_valid & !ar_ready |-> ar_valid;
    endproperty
    
     property ar_ready_stable;
        @(posedge vif.clk) disable iff(vif.reset)
        !ar_valid & ar_ready |-> ar_ready;
    endproperty
    
//CHECK UNKNOWN AR CHENNEL
    property ar_addr_x;
        @(posedge vif.clk) disable iff(vif.reset)
        ar_valid |-> !$isunknown(ar_addr);
    endproperty

    property ar_len_x;
        @(posedge vif.clk) disable iff(vif.reset)
        ar_valid |-> !$isunknown(ar_len);
    endproperty

    property ar_size_x;
        @(posedge vif.clk) disable iff(vif.reset)
        ar_valid |-> !$isunknown(ar_len);
    endproperty
    
    property ar_burst_x;
        @(posedge vif.clk) disable iff(vif.reset)
        ar_valid |-> !$isunknown(ar_burst);
    endproperty

//CHECK AR_CHENNEL
     property r_valid_stable;
        @(posedge vif.clk) disable iff(vif.reset)
        r_valid & !r_ready |-> r_valid;
    endproperty
    
     property r_ready_stable;
        @(posedge vif.clk) disable iff(vif.reset)
        !r_valid & r_ready |-> r_ready;
    endproperty
    
//CHECK UNKNOWN R CHENNEL
    property r_last_x;
        @(posedge vif.clk) disable iff(vif.reset)
        r_valid |-> !$isunknown(r_last);
    endproperty
    
    property r_data_x;
        @(posedge vif.clk) disable iff(vif.reset)
        r_valid |-> !$isunknown(r_last);
    endproperty
    
//HANDSHAKE AR - R
    property handshake_ar_r;
      @(posedge vif.clk) disable iff(vif.reset)
      (ar_valid & ar_ready) |=> (r_valid | r_ready);  
    endproperty
    
//==================ASSERT========================//
label1 : assert property (aw_valid_stable)  else $display("[%0t] Error! aw_valid_stable", $time) ;
label2 : assert property (aw_ready_stable)  else $display("[%0t] Error! aw_ready_stable", $time) ;
label3 : assert property (aw_addr_x)        else $display("[%0t] Error! aw_addr_x", $time) ;
label4 : assert property (aw_len_x)         else $display("[%0t] aw_len_x", $time) ;
label5 : assert property (aw_size_x)        else $display("[%0t] Error! aw_size_x", $time) ;
label6 : assert property (aw_burst_x)       else $display("[%0t] Error! aw_burst_x", $time) ;
label7 : assert property (w_valid_stable)   else $display("[%0t] Error! w_valid_stable", $time) ;
label8 : assert property (w_ready_stable)   else $display("[%0t] Error! w_ready_stable", $time) ;
label9 : assert property (w_data_x)         else $display("[%0t] Error! w_data_x", $time) ;
label10 : assert property (w_last_x)         else $display("[%0t] Error! w_last_x", $time) ;
label11 : assert property (w_strb_x)         else $display("[%0t] Error! w_strb_x", $time) ;
label12 : assert property (handshake_aw_w)   else $display("[%0t] Error! handshake_aw_w", $time) ;
label13 : assert property (handshake_w_b)    else $display("[%0t] Error! handshake_w_b", $time) ;
label14 : assert property (check_b_resp)     else $display("[%0t] Error! check_b_resp", $time) ;
label15 : assert property (ar_valid_stable)  else $display("[%0t] Error! ar_valid_stable", $time) ;
label16 : assert property (ar_ready_stable)  else $display("[%0t] Error! ar_ready_stable", $time) ;
label17 : assert property (ar_addr_x)        else $display("[%0t] Error! ar_addr_x", $time) ;
label18 : assert property (ar_len_x)         else $display("[%0t] Error! ar_len_x", $time) ;
label19 : assert property (ar_size_x)        else $display("[%0t] Error! ar_size_x", $time) ;
label20 : assert property (ar_burst_x)       else $display("[%0t] Error! ar_burst_x", $time) ;
label21 : assert property (r_valid_stable)   else $display("[%0t] Error! r_valid_stable", $time) ;
label22 : assert property (r_ready_stable)   else $display("[%0t] Error! r_ready_stable", $time) ;
label23 : assert property (r_last_x)         else $display("[%0t] Error! r_last_x", $time) ;
label24 : assert property (r_data_x)       	 else $display("[%0t] Error! r_data_x", $time) ;
label25 : assert property (handshake_ar_r)   else $display("[%0t] Error! handshake_ar_r", $time) ;

endinterface