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
ENTITY ShiftRows IS
	GENERIC (BS : BLOCK_SIZE);
	PORT ( X : IN	STD_LOGIC_VECTOR ((GET_BLOCK_SIZE(BS) - 1) DOWNTO 0);
          Y : OUT	STD_LOGIC_VECTOR ((GET_BLOCK_SIZE(BS) - 1) DOWNTO 0));
END ShiftRows;



-- ARCHITECTURE : PARALLEL
----------------------------------------------------------------------------------
ARCHITECTURE Parallel OF ShiftRows IS

	-- CONSTANT -------------------------------------------------------------------
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);

BEGIN

	-- ROW 1 ----------------------------------------------------------------------
	Y((16 * W - 1) DOWNTO (12 * W)) <= X((16 * W - 1) DOWNTO (12 * W));

	-- ROW 2 ----------------------------------------------------------------------
	Y((12 * W - 1) DOWNTO ( 8 * W)) <= X(( 9 * W - 1) DOWNTO ( 8 * W)) & X((12 * W - 1) DOWNTO ( 9 * W));

	-- ROW 3 ----------------------------------------------------------------------
	Y(( 8 * W - 1) DOWNTO ( 4 * W)) <= X(( 6 * W - 1) DOWNTO ( 4 * W)) & X(( 8 * W - 1) DOWNTO ( 6 * W));

	-- ROW 4 ----------------------------------------------------------------------
	Y(( 4 * W - 1) DOWNTO ( 0 * W)) <= X(( 3 * W - 1) DOWNTO ( 0 * W)) & X(( 4 * W - 1) DOWNTO ( 3 * W));

END Parallel;
