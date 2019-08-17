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
ENTITY Permutation is
	GENERIC (BS : BLOCK_SIZE);
	PORT ( X : IN  STD_LOGIC_VECTOR ((GET_BLOCK_SIZE(BS) - 1) DOWNTO 0);
          Y : OUT STD_LOGIC_VECTOR ((GET_BLOCK_SIZE(BS) - 1) DOWNTO 0));
END Permutation;



-- ARCHITECTURE : PARALLEL
----------------------------------------------------------------------------------
ARCHITECTURE Parallel OF Permutation IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);

BEGIN

	-- ROW 1 ----------------------------------------------------------------------
	Y((16 * W - 1) DOWNTO (15 * W)) <= X(( 7 * W - 1) DOWNTO ( 6 * W));
	Y((15 * W - 1) DOWNTO (14 * W)) <= X(( 1 * W - 1) DOWNTO ( 0 * W));
	Y((14 * W - 1) DOWNTO (13 * W)) <= X(( 8 * W - 1) DOWNTO ( 7 * W));
	Y((13 * W - 1) DOWNTO (12 * W)) <= X(( 3 * W - 1) DOWNTO ( 2 * W));

	-- ROW 2 ----------------------------------------------------------------------
	Y((12 * W - 1) DOWNTO (11 * W)) <= X(( 6 * W - 1) DOWNTO ( 5 * W));
	Y((11 * W - 1) DOWNTO (10 * W)) <= X(( 2 * W - 1) DOWNTO ( 1 * W));
	Y((10 * W - 1) DOWNTO ( 9 * W)) <= X(( 4 * W - 1) DOWNTO ( 3 * W));
	Y(( 9 * W - 1) DOWNTO ( 8 * W)) <= X(( 5 * W - 1) DOWNTO ( 4 * W));

	-- ROW 3 ----------------------------------------------------------------------
	Y(( 8 * W - 1) DOWNTO ( 7 * W)) <= X((16 * W - 1) DOWNTO (15 * W));
	Y(( 7 * W - 1) DOWNTO ( 6 * W)) <= X((15 * W - 1) DOWNTO (14 * W));
	Y(( 6 * W - 1) DOWNTO ( 5 * W)) <= X((14 * W - 1) DOWNTO (13 * W));
	Y(( 5 * W - 1) DOWNTO ( 4 * W)) <= X((13 * W - 1) DOWNTO (12 * W));

	-- ROW 4 ----------------------------------------------------------------------
	Y(( 4 * W - 1) DOWNTO ( 3 * W)) <= X((12 * W - 1) DOWNTO (11 * W));
	Y(( 3 * W - 1) DOWNTO ( 2 * W)) <= X((11 * W - 1) DOWNTO (10 * W));
	Y(( 2 * W - 1) DOWNTO ( 1 * W)) <= X((10 * W - 1) DOWNTO ( 9 * W));
	Y(( 1 * W - 1) DOWNTO ( 0 * W)) <= X(( 9 * W - 1) DOWNTO ( 8 * W));

END Parallel;
