----------------------------------------------------------------------------------
-- Copyright 2016-2019:
--     Amir Moradi & Pascal Sasdrich for the SKINNY Team
--     https://sites.google.com/site/skinnycipher/
--
-- This program is free software; you can redistribute it and/or
-- modify it under the terms of the GNU General Public License as
-- published by the Free Software Foundation; either version 2 of the
-- License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful, but
-- WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
-- General Public License for more details.
----------------------------------------------------------------------------------



-- IMPORTS
----------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

USE WORK.SKINNYPKG.ALL;



-- ENTITY
----------------------------------------------------------------------------------
ENTITY CellSB IS
	GENERIC (BS : BLOCK_SIZE);
   PORT ( CLK	: IN 	STD_LOGIC;
          SE 	: IN 	STD_LOGIC;
			 SB	: IN 	STD_LOGIC_VECTOR(1 DOWNTO 0);
          D  	: IN 	STD_LOGIC;
          DS  	: IN 	STD_LOGIC;
          Q 	: OUT STD_LOGIC_VECTOR((GET_WORD_SIZE(BS) - 1) DOWNTO 0));
END CellSB;



-- ARCHITECTURE : STRUCTURAL
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF CellSB IS

	-- COMPONENTS -----------------------------------------------------------------
	COMPONENT dflipfloplw IS
	PORT ( CLK  : IN  STD_LOGIC;
			 SEL	: IN  STD_LOGIC;
			 D0   : IN  STD_LOGIC;
			 D1   : IN  STD_LOGIC;
			 Q    : OUT STD_LOGIC);
	END COMPONENT;

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL STATE : STD_LOGIC_VECTOR(W DOWNTO 0);
	SIGNAL NOX1, NOX2, SWP1, SWP2, FDB1, FDB2 : STD_LOGIC;

BEGIN

	-- 4-BIT S-BOX ----------------------------------------------------------------
	S4 : IF BS = BLOCK_SIZE_64 GENERATE
		SB3 : ENTITY work.DataFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, D(0) => STATE(3), Q(0) => STATE(4));
		SB2 : ENTITY work.DataFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, D(0) => STATE(2), Q(0) => STATE(3));
		SB1 : ENTITY work.ScanFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, SE => SB(0), D(0) => STATE(1), DS(0) => NOX1, Q(0) => STATE(2));
		SB0 : ENTITY work.ScanFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, SE => SE, 	D(0) => STATE(0), DS(0) => DS, 	Q(0) => STATE(1));

		-- INPUT MULTIPLEXER -------------------------------------------------------
		STATE(0) <= D WHEN (SB(1) = '1') ELSE STATE(4);

		-- SBOX LOGIC (NOR / XOR) --------------------------------------------------
		NOX1  <= STATE(1) XOR (STATE(4) NOR STATE(3));

		-- OUTPUT ------------------------------------------------------------------
		Q <= STATE(W DOWNTO 1);

	END GENERATE;

	-- 8-BIT S-BOX ----------------------------------------------------------------
	S8 : IF BS = BLOCK_SIZE_128 GENERATE
		SB7 : ENTITY work.ScanFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, SE => SB(1), D(0) => STATE(3), DS(0) => STATE(7), 	Q(0) => STATE(8));
		SB6 : ENTITY work.ScanFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, SE => SB(1), D(0) => STATE(2), DS(0) => STATE(6), 	Q(0) => STATE(7));
		SB5 : ENTITY work.ScanFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, SE => SB(1), D(0) => STATE(8), DS(0) => FDB2, 		Q(0) => STATE(6));
		SB4 : ENTITY work.ScanFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, SE => SB(1), D(0) => STATE(7), DS(0) => STATE(4), 	Q(0) => STATE(5));
		SB3 : ENTITY work.ScanFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, SE => SB(1), D(0) => NOX2, 	 	DS(0) => SWP2, 		Q(0) => STATE(4));
		SB2 : ENTITY work.ScanFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, SE => SB(1), D(0) => NOX1, 	 	DS(0) => SWP1, 		Q(0) => STATE(3));
		SB1 : ENTITY work.ScanFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, SE => SB(1), D(0) => STATE(4), DS(0) => FDB1, 		Q(0) => STATE(2));
		SB0 : ENTITY work.ScanFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, SE => SE, 	D(0) => STATE(0), DS(0) => DS,  			Q(0) => STATE(1));

		-- INPUT MULTIPLEXER -------------------------------------------------------
		STATE(0) <= D WHEN (SB(1) = '1') ELSE STATE(6);

		SWP1	<= STATE(3) WHEN (SB(0) = '1' AND SB(1) = '1') ELSE STATE(2);
		SWP2	<= STATE(2) WHEN (SB(0) = '1' AND SB(1) = '1') ELSE STATE(3);

		FDB1	<= NOX1 WHEN (SB(0) = '1' AND SB(1) = '1') ELSE STATE(1);
		FDB2	<= NOX2 WHEN (SB(0) = '1' AND SB(1) = '1') ELSE STATE(5);

		-- SBOX LOGIC (NOR / XOR) --------------------------------------------------
		NOX1	<= STATE(1) XOR (STATE(4) NOR STATE(3));
		NOX2	<= STATE(5) XOR (STATE(8) NOR STATE(7));

		-- OUTPUT ------------------------------------------------------------------
		Q <= STATE(W DOWNTO 1);

	END GENERATE;
END Structural;
