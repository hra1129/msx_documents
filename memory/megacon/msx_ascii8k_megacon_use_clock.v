// =============================================================================
//	ASCII-8K Type MegaROM Controller for MSX
//	Copyright (C)2021 HRA!
// -----------------------------------------------------------------------------
//	このファイルは、ご自由にご利用下さい。
//	ただし、このファイルによって何らかの被害・損害が発生しても、HRA!は一切責任を
//	負いませんので、各自の責任でご利用下さい。
//
//	Please feel free to use this file.
//	HRA! is not responsible for any damage or loss caused by this file, 
//	so please use it at your own risk.
// =============================================================================

module msx_ascii8k_megacon (
		// -- Cartridge connector side
		input			reset_n,
		input			clock,
		input			a11,
		input			a12,
		input			a13,
		input			a14,
		input	[7:0]	d,
		input			sltsl_n,
		input			wr_n,
		input			merq_n,
		// -- Bank address output
		output	[6:0]	ba,					//	ba[6] = BA19, ... ba[0] = BA13
		output			romwe_n
	);
	reg		[7:0]		ff_bank0_sel;
	reg		[7:0]		ff_bank1_sel;
	reg		[7:0]		ff_bank2_sel;
	reg		[7:0]		ff_bank3_sel;
	wire				w_bank0;
	wire				w_bank1;
	wire				w_bank2;
	wire				w_bank3;
	wire				w_bank0_sel_wr;
	wire				w_bank1_sel_wr;
	wire				w_bank2_sel_wr;
	wire				w_bank3_sel_wr;
	wire				w_mem_wr;
	wire				w_reg_wr;
	wire	[7:0]		w_bank0_mask;
	wire	[7:0]		w_bank1_mask;
	wire	[7:0]		w_bank2_mask;
	wire	[7:0]		w_bank3_mask;
	wire	[7:0]		w_ba;

	assign w_bank0 =  a14 & ~a13;
	assign w_bank1 =  a14 &  a13;
	assign w_bank2 = ~a14 & ~a13;
	assign w_bank3 = ~a14 &  a13;

	assign w_bank0_sel_wr = ~a12 & ~a11;
	assign w_bank1_sel_wr = ~a12 &  a11;
	assign w_bank2_sel_wr =  a12 & ~a11;
	assign w_bank3_sel_wr =  a12 &  a11;

	assign w_mem_wr = ~sltsl_n & ~wr_n & ~merq_n & ~w_bank1;
	assign w_reg_wr = ~sltsl_n & ~wr_n & ~merq_n &  w_bank1;

	assign w_bank0_mask = w_bank0 ? ff_bank0_sel : 8'd0;
	assign w_bank1_mask = w_bank1 ? ff_bank1_sel : 8'd0;
	assign w_bank2_mask = w_bank2 ? ff_bank2_sel : 8'd0;
	assign w_bank3_mask = w_bank3 ? ff_bank3_sel : 8'd0;

	always @( negedge reset_n or posedge clock ) begin
		if( !reset_n ) begin
			ff_bank0_sel <= 8'd0;
		end
		else if( w_reg_wr && w_bank0_sel_wr ) begin
			ff_bank0_sel <= d;
		end
		else begin
			//	hold
		end
	end

	always @( negedge reset_n or posedge clock ) begin
		if( !reset_n ) begin
			ff_bank1_sel <= 8'd0;
		end
		else if( w_reg_wr && w_bank1_sel_wr ) begin
			ff_bank1_sel <= d;
		end
		else begin
			//	hold
		end
	end

	always @( negedge reset_n or posedge clock ) begin
		if( !reset_n ) begin
			ff_bank2_sel <= 8'd0;
		end
		else if( w_reg_wr && w_bank2_sel_wr ) begin
			ff_bank2_sel <= d;
		end
		else begin
			//	hold
		end
	end

	always @( negedge reset_n or posedge clock ) begin
		if( !reset_n ) begin
			ff_bank3_sel <= 8'd0;
		end
		else if( w_reg_wr && w_bank3_sel_wr ) begin
			ff_bank3_sel <= d;
		end
		else begin
			//	hold
		end
	end

	assign w_ba		= w_bank0_mask | w_bank1_mask | w_bank2_mask | w_bank3_mask;
	assign ba		= w_ba[6:0];
	assign romwe_n	= ~( w_ba[7] & w_mem_wr );
endmodule
