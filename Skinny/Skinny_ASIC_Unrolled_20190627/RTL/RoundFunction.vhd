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
ENTITY RoundFunction IS
	GENERIC ( BS : BLOCK_SIZE 		 := BLOCK_SIZE_64;
				 TS : TWEAK_SIZE 		 := TWEAK_SIZE_1N);
   PORT ( CLK        : IN  STD_LOGIC;
   	    -- CONSTANT PORT --------------------------------
          ROUND_CST  : IN  STD_LOGIC_VECTOR (5 DOWNTO 0);
   	    -- KEY PORT -------------------------------------
          ROUND_KEY  : IN  STD_LOGIC_VECTOR ((GET_TWEAK_SIZE(BS, TS) - 1) DOWNTO 0);
   	    -- DATA PORTS -----------------------------------
          ROUND_IN   : IN  STD_LOGIC_VECTOR ((GET_BLOCK_SIZE(BS) 	   - 1) DOWNTO 0);
          ROUND_OUT  : OUT STD_LOGIC_VECTOR ((GET_BLOCK_SIZE(BS) 	   - 1) DOWNTO 0));
END RoundFunction;



-- ARCHITECTURE : UNROLLED
----------------------------------------------------------------------------------
ARCHITECTURE Unrolled OF RoundFunction IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);
	CONSTANT N : INTEGER := GET_BLOCK_SIZE(BS);
	CONSTANT T : INTEGER := GET_TWEAK_SIZE(BS, TS);

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL SUBSTITUTE, ADDITION, SHIFTROWS	: STD_LOGIC_VECTOR((N - 1) DOWNTO 0);

BEGIN

	-- SUBSTITUTION ---------------------------------------------------------------
	SB : FOR I IN 0 TO 15 GENERATE
			S : ENTITY work.SBox GENERIC MAP (BS => BS) PORT MAP (ROUND_IN((W * (I + 1) - 1) DOWNTO (W * I)), SUBSTITUTE((W * (I + 1) - 1) DOWNTO (W * I)));
	END GENERATE;

	-- CONSTANT AND KEY ADDITION --------------------------------------------------
	KA : ENTITY work.AddConstKey GENERIC MAP (BS => BS, TS => TS) PORT MAP (ROUND_CST, ROUND_KEY, SUBSTITUTE, ADDITION);

	-- SHIFT ROWS -----------------------------------------------------------------
	SR : ENTITY work.ShiftRows GENERIC MAP (BS => BS) PORT MAP (ADDITION, SHIFTROWS);

	-- MIX COLUMNS ----------------------------------------------------------------
	MC : ENTITY work.MixColumns GENERIC MAP (BS => BS) PORT MAP (SHIFTROWS, ROUND_OUT);

END Unrolled;
