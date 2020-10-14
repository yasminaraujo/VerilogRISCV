module fetch (input zero, rst, clk, branch, jump, input [31:0] sigext, output [31:0] inst);
  
  wire [31:0] pc, pc_4, new_pc;

  assign pc_4 = 4 + pc; // pc+4  Adder
  assign new_pc = (branch & zero) ? pc_4 + sigext : (jump? pc + sigext : pc_4); // new PC Mux

  PC program_counter(new_pc, clk, rst, pc);

  reg [31:0] inst_mem [0:31];

  assign inst = inst_mem[pc[31:2]];

  initial begin
    //=============ORI
    // inst_mem[0] <= 32'h00000000; // nop
    // inst_mem[1] <= 32'h106093;   // ori x1, x0, 1
    // inst_mem[2] <= 32'h20E113;   // ori x2, x1, 2 
    // inst_mem[3] <= 32'ha36293;   //ori x5, x6, 10
    // inst_mem[4] <= 32'h546313;   //ori x6, x8, 5
    //=============SLLI
    // inst_mem[0] <= 32'h00000000;  // nop
    // inst_mem[1] <= 32'h506213;    // ori x4, x0, 5
    // inst_mem[2] <= 32'h221293;    // slli x5, x4, 2
    //=============LUI
    // inst_mem[0] <= 32'h00000000;  // nop
    // inst_mem[1] <= 32'h5337;      // lui x6 5
    // inst_mem[2] <= 32'h7CD2B7;    // lui x5 1997
    //=============LWI
    //inst_mem[0] <= 32'h00000000;  // nop
    //inst_mem[1] <= 32'h406093;    // ori x1 x0 4
    //inst_mem[2] <= 32'h406113;    // ori x2 x0 4
    //inst_mem[3] <= 32'h208181;    // lwi x3 x1 x2
    //inst_mem[4] <= 32'h109113;    // slli x2 x1 1
    //inst_mem[5] <= 32'h208181;    // lwi x3 x1 x2
    //=============SWAP
    inst_mem[0] <= 32'h00000000;  // nop
    inst_mem[1] <= 32'h520002;    // swap x4 x5
    inst_mem[2] <= 32'h660002;    // swap x12 x6
    //=============SS
    // inst_mem[0] <= 32'h00000000;  // nop
    // inst_mem[1] <= 32'h508004;    // ss x1 x5 0
    // inst_mem[2] <= 32'h508284;    // ss x1 x5 5
    // inst_mem[3] <= 32'h248684;    // ss x9 x2 13
    //=============BLT
    // inst_mem[0] <= 32'h00000000; // 0  nop
    // inst_mem[1] <= 32'h00206413; // 4  ori x8, x0, 2
    // inst_mem[2] <= 32'h00306493; // 8  ori x9, x0, 3
    // inst_mem[3] <= 32'h00944463; // 12 blt x8 x9 8 pula duas instrucoes, vai para 24
    // inst_mem[4] <= 32'h00248413; // 16 addi x8, x9, 2  
    // inst_mem[5] <= 32'h00548413; // 20 addi x8, x9, 5  
    // inst_mem[6] <= 32'hfe944ae3; // 24 blt x8 x9 -12 volta duas instrucoes, vai para 16
    //=============BGE
    //inst_mem[0] <= 32'h00000000;  // 0  nop
    //inst_mem[1] <= 32'h00206413;  // 4  ori x8, x0, 2
    //inst_mem[2] <= 32'h00306493;  // 8  ori x9, x0, 3
    //inst_mem[3] <= 32'h0084d463;  // 12 bge x9 x8 8 pula duas instrucoes, vai para 24
    //inst_mem[4] <= 32'h00248413;  // 16 addi x8, x9, 2  
    //inst_mem[5] <= 32'h00548413;  // 20 addi x8, x9, 5  
    //inst_mem[6] <= 32'hfe84dae3;  // 24 bge x9 x8 -12 volta duas instrucoes, vai para 16
    //=============J
    // inst_mem[0] <= 32'h00000000;  // 0  nop
    // inst_mem[1] <= 32'h00206413;  // 4  ori x8, x0, 2
    // inst_mem[2] <= 32'h00306493;  // 8  ori x9, x0, 3
    // inst_mem[3] <= 32'h0084d463;  // 12 bge x9 x8 8 pula duas instrucoes, vai para 24
    // inst_mem[4] <= 32'h00248413;  // 16 addi x8, x9, 2  
    // inst_mem[5] <= 32'h00548413;  // 20 addi x8, x9, 5  
    // inst_mem[6] <= 32'hfe84dae3;  // 24 bge x9 x8 -12 volta duas instrucoes, vai para 16
  end
  
endmodule

module PC (input [31:0] pc_in, input clk, rst, output reg [31:0] pc_out);

  always @(posedge clk) begin
    pc_out <= pc_in;
    if (~rst)
      pc_out <= 0;
  end

endmodule

module decode (input [31:0] inst, writedata, input clk, output [31:0] data1, data2, ImmGen, output alusrc, memread, memwrite, memtoreg, branch, jump, aluwrite, output [1:0] aluop, output [9:0] funct);
  
  wire branch, jump, memread, memtoreg, MemWrite, alusrc, regwrite, regswap, aluwrite;
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

  ControlUnit control (opcode, inst, alusrc, aluwrite, memtoreg, regwrite, regswap, memread, memwrite, branch, jump, aluop, ImmGen);
  
  Register_Bank Registers (clk, regwrite, regswap, rs1, rs2, rd, writedata, data1, data2); 

endmodule

module ControlUnit (input [6:0] opcode, input [31:0] inst, output reg alusrc, aluwrite, memtoreg, regwrite, regswap, memread, memwrite, branch, jump, output reg [1:0] aluop, output reg [31:0] ImmGen);

  always @(opcode) begin
    alusrc   <= 0;
    memtoreg <= 0;
    regwrite <= 0;
    regswap  <= 0;
    memread  <= 0;
    memwrite <= 0;
    branch   <= 0;
    jump 	   <= 0; 
    aluop    <= 0;
    ImmGen   <= 0;
    aluwrite <= 0;
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
			7'b0010011: begin // addi == 19
        alusrc   <= 1;
       	aluop 	 <= 2;
        regwrite <= 1;
        ImmGen   <= {{20{inst[31]}},inst[31:20]};
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
      7'b1101111: begin // Jump
        jump <= 1;
        ImmGen  <= {{12{inst[31]}},inst[19:12],inst[20],inst[30:21],inst[31]};
      end
      7'b0110111: begin // lui == 55  
        alusrc   <= 1;
        regwrite <= 1;
        aluop    <= 3;
        ImmGen   <= {{12{inst[31]}},inst[31:12]};
      end
      7'b0000010: begin // swap == 2
        regswap <= 1;
      end
      7'b0000001: begin // lwi == 1
        regwrite <= 1;
        memread <= 1;
        memtoreg <= 1;
      end
      7'b0000100: begin // S type == 4
        alusrc   <= 1;
        memwrite <= 1;
        ImmGen   <= {{20{inst[31]}},inst[31:25],inst[11:7]};
        aluwrite <= 1;
      end
      7'b1101111: begin // jump == 111
        jump <= 1;
        ImmGen   <= {{12{inst[31]}},inst[19:12],inst[20],inst[30:21]};
      end
    endcase
  end

endmodule 

module Register_Bank (input clk, regwrite, regswap, input [4:0] read_reg1, read_reg2, writereg, input [31:0] writedata, output [31:0] read_data1, read_data2);

  integer i;
  reg [31:0] memory [0:31]; // 32 registers de 32 bits cada

  // fill the memory
  initial begin
    for (i = 0; i <= 31; i++) 
      memory[i] <= i;
  end
  // Luiz
  assign read_data1 = (regwrite && read_reg1==writereg) ? writedata : memory[read_reg1];
  assign read_data2 = (regwrite && read_reg2==writereg) ? writedata : memory[read_reg2];
	
  always @(posedge clk) begin
    if (regwrite) begin
      memory[writereg] <= writedata;
    end
    else if (regswap) begin
      memory[read_reg1] <= read_data2;
      memory[read_reg2] <= read_data1;
    end 
  end
  
endmodule

module execute (input [31:0] in1, in2, ImmGen, input alusrc, aluwrite, input [1:0] aluop, input [9:0] funct, output zero, output [31:0] aluout);

  wire [31:0] alu_A;
  wire [31:0] alu_B;
  wire [3:0] aluctrl;
  
  assign alu_A = (aluwrite) ? in2 : in1;
  assign alu_B = (alusrc) ? ImmGen : in2 ;

  //Unidade Lógico Aritimética
  ALU alu (aluctrl, alu_A, alu_B, aluout, zero);

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
      1: begin
        case (funct3)
          4: alucontrol <= 4'd5;
          5: alucontrol <= 4'd9;  // GET (greater or equal) to branch
          default: alucontrol <= 4'd6; // SUB to branch
        endcase
      end
      2: begin
        case(funct3)
          0: alucontrol <= 4'd2;
          1: alucontrol <= 4'd8;
          6: alucontrol <= 4'd1;
        endcase
      end
      3: alucontrol <= 4'd10; // SHIFT to LUI
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
        5: aluout <= (A < B) ? 0 : 1; //BLT
        6: aluout <= A - B; // SUB
        8: aluout <= A << B;
        9: aluout <= (A >= B) ? 0 : 1; // GET 
        10: aluout <= B << 12; // LUI
        
        //7: aluout <= A < B ? 32'd1:32'd0; //SLT
        //12: aluout <= ~(A | B); // NOR
      default: aluout <= 0; //default 0, Nada acontece;
    endcase
  end
endmodule

module MUX1(input aluwrite, input [31:0] aluout, data1, output [31:0] adress, mux_write);
  assign adress = (aluwrite) ? data1 : aluout;
  assign mux_write = (aluwrite) ? aluout : data1;
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
  
  wire [31:0] inst, sigext, data1, data2, aluout, readdata, mux_write, address;
  wire zero, memread, memwrite, memtoreg, branch, jump, alusrc, aluwrite;
  wire [9:0] funct;
  wire [1:0] aluop;
  
  // FETCH STAGE
  fetch fetch (zero, rst, clk, branch, jump, sigext, inst);
  
  // DECODE STAGE
  decode decode (inst, writedata, clk, data1, data2, sigext, alusrc, memread, memwrite, memtoreg, branch, jump, aluwrite, aluop, funct);   
  
  // EXECUTE STAGE
  execute execute (data1, data2, sigext, alusrc, aluwrite, aluop, funct, zero, aluout);

  // MEMORY STAGE
  MUX1 MUX1 (aluwrite, aluout, data1, address, mux_write);
  memory memory (address, mux_write, memread, memwrite, clk, readdata); 

  // WRITEBACK STAGE
  writeback writeback (aluout, readdata, memtoreg, writedata);

endmodule
