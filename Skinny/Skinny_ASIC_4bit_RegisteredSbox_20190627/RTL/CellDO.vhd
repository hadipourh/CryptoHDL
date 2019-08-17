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
ENTITY CellDO IS
	GENERIC (SIZE : INTEGER);
   PORT ( CLK	: IN 	STD_LOGIC;
          D  	: IN 	STD_LOGIC;
          Q 	: OUT STD_LOGIC_VECTOR((SIZE - 1) DOWNTO 0));
END CellDO;



-- ARCHITECTURE : STRUCTURAL
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF CellDO IS

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL STATE : STD_LOGIC_VECTOR(SIZE DOWNTO 0);

BEGIN

	STATE(0) <= D;

   DFF : ENTITY work.DataFF GENERIC MAP (SIZE => SIZE) PORT MAP (CLK, STATE((SIZE - 1) DOWNTO 0), STATE(SIZE DOWNTO 1));

	Q <= STATE(SIZE DOWNTO 1);

END Structural;
