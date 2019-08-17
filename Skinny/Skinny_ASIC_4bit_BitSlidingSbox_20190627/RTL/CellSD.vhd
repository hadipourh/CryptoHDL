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



-- ENTITY
----------------------------------------------------------------------------------
ENTITY CellSD IS
	GENERIC (SIZE : INTEGER);
   PORT ( CLK	: IN 	STD_LOGIC;
          SE 	: IN 	STD_LOGIC;
          D  	: IN 	STD_LOGIC;
          DS	: IN 	STD_LOGIC;
          Q 	: OUT STD_LOGIC_VECTOR((SIZE - 1) DOWNTO 0));
END CellSD;



-- ARCHITECTURE : STRUCTURAL
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF CellSD IS

	-- COMPONENTS -----------------------------------------------------------------
	COMPONENT dflipfloplw IS
	PORT ( CLK  : IN  STD_LOGIC;
			 SEL	: IN  STD_LOGIC;
			 D0   : IN  STD_LOGIC;
			 D1   : IN  STD_LOGIC;
			 Q    : OUT STD_LOGIC);
	END COMPONENT;

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL STATE : STD_LOGIC_VECTOR((SIZE - 1) DOWNTO 0);

BEGIN

   SFF : dflipfloplw PORT MAP (CLK, SE, D, DS, STATE(0));

   DFF : ENTITY work.DataFF GENERIC MAP (SIZE => (SIZE - 1)) PORT MAP (CLK, STATE((SIZE - 2) DOWNTO 0), STATE((SIZE - 1) DOWNTO 1));

	Q <= STATE;

END Structural;
