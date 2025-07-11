// 1D DCT modules : DCT_1D_8to11, DCT_1D11to12
// with solving glitch
// with optimizing just for DCT_1D_8to11

// 8 * 8bit input to 8 * BW bit output
// optimized 1D DCT modules
module DCT_1D11to12(DCT_out, DCT_in);

    // input BW
    parameter BW = 11;

    output [12*8-1:0] DCT_out;
    input [8*BW-1:0] DCT_in;

    // // original 8 bit parameters
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
    localparam signed c2 = 8'h3f; // changed from 8'h3b
    localparam signed c3 = 8'h35;
    // localparam signed c4 = 8'h2d;
    localparam signed c5 = 8'h24;
    localparam signed c6 = 8'h18;
    localparam signed c7 = 8'hc;   



    wire signed [11-1:0] data_in [0:7];

    wire signed [13-1:0] even_p_07;
    wire signed [13-1:0] even_p_16;
    wire signed [13-1:0] even_p_25;
    wire signed [13-1:0] even_p_34;
    wire signed [13-1:0] even_m_07;
    wire signed [13-1:0] even_m_16;
    wire signed [13-1:0] even_m_25;
    wire signed [13-1:0] even_m_34;

    wire signed [BW+16-1:0] acc [0:7];
    wire signed [12-1:0] acc_rounded [0:7];

    // for optimization
    // plus parts
    wire signed [20-1:0] c4p07, c4p16, c4p25, c4p34;
    wire signed [16-1:0] c4p07_pre, c4p16_pre, c4p25_pre, c4p34_pre;
    wire signed [20-1:0] c2p07;
    wire signed [15-1:0] c6p16_pre, c6p25_pre;
    wire signed [17-1:0] c6p16, c6p25;
    wire signed [20-1:0] c2p34;

    // minus parts
    wire signed [20-1:0] c1m07, c1m16, c1m25;

    wire signed[16-1:0] c3m07_101, c3m16_101, c3m34_101;
    wire signed[15-1:0] c3m07_11, c3m16_11, c3m34_11;
    wire signed[20-1:0] c3m07, c3m16, c3m34;

    wire signed [17-1:0] c5m07_pre, c5m25_pre, c5m34_pre;
    wire signed [18-1:0] c5m07, c5m25, c5m34;

    wire signed [15-1:0] c7m16_pre, c7m25_pre, c7m34_pre;
    wire signed [16-1:0] c7m16, c7m25, c7m34;    

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

    // 11 bit + 11 bit = 12bit
    assign even_p_07 = $signed({data_in[0][10], data_in[0]}) + $signed({data_in[7][10], data_in[7]});
    assign even_p_16 = $signed({data_in[1][10], data_in[1]}) + $signed({data_in[6][10], data_in[6]});
    assign even_p_25 = $signed({data_in[2][10], data_in[2]}) + $signed({data_in[5][10], data_in[5]});
    assign even_p_34 = $signed({data_in[3][10], data_in[3]}) + $signed({data_in[4][10], data_in[4]});
    assign even_m_07 = $signed({data_in[0][10], data_in[0]}) - $signed({data_in[7][10], data_in[7]});
    assign even_m_16 = $signed({data_in[1][10], data_in[1]}) - $signed({data_in[6][10], data_in[6]});
    assign even_m_25 = $signed({data_in[2][10], data_in[2]}) - $signed({data_in[5][10], data_in[5]});
    assign even_m_34 = $signed({data_in[3][10], data_in[3]}) - $signed({data_in[4][10], data_in[4]});


    // // ========== for optimization ========== //

    // plus parts
    // cnxx : 15bit + 18bit = 19bit
    // pre : 12bit + 14bit = 15bit
    assign c4p07_pre = $signed(even_p_07[11:0]) + $signed({even_p_07[11:0], 2'b00});
    assign c4p16_pre = $signed(even_p_16[11:0]) + $signed({even_p_16[11:0], 2'b00});
    assign c4p25_pre = $signed(even_p_25[11:0]) + $signed({even_p_25[11:0], 2'b00});
    assign c4p34_pre = $signed(even_p_34[11:0]) + $signed({even_p_34[11:0], 2'b00});
    assign c4p07 = $signed(c4p07_pre[14:0]) + $signed({c4p07_pre[14:0], 3'd0});
    assign c4p16 = $signed(c4p16_pre[14:0]) + $signed({c4p16_pre[14:0], 3'd0});
    assign c4p25 = $signed(c4p25_pre[14:0]) + $signed({c4p25_pre[14:0], 3'd0});
    assign c4p34 = $signed(c4p34_pre[14:0]) + $signed({c4p34_pre[14:0], 3'd0});


    // 18bit + 12bit = 19bit
    assign c2p07 = $signed({even_p_07[11:0], 6'd0}) - $signed(even_p_07[11:0]);

    // pre : 12bit + 13bit = 14bit
    // 14bit -> 17bit
    assign c6p16_pre = $signed(even_p_16[11:0]) + $signed({even_p_16[11:0], 1'b0});
    assign c6p16 = {c6p16_pre[13:0], 3'd0};

    // pre : 12bit + 13bit = 14bit
    // 14bit -> 17bit
    assign c6p25_pre = $signed(even_p_25[11:0]) + $signed({even_p_25[11:0], 1'b0});
    assign c6p25 = {c6p25_pre[13:0], 3'd0};

    // 18bit + 12bit = 19bit
    assign c2p34 = $signed({even_p_34[11:0], 6'd0}) - $signed(even_p_34[11:0]);


    // minus parts
    // 18bit + 12bit = 19bit
    assign c1m07 = $signed({even_m_07[11:0], 6'd0}) - $signed(even_m_07[11:0]);
    assign c1m16 = $signed({even_m_16[11:0], 6'd0}) - $signed(even_m_16[11:0]);
    assign c1m25 = $signed({even_m_25[11:0], 6'd0}) - $signed(even_m_25[11:0]);

    // 14bit + 12bit = 15bit
    // 13bit + 12bit = 14bit
    // 15bit + 18bit = 19bit
    assign c3m07_101 = $signed({even_m_07[11:0], 2'd0}) + $signed(even_m_07[11:0]);
    assign c3m07_11 = $signed({even_m_07[11:0], 1'b0}) + $signed(even_m_07[11:0]);
    assign c3m07 = $signed({c3m07_11[13:0], 4'd0}) + $signed(c3m07_101[14:0]);

    assign c3m16_101 = $signed({even_m_16[11:0], 2'd0}) + $signed(even_m_16[11:0]);
    assign c3m16_11 = $signed({even_m_16[11:0], 1'b0}) + $signed(even_m_16[11:0]);
    assign c3m16 = $signed({c3m16_11[13:0], 4'd0}) + $signed(c3m16_101[14:0]);
    
    assign c3m34_101 = $signed({even_m_34, 2'd0}) + $signed(even_m_34[11:0]);
    assign c3m34_11 = $signed({even_m_34, 1'b0}) + $signed(even_m_34[11:0]);
    assign c3m34 = $signed({c3m34_11[13:0], 4'd0}) + $signed(c3m34_101[14:0]);    

    // 15bit + 12bit = 16bit
    // 16bit -> 18bit
    assign c5m07_pre = $signed({even_m_07, 3'd0}) + $signed(even_m_07[11:0]);
    assign c5m07 = {c5m07_pre[15:0], 2'd0};

    assign c5m25_pre = $signed({even_m_25, 3'd0}) + $signed(even_m_25[11:0]);
    assign c5m25 = {c5m25_pre[15:0], 2'd0};

    assign c5m34_pre = $signed({even_m_34, 3'd0}) + $signed(even_m_34[11:0]);
    assign c5m34 = {c5m34_pre[15:0], 2'd0};        

    // 13bit + 12bit = 14bit
    // 14bit -> 16bit
    assign c7m16_pre = $signed({even_m_16[11:0], 1'b0}) + $signed(even_m_16[11:0]);
    assign c7m16 = {c7m16_pre[13:0], 2'd0};

    assign c7m25_pre = $signed({even_m_25[11:0], 1'b0}) + $signed(even_m_25[11:0]);
    assign c7m25 = {c7m25_pre[13:0], 2'd0};

    assign c7m34_pre = $signed({even_m_34[11:0], 1'b0}) + $signed(even_m_34[11:0]);
    assign c7m34 = {c7m34_pre[13:0], 2'd0};          


    // ========== End of optimization ========== //

    // accumulation
    // (BW + 3)bit * 10bit * 4 = BW+16bit
    // (BW+2, 2) * (10,9) => (BW+12,11)
    assign acc[0] = c4p07 + c4p16 + c4p25 + c4p34;
    assign acc[2] = c2p07 + c6p16 - c6p25 - c2p34;
    assign acc[4] = c4p07 - c4p16 - c4p25 + c4p34;
    // assign acc[6] = c6 * even_p_07 - c2 * even_p_16 + c2 * even_p_25 - c6 * even_p_34;
    assign acc[1] = $signed(c1m07[18:0]) + $signed(c3m16[18:0]) + c5m25 + c7m34;
    assign acc[3] = $signed(c3m07[18:0]) - c7m16 - $signed(c1m25[18:0]) - c5m34;
    assign acc[5] = c5m07 - $signed(c1m16[18:0]) + c7m25 + $signed(c3m34[18:0]);
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

// 8 * 8bit input to 8 * BW bit output
module DCT_1D_8to11(DCT_out, DCT_in);

    parameter BW = 11;

    output [8*BW-1:0] DCT_out;
    input [64-1:0] DCT_in;

    // // original 8 bit parameters
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
    localparam signed c2 = 8'h3f; // changed from 8'h3b
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

    //for optimization
    //for plus
    wire signed [18-1:0] c4p07, c4p16, c4p25, c4p34;
    wire signed [14-1:0] c4p07_pre, c4p16_pre, c4p25_pre, c4p34_pre;
    wire signed [18-1:0] c2p07;
    wire signed [13-1:0] c6p16_pre, c6p25_pre;
    wire signed [15-1:0] c6p16, c6p25;
    wire signed [18-1:0] c2p34;
    //for minus
    wire signed [18-1:0] c1m07, c1m16, c1m25;

    wire signed[14-1:0] c3m07_101, c3m16_101, c3m34_101;
    wire signed[13-1:0] c3m07_11, c3m16_11, c3m34_11;
    wire signed[18-1:0] c3m07, c3m16, c3m34;

    wire signed [15-1:0] c5m07_pre, c5m25_pre, c5m34_pre;
    wire signed [16-1:0] c5m07, c5m25, c5m34;

    wire signed [13-1:0] c7m16_pre, c7m25_pre, c7m34_pre;
    wire signed [14-1:0] c7m16, c7m25, c7m34;

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


    // ========== for optimization ========== //

    // plus parts
    // cnxx : 13bit + 16bit = 17bit
    // pre : 10bit + 12bit = 13bit
    assign c4p07_pre = even_p_07[9:0] + {even_p_07[9:0], 2'b00};
    assign c4p07 = c4p07_pre[12:0] + {c4p07_pre[12:0], 3'd0};    
    assign c4p16_pre = even_p_16[9:0] + {even_p_16[9:0], 2'b00};
    assign c4p16 = c4p16_pre[12:0] + {c4p16_pre[12:0], 3'd0};
    assign c4p25_pre = even_p_25[9:0] + {even_p_25[9:0], 2'b00};
    assign c4p25 = c4p25_pre[12:0] + {c4p25_pre[12:0], 3'd0};
    assign c4p34_pre = even_p_34[9:0] + {even_p_34[9:0], 2'b00};
    assign c4p34 = c4p34_pre[12:0] + {c4p34_pre[12:0], 3'd0};

    // 16bit + 10bit = 17bit
    assign c2p07 = {even_p_07[9:0], 6'd0} - even_p_07[9:0];

    // pre : 10bit + 11bit = 12bit
    // 12bit -> 15bit
    assign c6p16_pre = even_p_16[9:0] + {even_p_16[9:0], 1'b0};
    assign c6p16 = {c6p16_pre[12:0], 3'd0};

    // pre : 10bit + 11bit = 12bit
    // 12bit -> 15bit
    assign c6p25_pre = even_p_25[9:0] + {even_p_25[9:0], 1'b0};
    assign c6p25 = {c6p25_pre[12:0], 3'd0};

    // 16bit + 10bit = 17bit
    assign c2p34 = {even_p_34[9:0], 6'd0} - even_p_34[9:0];

    // minus parts
    // 16bit + 10bit = 17bit
    assign c1m07 = $signed({even_m_07[9:0], 6'd0}) - $signed(even_m_07[9:0]);
    assign c1m16 = $signed({even_m_16[9:0], 6'd0}) - $signed(even_m_16[9:0]);
    assign c1m25 = $signed({even_m_25[9:0], 6'd0}) - $signed(even_m_25[9:0]);

    // 12bit + 10bit = 13bit
    // 11bit + 10bit = 12bit
    // 13bit + 16bit = 17bit
    assign c3m07_101 = $signed({even_m_07[9:0], 2'd0}) + $signed(even_m_07[9:0]);
    assign c3m07_11 = $signed({even_m_07[9:0], 1'b0}) + $signed(even_m_07[9:0]);
    assign c3m07 = $signed({c3m07_11[11:0], 4'd0}) + $signed(c3m07_101[12:0]);

    assign c3m16_101 = $signed({even_m_16[9:0], 2'd0}) + $signed(even_m_16[9:0]);
    assign c3m16_11 = $signed({even_m_16[9:0], 1'b0}) + $signed(even_m_16[9:0]);
    assign c3m16 = $signed({c3m16_11[11:0], 4'd0}) + $signed(c3m16_101[12:0]);
    
    assign c3m34_101 = $signed({even_m_34, 2'd0}) + $signed(even_m_34[9:0]);
    assign c3m34_11 = $signed({even_m_34, 1'b0}) + $signed(even_m_34[9:0]);
    assign c3m34 = $signed({c3m34_11[11:0], 4'd0}) + $signed(c3m34_101[12:0]);    

    // 13bit + 10bit = 14bit
    // 14bit -> 16bit
    assign c5m07_pre = $signed({even_m_07, 3'd0}) + $signed(even_m_07[9:0]);
    assign c5m07 = {c5m07_pre[13:0], 2'd0};

    assign c5m25_pre = $signed({even_m_25, 3'd0}) + $signed(even_m_25[9:0]);
    assign c5m25 = {c5m25_pre[13:0], 2'd0};

    assign c5m34_pre = $signed({even_m_34, 3'd0}) + $signed(even_m_34[9:0]);
    assign c5m34 = {c5m34_pre[13:0], 2'd0};        

    // 11bit + 10bit = 12bit
    // 12bit -> 14bit
    assign c7m16_pre = $signed({even_m_16[9:0], 1'b0}) + $signed(even_m_16[9:0]);
    assign c7m16 = {c7m16_pre[11:0], 2'd0};

    assign c7m25_pre = $signed({even_m_25[9:0], 1'b0}) + $signed(even_m_25[9:0]);
    assign c7m25 = {c7m25_pre[11:0], 2'd0};

    assign c7m34_pre = $signed({even_m_34[9:0], 1'b0}) + $signed(even_m_34[9:0]);
    assign c7m34 = {c7m34_pre[11:0], 2'd0};           


    // ========== End of optimization ========== //



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

    // accumulation optimized
    // 10bit * 8bit * 4 = 24bit + 1 sign bit
    // (10, 0) * (8, 7) = (18, 7)
    // (18, 7) * 4 = (21, 7)
    assign acc[0] = c4p07[16:0] + c4p16[16:0] + c4p25[16:0] + c4p34[16:0];
    assign acc[2] = c2p07[16:0] + c6p16[14:0] - c6p25[14:0] - c2p34[16:0];
    assign acc[4] = c4p07[16:0] - c4p16[16:0] - c4p25[16:0] + c4p34[16:0];    
    // assign acc[6] = c6 * even_p_07 - c2 * even_p_16 + c2 * even_p_25 - c6 * even_p_34;
    assign acc[1] = $signed(c1m07[16:0]) + $signed(c3m16[16:0]) + c5m25 + c7m34;
    assign acc[3] = $signed(c3m07[16:0]) - c7m16 - $signed(c1m25[16:0]) - c5m34;
    assign acc[5] = c5m07 - $signed(c1m16[16:0]) + c7m25 + $signed(c3m34[16:0]);
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
    // assign acc_rounded[1] = acc[1] [5+BW-1:5];
    assign acc_rounded[3] = acc[3] [5+BW-1:5];
    assign acc_rounded[5] = acc[5] [5+BW-1:5];
    // assign acc_rounded[7] = acc[7] [5+BW-1:5];

    // To solve glitching
    assign acc_rounded[1] = acc[1][16] ? (acc[1][15] ? acc[1][5+BW-1:5] : 11'b100_0000_0000) : (acc[1][15] ? 11'b011_1111_1111 : acc[1] [5+BW-1:5]);

    // assign DCT_out = {acc_rounded[0], acc_rounded[1], acc_rounded[2], acc_rounded[3], acc_rounded[4], acc_rounded[5], acc_rounded[6], acc_rounded[7]};
    assign DCT_out = {acc_rounded[0], acc_rounded[1], acc_rounded[2], acc_rounded[3], acc_rounded[4], acc_rounded[5], 22'd0};

endmodule

