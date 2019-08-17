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
			 KEY_CTL		: IN	STD_LOGIC_VECTOR(0 DOWNTO 0);
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
	SIGNAL TK1, TK2, TK3							: STD_LOGIC_VECTOR((16 * W - 1) DOWNTO 0);
	SIGNAL TK1_LFSR, TK2_LFSR, TK3_LFSR		: STD_LOGIC_VECTOR(( 4 * W - 1) DOWNTO 0);
	SIGNAL TK1_PERM, TK2_PERM, TK3_PERM		: STD_LOGIC_VECTOR((16 * W - 1) DOWNTO 0);
	SIGNAL TK1_NEXT, TK2_NEXT, TK3_NEXT		: STD_LOGIC_VECTOR((16 * W - 1) DOWNTO 0);

BEGIN

	-- TWEAKEY ARRAY PERMUTATIONS : TK1 -------------------------------------------
	GEN_TK1 : IF TS = TWEAK_SIZE_1N OR TS = TWEAK_SIZE_2N OR TS = TWEAK_SIZE_3N GENERATE

		-- REGISTER STAGE -------------------------------------------------------------
		TK13 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK, KEY_CTL(0), TK1_NEXT((16 * W - 1) DOWNTO (12 * W)), TK1_PERM((16 * W - 1) DOWNTO (12 * W)), TK1((16 * W - 1) DOWNTO (12 * W)));
		TK12 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK, KEY_CTL(0), TK1_NEXT((12 * W - 1) DOWNTO ( 8 * W)), TK1_PERM((12 * W - 1) DOWNTO ( 8 * W)), TK1((12 * W - 1) DOWNTO ( 8 * W)));
		TK11 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK, KEY_CTL(0), TK1_NEXT(( 8 * W - 1) DOWNTO ( 4 * W)), TK1_PERM(( 8 * W - 1) DOWNTO ( 4 * W)), TK1(( 8 * W - 1) DOWNTO ( 4 * W)));
		TK10 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK, KEY_CTL(0), TK1_NEXT(( 4 * W - 1) DOWNTO ( 0 * W)), TK1_PERM(( 4 * W - 1) DOWNTO ( 0 * W)), TK1(( 4 * W - 1) DOWNTO ( 0 * W)));

		-- PERMUTATION -------------------------------------------------------------
		P1 : ENTITY work.Permutation GENERIC MAP (BS => BS) PORT MAP (TK1, TK1_PERM);

		-- NO LFSR -----------------------------------------------------------------
		TK1_LFSR((4 * W - 1) DOWNTO (3 * W)) <= TK1((16 * W - 1) DOWNTO (15 * W));
		TK1_LFSR((3 * W - 1) DOWNTO (2 * W)) <= TK1((12 * W - 1) DOWNTO (11 * W));
		TK1_LFSR((2 * W - 1) DOWNTO (1 * W)) <= TK1(( 8 * W - 1) DOWNTO ( 7 * W));
		TK1_LFSR((1 * W - 1) DOWNTO (0 * W)) <= TK1(( 4 * W - 1) DOWNTO ( 3 * W));

		-- NEXT KEY ----------------------------------------------------------------
		TK1_NEXT((16 * W - 1) DOWNTO (12 * W)) <= TK1((15 * W - 1) DOWNTO (12 * W)) & KEY((4 * W - 1) DOWNTO (3 * W)) WHEN (RESET = '1') ELSE TK1((15 * W - 1) DOWNTO (12 * W)) & TK1_LFSR((4 * W - 1) DOWNTO (3 * W));
	   TK1_NEXT((12 * W - 1) DOWNTO ( 8 * W)) <= TK1((11 * W - 1) DOWNTO ( 8 * W)) & KEY((3 * W - 1) DOWNTO (2 * W)) WHEN (RESET = '1') ELSE TK1((11 * W - 1) DOWNTO ( 8 * W)) & TK1_LFSR((3 * W - 1) DOWNTO (2 * W));
	   TK1_NEXT(( 8 * W - 1) DOWNTO ( 4 * W)) <= TK1(( 7 * W - 1) DOWNTO ( 4 * W)) & KEY((2 * W - 1) DOWNTO (1 * W)) WHEN (RESET = '1') ELSE TK1(( 7 * W - 1) DOWNTO ( 4 * W)) & TK1_LFSR((2 * W - 1) DOWNTO (1 * W));
	   TK1_NEXT(( 4 * W - 1) DOWNTO ( 0 * W)) <= TK1(( 3 * W - 1) DOWNTO ( 0 * W)) & KEY((1 * W - 1) DOWNTO (0 * W)) WHEN (RESET = '1') ELSE TK1(( 3 * W - 1) DOWNTO ( 0 * W)) & TK1_LFSR((1 * W - 1) DOWNTO (0 * W));

		-- ROUND KEY ---------------------------------------------------------------
		ROUND_KEY(( 4 * W - 1) DOWNTO ( 2 * W)) <= TK1((8 * W - 1) DOWNTO (7 * W)) & TK1((1 * W - 1) DOWNTO (0 * W));
		ROUND_KEY(( 2 * W - 1) DOWNTO ( 0 * W)) <= (OTHERS => '0');

	END GENERATE;

	-- TWEAKEY ARRAY PERMUTATIONS : TK2 -------------------------------------------
	GEN_TK2 : IF TS = TWEAK_SIZE_2N OR TS = TWEAK_SIZE_3N GENERATE

		-- REGISTER STAGE -------------------------------------------------------------
		TK23 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK, KEY_CTL(0), TK2_NEXT((16 * W - 1) DOWNTO (12 * W)), TK2_PERM((16 * W - 1) DOWNTO (12 * W)), TK2((16 * W - 1) DOWNTO (12 * W)));
		TK22 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK, KEY_CTL(0), TK2_NEXT((12 * W - 1) DOWNTO ( 8 * W)), TK2_PERM((12 * W - 1) DOWNTO ( 8 * W)), TK2((12 * W - 1) DOWNTO ( 8 * W)));
		TK21 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK, KEY_CTL(0), TK2_NEXT(( 8 * W - 1) DOWNTO ( 4 * W)), TK2_PERM(( 8 * W - 1) DOWNTO ( 4 * W)), TK2(( 8 * W - 1) DOWNTO ( 4 * W)));
		TK20 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK, KEY_CTL(0), TK2_NEXT(( 4 * W - 1) DOWNTO ( 0 * W)), TK2_PERM(( 4 * W - 1) DOWNTO ( 0 * W)), TK2(( 4 * W - 1) DOWNTO ( 0 * W)));

		-- PERMUTATION -------------------------------------------------------------
		P2 : ENTITY work.Permutation GENERIC MAP (BS => BS) PORT MAP (TK2, TK2_PERM);

		-- NO LFSR -----------------------------------------------------------------
		TK2_LFSR((4 * W - 1) DOWNTO (3 * W)) <= TK2((16 * W - 2) DOWNTO (15 * W)) & (TK2(16 * W - 1) XOR TK2(16 * W - (W / 8) - 2));
		TK2_LFSR((3 * W - 1) DOWNTO (2 * W)) <= TK2((12 * W - 2) DOWNTO (11 * W)) & (TK2(12 * W - 1) XOR TK2(12 * W - (W / 8) - 2));
		TK2_LFSR((2 * W - 1) DOWNTO (1 * W)) <= TK2(( 8 * W - 1) DOWNTO ( 7 * W));
		TK2_LFSR((1 * W - 1) DOWNTO (0 * W)) <= TK2(( 4 * W - 1) DOWNTO ( 3 * W));

		-- NEXT KEY ----------------------------------------------------------------
		TK2_NEXT((16 * W - 1) DOWNTO (12 * W)) <= TK2((15 * W - 1) DOWNTO (12 * W)) & KEY((8 * W - 1) DOWNTO (7 * W)) WHEN (RESET = '1') ELSE TK2((15 * W - 1) DOWNTO (12 * W)) & TK2_LFSR((4 * W - 1) DOWNTO (3 * W));
	   TK2_NEXT((12 * W - 1) DOWNTO ( 8 * W)) <= TK2((11 * W - 1) DOWNTO ( 8 * W)) & KEY((7 * W - 1) DOWNTO (6 * W)) WHEN (RESET = '1') ELSE TK2((11 * W - 1) DOWNTO ( 8 * W)) & TK2_LFSR((3 * W - 1) DOWNTO (2 * W));
	   TK2_NEXT(( 8 * W - 1) DOWNTO ( 4 * W)) <= TK2(( 7 * W - 1) DOWNTO ( 4 * W)) & KEY((6 * W - 1) DOWNTO (5 * W)) WHEN (RESET = '1') ELSE TK2(( 7 * W - 1) DOWNTO ( 4 * W)) & TK2_LFSR((2 * W - 1) DOWNTO (1 * W));
	   TK2_NEXT(( 4 * W - 1) DOWNTO ( 0 * W)) <= TK2(( 3 * W - 1) DOWNTO ( 0 * W)) & KEY((5 * W - 1) DOWNTO (4 * W)) WHEN (RESET = '1') ELSE TK2(( 3 * W - 1) DOWNTO ( 0 * W)) & TK2_LFSR((1 * W - 1) DOWNTO (0 * W));

		-- ROUND KEY ---------------------------------------------------------------
		ROUND_KEY(( 8 * W - 1) DOWNTO ( 6 * W)) <= TK2((8 * W - 1) DOWNTO (7 * W)) & TK2((1 * W - 1) DOWNTO (0 * W));
		ROUND_KEY(( 6 * W - 1) DOWNTO ( 4 * W)) <= (OTHERS => '0');

	END GENERATE;

	-- TWEAKEY ARRAY PERMUTATIONS : TK3 -------------------------------------------
	GEN_TK3 : IF TS = TWEAK_SIZE_3N GENERATE

		-- REGISTER STAGE -------------------------------------------------------------
		TK33 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK, KEY_CTL(0), TK3_NEXT((16 * W - 1) DOWNTO (12 * W)), TK3_PERM((16 * W - 1) DOWNTO (12 * W)), TK3((16 * W - 1) DOWNTO (12 * W)));
		TK32 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK, KEY_CTL(0), TK3_NEXT((12 * W - 1) DOWNTO ( 8 * W)), TK3_PERM((12 * W - 1) DOWNTO ( 8 * W)), TK3((12 * W - 1) DOWNTO ( 8 * W)));
		TK31 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK, KEY_CTL(0), TK3_NEXT(( 8 * W - 1) DOWNTO ( 4 * W)), TK3_PERM(( 8 * W - 1) DOWNTO ( 4 * W)), TK3(( 8 * W - 1) DOWNTO ( 4 * W)));
		TK30 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK, KEY_CTL(0), TK3_NEXT(( 4 * W - 1) DOWNTO ( 0 * W)), TK3_PERM(( 4 * W - 1) DOWNTO ( 0 * W)), TK3(( 4 * W - 1) DOWNTO ( 0 * W)));

		-- PERMUTATION -------------------------------------------------------------
		P2 : ENTITY work.Permutation GENERIC MAP (BS => BS) PORT MAP (TK3, TK3_PERM);

		-- NO LFSR -----------------------------------------------------------------
		TK3_LFSR((4 * W - 1) DOWNTO (3 * W)) <= (TK3(16 * W - (W / 8) - 1) XOR TK3(15 * W)) & TK3((16 * W - 1) DOWNTO (15 * W + 1));
		TK3_LFSR((3 * W - 1) DOWNTO (2 * W)) <= (TK3(12 * W - (W / 8) - 1) XOR TK3(11 * W)) & TK3((12 * W - 1) DOWNTO (11 * W + 1));
		TK3_LFSR((2 * W - 1) DOWNTO (1 * W)) <= TK3(( 8 * W - 1) DOWNTO ( 7 * W));
		TK3_LFSR((1 * W - 1) DOWNTO (0 * W)) <= TK3(( 4 * W - 1) DOWNTO ( 3 * W));

		-- NEXT KEY ----------------------------------------------------------------
		TK3_NEXT((16 * W - 1) DOWNTO (12 * W)) <= TK3((15 * W - 1) DOWNTO (12 * W)) & KEY((12 * W - 1) DOWNTO (11 * W)) WHEN (RESET = '1') ELSE TK3((15 * W - 1) DOWNTO (12 * W)) & TK3_LFSR((4 * W - 1) DOWNTO (3 * W));
	   TK3_NEXT((12 * W - 1) DOWNTO ( 8 * W)) <= TK3((11 * W - 1) DOWNTO ( 8 * W)) & KEY((11 * W - 1) DOWNTO (10 * W)) WHEN (RESET = '1') ELSE TK3((11 * W - 1) DOWNTO ( 8 * W)) & TK3_LFSR((3 * W - 1) DOWNTO (2 * W));
	   TK3_NEXT(( 8 * W - 1) DOWNTO ( 4 * W)) <= TK3(( 7 * W - 1) DOWNTO ( 4 * W)) & KEY((10 * W - 1) DOWNTO ( 9 * W)) WHEN (RESET = '1') ELSE TK3(( 7 * W - 1) DOWNTO ( 4 * W)) & TK3_LFSR((2 * W - 1) DOWNTO (1 * W));
	   TK3_NEXT(( 4 * W - 1) DOWNTO ( 0 * W)) <= TK3(( 3 * W - 1) DOWNTO ( 0 * W)) & KEY(( 9 * W - 1) DOWNTO ( 8 * W)) WHEN (RESET = '1') ELSE TK3(( 3 * W - 1) DOWNTO ( 0 * W)) & TK3_LFSR((1 * W - 1) DOWNTO (0 * W));

		-- ROUND KEY ---------------------------------------------------------------
		ROUND_KEY((12 * W - 1) DOWNTO (10 * W)) <= TK3((8 * W - 1) DOWNTO (7 * W)) & TK3((1 * W - 1) DOWNTO (0 * W));
		ROUND_KEY((10 * W - 1) DOWNTO ( 8 * W)) <= (OTHERS => '0');

	END GENERATE;

END Round;
