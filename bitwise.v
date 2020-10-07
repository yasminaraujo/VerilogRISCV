module bitwise_operators();

    initial begin
        // risc-v content
        // Bit Wise OR
        // ANDI, ORI, XORI are logical operations that perform bitwise AND, OR, and XOR on register rs1
        // and the sign-extended 12-bit immediate and place the result in rd. Note, XORI rd, rs1, -1 performs
        // a bitwise logical inversion of register rs1 (assembler pseudo-instruction NOT rd, rs).
        
        // $display (" 4'b0001 |  4'b1001 = %b", (4'b0001 |  4'b1001));
        // $display (" 4'b0001 |  4'bx001 = %b", (4'b0001 |  4'bx001));
        // $display (" 4'b0001 |  4'bz001 = %b", (4'b0001 |  4'bz001));
        // #10  $finish;

        // ler a instrucao no pc
        
        // enviar pro controllunit para marcar leitura e escrita do registrador, or para alu control e os demais comandos que nao sei
        
        // ler o registrador rs1 

        // pegar o immediate do rs1
        
        // fazer um or entre rs1 e rs1.immediate na alu 
        
        // escrever no reg o valor da alu
    end

endmodule
