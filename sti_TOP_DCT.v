// with 1D, 2D, output vector match
// set parameter BW with your own

//sti with vector
module sti_project2;

parameter BW = 11;

reg clk;
reg reset;

wire [8*12-1:0] DCT_out;

// for test
wire [16-1:0] counter_out, counter_out_m1, counter_out_m10, counter_out_m19;
wire [64-1:0] DO_MEM_IN; 
wire [8*BW-1:0]  i_data;
wire [8*BW-1:0] o_data;
wire [15-1:0] output_mem_addr;

// for vector match 1D
reg [BW*8-1:0] mat_in [0:32768-1];
reg [BW*8-1:0] vector;

// // for vector match 2D
// reg [12*8-1:0] mat_in [0:32768-1];
// reg [12*8-1:0] vector;

integer f;
integer i;

initial
begin
	clk <= 1;
	reset <= 0;
	#12
	reset <= 1;
end

always #5 clk <= ~clk;

Top_DCT_2D #(.BW(BW)) TEST (DCT_out, clk, reset, counter_out, counter_out_m1, counter_out_m10, counter_out_m19, DO_MEM_IN, i_data, o_data, output_mem_addr); // define input & output ports of your top module by youself 

initial	$readmemh("image_in_1.txt", TEST.MEM_IN.SRAM_syn.SRAM32768x64.Mem); //input image, check the path of memory rocation (module instance)



// // acc_rounded check
// // dct_in module
// integer j;
// integer err = 0;
// initial
// begin		
// 	$readmemh("output_1_1D.txt", mat_in);
// 	begin
// 		#(20);
// 		for (j=0; j<32790; j=j+1)
// 		begin
// 			vector <= mat_in[j];
// 			if (vector != TEST.dct_in.DCT_out) err = err + 1;
// 			#(10);
// 		end
// 	end
// end



// // acc_rounded check 2
// // dct_out module
// integer j;
// integer err = 0;
// initial
// begin		
// 	$readmemh("output_1_2D.txt", mat_in); 
// 	begin
// 		#(110);
// 		for (j=0; j<32790; j=j+1)
// 		begin
// 			vector <= mat_in[j];
// 			if (vector != TEST.dct_out.DCT_out) err = err + 1;
// 			#(10);
// 		end
// 	end
// end


 

// // final result check
// // *** Caution : sharing mat_in with upper test ***
// integer k;
// integer err = 0;
// initial
// begin		
// 	$readmemh("output_5_final.txt", mat_in);
// 	begin
// 		#(200);
// 		for (k=0; k<32790; k=k+1)
// 		begin
// 			vector <= mat_in[k];
// 			if (vector != DCT_out) err = err + 1;
// 			#(10);
// 		end
// 	end
// end





initial
begin
	f = $fopen("image_out_1_test.txt","w"); //output image, this is the output file that finished 2D-DCT operations.

	#327900; //change if you need

	for (i = 0; i<32768; i=i+1)
	begin
		$display("DATA %b", TEST.MEM_OUT.SRAM_syn2.SRAM32768x96.Mem[i]); //check the path of memory rocation (module instance)
		$fwrite(f,"%b\n",   TEST.MEM_OUT.SRAM_syn2.SRAM32768x96.Mem[i]); //check the path of memory rocation (module instance)
	end
   
	#100
	$fclose(f);  
	$finish;
end


endmodule
