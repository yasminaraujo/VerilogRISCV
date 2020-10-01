module shift_operators();

    initial begin
        // Left Shift
        // Shifts by a constant are encoded as a specialization of the I-type format. The operand to be shifted
        // is in rs1, and the shift amount is encoded in the lower 5 bits of the I-immediate field. The right
        // shift type is encoded in a high bit of the I-immediate. SLLI is a logical left shift (zeros are shifted
        // into the lower bits); SRLI is a logical right shift (zeros are shifted into the upper bits); and SRAI
        // is an arithmetic right shift (the original sign bit is copied into the vacated upper bits).
        
        $display (" 4'b1001 << 1 = %b", (4'b1001 << 1));
        $display (" 4'b10x1 << 1 = %b", (4'b10x1 << 1));
        $display (" 4'b10z1 << 1 = %b", (4'b10z1 << 1));
        #10  $finish;
    end

endmodule