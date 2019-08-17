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
   		 -- CONTROL PORTS --------------------------------
          RESET      : IN  STD_LOGIC;
          ROUND_CTL  : IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
   	    -- CONSTANT PORT --------------------------------
          ROUND_CST  : IN  STD_LOGIC_VECTOR(((GET_BLOCK_SIZE(BS) 	   / 4) - 1) DOWNTO 0);
   	    -- KEY PORT -------------------------------------
          ROUND_KEY  : IN  STD_LOGIC_VECTOR(((GET_TWEAK_SIZE(BS, TS) / 4) - 1) DOWNTO 0);
   	    -- DATA PORTS -----------------------------------
          ROUND_IN   : IN  STD_LOGIC_VECTOR(((GET_BLOCK_SIZE(BS) 	   / 4) - 1) DOWNTO 0);
          ROUND_OUT  : OUT STD_LOGIC_VECTOR(((GET_BLOCK_SIZE(BS) 	   / 4) - 1) DOWNTO 0));
END RoundFunction;



-- ARCHITECTURE : ROW
----------------------------------------------------------------------------------
ARCHITECTURE Row OF RoundFunction IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);
	CONSTANT N : INTEGER := GET_BLOCK_SIZE(BS);
	CONSTANT T : INTEGER := GET_TWEAK_SIZE(BS, TS);

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL STATE, SHIFTROWS, STATE_NEXT             : STD_LOGIC_VECTOR((16 * W - 1) DOWNTO 0);
	SIGNAL SUBSTITUTE, ADDITION, COLUMN, MIXCOLUMN	: STD_LOGIC_VECTOR(( 4 * W - 1) DOWNTO 0);

BEGIN

   -- SIGNAL ASSIGNMENTS ---------------------------------------------------------
   COLUMN <= STATE((16 * W - 1) DOWNTO (15 * W)) & STATE((12 * W - 1) DOWNTO (11 * W)) & STATE((8 * W - 1) DOWNTO (7 * W)) & STATE((4 * W - 1) DOWNTO (3 * W));

	-- REGISTER STAGES ------------------------------------------------------------
	R3 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK, ROUND_CTL(2), STATE_NEXT((16 * W - 1) DOWNTO (12 * W)), SHIFTROWS((12 * W - 1) DOWNTO ( 8 * W)), STATE((16 * W - 1) DOWNTO (12 * W)));
	R2 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK, ROUND_CTL(1), STATE_NEXT((12 * W - 1) DOWNTO ( 8 * W)), SHIFTROWS(( 8 * W - 1) DOWNTO ( 4 * W)), STATE((12 * W - 1) DOWNTO ( 8 * W)));
	R1 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK, ROUND_CTL(0), STATE_NEXT(( 8 * W - 1) DOWNTO ( 4 * W)), SHIFTROWS(( 4 * W - 1) DOWNTO ( 0 * W)), STATE(( 8 * W - 1) DOWNTO ( 4 * W)));
	R0 : ENTITY work.ScanFF GENERIC MAP (SIZE => 4 * W) PORT MAP (CLK, RESET,        STATE_NEXT(( 4 * W - 1) DOWNTO ( 0 * W)), ROUND_IN,                                STATE(( 4 * W - 1) DOWNTO ( 0 * W)));

	-- SUBSTITUTION ---------------------------------------------------------------
	SB : FOR I IN 0 TO 3 GENERATE
			S : ENTITY work.SBox GENERIC MAP (BS => BS) PORT MAP (STATE((W * (I + 13) - 1) DOWNTO (W * (I + 12))), SUBSTITUTE((W * (I + 1) - 1) DOWNTO (W * I)));
	END GENERATE;

	-- CONSTANT AND KEY ADDITION --------------------------------------------------
	KA : ENTITY work.AddConstKey GENERIC MAP (BS => BS, TS => TS) PORT MAP (ROUND_CST, ROUND_KEY, SUBSTITUTE, ADDITION);

	-- SHIFT ROWS -----------------------------------------------------------------
	SR : ENTITY work.ShiftRows GENERIC MAP (BS => BS) PORT MAP (STATE, SHIFTROWS);

	-- MIX COLUMNS ----------------------------------------------------------------
	MC : ENTITY work.MixColumns GENERIC MAP (BS => BS) PORT MAP (COLUMN, MIXCOLUMN);

   -- MULTIPLEXERS ---------------------------------------------------------------
   STATE_NEXT((16 * W - 1) DOWNTO (12 * W)) <= STATE((15 * W - 1) DOWNTO (12 * W)) & MIXCOLUMN((4 * W - 1) DOWNTO (3 * W)) WHEN (ROUND_CTL(3) = '1') ELSE STATE((12 * W - 1) DOWNTO (8 *W));
   STATE_NEXT((12 * W - 1) DOWNTO ( 8 * W)) <= STATE((11 * W - 1) DOWNTO ( 8 * W)) & MIXCOLUMN((3 * W - 1) DOWNTO (2 * W)) WHEN (ROUND_CTL(3) = '1') ELSE STATE(( 8 * W - 1) DOWNTO (4 *W));
   STATE_NEXT(( 8 * W - 1) DOWNTO ( 4 * W)) <= STATE(( 7 * W - 1) DOWNTO ( 4 * W)) & MIXCOLUMN((2 * W - 1) DOWNTO (1 * W)) WHEN (ROUND_CTL(3) = '1') ELSE STATE(( 4 * W - 1) DOWNTO (0 *W));
   STATE_NEXT(( 4 * W - 1) DOWNTO ( 0 * W)) <= STATE(( 3 * W - 1) DOWNTO ( 0 * W)) & MIXCOLUMN((1 * W - 1) DOWNTO (0 * W)) WHEN (ROUND_CTL(3) = '1') ELSE ADDITION;

	-- ROUND OUTPUT ---------------------------------------------------------------
	ROUND_OUT <= STATE((16 * W - 1) DOWNTO (12 * W));

END Row;
