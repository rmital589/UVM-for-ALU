`include "uvm_macros.svh"
package coverage;
import sequences::*;
import uvm_pkg::*;

class alu_subscriber_in extends uvm_subscriber #(alu_transaction_in);
    `uvm_component_utils(alu_subscriber_in)

    //Declare Variables
    logic [31:0] A;
    logic [31:0] B;
    logic [4:0] opcode;
    logic cin;

    //TODO: Add covergroups for the inputs
    covergroup inputs;
	coverpoint opcode{
		bins nop = {5'b00001, 5'b00010, 5'b00100, 5'b00110, 5'b01000, 5'b01101, 5'b10010, 5'b10011, 5'b10110, 5'b10111};
		bins l_or = {5'b00111};
		bins l_xor = {5'b00011};
		bins l_not = {5'b00000};
		bins l_and = {5'b00101};
		bins sle = {5'b01100};
		bins slt = {5'b01001};
		bins sge = {5'b01110};
		bins sgt = {5'b01011};
		bins seq = {5'b01111};
		bins sne = {5'b01010};
		bins add = {5'b10101};
		bins addu = {5'b10001};
		bins sub = {5'b10100};
		bins subu = {5'b10000};
		bins inc = {5'b10111};
		bins dec = {5'b10110};
		bins sll = {5'b11010};
		bins srl = {5'b11011};
		bins sla = {5'b11100};
		bins sra = {5'b11101};
		bins slr = {5'b11000};
		bins srr = {5'b11001};	
}
	
    endgroup: inputs
    

    function new(string name, uvm_component parent);
        super.new(name,parent);
         //TODO: Uncomment
        inputs=new;
    endfunction: new

    function void write(alu_transaction_in t);
        A={t.A};
        B={t.B};
        opcode={t.opcode};
        cin={t.CIN};
        // TODO: Uncomment
        inputs.sample();
        
    endfunction: write

endclass: alu_subscriber_in

class alu_subscriber_out extends uvm_subscriber #(alu_transaction_out);
    `uvm_component_utils(alu_subscriber_out)

    logic [31:0] out;
    logic cout;
    logic vout;

    //TODO: Add covergroups for the outputs
    
     covergroup outputs;
	coverpoint cout{
		bins no_carry = {0};
		bins carry    = {1};
	}
	coverpoint vout{
		bins no_overflow = {0};
		bins overflow    = {1};
	} 
     endgroup: outputs
    

function new(string name, uvm_component parent);
    super.new(name,parent);
    // TODO: Uncomment
     outputs=new;
    
endfunction: new

function void write(alu_transaction_out t);
    out={t.OUT};
    cout={t.COUT};
    vout={t.VOUT};
    //TODO: Uncomment
     outputs.sample();
    
endfunction: write
endclass: alu_subscriber_out

endpackage: coverage
