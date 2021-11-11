module datapath(input slow_clock, input fast_clock, input resetb,
                input load_pcard1, input load_pcard2, input load_pcard3,
                input load_dcard1, input load_dcard2, input load_dcard3,
                output [3:0] pcard3_out,
                output [3:0] pscore_out, output [3:0] dscore_out,
                output[6:0] HEX5, output[6:0] HEX4, output[6:0] HEX3,
                output[6:0] HEX2, output[6:0] HEX1, output[6:0] HEX0);
						
// The code describing your datapath will go here.  Your datapath 
// will hierarchically instantiate six card7seg blocks, two scorehand
// blocks, and a dealcard block.  The registers may either be instatiated
// or included as sequential always blocks directly in this file.
//
// Follow the block diagram in the Lab 1 handout closely as you write this code.

    wire [3:0] new_card, pcard1, pcard2, pcard3, dcard1, dcard2, dcard3;

    assign pcard3_out = pcard3;

    dealcard dc(fast_clock, resetb, new_card);

    reg4 preg1(slow_clock, load_pcard1, resetb, new_card, pcard1);
    reg4 preg2(slow_clock, load_pcard2, resetb, new_card, pcard2);
    reg4 preg3(slow_clock, load_pcard3, resetb, new_card, pcard3);
    reg4 dreg1(slow_clock, load_dcard1, resetb, new_card, dcard1);
    reg4 dreg2(slow_clock, load_dcard2, resetb, new_card, dcard2);
    reg4 dreg3(slow_clock, load_dcard3, resetb, new_card, dcard3);

    card7seg pled1(pcard1, HEX0);
    card7seg pled2(pcard2, HEX1);
    card7seg pled3(pcard3, HEX2);
    card7seg dled1(dcard1, HEX3);
    card7seg dled2(dcard2, HEX4);
    card7seg dled3(dcard3, HEX5);

    scorehand psum(pcard1, pcard2, pcard3, pscore_out);
    scorehand dsum(dcard1, dcard2, dcard3, dscore_out);

endmodule

