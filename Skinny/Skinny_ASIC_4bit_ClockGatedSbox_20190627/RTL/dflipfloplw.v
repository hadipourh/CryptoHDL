//--------------------------------------------------------------------------------
// Copyright 2016-2019:
//     Amir Moradi & Pascal Sasdrich for the SKINNY Team
//     https://sites.google.com/site/skinnycipher/
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License as
// published by the Free Software Foundation; either version 2 of the
// License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
// General Public License for more details.
//--------------------------------------------------------------------------------
module dflipfloplw (clk, sel, D0, D1, Q);
	input  clk, sel, D0, D1;
	output Q;

	reg Q;

	always @ (posedge clk)
	if (sel) begin
		Q <= D1;
	end else begin
		Q <= D0;
	end

endmodule
