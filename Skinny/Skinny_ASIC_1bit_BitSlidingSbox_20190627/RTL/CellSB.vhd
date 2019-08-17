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
			 SB	: IN 	STD_LOGIC;
          D  	: IN 	STD_LOGIC;
          DS	: IN 	STD_LOGIC;
          Q 	: OUT STD_LOGIC_VECTOR((GET_WORD_SIZE(BS) - 1) DOWNTO 0));
END CellSB;



-- ARCHITECTURE : STRUCTURAL
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF CellSB IS

	-- COMPONENTS -----------------------------------------------------------------
	COMPONENT dflipfloplw IS
	PORT ( CLK  : IN  STD_LOGIC;
			 SEL	: IN  STD_LOGIC;
			 D0   : IN  STD_LOGIC;
			 D1   : IN  STD_LOGIC;
			 Q    : OUT STD_LOGIC);
	END COMPONENT;

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL STATE, SBOX_IN, SBOX_OUT : STD_LOGIC_VECTOR((W - 1) DOWNTO 0);

BEGIN

	-- SIGNAL ASSIGNMENTS ---------------------------------------------------------
	SBOX_IN 	<= STATE((W - 1) DOWNTO 0);
	Q((W - 2) DOWNTO 0) <= STATE((W - 2) DOWNTO 0);

 	-- MULTIPLEXERS ---------------------------------------------------------------
	Q(W - 1) <= SBOX_OUT(W - 1) WHEN (SB = '1') ELSE STATE(W - 1);

	-- SUBSTITUTION ---------------------------------------------------------------
	S : ENTITY work.SBox GENERIC MAP (BS => BS) PORT MAP (SBOX_IN, SBOX_OUT);

	-- REGISTER STAGE -------------------------------------------------------------
   SF0 : dflipfloplw PORT MAP (CLK, SE, D, DS, STATE(0));
   SFF : ENTITY work.ScanFF GENERIC MAP (SIZE => (W - 1)) PORT MAP (CLK, SB, STATE((W - 2) DOWNTO 0), SBOX_OUT((W - 2) DOWNTO 0), STATE((W - 1) DOWNTO 1));


END Structural;
