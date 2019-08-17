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
          ROUND_CTL  : IN  STD_LOGIC_VECTOR((GET_WORD_SIZE(BS)  + 1) DOWNTO 0);
   	    -- KEY PORT -------------------------------------
          ROUND_KEY  : IN  STD_LOGIC_VECTOR((GET_TWEAK_FACT(TS) - 1) DOWNTO 0);
   	    -- CONSTANT PORT --------------------------------
          ROUND_CST  : IN  STD_LOGIC;
   	    -- DATA PORTS -----------------------------------
          ROUND_IN   : IN  STD_LOGIC;
          ROUND_OUT  : OUT STD_LOGIC);
END RoundFunction;



-- ARCHITECTURE : BIT
----------------------------------------------------------------------------------
ARCHITECTURE Bit OF RoundFunction IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);
	CONSTANT N : INTEGER := GET_BLOCK_SIZE(BS);
	CONSTANT T : INTEGER := GET_TWEAK_SIZE(BS, TS);

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL STATE, SHIFTROWS, STATE_NEXT : STD_LOGIC_VECTOR((16 * W - 1) DOWNTO 0);
	SIGNAL COLUMN, MIXCOLUMN				: STD_LOGIC_VECTOR(           3 DOWNTO 0);
	SIGNAL ADDITION							: STD_LOGIC;

BEGIN

   -- SIGNAL ASSIGNMENTS ---------------------------------------------------------
   COLUMN <= STATE((16 * W - 1)) & STATE((12 * W - 1)) & STATE((8 * W - 1)) & STATE((4 * W - 1));

	-- REGISTER STAGES ------------------------------------------------------------
   C15 : ENTITY work.CellSB GENERIC MAP (BS => BS)  PORT MAP (CLK, ROUND_CTL(0), ROUND_CTL((W + 1) DOWNTO 2), STATE_NEXT(15 * W), SHIFTROWS((16 * W - 1)), STATE((16 * W - 1) DOWNTO (15 * W)));
	C14 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK, ROUND_CTL(0),               					  STATE_NEXT(14 * W), SHIFTROWS((15 * W - 1)), STATE((15 * W - 1) DOWNTO (14 * W)));
	C13 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK, ROUND_CTL(0),               					  STATE_NEXT(13 * W), SHIFTROWS((14 * W - 1)), STATE((14 * W - 1) DOWNTO (13 * W)));
	C12 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK, ROUND_CTL(0),              					  STATE_NEXT(12 * W), SHIFTROWS((13 * W - 1)), STATE((13 * W - 1) DOWNTO (12 * W)));

	C11 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK, ROUND_CTL(0), 									  STATE_NEXT(11 * w), SHIFTROWS((12 * W - 1)), STATE((12 * W - 1) DOWNTO (11 * W)));
	C10 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK, ROUND_CTL(0), 									  STATE_NEXT(10 * W), SHIFTROWS((11 * W - 1)), STATE((11 * W - 1) DOWNTO (10 * W)));
	C09 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK, ROUND_CTL(0),            						  STATE_NEXT( 9 * W), SHIFTROWS((10 * W - 1)), STATE((10 * W - 1) DOWNTO ( 9 * W)));
	C08 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK, ROUND_CTL(0),             					  STATE_NEXT( 8 * W), SHIFTROWS(( 9 * W - 1)), STATE(( 9 * W - 1) DOWNTO ( 8 * W)));

	C07 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK, ROUND_CTL(0), 									  STATE_NEXT( 7 * W), SHIFTROWS(( 8 * W - 1)), STATE(( 8 * W - 1) DOWNTO ( 7 * W)));
	C06 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK, ROUND_CTL(0),             					  STATE_NEXT( 6 * W), SHIFTROWS(( 7 * W - 1)), STATE(( 7 * W - 1) DOWNTO ( 6 * W)));
	C05 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK, ROUND_CTL(0), 									  STATE_NEXT( 5 * W), SHIFTROWS(( 6 * W - 1)), STATE(( 6 * W - 1) DOWNTO ( 5 * W)));
	C04 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK, ROUND_CTL(0),             					  STATE_NEXT( 4 * W), SHIFTROWS(( 5 * W - 1)), STATE(( 5 * W - 1) DOWNTO ( 4 * W)));

	C03 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK, 														  STATE_NEXT( 3 * W), 							     STATE(( 4 * W - 1) DOWNTO ( 3 * W)));
	C02 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK, 					           						  STATE_NEXT( 2 * W), 							     STATE(( 3 * W - 1) DOWNTO ( 2 * W)));
	C01 : ENTITY work.CellDO GENERIC MAP (SIZE => W) PORT MAP (CLK, 					            					  STATE_NEXT( 1 * W), 								  STATE(( 2 * W - 1) DOWNTO ( 1 * W)));
	C00 : ENTITY work.CellSD GENERIC MAP (SIZE => W) PORT MAP (CLK, ROUND_CTL(0),										  STATE_NEXT( 0 * W), SHIFTROWS(( 1 * W - 1)), STATE(( 1 * W - 1) DOWNTO ( 0 * W)));

	-- CONSTANT AND KEY ADDITION --------------------------------------------------
	KA : ENTITY work.AddConstKey GENERIC MAP (BS => BS, TS => TS) PORT MAP (ROUND_KEY, ROUND_CST, STATE(16 * W - 1), ADDITION);

	-- SHIFT ROWS -----------------------------------------------------------------
	SR : ENTITY work.ShiftRows GENERIC MAP (BS => BS) PORT MAP (STATE, SHIFTROWS);

	-- MIX COLUMNS ----------------------------------------------------------------
	MC : ENTITY work.MixColumns GENERIC MAP (BS => BS) PORT MAP (COLUMN, MIXCOLUMN);

   -- MULTIPLEXERS ---------------------------------------------------------------
   STATE_NEXT((16 * W - 1) DOWNTO (12 * W)) <= STATE((16 * W - 2) DOWNTO (12 * W - 1))			 WHEN (RESET = '1') ELSE STATE((16 * W - 2) DOWNTO (12 * W)) & MIXCOLUMN(3) WHEN (ROUND_CTL(1) = '1') ELSE STATE((16 * W - 2) DOWNTO (12 * W - 1));
   STATE_NEXT((12 * W - 1) DOWNTO ( 8 * W)) <= STATE((12 * W - 2) DOWNTO ( 8 * W - 1))			 WHEN (RESET = '1') ELSE STATE((12 * W - 2) DOWNTO ( 8 * W)) & MIXCOLUMN(2) WHEN (ROUND_CTL(1) = '1') ELSE STATE((12 * W - 2) DOWNTO ( 8 * W - 1));
   STATE_NEXT(( 8 * W - 1) DOWNTO ( 4 * W)) <= STATE(( 8 * W - 2) DOWNTO ( 4 * W - 1))			 WHEN (RESET = '1') ELSE STATE(( 8 * W - 2) DOWNTO ( 4 * W)) & MIXCOLUMN(1) WHEN (ROUND_CTL(1) = '1') ELSE STATE(( 8 * W - 2) DOWNTO ( 4 * W - 1));
   STATE_NEXT(( 4 * W - 1) DOWNTO ( 0 * W)) <= STATE(( 4 * W - 2) DOWNTO ( 0 * W)) & ROUND_IN WHEN (RESET = '1') ELSE STATE(( 4 * W - 2) DOWNTO ( 0 * W)) & MIXCOLUMN(0) WHEN (ROUND_CTL(1) = '1') ELSE STATE(( 4 * W - 2) DOWNTO ( 0 * W)) & ADDITION;

	-- ROUND OUTPUT ---------------------------------------------------------------
	ROUND_OUT <= STATE(16 * W - 1);

END Bit;
