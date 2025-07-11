// 1D without any optimization
// with making line 7, 8 zero

// 8 * 8bit input to 8 * BW bit output
module DCT_1D_8to11(DCT_out, DCT_in);

    parameter BW = 11;

    output [8*BW-1:0] DCT_out;
    input [64-1:0] DCT_in;

    // // 8 bit parameters
    // // (8, 7) fixed point
    // localparam signed c4 = 8'h2d;
    // localparam signed c1 = 8'h3f;
    // localparam signed c2 = 8'h3b;
    // localparam signed c3 = 8'h35;
    // // localparam signed c4 = 8'h2d;
    // localparam signed c5 = 8'h24;
    // localparam signed c6 = 8'h18;
    // localparam signed c7 = 8'hc;

    // For simplification
    localparam signed c4 = 8'h2d;
    localparam signed c1 = 8'h3f;
    localparam signed c2 = 8'h3f;
    localparam signed c3 = 8'h35;
    // localparam signed c4 = 8'h2d;
    localparam signed c5 = 8'h24;
    localparam signed c6 = 8'h18;
    localparam signed c7 = 8'hc;    

    wire [8-1:0] data_in [0:7];

    wire signed [11-1:0] even_p_07;
    wire signed [11-1:0] even_p_16;
    wire signed [11-1:0] even_p_25;
    wire signed [11-1:0] even_p_34;
    wire signed [11-1:0] even_m_07;
    wire signed [11-1:0] even_m_16;
    wire signed [11-1:0] even_m_25;
    wire signed [11-1:0] even_m_34;

    wire signed [21-1:0] acc [0:7];
    wire signed [BW-1:0] acc_rounded [0:7];

    /*
Deviding input data
for i in range(8):
    print(f"assign data_in[{i}] = DCT_in[{i*8+7}:{i*8}];")
    */
    assign data_in[7] = DCT_in[7:0];
    assign data_in[6] = DCT_in[15:8];
    assign data_in[5] = DCT_in[23:16];
    assign data_in[4] = DCT_in[31:24];
    assign data_in[3] = DCT_in[39:32];
    assign data_in[2] = DCT_in[47:40];
    assign data_in[1] = DCT_in[55:48];
    assign data_in[0] = DCT_in[63:56];

    // sign extension for data_in (all positive) 8bit -> 9bit
    //9bit + 9bit = 10bit
    assign even_p_07 = {1'b0, data_in[0]} + {1'b0, data_in[7]};
    assign even_p_16 = {1'b0, data_in[1]} + {1'b0, data_in[6]};
    assign even_p_25 = {1'b0, data_in[2]} + {1'b0, data_in[5]};
    assign even_p_34 = {1'b0, data_in[3]} + {1'b0, data_in[4]};
    assign even_m_07 = {1'b0, data_in[0]} - {1'b0, data_in[7]};
    assign even_m_16 = {1'b0, data_in[1]} - {1'b0, data_in[6]};
    assign even_m_25 = {1'b0, data_in[2]} - {1'b0, data_in[5]};
    assign even_m_34 = {1'b0, data_in[3]} - {1'b0, data_in[4]};    

    // accumulation
    // 10bit * 8bit * 4 = 24bit + 1 sign bit
    // (10, 0) * (8, 7) = (18, 7)
    // (18, 7) * 4 = (21, 7)
    assign acc[0] = c4 * even_p_07 + c4 * even_p_16 + c4 * even_p_25 + c4 * even_p_34;
    assign acc[2] = c2 * even_p_07 + c6 * even_p_16 - c6 * even_p_25 - c2 * even_p_34;
    assign acc[4] = c4 * even_p_07 - c4 * even_p_16 - c4 * even_p_25 + c4 * even_p_34;
    // assign acc[6] = c6 * even_p_07 - c2 * even_p_16 + c2 * even_p_25 - c6 * even_p_34;
    assign acc[1] = c1 * even_m_07 + c3 * even_m_16 + c5 * even_m_25 + c7 * even_m_34;
    assign acc[3] = c3 * even_m_07 - c7 * even_m_16 - c1 * even_m_25 - c5 * even_m_34;
    assign acc[5] = c5 * even_m_07 - c1 * even_m_16 + c7 * even_m_25 + c3 * even_m_34;
    // assign acc[7] = c7 * even_m_07 - c5 * even_m_16 + c3 * even_m_25 - c1 * even_m_34;

    // Truncation
    // 24 bit -> BW bit
    // (21, 7) -> (BW, 2)
    // (21, 7) -> (BW, 0) for acc_rounded[0]
    //assign acc_rounded[0] = acc[0] [9+BW-1:9]; // for DC output
    assign acc_rounded[0] = acc[0] [7+BW-1:7];
    assign acc_rounded[2] = acc[2] [5+BW-1:5];
    assign acc_rounded[4] = acc[4] [5+BW-1:5];
    // assign acc_rounded[6] = acc[6] [5+BW-1:5];
    assign acc_rounded[1] = acc[1] [5+BW-1:5];
    assign acc_rounded[3] = acc[3] [5+BW-1:5];
    assign acc_rounded[5] = acc[5] [5+BW-1:5];
    // assign acc_rounded[7] = acc[7] [5+BW-1:5];

    // assign DCT_out = {acc_rounded[0], acc_rounded[1], acc_rounded[2], acc_rounded[3], acc_rounded[4], acc_rounded[5], acc_rounded[6], acc_rounded[7]};
    assign DCT_out = {acc_rounded[0], acc_rounded[1], acc_rounded[2], acc_rounded[3], acc_rounded[4], acc_rounded[5], 22'd0};

endmodule


module DCT_1D11to12(DCT_out, DCT_in);

    parameter BW = 11;

    output [12*8-1:0] DCT_out;
    input [8*BW-1:0] DCT_in;

    // // 8 bit parameters
    // // (8, 7) fixed point
    // localparam signed c4 = 8'h2d;
    // localparam signed c1 = 8'h3f;
    // localparam signed c2 = 8'h3b;
    // localparam signed c3 = 8'h35;
    // // localparam signed c4 = 8'h2d;
    // localparam signed c5 = 8'h24;
    // localparam signed c6 = 8'h18;
    // localparam signed c7 = 8'hc;

    // For simplification
    localparam signed c4 = 8'h2d;
    localparam signed c1 = 8'h3f;
    localparam signed c2 = 8'h3f;
    localparam signed c3 = 8'h35;
    // localparam signed c4 = 8'h2d;
    localparam signed c5 = 8'h24;
    localparam signed c6 = 8'h18;
    localparam signed c7 = 8'hc;   



    wire signed [BW-1:0] data_in [0:7];

    wire signed [BW+2-1:0] even_p_07;
    wire signed [BW+2-1:0] even_p_16;
    wire signed [BW+2-1:0] even_p_25;
    wire signed [BW+2-1:0] even_p_34;
    wire signed [BW+2-1:0] even_m_07;
    wire signed [BW+2-1:0] even_m_16;
    wire signed [BW+2-1:0] even_m_25;
    wire signed [BW+2-1:0] even_m_34;

    wire signed [BW+16-1:0] acc [0:7];
    wire signed [12-1:0] acc_rounded [0:7];

    /*
Deviding input data
for i in range(8):
    print(f"assign data_in[{i}] = DCT_in[BW*{i+1}-1}:BW*{i}];")
    */
    assign data_in[7] = DCT_in[BW*1-1:BW*0];
    assign data_in[6] = DCT_in[BW*2-1:BW*1];
    assign data_in[5] = DCT_in[BW*3-1:BW*2];
    assign data_in[4] = DCT_in[BW*4-1:BW*3];
    assign data_in[3] = DCT_in[BW*5-1:BW*4];
    assign data_in[2] = DCT_in[BW*6-1:BW*5];
    assign data_in[1] = DCT_in[BW*7-1:BW*6];
    assign data_in[0] = DCT_in[BW*8-1:BW*7]; 

    // (BW + 1) bit + (BW + 1) bit = (BW + 2)bit
    // (BW+1 ,2) + (BW+1 ,2) => (BW+3, 2)
    assign even_p_07 = data_in[0] + data_in[7];
    assign even_p_16 = data_in[1] + data_in[6];
    assign even_p_25 = data_in[2] + data_in[5];
    assign even_p_34 = data_in[3] + data_in[4];
    assign even_m_07 = data_in[0] - data_in[7];
    assign even_m_16 = data_in[1] - data_in[6];
    assign even_m_25 = data_in[2] - data_in[5];
    assign even_m_34 = data_in[3] - data_in[4];    

    // accumulation
    // (BW + 3)bit * 10bit * 4 = BW+16bit
    // (BW+2, 2) * (10,9) => (BW+12,11)
    assign acc[0] = c4 * even_p_07 + c4 * even_p_16 + c4 * even_p_25 + c4 * even_p_34;
    assign acc[2] = c2 * even_p_07 + c6 * even_p_16 - c6 * even_p_25 - c2 * even_p_34;
    assign acc[4] = c4 * even_p_07 - c4 * even_p_16 - c4 * even_p_25 + c4 * even_p_34;
    // assign acc[6] = c6 * even_p_07 - c2 * even_p_16 + c2 * even_p_25 - c6 * even_p_34;
    assign acc[1] = c1 * even_m_07 + c3 * even_m_16 + c5 * even_m_25 + c7 * even_m_34;
    assign acc[3] = c3 * even_m_07 - c7 * even_m_16 - c1 * even_m_25 - c5 * even_m_34;
    assign acc[5] = c5 * even_m_07 - c1 * even_m_16 + c7 * even_m_25 + c3 * even_m_34;
    // assign acc[7] = c7 * even_m_07 - c5 * even_m_16 + c3 * even_m_25 - c1 * even_m_34;

    // Truncation
    // BW+16 bit -> 12 bit
    // (24, 9) -> (12, 2)
    // (24, 9) -> (12, 0) for acc_rounded[0]
    assign acc_rounded[0] = acc[0] [9+12:9]; // for DC output
    assign acc_rounded[2] = acc[2] [7+12:7];
    assign acc_rounded[4] = acc[4] [7+12:7];
    // assign acc_rounded[6] = acc[6] [7+12:7];
    assign acc_rounded[1] = acc[1] [7+12:7];
    assign acc_rounded[3] = acc[3] [7+12:7];
    assign acc_rounded[5] = acc[5] [7+12:7];
    // assign acc_rounded[7] = acc[7] [7+12:7];

    // assign DCT_out = {acc_rounded[0], acc_rounded[1], acc_rounded[2], acc_rounded[3], acc_rounded[4], acc_rounded[5], acc_rounded[6], acc_rounded[7]};
    assign DCT_out = {acc_rounded[0], acc_rounded[1], acc_rounded[2], acc_rounded[3], acc_rounded[4], acc_rounded[5], 24'd0};    

endmodule
