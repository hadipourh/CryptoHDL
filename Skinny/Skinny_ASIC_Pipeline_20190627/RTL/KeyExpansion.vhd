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
		    -- KEY PORT -------------------------------------
			 KEY			: IN  STD_LOGIC_VECTOR ((GET_TWEAK_SIZE(BS, TS) - 1) DOWNTO 0);
			 ROUND_KEY	: OUT STD_LOGIC_VECTOR ((GET_TWEAK_SIZE(BS, TS) - 1) DOWNTO 0));
END KeyExpansion;



-- ARCHITECTURE : ROUND
----------------------------------------------------------------------------------
ARCHITECTURE Round OF KeyExpansion IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);
	CONSTANT N : INTEGER := GET_BLOCK_SIZE(BS);
	CONSTANT T : INTEGER := GET_TWEAK_SIZE(BS, TS);

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL KEY_STATE, KEY_NEXT, KEY_PERM	: STD_LOGIC_VECTOR((T - 1) DOWNTO 0);

BEGIN

	-- TWEAKEY ARRAY PERMUTATIONS : TK1 -------------------------------------------
	TK1 : IF TS = TWEAK_SIZE_1N OR TS = TWEAK_SIZE_2N OR TS = TWEAK_SIZE_3N GENERATE

		-- PERMUTATION -------------------------------------------------------------
		P1 : ENTITY work.Permutation GENERIC MAP (BS => BS) PORT MAP (KEY((T - 0 * N - 1) DOWNTO (T - 1 * N)), KEY_PERM((T - 0 * N - 1) DOWNTO (T - 1 * N)));

		-- NO LFSR -----------------------------------------------------------------
		KEY_NEXT((T - 0 * N - 1) DOWNTO (T - 1 * N)) <= KEY_PERM((T - 0 * N - 1) DOWNTO (T - 1 * N));

	END GENERATE;

	-- TWEAKEY ARRAY PERMUTATIONS : TK2 -------------------------------------------
	TK2 : IF TS = TWEAK_SIZE_2N OR TS = TWEAK_SIZE_3N GENERATE

		-- PERMUTATION -------------------------------------------------------------
		P2 : ENTITY work.Permutation GENERIC MAP (BS => BS) PORT MAP (KEY((T - 1 * N - 1) DOWNTO (T - 2 * N)), KEY_PERM((T - 1 * N - 1) DOWNTO (T - 2 * N)));

		-- LFSR --------------------------------------------------------------------
		LFSR2 : FOR I IN 0 TO 3 GENERATE
			KEY_NEXT((T + W * (I + 13) - 2 * N - 1) DOWNTO (T + W * (I + 12) - 2 * N)) <= KEY_PERM((T + W * (I + 13) - 2 * N - 2) DOWNTO (T + W * (I + 12) - 2 * N)) & (KEY_PERM(T + W * (I + 13) - 2 * N - 1) XOR KEY_PERM(T + W * (I + 13) - 2 * N - (W / 4) - 1));
			KEY_NEXT((T + W * (I +  9) - 2 * N - 1) DOWNTO (T + W * (I +  8) - 2 * N)) <= KEY_PERM((T + W * (I +  9) - 2 * N - 2) DOWNTO (T + W * (I +  8) - 2 * N)) & (KEY_PERM(T + W * (I +  9) - 2 * N - 1) XOR KEY_PERM(T + W * (I +  9) - 2 * N - (W / 4) - 1));
			KEY_NEXT((T + W * (I +  5) - 2 * N - 1) DOWNTO (T + W * (I +  4) - 2 * N)) <= KEY_PERM((T + W * (I +  5) - 2 * N - 1) DOWNTO (T + W * (I +  4) - 2 * N));
			KEY_NEXT((T + W * (I +  1) - 2 * N - 1) DOWNTO (T + W * (I +  0) - 2 * N)) <= KEY_PERM((T + W * (I +  1) - 2 * N - 1) DOWNTO (T + W * (I +  0) - 2 * N));
		END GENERATE;

	END GENERATE;

	-- TWEAKEY ARRAY PERMUTATIONS : TK3 -------------------------------------------
	TK3 : IF TS = TWEAK_SIZE_3N GENERATE

		-- PERMUTATION -------------------------------------------------------------
		P3 : ENTITY work.Permutation GENERIC MAP (BS => BS) PORT MAP (KEY((T - 2 * N - 1) DOWNTO (T - 3 * N)), KEY_PERM((T - 2 * N - 1) DOWNTO (T - 3 * N)));

		-- LFSR --------------------------------------------------------------------
		LFSR3 : FOR I IN 0 TO 3 GENERATE
			KEY_NEXT((T + W * (I + 13) - 3 * N - 1) DOWNTO (T + W * (I + 12) - 3 * N)) <= (KEY_PERM(T + W * (I + 12) - 3 * N) XOR KEY_PERM(T + W * (I + 13) - 3 * N - (W / 4))) & KEY_PERM((T + W * (I + 13) - 3 * N - 1) DOWNTO (T + W * (I + 12) - 3 * N + 1));
			KEY_NEXT((T + W * (I +  9) - 3 * N - 1) DOWNTO (T + W * (I +  8) - 3 * N)) <= (KEY_PERM(T + W * (I +  8) - 3 * N) XOR KEY_PERM(T + W * (I +  9) - 3 * N - (W / 4))) & KEY_PERM((T + W * (I +  9) - 3 * N - 1) DOWNTO (T + W * (I +  8) - 3 * N + 1));
			KEY_NEXT((T + W * (I +  5) - 3 * N - 1) DOWNTO (T + W * (I +  4) - 3 * N)) <= KEY_PERM((T + W * (I +  5) - 3 * N - 1) DOWNTO (T + W * (I +  4) - 3 * N));
			KEY_NEXT((T + W * (I +  1) - 3 * N - 1) DOWNTO (T + W * (I +  0) - 3 * N)) <= KEY_PERM((T + W * (I +  1) - 3 * N - 1) DOWNTO (T + W * (I +  0) - 3 * N));
		END GENERATE;

	END GENERATE;

	-- REGISTER STAGE -------------------------------------------------------------
	RS : ENTITY work.DataFF GENERIC MAP (SIZE => T) PORT MAP (CLK, KEY_NEXT, ROUND_KEY);

END Round;
