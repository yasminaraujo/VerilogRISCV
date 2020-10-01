module bitwise_operators();

    initial begin
        // Bit Wise OR
        // ANDI, ORI, XORI are logical operations that perform bitwise AND, OR, and XOR on register rs1
        // and the sign-extended 12-bit immediate and place the result in rd. Note, XORI rd, rs1, -1 performs
        // a bitwise logical inversion of register rs1 (assembler pseudo-instruction NOT rd, rs).
        
        $display (" 4'b0001 |  4'b1001 = %b", (4'b0001 |  4'b1001));
        $display (" 4'b0001 |  4'bx001 = %b", (4'b0001 |  4'bx001));
        $display (" 4'b0001 |  4'bz001 = %b", (4'b0001 |  4'bz001));
        #10  $finish;
    end

endmodule