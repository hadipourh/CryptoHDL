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
			 SB	: IN 	STD_LOGIC_VECTOR((GET_WORD_SIZE(BS) - 1) DOWNTO 0);
          D  	: IN 	STD_LOGIC;
          DS	: IN 	STD_LOGIC;
          Q 	: OUT STD_LOGIC_VECTOR((GET_WORD_SIZE(BS) - 1) DOWNTO 0));
END CellSB;



-- ARCHITECTURE : STRUCTURAL
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF CellSB IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL STATE : STD_LOGIC_VECTOR((W - 1) DOWNTO 0);
	SIGNAL TEMP	 : STD_LOGIC_VECTOR(		 2  DOWNTO 0);

	SIGNAL SOUT, S1, S2, S3, T1, T2	 : STD_LOGIC;

BEGIN

	-- 4-BIT S-BOX ----------------------------------------------------------------
	S4 : IF BS = BLOCK_SIZE_64 GENERATE

		SB3 : ENTITY work.ScanFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, SE => SB(2), D(0) => STATE(2), DS(0) => STATE(3), Q(0) => STATE(3));
		SB2 : ENTITY work.ScanFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, SE => SB(1), D(0) => STATE(1), DS(0) => STATE(3), Q(0) => STATE(2));
		SB1 : ENTITY work.ScanFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, SE => SB(0), D(0) => STATE(0), DS(0) => STATE(3), Q(0) => STATE(1));
		SB0 : ENTITY work.ScanFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, SE => SE, 	D(0) => D, 			DS(0) => DS, 		 Q(0) => STATE(0));

		-- TEMP REGISTERS ----------------------------------------------------------
		T0 : ENTITY work.DataFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, D(0) => SOUT, 	Q(0) => TEMP(0));
		T1 : ENTITY work.DataFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, D(0) => TEMP(0), Q(0) => TEMP(1));
		T2 : ENTITY work.DataFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, D(0) => TEMP(1), Q(0) => TEMP(2));

		-- SBOX LOGIC (NOR / XOR) --------------------------------------------------
		SOUT <= (STATE(3) NOR STATE(2)) XOR STATE(0) WHEN (SB(0) = '1') ELSE
		        (STATE(3) NOR STATE(2)) XOR STATE(1) WHEN (SB(1) = '1') ELSE
		        (TEMP (1) NOR STATE(3)) XOR STATE(2) WHEN (SB(2) = '1') ELSE
		        (TEMP (2) NOR TEMP (1)) XOR STATE(3) WHEN (SB(3) = '1') ELSE '0';

		-- OUTPUT ------------------------------------------------------------------
		Q <= STATE WHEN (SB = "0000") ELSE SOUT & STATE(2 DOWNTO 0);

	END GENERATE;

	-- 8-BIT S-BOX ----------------------------------------------------------------
	S8 : IF BS = BLOCK_SIZE_128 GENERATE

		SB7 : ENTITY work.ScanFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, SE => S1,	D(0) => STATE(6), DS(0) => STATE(7), Q(0) => STATE(7));
		SB6 : ENTITY work.ScanFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, SE => S2, D(0) => STATE(5), DS(0) => STATE(7), Q(0) => STATE(6));
		SB5 : ENTITY work.DataFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, 				D(0) => STATE(4), 						 Q(0) => STATE(5));
		SB4 : ENTITY work.DataFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, 				D(0) => STATE(3), 						 Q(0) => STATE(4));
		SB3 : ENTITY work.ScanFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, SE => S3, D(0) => STATE(2), DS(0) => STATE(7), Q(0) => STATE(3));
		SB2 : ENTITY work.DataFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, 		 		D(0) => STATE(1), 						 Q(0) => STATE(2));
		SB1 : ENTITY work.DataFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, 		 		D(0) => STATE(0), 						 Q(0) => STATE(1));
		SB0 : ENTITY work.ScanFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, SE => SE, D(0) => D, 			DS(0) => DS,  		 Q(0) => STATE(0));

		-- TEMP REGISTERS ----------------------------------------------------------
		T00 : ENTITY work.ScanFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, SE => T1, D(0) => SOUT, 		DS(0) => STATE(7), Q(0) => TEMP(0));
		T01 : ENTITY work.DataFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, 				D(0) => TEMP(0), 							 Q(0) => TEMP(1));
		T02 : ENTITY work.ScanFF GENERIC MAP (SIZE => 1) PORT MAP (CLK => CLK, SE => T2, D(0) => TEMP(1), 	DS(0) => TEMP(2),  Q(0) => TEMP(2));

		-- SELECT SIGNALS ----------------------------------------------------------
		S1 <= SB(5) OR SB(6);
		S2 <= SB(0) OR SB(1);
		S3 <= SB(2);

		T1 <= SB(3);
		T2 <= SB(3) XOR SB(4) XOR SB(5);

		-- SBOX LOGIC (NOR / XOR) --------------------------------------------------
		SOUT <= 	(((STATE(7) NOR STATE(6)) XOR STATE(4)) NOR ((STATE(3) NOR STATE(2)) XOR STATE(0))) XOR STATE(5) WHEN (SB(0) = '1') ELSE
					  (STATE(7) NOR STATE(6)) XOR STATE(5) 																			 WHEN (SB(1) = '1') ELSE
					  (STATE(5) NOR STATE(4)) XOR STATE(2) 																			 WHEN (SB(2) = '1') ELSE
					  (TEMP (2) NOR TEMP (1)) XOR STATE(6) 																			 WHEN (SB(3) = '1') ELSE
					  (STATE(7) NOR TEMP (1)) XOR STATE(5) 																			 WHEN (SB(4) = '1') ELSE
					  (STATE(7) NOR STATE(6)) XOR TEMP (1) 																			 WHEN (SB(5) = '1') ELSE
					  (TEMP (2) NOR TEMP (0)) XOR STATE(6) 																			 WHEN (SB(6) = '1') ELSE
					  (TEMP (2) NOR TEMP (0)) XOR STATE(7) 																			 WHEN (SB(7) = '1') ELSE '0';

		-- OUTPUT ------------------------------------------------------------------
		Q <= STATE WHEN (SB = "00000000") ELSE SOUT & STATE(6 DOWNTO 0);

	END GENERATE;

END Structural;
