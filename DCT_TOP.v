// Top with new 1D DCT, new TP memory
module Top_DCT_2D(DCT_out, clk, reset, counter_out, counter_out_m10, counter_out_m19, DO_MEM_IN, i_data, o_data, output_mem_addr);
                
parameter BW = 11;

output [12*8-1:0] DCT_out;
input clk, reset;

output [16-1:0] counter_out, counter_out_m10, counter_out_m19;
output [64-1:0] DO_MEM_IN; 
output [8*BW-1:0]  i_data;
output [8*BW-1:0] o_data;
output [15-1:0] output_mem_addr;

// output memory address
wire [15-1:0] output_mem_addr;

// DCT output
wire [12*8-1:0] DCT_out;
wire [12*8-1:0] dct_2d_out;

// for input memory
wire [64-1:0] DO_MEM_IN; 

// memory address
wire [11-1:0] MEM_IN_RA, MEM_OUT_RA;
wire [4-1:0] MEM_IN_CA, MEM_OUT_CA;

// for TP mem
wire [8*BW-1:0] i_data;
wire [8*BW-1:0] o_data;

wire [16-1:0] counter_out;
wire [16-1:0] counter_out_m10, counter_out_m19;


// for input memory
assign MEM_IN_RA = counter_out[14:4];
assign MEM_IN_CA = counter_out[3:0];

// for ourput memory
assign MEM_OUT_RA = counter_out_m19[14:4];
assign MEM_OUT_CA = counter_out_m19[3:0];
// output memory address
assign output_mem_addr = {MEM_OUT_RA, MEM_OUT_CA};

assign counter_out_m10 = counter_out - 16'd10;
assign counter_out_m19 = counter_out - 16'd19;

// input SRAM
// 11bit RA, 4bit CA
// SRAM32768x64 MEM_IN(NWRT_MEM_IN, DIN_MEM_IN, RA_MEM_IN, CA_MEM_IN, NCE_MEM_IN, clk, DO_MEM_IN);
SRAM32768x64 MEM_IN(.NWRT(1'b1), .DIN(), .RA(MEM_IN_RA), .CA(MEM_IN_CA), .NCE(1'b0), .CK(clk), .DO(DO_MEM_IN));

DCT_1D_8to11 #(.BW(BW)) dct_in (i_data, DO_MEM_IN);

TPmem_11b #(.BW(11) ) tp_new0 (.i_data(i_data), .i_clk(clk), .i_Reset(reset & ~(counter_out == 16'd0)), .o_data(o_data), .o_en());

DCT_1D11to12 #(.BW(BW)) dct_out (dct_2d_out, o_data);

TPmem_12b #(.BW(12) ) tp_new1 (.i_data(dct_2d_out), .i_clk(clk), .i_Reset(reset & ~(counter_out == 16'd9)), .o_data(DCT_out), .o_en());

// output SRAM
// 11bit RA, 4bit CA
// SRAM32768x96 MEM_OUT(NWRT, DIN, RA, CA, NCE, CLK, DO);
SRAM32768x96 MEM_OUT(.NWRT(1'b0), .DIN(DCT_out), .RA(MEM_OUT_RA), .CA(MEM_OUT_CA), .NCE(1'b0), .CK(clk), .DO());

counter_16bit c0 (counter_out, clk, reset);

endmodule


module counter_16bit(q, clk, reset);

output reg [16-1:0] q;
input clk, reset;

always @(posedge clk) begin
    if (!reset) begin
        q <= 16'd0;
    end 
    else begin
        q <= q + 1;
    end
end

endmodule

