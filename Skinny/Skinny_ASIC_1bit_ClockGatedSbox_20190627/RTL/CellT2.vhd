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
ENTITY CellT2 IS
	GENERIC (BS : BLOCK_SIZE);
   PORT ( CLK	: IN 	STD_LOGIC;
          SE 	: IN 	STD_LOGIC;
			 SR	: IN 	STD_LOGIC;
          D  	: IN 	STD_LOGIC;
          DS	: IN 	STD_LOGIC;
          Q 	: OUT STD_LOGIC_VECTOR((GET_WORD_SIZE(BS) - 1) DOWNTO 0));
END CellT2;



-- ARCHITECTURE : STRUCTURAL
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF CellT2 IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL LFSR  : STD_LOGIC_VECTOR((W - 1) DOWNTO 0);
	SIGNAL STATE : STD_LOGIC_VECTOR( 	 W  DOWNTO 0);

BEGIN

	-- SIGNAL ASSIGNMENTS ---------------------------------------------------------
	Q <= STATE(W DOWNTO 1);

	-- MULTIPLEXERS ---------------------------------------------------------------
	STATE(0) <= DS WHEN (SE = '1') ELSE D;

	-- LFSR -----------------------------------------------------------------------
	LFSR <= STATE((W - 2) DOWNTO 0) & (STATE(W - 1) XOR STATE(W - (W / 8) - 2));

	-- REGISTER STAGE -------------------------------------------------------------
   SFF : ENTITY work.ScanFF GENERIC MAP (SIZE => W) PORT MAP (CLK, SR, STATE((W - 1) DOWNTO 0), LFSR((W - 1) DOWNTO 0), STATE(W DOWNTO 1));


END Structural;
