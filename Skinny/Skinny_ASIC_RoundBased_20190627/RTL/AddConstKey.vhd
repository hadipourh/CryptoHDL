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
ENTITY AddConstKey IS
	GENERIC ( BS : BLOCK_SIZE 		 := BLOCK_SIZE_64;
			 	 TS : TWEAK_SIZE 		 := TWEAK_SIZE_1N);
	PORT ( -- CONST PORT -----------------------------------
			 CONST			: IN	STD_LOGIC_VECTOR(5 DOWNTO 0);
			 -- KEY PORT -------------------------------------
			 ROUND_KEY		: IN	STD_LOGIC_VECTOR((GET_TWEAK_SIZE(BS, TS) 	- 1) DOWNTO 0);
			 -- DATA PORTS -----------------------------------
			 DATA_IN			: IN	STD_LOGIC_VECTOR((GET_BLOCK_SIZE(BS)	 	- 1) DOWNTO 0);
			 DATA_OUT		: OUT STD_LOGIC_VECTOR((GET_BLOCK_SIZE(BS) 		- 1) DOWNTO 0));
END AddConstKey;



-- ARCHITECTURE : MIXED
----------------------------------------------------------------------------------
ARCHITECTURE Parallel OF AddConstKey IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT N : INTEGER := GET_BLOCK_SIZE(BS);
	CONSTANT T : INTEGER := GET_TWEAK_SIZE(BS, TS);
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL CONST_ADDITION	: STD_LOGIC_VECTOR((N - 1) DOWNTO 0);

BEGIN

	-- CONSTANT ADDITION ----------------------------------------------------------
	N64 : IF BS = BLOCK_SIZE_64 GENERATE
		CONST_ADDITION(63 DOWNTO 60) <= DATA_IN(63 DOWNTO 60) XOR CONST(3 DOWNTO 0);
		CONST_ADDITION(59 DOWNTO 46) <= DATA_IN(59 DOWNTO 46);
		CONST_ADDITION(45 DOWNTO 44) <= DATA_IN(45 DOWNTO 44) XOR CONST(5 DOWNTO 4);
		CONST_ADDITION(43 DOWNTO 30) <= DATA_IN(43 DOWNTO 30);
		CONST_ADDITION(29) 	     	  <= NOT(DATA_IN(29));
		CONST_ADDITION(28 DOWNTO  0) <= DATA_IN(28 DOWNTO  0);
	END GENERATE;

	N128 : IF BS = BLOCK_SIZE_128 GENERATE
		CONST_ADDITION(127 DOWNTO 124) <= DATA_IN(127 DOWNTO 124);
		CONST_ADDITION(123 DOWNTO 120) <= DATA_IN(123 DOWNTO 120) XOR CONST(3 DOWNTO 0);
		CONST_ADDITION(119 DOWNTO  90) <= DATA_IN(119 DOWNTO  90);
		CONST_ADDITION( 89 DOWNTO  88) <= DATA_IN( 89 DOWNTO  88) XOR CONST(5 DOWNTO 4);
		CONST_ADDITION( 87 DOWNTO  58) <= DATA_IN( 87 DOWNTO  58);
		CONST_ADDITION(57) 	    	    <= NOT(DATA_IN(57));
		CONST_ADDITION( 56 DOWNTO   0) <= DATA_IN( 56 DOWNTO   0);
	END GENERATE;
	-------------------------------------------------------------------------------

	-- ROUNDKEY ADDITION ----------------------------------------------------------
	T1N : IF TS = TWEAK_SIZE_1N GENERATE
		DATA_OUT((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY((16 * W - 1) DOWNTO (12 * W));
		DATA_OUT((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY((12 * W - 1) DOWNTO ( 8 * W));
	END GENERATE;

	T2N : IF TS = TWEAK_SIZE_2N GENERATE
		DATA_OUT((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY((16 * W - 1) DOWNTO (12 * W));
		DATA_OUT((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY((12 * W - 1) DOWNTO ( 8 * W));
	END GENERATE;

	T3N : IF TS = TWEAK_SIZE_3N GENERATE
		DATA_OUT((16 * W - 1) DOWNTO (12 * W)) <= CONST_ADDITION((16 * W - 1) DOWNTO (12 * W)) XOR ROUND_KEY((2 * N + 16 * W - 1) DOWNTO (2 * N + 12 * W)) XOR ROUND_KEY((1 * N + 16 * W - 1) DOWNTO (1 * N + 12 * W)) XOR ROUND_KEY((16 * W - 1) DOWNTO (12 * W));
		DATA_OUT((12 * W - 1) DOWNTO ( 8 * W)) <= CONST_ADDITION((12 * W - 1) DOWNTO ( 8 * W)) XOR ROUND_KEY((2 * N + 12 * W - 1) DOWNTO (2 * N +  8 * W)) XOR ROUND_KEY((1 * N + 12 * W - 1) DOWNTO (1 * N +  8 * W)) XOR ROUND_KEY((12 * W - 1) DOWNTO ( 8 * W));
	END GENERATE;

	DATA_OUT(( 8 * W - 1) DOWNTO ( 4 * W)) <= CONST_ADDITION(( 8 * W - 1) DOWNTO ( 4 * W));
	DATA_OUT(( 4 * W - 1) DOWNTO ( 0 * W)) <= CONST_ADDITION(( 4 * W - 1) DOWNTO ( 0 * W));
	-------------------------------------------------------------------------------

END Parallel;
