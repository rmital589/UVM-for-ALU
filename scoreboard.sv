`include "uvm_macros.svh"
package scoreboard; 
import uvm_pkg::*;
import sequences::*;

class alu_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(alu_scoreboard)

    uvm_analysis_export #(alu_transaction_in) sb_in;
    uvm_analysis_export #(alu_transaction_out) sb_out;

    uvm_tlm_analysis_fifo #(alu_transaction_in) fifo_in;
    uvm_tlm_analysis_fifo #(alu_transaction_out) fifo_out;

    alu_transaction_in tx_in;
    alu_transaction_out tx_out;

    function new(string name, uvm_component parent);
        super.new(name,parent);
        tx_in=new("tx_in");
        tx_out=new("tx_out");
    endfunction: new

    function void build_phase(uvm_phase phase);
        sb_in=new("sb_in",this);
        sb_out=new("sb_out",this);
        fifo_in=new("fifo_in",this);
        fifo_out=new("fifo_out",this);
    endfunction: build_phase

    function void connect_phase(uvm_phase phase);
        sb_in.connect(fifo_in.analysis_export);
        sb_out.connect(fifo_out.analysis_export);
    endfunction: connect_phase

    task run();
        forever begin
            fifo_in.get(tx_in);
            fifo_out.get(tx_out);
            compare();
        end
    endtask: run

    extern virtual function [33:0] getresult; 
    extern virtual function void compare; 
        
endclass: alu_scoreboard

function void alu_scoreboard::compare;
    //TODO: Write this function to check whether the output of the DUT matches
    //the spec.
    //Use the getresult() function to get the spec output.
    //Consider using `uvm_info(ID,MSG,VERBOSITY) in this function to print the
    //results of the comparison.
    //You can use tx_in.convert2string() and tx_out.convert2string() for
    //debugging purposes
	if({tx_out.VOUT,tx_out.COUT,tx_out.OUT[31:0]} == getresult()) begin
		`uvm_info("compare",{"Test:OK"},UVM_LOW);
	end
	else begin
		`uvm_info("compare",{"TEST:FAIL"},UVM_LOW);
		 uvm_report_info("Input",{"Sending:\n ",tx_in.convert2string()});
		 uvm_report_info("Output",{"Sending:\n ",tx_out.convert2string()});
	end
endfunction

function [33:0] alu_scoreboard::getresult;
    //TODO: Remove the statement below
    //Modify this function to return a 34-bit result {VOUT, COUT,OUT[31:0]} which is
    //consistent with the given spec.
	logic [31:0] A = tx_in.A;
	logic [31:0]B = tx_in.B;
	logic cin = tx_in.CIN;
	logic [4:0] opcode = tx_in.opcode;
	logic rst = tx_in.rst;
	logic[31:0] out;
	logic vout;
	logic cout;
	int i = B[4:0];
	

		
		
		
			if(rst)
			begin
			out = 32'd0;
			vout = 0;
			cout = 0;
			end
			else
			begin
				case(opcode[4:3]) 
				2'b00: begin
					cout = 0;
					vout = 0;
						case(opcode[2:0])
							3'b111: out = A | B;
							3'b011: out = A ^ B;
							3'b000: out = ~A;
							3'b101: out = A & B;
							default: out = 32'd0;
						endcase
					end
				2'b01: begin
					cout =0;
					vout =0;
						case(opcode[2:0]) 
							3'b100: begin 
								 if(A<=B)
								 out = 32'd1;
								 else 
								 out = 32'd0;
								 end
							3'b001: begin 
								 if(A<B)
								 out = 32'd1;
								 else 
								 out = 32'd0;
								 end
							3'b110: begin 
								 if(A>=B)
								 out = 32'd1;
								 else 
								 out = 32'd0;
								 end
							3'b011: begin 
								 if(A>B)
								 out = 32'd1;
								 else 
								 out = 32'd0;
								 end
							3'b111: begin 
								 if(A==B)
								 out = 32'd1;
								 else 
								 out = 32'd0;
								 end
							3'b010: begin 
								 if(A!=B)
								 out = 32'd1;
								 else 
								 out = 32'd0;
								 end
							default: out = 32'd0;
  							endcase
					
				      end
				2'b10: begin
						case(opcode[2:0]) 
							3'b101: begin
								 {cout,out} = A+B+cin;
								  if ((!A[31] & !B[31]& cout) | (A[31] & B[31] & !cout))
									vout = 1'b1;
								  else
									vout = 1'b0;
								end
							3'b001: begin
								 {cout,out} = A+B+cin;
								  if (cout)
									vout = 1'b1;
								  else 
									vout = 1'b0;
								end
							3'b100: begin
								 {cout,out} = A + (~B) + cin;
								 if( (!A[31] & B[31] & cout ) | (A[31] & !B[31] & !cout ))
								 	vout = 1'b1;
								 else 
									vout = 1'b0;
								end
							3'b100: begin
								 {cout,out} = A + (~B) + cin;
							 	   if (cout)
									vout = 1'b1;
								  else 
									vout = 1'b0;
					                        end
							3'b111: begin
								{cout,out} = A+1;
								 vout = 1'b0;
								end
							3'b110: begin
								{cout,out} = A-1;
								 vout = 1'b0;
								end
							default: begin
								cout = 0;
								vout = 0;
								out = 32'd0;
								end
							endcase
					end
				2'b11: begin
						cout = 0; 
						case(opcode[2:0]) 
							3'b010: begin
								out = A << i;
								vout = 0; 
								end 
							3'b011: begin
								out = A >> i;
								vout = 0;
								end
							3'b100: begin
								out = A <<< i;
								if (out[31]!=A[31])
									vout =1'b1;
								else
									vout =1'b0;
								end
							3'b101: begin
								out = A >>>i;
								if (B[0])
									vout= 1'b1;
								else
									vout= 1'b0;
								end
							3'b000: begin
								vout = 0;
								out = (A<<i)+(A>>(32-i));
								end
							3'b001: begin
								vout = 0;
								out = (A>>i) + (A<<(32-i));
								end
							default: begin
								vout=0;
								out= 32'd0;
								end
						endcase
					end
			        endcase
				
			end
	

		return({vout,cout,out[31:0]});	
    
endfunction

endpackage: scoreboard
