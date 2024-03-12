`ifndef constraint_sv
`define constraint_sv
`define OK 2'b00 
`define SLERR 2'b01
`define FIXED 2'b00 
`define INCR 2'b01
// Burst
enum bit [1:0] { FIXED , INCR , WRAP , RESERVED } burst_type ;
// B respond
enum bit [1:0] { OK, EXOK, SLERR , DECERR } respond ;

`endif 