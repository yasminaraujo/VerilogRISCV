module fetch (input zero, rst, clk, branch, jump, input [31:0] sigext, output [31:0] inst);
  
  wire [31:0] pc, pc_4, new_pc;

  assign pc_4 = 4 + pc; // pc+4  Adder
  assign new_pc = (branch & zero) ? pc_4 + sigext : (jump? pc + sigext : pc_4); // new PC Mux
  
  PC program_counter(new_pc, clk, rst, pc);

  reg [31:0] inst_mem [0:31];

  assign inst = inst_mem[pc[31:2]];

  initial begin
    // Exemplos
    inst_mem[0] <= 32'h00000000; // nop
    //inst_mem[1] <= 32'h21C00D; // SWAP X3 X2
    //inst_mem[2] <= 32'h00210233; // add  x4, x2, x2  ok
	//inst_mem[1] <= 32'b11111111111100000000000100001110; // storeSum
	  //inst_mem[1] <= 32'b00000000001100010000000000001111; // lwi  ok
	  //inst_mem[1] <= 32'b00000000001000000000000000001101; //swap x0 x1
	 	//inst_mem[2] <= 32'h0000a003; // lw x1, x0(0) ok
	    //inst_mem[1] <= 32'hfff00113; // addi x2,x0,-1 ok
	    //inst_mem[2] <= 32'h00318133; // add x2, x3, x3 ok
	    //inst_mem[3] <= 32'h40328133; // sub x2, x5, x3 ok
		  // inst_mem[1] <= 32'h506213;    // ori x4, x0, 5
	// inst_mem[2] <= 32'h221293;    // slli x5, x4, 2
	// inst_mem[2] <= 32'h7CD2B7;    // lui x5 1997
	// inst_mem[0] <= 32'h00000000; // 0  nop
	// inst_mem[1] <= 32'h00206413; // 4  ori x8, x0, 2
	// inst_mem[2] <= 32'h00306493; // 8  ori x9, x0, 3
	// inst_mem[3] <= 32'h00944463; // 12 blt x8 x9 8 pula duas instrucoes, vai para 24
	// inst_mem[4] <= 32'h00248413; // 16 addi x8, x9, 2  
	// inst_mem[5] <= 32'h00548413; // 20 addi x8, x9, 5  
	// inst_mem[6] <= 32'hfe944ae3; // 24 blt x8 x9 -12 volta duas instrucoes, vai para 16
	//inst_mem[0] <= 32'h00000000;  // 0  nop
	//inst_mem[1] <= 32'h00206413;  // 4  ori x8, x0, 2
	//inst_mem[2] <= 32'h00306493;  // 8  ori x9, x0, 3
	//inst_mem[3] <= 32'h0084d463;  // 12 bge x9 x8 8 pula duas instrucoes, vai para 24
	//inst_mem[4] <= 32'h00248413;  // 16 addi x8, x9, 2  
	//inst_mem[5] <= 32'h00548413;  // 20 addi x8, x9, 5  
	//inst_mem[6] <= 32'hfe84dae3;  // 24 bge x9 x8 -12 volta duas instrucoes, vai para 16
  end
  
endmodule

module PC (input [31:0] pc_in, input clk, rst, output reg [31:0] pc_out);

  always @(posedge clk) begin
    pc_out <= pc_in;
    if (~rst)
      pc_out <= 0;
  end

endmodule

module decode (input [31:0] inst, writedata, input clk, output [31:0] data1, data2, ImmGen, output alusrc, memread, memwrite, memtoreg, branch, jump,  output [1:0] aluop, output [9:0] funct);
  
  wire branch, jump, memread, memtoreg, MemWrite, alusrc, regwrite;
  wire [1:0] aluop; 
  wire [4:0] writereg, rs1, rs2, rd;
  wire [6:0] opcode;
  wire [9:0] funct;
  wire [31:0] ImmGen;

  assign opcode = inst[6:0];
  assign rs1    = inst[19:15];
  assign rs2    = inst[24:20];
  assign rd     = inst[11:7];
  assign funct = {inst[31:25],inst[14:12]};

  ControlUnit control (opcode, inst, alusrc, memtoreg, regwrite, memread, memwrite, branch,jump, swap, aluop, ImmGen);
  
  Register_Bank Registers (clk, regwrite, rs1, rs2, rd, swap, writedata, data1, data2); 

endmodule

module ControlUnit (input [6:0] opcode, input [31:0] inst, output reg alusrc, memtoreg, regwrite, memread, memwrite, branch, jump, swap, output reg [1:0] aluop, output reg [31:0] ImmGen);

  always @(opcode) begin
    alusrc   <= 0;
    memtoreg <= 0;
    regwrite <= 0;
    memread  <= 0;
    memwrite <= 0;
    branch   <= 0;
    aluop    <= 0;
    ImmGen   <= 0; 
    swap <= 0;
    jump <=0;
    case(opcode) 
      7'b0110011: begin // R type == 51
        regwrite <= 1;
        aluop    <= 2;
			end
		  7'b1100011: begin // beq == 99
        branch   <= 1;
        aluop    <= 1;
        ImmGen   <= {{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
			end
      7'b1100100: begin // blt == 100
        branch   <= 1;
        aluop    <= 3;
        ImmGen   <= {{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
			end
      7'b1100101: begin // bge == 101
        branch   <= 1;
        aluop    <= 4;
        ImmGen   <= {{19{inst[31]}},inst[31],inst[7],inst[30:25],inst[11:8],1'b0};
			end
			7'b0010011: begin // addi == 19
        alusrc   <= 1;
        regwrite <= 1;
        ImmGen   <= {{20{inst[31]}},inst[31:20]};
        aluop <= 2;
      end
			7'b0000011: begin // lw == 3
        alusrc   <= 1;
        memtoreg <= 1;
        regwrite <= 1;
        memread  <= 1;
        ImmGen   <= {{20{inst[31]}},inst[31:20]};
      end
			7'b0100011: begin // sw == 35
        alusrc   <= 1;
        memwrite <= 1;
        ImmGen   <= {{20{inst[31]}},inst[31:25],inst[11:7]};
      end
      7'b0001101:begin //swap == 13 TODO
        swap <= 1;
      end
      7'b0001110:begin //storeSum == 14
        alusrc   <= 1;
        regwrite <= 1;
        memtoreg <= 1;
        ImmGen   <= {{20{inst[31]}},inst[31:20]};
      end
      7'b0001111:begin //lwi 15
        regwrite <= 1;
        memtoreg <= 1;
        memread  <= 1;
        aluop <= 2;
      end
       7'b0110111: begin // lui   
        alusrc   <= 1;
        regwrite <= 1;
        aluop    <= 5;
        ImmGen   <= {{12{inst[31]}},inst[31:12]};
      end
      7'b1101111: begin // jump == 111
        jump <= 1;
        ImmGen   <= {{12{inst[31]}},inst[19:12],inst[20],inst[30:21]};
      end
    endcase
  end

endmodule 

module Register_Bank (input clk, regwrite, input [4:0] read_reg1, read_reg2, writereg, swap, input [31:0] writedata, output [31:0] read_data1, read_data2);

  integer i;
  reg [31:0] memory [0:31]; // 32 registers de 32 bits cada

  // fill the memory
  initial begin
    for (i = 0; i <= 31; i++) 
      memory[i] <= i;
  end

  assign read_data1 = (regwrite && read_reg1==writereg) ? writedata : memory[read_reg1];
  assign read_data2 = (regwrite && read_reg2==writereg) ? writedata : memory[read_reg2];
	
  always @(posedge clk) begin
    if (regwrite)
      memory[writereg] <= writedata;
    if(swap) begin
      memory[read_reg1] = read_reg2;
      memory[read_reg2] = read_reg1;
    end
  end
  
endmodule

module execute (input [31:0] in1, in2, ImmGen, input alusrc, input [1:0] aluop, input [9:0] funct, output zero, output [31:0] aluout);

  wire [31:0] alu_B;
  wire [3:0] aluctrl;
  
  assign alu_B = (alusrc) ? ImmGen : in2 ;

  //Unidade Lógico Aritimética
  ALU alu (aluctrl, in1, alu_B, aluout, zero);

  alucontrol alucontrol (aluop, funct, aluctrl);

endmodule

module alucontrol (input [1:0] aluop, input [9:0] funct, output reg [3:0] alucontrol);
  
  wire [7:0] funct7;
  wire [2:0] funct3;

  assign funct3 = funct[2:0];
  assign funct7 = funct[9:3];

  always @(aluop) begin
    case (aluop)
      0: alucontrol <= 4'd2; // ADD to SW and LW
      1: alucontrol <= 4'd6; // SUB to branch
      2: begin
        case(funct3)
          0: alucontrol <= 4'd2;
          1: alucontrol <= 4'd12;
          6: alucontrol <= 4'd1;
        endcase
      end
      3: alucontrol <= 4'd8; //SLT to BLT
      4: alucontrol <= 4'd9; //greater or equal BGE
      5: alucontrol <= 4'd10; // SHIFT to LUI

      default: begin
        case (funct3)
          0: alucontrol <= (funct7 == 0) ? /*ADD*/ 4'd2 : /*SUB*/ 4'd6; 
          2: alucontrol <= 4'd7; // SLT
          6: alucontrol <= 4'd1; // OR
          //39: alucontrol <= 4'd12; // NOR
          7: alucontrol <= 4'd0; // AND
          default: alucontrol <= 4'd15; // Nop
        endcase
      end
    endcase
  end
endmodule

module ALU (input [3:0] alucontrol, input [31:0] A, B, output reg [31:0] aluout, output zero);
  
  assign zero = (aluout == 0); // Zero recebe um valor lógico caso aluout seja igual a zero.
  
  always @(alucontrol, A, B) begin
      case (alucontrol)
        0: aluout <= A & B; // AND
        1: aluout <= A | B; // OR
        2: aluout <= A + B; // ADD
        6: aluout <= A - B; // SUB
        7: aluout <= A < B ? 32'd1:32'd0; //SLT
        8: aluout <= A < B ? 32'd0:32'd1; //Condicional para BLT
        9: aluout <= A >= B ? 32'd0:32'd1;
        12: aluout <= A << B;
      default: aluout <= 0; //default 0, Nada acontece;
    endcase
  end
endmodule

module memory (input [31:0] address, writedata, input memread, memwrite, clk, output [31:0] readdata);

  integer i;
  reg [31:0] memory [0:127]; 
  
  // fill the memory
  initial begin
    for (i = 0; i <= 127; i++) 
      memory[i] <= i;
  end

  assign readdata = (memread) ? memory[address[31:2]] : 0;

  always @(posedge clk) begin
    if (memwrite)
      memory[address[31:2]] <= writedata;
	end
endmodule

module writeback (input [31:0] aluout, readdata, input memtoreg, output reg [31:0] write_data);
  always @(memtoreg) begin
    write_data <= (memtoreg) ? readdata : aluout;
  end
endmodule

// TOP -------------------------------------------
module mips (input clk, rst, output [31:0] writedata);
  
  wire [31:0] inst, sigext, data1, data2, aluout, readdata;
  wire zero, memread, memwrite, memtoreg, branch, jump, alusrc, swap;
  wire [9:0] funct;
  wire [1:0] aluop;
  
  // FETCH STAGE
  fetch fetch (zero, rst, clk, branch, jump, sigext, inst);
  
  // DECODE STAGE
  decode decode (inst, writedata, clk, data1, data2, sigext, alusrc, memread, memwrite, memtoreg, branch, jump, aluop, funct);   
  
  // EXECUTE STAGE
  execute execute (data1, data2, sigext, alusrc, aluop, funct, zero, aluout);

  // MEMORY STAGE
  memory memory (aluout, data2, memread, memwrite, clk, readdata);

  // WRITEBACK STAGE
  writeback writeback (aluout, readdata, memtoreg, writedata);

endmodule
