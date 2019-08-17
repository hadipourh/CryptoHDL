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
			 KEY_CTL		: IN	STD_LOGIC_VECTOR(1 DOWNTO 0);
		    -- KEY PORT -------------------------------------
			 KEY			: IN  STD_LOGIC_VECTOR (((GET_TWEAK_SIZE(BS, TS) / 4) - 1) DOWNTO 0);
			 ROUND_KEY	: OUT STD_LOGIC_VECTOR (((GET_TWEAK_SIZE(BS, TS) / 4) - 1) DOWNTO 0));
END KeyExpansion;



-- ARCHITECTURE : ROUND
----------------------------------------------------------------------------------
ARCHITECTURE Round OF KeyExpansion IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);
	CONSTANT N : INTEGER := GET_BLOCK_SIZE(BS);
	CONSTANT T : INTEGER := GET_TWEAK_SIZE(BS, TS);

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL CLK_K, CLK_CE_K, CLK_GATE_K		: STD_LOGIC;
	SIGNAL TK1, TK2, TK3							: STD_LOGIC_VECTOR((16 * W - 1) DOWNTO 0);
	SIGNAL TK1_PERM, TK2_PERM, TK3_PERM		: STD_LOGIC_VECTOR(( 8 * W - 1) DOWNTO 0);
	SIGNAL TK1_NEXT, TK2_NEXT, TK3_NEXT		: STD_LOGIC_VECTOR(( 8 * W - 1) DOWNTO 0);

BEGIN

	-- CLOCK GATING ---------------------------------------------------------------
	CLK_CE_K <= '1' WHEN (RESET = '1' OR KEY_CTL(0) = '1') ELSE '0';

	GATE : PROCESS(CLK, CLK_CE_K)
	BEGIN
		IF (NOT(CLK) = '1') THEN
			CLK_GATE_K	<= CLK_CE_K;
		END IF;
	END PROCESS;

	CLK_K	<= CLK AND CLK_GATE_K;
	-------------------------------------------------------------------------------

	-- TWEAKEY ARRAY PERMUTATIONS : TK1 -------------------------------------------
	GEN_TK1 : IF TS = TWEAK_SIZE_1N OR TS = TWEAK_SIZE_2N OR TS = TWEAK_SIZE_3N GENERATE

		-- REGISTER STAGE -------------------------------------------------------------
		TK13 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK_K, KEY_CTL(1), TK1((12 * W - 1) DOWNTO ( 8 * W)), TK1_NEXT((8 * W - 1) DOWNTO ( 4 * W)), TK1((16 * W - 1) DOWNTO (12 * W)));
		TK12 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK_K, KEY_CTL(1), TK1(( 8 * W - 1) DOWNTO ( 4 * W)), TK1_NEXT((4 * W - 1) DOWNTO ( 0 * W)), TK1((12 * W - 1) DOWNTO ( 8 * W)));
		TK11 : ENTITY work.DataFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK_K, 				  TK1(( 4 * W - 1) DOWNTO ( 0 * W)),													 TK1(( 8 * W - 1) DOWNTO ( 4 * W)));
		TK10 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK_K, RESET, 	  TK1((16 * W - 1) DOWNTO (12 * W)), KEY(( 4 * W - 1) DOWNTO ( 0 * W)), 	 TK1(( 4 * W - 1) DOWNTO ( 0 * W)));

		-- PERMUTATION -------------------------------------------------------------
		P1 : ENTITY work.Permutation GENERIC MAP (BS => BS) PORT MAP (TK1((12 * W - 1) DOWNTO (4 * W)), TK1_PERM);

		-- NO LFSR -----------------------------------------------------------------
		TK1_NEXT <= TK1_PERM;

		-- ROUND KEY ---------------------------------------------------------------
		ROUND_KEY(( 4 * W - 1) DOWNTO ( 0 * W)) <= TK1((16 * W - 1) DOWNTO (12 * W)) 												  WHEN (CLK_CE_K = '1' AND KEY_CTL(1) = '0') ELSE
																 TK1((13 * W - 1) DOWNTO (12 * W)) & TK1((16 * W - 1) DOWNTO (13 * W)) WHEN (CLK_CE_K = '1' AND KEY_CTL(1) = '1') ELSE (OTHERS => '0');

	END GENERATE;

	-- TWEAKEY ARRAY PERMUTATIONS : TK2 -------------------------------------------
	GEN_TK2 : IF TS = TWEAK_SIZE_2N OR TS = TWEAK_SIZE_3N GENERATE

		-- REGISTER STAGE -------------------------------------------------------------
		TK23 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK_K, KEY_CTL(1), TK2((12 * W - 1) DOWNTO ( 8 * W)), TK2_NEXT((8 * W - 1) DOWNTO ( 4 * W)), TK2((16 * W - 1) DOWNTO (12 * W)));
		TK22 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK_K, KEY_CTL(1), TK2(( 8 * W - 1) DOWNTO ( 4 * W)), TK2_NEXT((4 * W - 1) DOWNTO ( 0 * W)), TK2((12 * W - 1) DOWNTO ( 8 * W)));
		TK21 : ENTITY work.DataFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK_K, 				  TK2(( 4 * W - 1) DOWNTO ( 0 * W)),													 TK2(( 8 * W - 1) DOWNTO ( 4 * W)));
		TK20 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK_K, RESET, 	  TK2((16 * W - 1) DOWNTO (12 * W)), KEY(( 8 * W - 1) DOWNTO ( 4 * W)), 	 TK2(( 4 * W - 1) DOWNTO ( 0 * W)));

		-- PERMUTATION -------------------------------------------------------------
		P1 : ENTITY work.Permutation GENERIC MAP (BS => BS) PORT MAP (TK2((12 * W - 1) DOWNTO (4 * W)), TK2_PERM);

		-- LFSR --------------------------------------------------------------------
		TK2_NEXT((8 * W - 1) DOWNTO (7 * W)) <= TK2_PERM((8 * W - 2) DOWNTO (7 * W)) & (TK2_PERM(8 * W - 1) XOR TK2_PERM(8 * W - (W / 8) - 2));
		TK2_NEXT((7 * W - 1) DOWNTO (6 * W)) <= TK2_PERM((7 * W - 2) DOWNTO (6 * W)) & (TK2_PERM(7 * W - 1) XOR TK2_PERM(7 * W - (W / 8) - 2));
		TK2_NEXT((6 * W - 1) DOWNTO (5 * W)) <= TK2_PERM((6 * W - 2) DOWNTO (5 * W)) & (TK2_PERM(6 * W - 1) XOR TK2_PERM(6 * W - (W / 8) - 2));
		TK2_NEXT((5 * W - 1) DOWNTO (4 * W)) <= TK2_PERM((5 * W - 2) DOWNTO (4 * W)) & (TK2_PERM(5 * W - 1) XOR TK2_PERM(5 * W - (W / 8) - 2));
		TK2_NEXT((4 * W - 1) DOWNTO (3 * W)) <= TK2_PERM((4 * W - 2) DOWNTO (3 * W)) & (TK2_PERM(4 * W - 1) XOR TK2_PERM(4 * W - (W / 8) - 2));
		TK2_NEXT((3 * W - 1) DOWNTO (2 * W)) <= TK2_PERM((3 * W - 2) DOWNTO (2 * W)) & (TK2_PERM(3 * W - 1) XOR TK2_PERM(3 * W - (W / 8) - 2));
		TK2_NEXT((2 * W - 1) DOWNTO (1 * W)) <= TK2_PERM((2 * W - 2) DOWNTO (1 * W)) & (TK2_PERM(2 * W - 1) XOR TK2_PERM(2 * W - (W / 8) - 2));
		TK2_NEXT((1 * W - 1) DOWNTO (0 * W)) <= TK2_PERM((1 * W - 2) DOWNTO (0 * W)) & (TK2_PERM(1 * W - 1) XOR TK2_PERM(1 * W - (W / 8) - 2));

		-- ROUND KEY ---------------------------------------------------------------
		ROUND_KEY(( 8 * W - 1) DOWNTO ( 4 * W)) <= TK2((16 * W - 1) DOWNTO (12 * W)) 												  WHEN (CLK_CE_K = '1' AND KEY_CTL(1) = '0') ELSE
																 TK2((13 * W - 1) DOWNTO (12 * W)) & TK2((16 * W - 1) DOWNTO (13 * W)) WHEN (CLK_CE_K = '1' AND KEY_CTL(1) = '1') ELSE (OTHERS => '0');

	END GENERATE;

	-- TWEAKEY ARRAY PERMUTATIONS : TK3 -------------------------------------------
	GEN_TK3 : IF TS = TWEAK_SIZE_3N GENERATE

		-- REGISTER STAGE -------------------------------------------------------------
		TK33 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK_K, KEY_CTL(1), TK3((12 * W - 1) DOWNTO ( 8 * W)), TK3_NEXT((8 * W - 1) DOWNTO ( 4 * W)), TK3((16 * W - 1) DOWNTO (12 * W)));
		TK32 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK_K, KEY_CTL(1), TK3(( 8 * W - 1) DOWNTO ( 4 * W)), TK3_NEXT((4 * W - 1) DOWNTO ( 0 * W)), TK3((12 * W - 1) DOWNTO ( 8 * W)));
		TK31 : ENTITY work.DataFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK_K, 				  TK3(( 4 * W - 1) DOWNTO ( 0 * W)),													 TK3(( 8 * W - 1) DOWNTO ( 4 * W)));
		TK30 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK_K, RESET, 	  TK3((16 * W - 1) DOWNTO (12 * W)), KEY((12 * W - 1) DOWNTO ( 8 * W)), 	 TK3(( 4 * W - 1) DOWNTO ( 0 * W)));

		-- PERMUTATION -------------------------------------------------------------
		P1 : ENTITY work.Permutation GENERIC MAP (BS => BS) PORT MAP (TK3((12 * W - 1) DOWNTO (4 * W)), TK3_PERM);

		-- LFSR --------------------------------------------------------------------
		TK3_NEXT((8 * W - 1) DOWNTO (7 * W)) <= (TK3_PERM(8 * W - (W / 8) - 1) XOR TK3_PERM(7 * W)) & TK3_PERM((8 * W - 1) DOWNTO (7 * W + 1));
		TK3_NEXT((7 * W - 1) DOWNTO (6 * W)) <= (TK3_PERM(7 * W - (W / 8) - 1) XOR TK3_PERM(6 * W)) & TK3_PERM((7 * W - 1) DOWNTO (6 * W + 1));
		TK3_NEXT((6 * W - 1) DOWNTO (5 * W)) <= (TK3_PERM(6 * W - (W / 8) - 1) XOR TK3_PERM(5 * W)) & TK3_PERM((6 * W - 1) DOWNTO (5 * W + 1));
		TK3_NEXT((5 * W - 1) DOWNTO (4 * W)) <= (TK3_PERM(5 * W - (W / 8) - 1) XOR TK3_PERM(4 * W)) & TK3_PERM((5 * W - 1) DOWNTO (4 * W + 1));
		TK3_NEXT((4 * W - 1) DOWNTO (3 * W)) <= (TK3_PERM(4 * W - (W / 8) - 1) XOR TK3_PERM(3 * W)) & TK3_PERM((4 * W - 1) DOWNTO (3 * W + 1));
		TK3_NEXT((3 * W - 1) DOWNTO (2 * W)) <= (TK3_PERM(3 * W - (W / 8) - 1) XOR TK3_PERM(2 * W)) & TK3_PERM((3 * W - 1) DOWNTO (2 * W + 1));
		TK3_NEXT((2 * W - 1) DOWNTO (1 * W)) <= (TK3_PERM(2 * W - (W / 8) - 1) XOR TK3_PERM(1 * W)) & TK3_PERM((2 * W - 1) DOWNTO (1 * W + 1));
		TK3_NEXT((1 * W - 1) DOWNTO (0 * W)) <= (TK3_PERM(1 * W - (W / 8) - 1) XOR TK3_PERM(0 * W)) & TK3_PERM((1 * W - 1) DOWNTO (0 * W + 1));

		-- ROUND KEY ---------------------------------------------------------------
		ROUND_KEY((12 * W - 1) DOWNTO ( 8 * W)) <= TK3((16 * W - 1) DOWNTO (12 * W)) 												  WHEN (CLK_CE_K = '1' AND KEY_CTL(1) = '0') ELSE
																 TK3((13 * W - 1) DOWNTO (12 * W)) & TK3((16 * W - 1) DOWNTO (13 * W)) WHEN (CLK_CE_K = '1' AND KEY_CTL(1) = '1') ELSE (OTHERS => '0');

	END GENERATE;

END Round;
