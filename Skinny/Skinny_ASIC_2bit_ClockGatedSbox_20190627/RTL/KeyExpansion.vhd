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
ENTITY KeyExpansion IS
	GENERIC ( BS : BLOCK_SIZE 		 := BLOCK_SIZE_64;
				 TS : TWEAK_SIZE 		 := TWEAK_SIZE_1N);
	PORT ( CLK			: IN  STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
          RESET		: IN  STD_LOGIC;
			 KEY_CTL		: IN	STD_LOGIC_VECTOR(2 DOWNTO 0);
		    -- KEY PORT -------------------------------------
          KEY        : IN  STD_LOGIC_VECTOR ((2 * GET_TWEAK_FACT(TS) - 1) DOWNTO 0);
          ROUND_KEY  : OUT STD_LOGIC_VECTOR ((2 * GET_TWEAK_FACT(TS) - 1) DOWNTO 0));
END KeyExpansion;



-- ARCHITECTURE : ROUND
----------------------------------------------------------------------------------
ARCHITECTURE Round OF KeyExpansion IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);
	CONSTANT N : INTEGER := GET_BLOCK_SIZE(BS);
	CONSTANT T : INTEGER := GET_TWEAK_SIZE(BS, TS);

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL CLK_CE_H, CLK_GATE_H, CLK_H		: STD_LOGIC;
	SIGNAL CLK_CE_L, CLK_GATE_L, CLK_L		: STD_LOGIC;
	SIGNAL TK1, TK2, TK3							: STD_LOGIC_VECTOR((16 * W - 1) DOWNTO 0);
	SIGNAL TK1_NEXT, TK2_NEXT, TK3_NEXT		: STD_LOGIC_VECTOR((16 * W - 1) DOWNTO 0);
	SIGNAL TK1_PERM, TK2_PERM, TK3_PERM		: STD_LOGIC_VECTOR(( 8 * W - 1) DOWNTO 0);

BEGIN

	-- CLOCK GATING ---------------------------------------------------------------
	CLK_CE_H	<= RESET OR KEY_CTL(2) OR KEY_CTL(1);
	CLK_CE_L	<= RESET OR KEY_CTL(2);

	GATE : PROCESS(CLK, CLK_CE_H, CLK_CE_L)
	BEGIN
		IF (NOT(CLK) = '1') THEN
			CLK_GATE_H	<= CLK_CE_H;
			CLK_GATE_L	<= CLK_CE_L;
		END IF;
	END PROCESS;

	CLK_H <= CLK AND CLK_GATE_H;
	CLK_L	<= CLK AND CLK_GATE_L;
	-------------------------------------------------------------------------------

	-- TWEAKEY ARRAY PERMUTATIONS : TK1 -------------------------------------------
	GEN_TK1 : IF TS = TWEAK_SIZE_1N OR TS = TWEAK_SIZE_2N OR TS = TWEAK_SIZE_3N GENERATE

		-- REGISTER STAGE -------------------------------------------------------------
		C15 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), TK1_NEXT(15 * W), TK1_PERM((8 * W - 1)), TK1((16 * W - 1) DOWNTO (15 * W)));
		C14 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), TK1_NEXT(14 * W), TK1_PERM((7 * W - 1)), TK1((15 * W - 1) DOWNTO (14 * W)));
		C13 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), TK1_NEXT(13 * W), TK1_PERM((6 * W - 1)), TK1((14 * W - 1) DOWNTO (13 * W)));
		C12 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), TK1_NEXT(12 * W), TK1_PERM((5 * W - 1)), TK1((13 * W - 1) DOWNTO (12 * W)));

		C11 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), TK1_NEXT(11 * W), TK1_PERM((4 * W - 1)), TK1((12 * W - 1) DOWNTO (11 * W)));
		C10 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), TK1_NEXT(10 * W), TK1_PERM((3 * W - 1)), TK1((11 * W - 1) DOWNTO (10 * W)));
		C09 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), TK1_NEXT( 9 * W), TK1_PERM((2 * W - 1)), TK1((10 * W - 1) DOWNTO ( 9 * W)));
		C08 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), TK1_NEXT( 8 * W), TK1_PERM((1 * W - 1)), TK1(( 9 * W - 1) DOWNTO ( 8 * W)));

		C07 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,					TK1_NEXT( 7 * W),								  TK1(( 8 * W - 1) DOWNTO ( 7 * W)));
		C06 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,				 	TK1_NEXT( 6 * W),								  TK1(( 7 * W - 1) DOWNTO ( 6 * W)));
		C05 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,				 	TK1_NEXT( 5 * W),								  TK1(( 6 * W - 1) DOWNTO ( 5 * W)));
		C04 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,				 	TK1_NEXT( 4 * W),								  TK1(( 5 * W - 1) DOWNTO ( 4 * W)));

		C03 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,					TK1_NEXT( 3 * W), 							  TK1(( 4 * W - 1) DOWNTO ( 3 * W)));
		C02 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,				 	TK1_NEXT( 2 * W),								  TK1(( 3 * W - 1) DOWNTO ( 2 * W)));
		C01 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,				 	TK1_NEXT( 1 * W), 							  TK1(( 2 * W - 1) DOWNTO ( 1 * W)));
		C00 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_L, RESET, 		TK1_NEXT( 0 * W), KEY(0), 					  TK1(( 1 * W - 1) DOWNTO ( 0 * W)));

		-- PERMUTATION -------------------------------------------------------------
		P1 : ENTITY work.Permutation GENERIC MAP (BS => BS) PORT MAP (TK1((16 * W - 1) DOWNTO (8 * W)), TK1_PERM);

		-- NEXT KEY ----------------------------------------------------------------
		TK1_NEXT((16 * W - 1) DOWNTO (8 * W)) <= TK1((16 * W - 2) DOWNTO (8 * W)) & TK1( 8 * W - 1) WHEN (RESET = '0') ELSE TK1((16 * W - 2) DOWNTO (8 * W)) & KEY(1);
		TK1_NEXT(( 8 * W - 1) DOWNTO (0 * W)) <= TK1(( 8 * W - 2) DOWNTO (0 * W)) & TK1(16 * W - 1);

		-- ROUND KEY ---------------------------------------------------------------
		ROUND_KEY(1) <= TK1(16 * W - 1) AND KEY_CTL(2);
		ROUND_KEY(0) <= '0';

	END GENERATE;

	-- TWEAKEY ARRAY PERMUTATIONS : TK2 -------------------------------------------
	GEN_TK2 : IF TS = TWEAK_SIZE_2N OR TS = TWEAK_SIZE_3N GENERATE

		-- REGISTER STAGE -------------------------------------------------------------
		C15 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), 				TK2_NEXT(15 * W), TK2_PERM((8 * W - 1)), TK2((16 * W - 1) DOWNTO (15 * W)));
		C14 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), 				TK2_NEXT(14 * W), TK2_PERM((7 * W - 1)), TK2((15 * W - 1) DOWNTO (14 * W)));
		C13 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), 				TK2_NEXT(13 * W), TK2_PERM((6 * W - 1)), TK2((14 * W - 1) DOWNTO (13 * W)));
		C12 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), 				TK2_NEXT(12 * W), TK2_PERM((5 * W - 1)), TK2((13 * W - 1) DOWNTO (12 * W)));

		C11 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), 				TK2_NEXT(11 * W), TK2_PERM((4 * W - 1)), TK2((12 * W - 1) DOWNTO (11 * W)));
		C10 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), 				TK2_NEXT(10 * W), TK2_PERM((3 * W - 1)), TK2((11 * W - 1) DOWNTO (10 * W)));
		C09 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), 				TK2_NEXT( 9 * W), TK2_PERM((2 * W - 1)), TK2((10 * W - 1) DOWNTO ( 9 * W)));
		C08 : ENTITY work.CellT2 GENERIC MAP (BS => BS)  PORT MAP (CLK_H, KEY_CTL(1), KEY_CTL(0), TK2_NEXT( 8 * W), TK2_PERM((1 * W - 1)), TK2(( 9 * W - 1) DOWNTO ( 8 * W)));

		C07 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,									TK2_NEXT( 7 * W),								  TK2(( 8 * W - 1) DOWNTO ( 7 * W)));
		C06 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,				 					TK2_NEXT( 6 * W),								  TK2(( 7 * W - 1) DOWNTO ( 6 * W)));
		C05 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,				 					TK2_NEXT( 5 * W),								  TK2(( 6 * W - 1) DOWNTO ( 5 * W)));
		C04 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,				 					TK2_NEXT( 4 * W),								  TK2(( 5 * W - 1) DOWNTO ( 4 * W)));

		C03 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,									TK2_NEXT( 3 * W), 							  TK2(( 4 * W - 1) DOWNTO ( 3 * W)));
		C02 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,				 					TK2_NEXT( 2 * W),								  TK2(( 3 * W - 1) DOWNTO ( 2 * W)));
		C01 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,				 					TK2_NEXT( 1 * W), 							  TK2(( 2 * W - 1) DOWNTO ( 1 * W)));
		C00 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_L, RESET, 						TK2_NEXT( 0 * W), KEY(2), 					  TK2(( 1 * W - 1) DOWNTO ( 0 * W)));

		-- PERMUTATION -------------------------------------------------------------
		P2 : ENTITY work.Permutation GENERIC MAP (BS => BS) PORT MAP (TK2((16 * W - 1) DOWNTO (8 * W)), TK2_PERM);

		-- NEXT KEY ----------------------------------------------------------------
		TK2_NEXT((16 * W - 1) DOWNTO (8 * W)) <= TK2((16 * W - 2) DOWNTO (8 * W)) & TK2( 8 * W - 1) WHEN (RESET = '0') ELSE TK2((16 * W - 2) DOWNTO (8 * W)) & KEY(3);
		TK2_NEXT(( 8 * W - 1) DOWNTO (0 * W)) <= TK2(( 8 * W - 2) DOWNTO (0 * W)) & TK2(16 * W - 1);

		-- ROUND KEY ---------------------------------------------------------------
		ROUND_KEY(3) <= TK2(16 * W - 1) AND KEY_CTL(2);
		ROUND_KEY(2) <= '0';

	END GENERATE;

	-- TWEAKEY ARRAY PERMUTATIONS : TK3 -------------------------------------------
	GEN_TK3 : IF TS = TWEAK_SIZE_3N GENERATE

		-- REGISTER STAGE -------------------------------------------------------------
		C15 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), 				TK3_NEXT(15 * W), TK3_PERM((8 * W - 1)), TK3((16 * W - 1) DOWNTO (15 * W)));
		C14 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), 				TK3_NEXT(14 * W), TK3_PERM((7 * W - 1)), TK3((15 * W - 1) DOWNTO (14 * W)));
		C13 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), 				TK3_NEXT(13 * W), TK3_PERM((6 * W - 1)), TK3((14 * W - 1) DOWNTO (13 * W)));
		C12 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), 				TK3_NEXT(12 * W), TK3_PERM((5 * W - 1)), TK3((13 * W - 1) DOWNTO (12 * W)));

		C11 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), 				TK3_NEXT(11 * W), TK3_PERM((4 * W - 1)), TK3((12 * W - 1) DOWNTO (11 * W)));
		C10 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), 				TK3_NEXT(10 * W), TK3_PERM((3 * W - 1)), TK3((11 * W - 1) DOWNTO (10 * W)));
		C09 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_H, KEY_CTL(1), 				TK3_NEXT( 9 * W), TK3_PERM((2 * W - 1)), TK3((10 * W - 1) DOWNTO ( 9 * W)));
		C08 : ENTITY work.CellT3 GENERIC MAP (BS => BS)  PORT MAP (CLK_H, KEY_CTL(1), KEY_CTL(0), TK3_NEXT( 8 * W), TK3_PERM((1 * W - 1)), TK3(( 9 * W - 1) DOWNTO ( 8 * W)));

		C07 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,									TK3_NEXT( 7 * W),								  TK3(( 8 * W - 1) DOWNTO ( 7 * W)));
		C06 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,				 					TK3_NEXT( 6 * W),								  TK3(( 7 * W - 1) DOWNTO ( 6 * W)));
		C05 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,				 					TK3_NEXT( 5 * W),								  TK3(( 6 * W - 1) DOWNTO ( 5 * W)));
		C04 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,				 					TK3_NEXT( 4 * W),								  TK3(( 5 * W - 1) DOWNTO ( 4 * W)));

		C03 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,									TK3_NEXT( 3 * W), 							  TK3(( 4 * W - 1) DOWNTO ( 3 * W)));
		C02 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,				 					TK3_NEXT( 2 * W),								  TK3(( 3 * W - 1) DOWNTO ( 2 * W)));
		C01 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK_L,				 					TK3_NEXT( 1 * W), 							  TK3(( 2 * W - 1) DOWNTO ( 1 * W)));
		C00 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK_L, RESET, 						TK3_NEXT( 0 * W), KEY(4), 					  TK3(( 1 * W - 1) DOWNTO ( 0 * W)));

		-- PERMUTATION -------------------------------------------------------------
		P3 : ENTITY work.Permutation GENERIC MAP (BS => BS) PORT MAP (TK3((16 * W - 1) DOWNTO (8 * W)), TK3_PERM);

		-- NEXT KEY ----------------------------------------------------------------
		TK3_NEXT((16 * W - 1) DOWNTO (8 * W)) <= TK3((16 * W - 2) DOWNTO (8 * W)) & TK3( 8 * W - 1) WHEN (RESET = '0') ELSE TK3((16 * W - 2) DOWNTO (8 * W)) & KEY(5);
		TK3_NEXT(( 8 * W - 1) DOWNTO (0 * W)) <= TK3(( 8 * W - 2) DOWNTO (0 * W)) & TK3(16 * W - 1);

		-- ROUND KEY ---------------------------------------------------------------
		ROUND_KEY(5) <= TK3(16 * W - 1) AND KEY_CTL(2);
		ROUND_KEY(4) <= '0';

	END GENERATE;

END Round;
