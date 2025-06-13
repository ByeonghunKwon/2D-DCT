// TPmem_new : simultaniously operating read and write
// |---	TPmem_11b : Optimized TPmem_new with removing last 11*2 FFs in array[6:7]
// |---	TPmem_12b : Optimized TPmem_new with removing last 12*2 FFs in every array


module TPmem_11b
#( parameter BW = 11 )

(  input [8*BW-1:0]  i_data,
   input 	   i_clk,
   input	   i_Reset,
   output reg [8*BW-1:0] o_data,
   output reg	   o_en
);

reg [4-1:0]  counter ;
reg [8*BW-1:0] array [6-1:0];  // 88bit
reg [6*BW-1:0] array_6_;       // 66bit
reg [6*BW-1:0] array_7_;

wire [8*BW-1:0] col [8-1:0];
wire [8*BW-1:0] row [8-1:0];
wire [3-1:0] index = counter[3-1:0] ;

reg [8*BW-1:0] w_data;

always@(posedge i_clk) begin
    if(~i_Reset) begin
    counter <= 4'b0;
    o_data <= {BW{8'b0}};
    o_en <= 1'b0; 
    end
    else    begin
	o_data <= w_data ;
	o_en <= 1'b1 ;

    counter <= counter + 4'b1;
    end
end

integer i;

always@(posedge i_clk) begin
    if(~i_Reset) begin
	array_7_ <= {66'd0};
	array_6_ <= {66'd0};
	array[5] <= {11{8'b0}};
	array[4] <= {11{8'b0}};
	array[3] <= {11{8'b0}};
	array[2] <= {11{8'b0}};
	array[1] <= {11{8'b0}};
	array[0] <= {11{8'b0}};
    end
    else    begin
        if(counter[3] == 0) begin
            case (index)
                3'd0: array[index] <= i_data ;
                3'd1: array[index] <= i_data ;
                3'd2: array[index] <= i_data ;
                3'd3: array[index] <= i_data ;
                3'd4: array[index] <= i_data ;
                3'd5: array[index] <= i_data ;
                3'd6: array_6_ <= i_data[88-1:22] ;
                3'd7: array_7_ <= i_data[88-1:22] ;
            endcase
        end
        else if (counter[3] == 1) begin
            for (i = 0; i < 6; i = i + 1) begin
                array[i][(8-index)*BW - 1 -: BW] <= i_data[(8 - i)*BW - 1 -: BW];
            end               
            case (index)
                3'd0: begin array_6_[(6-index)*BW -1 -: BW] <= i_data[2*BW-1:1*BW] ; 
                            array_7_[(6-index)*BW -1 -: BW] <= i_data[1*BW-1:0*BW] ;
                end
                3'd1: begin array_6_[(6-index)*BW -1 -: BW] <= i_data[2*BW-1:1*BW] ; 
                            array_7_[(6-index)*BW -1 -: BW] <= i_data[1*BW-1:0*BW] ;
                end
                3'd2: begin array_6_[(6-index)*BW -1 -: BW] <= i_data[2*BW-1:1*BW] ; 
                            array_7_[(6-index)*BW -1 -: BW] <= i_data[1*BW-1:0*BW] ;
                end
                3'd3: begin array_6_[(6-index)*BW -1 -: BW] <= i_data[2*BW-1:1*BW] ; 
                            array_7_[(6-index)*BW -1 -: BW] <= i_data[1*BW-1:0*BW] ;
                end
                3'd4: begin array_6_[(6-index)*BW -1 -: BW] <= i_data[2*BW-1:1*BW] ; 
                            array_7_[(6-index)*BW -1 -: BW] <= i_data[1*BW-1:0*BW] ;
                end
                3'd5: begin array_6_[(6-index)*BW -1 -: BW] <= i_data[2*BW-1:1*BW] ; 
                            array_7_[(6-index)*BW -1 -: BW] <= i_data[1*BW-1:0*BW] ;
                end
            endcase

            end
        end
    end

assign col[0] = {{array[0][8*BW-1:7*BW]},{array[1][8*BW-1:7*BW]},{array[2][8*BW-1:7*BW]},{array[3][8*BW-1:7*BW]},{array[4][8*BW-1:7*BW]},{array[5][8*BW-1:7*BW]},{array_6_[6*BW-1:5*BW]},{array_7_[6*BW-1:5*BW]}} ; 
assign col[1] = {{array[0][7*BW-1:6*BW]},{array[1][7*BW-1:6*BW]},{array[2][7*BW-1:6*BW]},{array[3][7*BW-1:6*BW]},{array[4][7*BW-1:6*BW]},{array[5][7*BW-1:6*BW]},{array_6_[5*BW-1:4*BW]},{array_7_[5*BW-1:4*BW]}} ; 
assign col[2] = {{array[0][6*BW-1:5*BW]},{array[1][6*BW-1:5*BW]},{array[2][6*BW-1:5*BW]},{array[3][6*BW-1:5*BW]},{array[4][6*BW-1:5*BW]},{array[5][6*BW-1:5*BW]},{array_6_[4*BW-1:3*BW]},{array_7_[4*BW-1:3*BW]}} ; 
assign col[3] = {{array[0][5*BW-1:4*BW]},{array[1][5*BW-1:4*BW]},{array[2][5*BW-1:4*BW]},{array[3][5*BW-1:4*BW]},{array[4][5*BW-1:4*BW]},{array[5][5*BW-1:4*BW]},{array_6_[3*BW-1:2*BW]},{array_7_[3*BW-1:2*BW]}} ; 
assign col[4] = {{array[0][4*BW-1:3*BW]},{array[1][4*BW-1:3*BW]},{array[2][4*BW-1:3*BW]},{array[3][4*BW-1:3*BW]},{array[4][4*BW-1:3*BW]},{array[5][4*BW-1:3*BW]},{array_6_[2*BW-1:1*BW]},{array_7_[2*BW-1:1*BW]}} ; 
assign col[5] = {{array[0][3*BW-1:2*BW]},{array[1][3*BW-1:2*BW]},{array[2][3*BW-1:2*BW]},{array[3][3*BW-1:2*BW]},{array[4][3*BW-1:2*BW]},{array[5][3*BW-1:2*BW]},{array_6_[1*BW-1:0*BW]},{array_7_[1*BW-1:0*BW]}} ; 
assign col[6] = {{array[0][2*BW-1:1*BW]},{array[1][2*BW-1:1*BW]},{array[2][2*BW-1:1*BW]},{array[3][2*BW-1:1*BW]},{array[4][2*BW-1:1*BW]},{array[5][2*BW-1:1*BW]}, 22'd0} ; 
assign col[7] = {{array[0][1*BW-1:0*BW]},{array[1][1*BW-1:0*BW]},{array[2][1*BW-1:0*BW]},{array[3][1*BW-1:0*BW]},{array[4][1*BW-1:0*BW]},{array[5][1*BW-1:0*BW]}, 22'd0} ; 

assign row[0] = array[0]; 
assign row[1] = array[1]; 
assign row[2] = array[2]; 
assign row[3] = array[3]; 
assign row[4] = array[4]; 
assign row[5] = array[5]; 
assign row[6] = {array_6_, 22'd0}; 
assign row[7] = {array_7_, 22'd0}; 

always@(*) begin
    if(counter[3]==1'b1) begin
    w_data = col[index] ;
    end
    else    begin
    w_data = row[index];
    end
end

endmodule


// TPmem re

module TPmem_12b
#( parameter BW = 12 )

(  input [8*BW-1:0]  i_data,
   input 	   i_clk,
   input	   i_Reset,
   output reg [8*BW-1:0] o_data,
   output reg	   o_en
);

reg [4-1:0]  counter ;
reg [6*BW-1:0] array [6-1:0];

wire [8*BW-1:0] col [8-1:0];
wire [8*BW-1:0] row [8-1:0];
wire [3-1:0] index = counter[3-1:0] ;

reg [8*BW-1:0] w_data;

always@(posedge i_clk) begin
    if(~i_Reset) begin
    counter <= 4'b0;
    o_data <= {BW{8'b0}};
    o_en <= 1'b0; 
    end
    else    begin
	o_data <= w_data ;
	o_en <= 1'b1 ;

    counter <= counter + 4'b1;
    end
end

integer i;

always@(posedge i_clk) begin
    if(~i_Reset) begin
	array[5] <= {BW{6'b0}};
	array[4] <= {BW{6'b0}};
	array[3] <= {BW{6'b0}};
	array[2] <= {BW{6'b0}};
	array[1] <= {BW{6'b0}};
	array[0] <= {BW{6'b0}};
    end
    else    begin
        if(counter[3] == 0) begin
            array[index] <= i_data[8*BW-1:2*BW] ;
        end
        else if (counter[3] == 1) begin
            for (i = 0; i < 6; i = i + 1) begin
                array[i][(6-index)*BW - 1 -: BW] <= i_data[(8 - i)*BW - 1 -: BW];
            end             
        end
    end
end

assign col[0] = {{array[0][6*BW-1:5*BW]},{array[1][6*BW-1:5*BW]},{array[2][6*BW-1:5*BW]},{array[3][6*BW-1:5*BW]},{array[4][6*BW-1:5*BW]},{array[5][6*BW-1:5*BW]}, 24'd0} ; 
assign col[1] = {{array[0][5*BW-1:4*BW]},{array[1][5*BW-1:4*BW]},{array[2][5*BW-1:4*BW]},{array[3][5*BW-1:4*BW]},{array[4][5*BW-1:4*BW]},{array[5][5*BW-1:4*BW]}, 24'd0} ; 
assign col[2] = {{array[0][4*BW-1:3*BW]},{array[1][4*BW-1:3*BW]},{array[2][4*BW-1:3*BW]},{array[3][4*BW-1:3*BW]},{array[4][4*BW-1:3*BW]},{array[5][4*BW-1:3*BW]}, 24'd0} ; 
assign col[3] = {{array[0][3*BW-1:2*BW]},{array[1][3*BW-1:2*BW]},{array[2][3*BW-1:2*BW]},{array[3][3*BW-1:2*BW]},{array[4][3*BW-1:2*BW]},{array[5][3*BW-1:2*BW]}, 24'd0} ; 
assign col[4] = {{array[0][2*BW-1:1*BW]},{array[1][2*BW-1:1*BW]},{array[2][2*BW-1:1*BW]},{array[3][2*BW-1:1*BW]},{array[4][2*BW-1:1*BW]},{array[5][2*BW-1:1*BW]}, 24'd0} ; 
assign col[5] = {{array[0][1*BW-1:0*BW]},{array[1][1*BW-1:0*BW]},{array[2][1*BW-1:0*BW]},{array[3][1*BW-1:0*BW]},{array[4][1*BW-1:0*BW]},{array[5][1*BW-1:0*BW]}, 24'd0} ; 
assign col[6] = 96'd0; 
assign col[7] = 96'd0; 

assign row[0] = {array[0], 24'd0}; 
assign row[1] = {array[1], 24'd0}; 
assign row[2] = {array[2], 24'd0}; 
assign row[3] = {array[3], 24'd0}; 
assign row[4] = {array[4], 24'd0}; 
assign row[5] = {array[5], 24'd0}; 
assign row[6] = 96'd0;
assign row[7] = 96'd0;


always@(*) begin
    if(counter[3]==1'b1) begin
    w_data = col[index] ;
    end
    else    begin
    w_data = row[index];
    end
end

endmodule


// TPmem new

module TPmem_new
#( parameter BW = 8 )

(  input [8*BW-1:0]  i_data,
   input 	   i_clk,
   input	   i_Reset,
   output reg [8*BW-1:0] o_data,
   output reg	   o_en
);

reg [4-1:0]  counter ;
reg [8*BW-1:0] array [8-1:0];

wire [8*BW-1:0] col [8-1:0];
wire [8*BW-1:0] row [8-1:0];
wire [3-1:0] index = counter[3-1:0] ;

reg [8*BW-1:0] w_data;

always@(posedge i_clk) begin
    if(~i_Reset) begin
    counter <= 4'b0;
    o_data <= {BW{8'b0}};
    o_en <= 1'b0; 
    end
    else    begin
	o_data <= w_data ;
	o_en <= 1'b1 ;

    counter <= counter + 4'b1;
    end
end

integer i;

always@(posedge i_clk) begin
    if(~i_Reset) begin
	array[7] <= {BW{8'b0}};
	array[6] <= {BW{8'b0}};
	array[5] <= {BW{8'b0}};
	array[4] <= {BW{8'b0}};
	array[3] <= {BW{8'b0}};
	array[2] <= {BW{8'b0}};
	array[1] <= {BW{8'b0}};
	array[0] <= {BW{8'b0}};
    end
    else    begin
        if(counter[3] == 0) begin
            array[index] <= i_data ;
        end
        else if (counter[3] == 1) begin
            for (i = 0; i < 8; i = i + 1) begin
                array[i][(8-index)*BW - 1 -: BW] <= i_data[(8 - i)*BW - 1 -: BW];
            end             
        end
    end
end

assign col[0] = {{array[0][8*BW-1:7*BW]},{array[1][8*BW-1:7*BW]},{array[2][8*BW-1:7*BW]},{array[3][8*BW-1:7*BW]},{array[4][8*BW-1:7*BW]},{array[5][8*BW-1:7*BW]},{array[6][8*BW-1:7*BW]},{array[7][8*BW-1:7*BW]}} ; 
assign col[1] = {{array[0][7*BW-1:6*BW]},{array[1][7*BW-1:6*BW]},{array[2][7*BW-1:6*BW]},{array[3][7*BW-1:6*BW]},{array[4][7*BW-1:6*BW]},{array[5][7*BW-1:6*BW]},{array[6][7*BW-1:6*BW]},{array[7][7*BW-1:6*BW]}} ; 
assign col[2] = {{array[0][6*BW-1:5*BW]},{array[1][6*BW-1:5*BW]},{array[2][6*BW-1:5*BW]},{array[3][6*BW-1:5*BW]},{array[4][6*BW-1:5*BW]},{array[5][6*BW-1:5*BW]},{array[6][6*BW-1:5*BW]},{array[7][6*BW-1:5*BW]}} ; 
assign col[3] = {{array[0][5*BW-1:4*BW]},{array[1][5*BW-1:4*BW]},{array[2][5*BW-1:4*BW]},{array[3][5*BW-1:4*BW]},{array[4][5*BW-1:4*BW]},{array[5][5*BW-1:4*BW]},{array[6][5*BW-1:4*BW]},{array[7][5*BW-1:4*BW]}} ; 
assign col[4] = {{array[0][4*BW-1:3*BW]},{array[1][4*BW-1:3*BW]},{array[2][4*BW-1:3*BW]},{array[3][4*BW-1:3*BW]},{array[4][4*BW-1:3*BW]},{array[5][4*BW-1:3*BW]},{array[6][4*BW-1:3*BW]},{array[7][4*BW-1:3*BW]}} ; 
assign col[5] = {{array[0][3*BW-1:2*BW]},{array[1][3*BW-1:2*BW]},{array[2][3*BW-1:2*BW]},{array[3][3*BW-1:2*BW]},{array[4][3*BW-1:2*BW]},{array[5][3*BW-1:2*BW]},{array[6][3*BW-1:2*BW]},{array[7][3*BW-1:2*BW]}} ; 
assign col[6] = {{array[0][2*BW-1:1*BW]},{array[1][2*BW-1:1*BW]},{array[2][2*BW-1:1*BW]},{array[3][2*BW-1:1*BW]},{array[4][2*BW-1:1*BW]},{array[5][2*BW-1:1*BW]},{array[6][2*BW-1:1*BW]},{array[7][2*BW-1:1*BW]}} ; 
assign col[7] = {{array[0][1*BW-1:0*BW]},{array[1][1*BW-1:0*BW]},{array[2][1*BW-1:0*BW]},{array[3][1*BW-1:0*BW]},{array[4][1*BW-1:0*BW]},{array[5][1*BW-1:0*BW]},{array[6][1*BW-1:0*BW]},{array[7][1*BW-1:0*BW]}} ; 

assign row[0] = array[0]; 
assign row[1] = array[1]; 
assign row[2] = array[2]; 
assign row[3] = array[3]; 
assign row[4] = array[4]; 
assign row[5] = array[5]; 
assign row[6] = array[6]; 
assign row[7] = array[7]; 


always@(*) begin
    if(counter[3]==1'b1) begin
    w_data = col[index] ;
    end
    else    begin
    w_data = row[index];
    end
end

endmodule
