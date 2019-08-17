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
	PORT ( X : IN  STD_LOGIC_VECTOR (((GET_BLOCK_SIZE(BS) / 2) - 1) DOWNTO 0);
          Y : OUT STD_LOGIC_VECTOR (((GET_BLOCK_SIZE(BS) / 2) - 1) DOWNTO 0));
END Permutation;



-- ARCHITECTURE : HALF
----------------------------------------------------------------------------------
ARCHITECTURE Half OF Permutation IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);

BEGIN

	Y((8 * W - 1) DOWNTO (7 * W)) <= X(( 7 * W - 1) DOWNTO ( 6 * W));
	Y((7 * W - 1) DOWNTO (6 * W)) <= X(( 1 * W - 1) DOWNTO ( 0 * W));
	Y((6 * W - 1) DOWNTO (5 * W)) <= X(( 8 * W - 1) DOWNTO ( 7 * W));
	Y((5 * W - 1) DOWNTO (4 * W)) <= X(( 3 * W - 1) DOWNTO ( 2 * W));
	Y((4 * W - 1) DOWNTO (3 * W)) <= X(( 6 * W - 1) DOWNTO ( 5 * W));
	Y((3 * W - 1) DOWNTO (2 * W)) <= X(( 2 * W - 1) DOWNTO ( 1 * W));
	Y((2 * W - 1) DOWNTO (1 * W)) <= X(( 4 * W - 1) DOWNTO ( 3 * W));
	Y((1 * W - 1) DOWNTO (0 * W)) <= X(( 5 * W - 1) DOWNTO ( 4 * W));

END Half;
