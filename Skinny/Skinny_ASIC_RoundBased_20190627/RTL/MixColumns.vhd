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
ENTITY MixColumns is
	GENERIC (BS : BLOCK_SIZE);
	PORT ( X : IN	STD_LOGIC_VECTOR ((GET_BLOCK_SIZE(BS) - 1) DOWNTO 0);
          Y : OUT	STD_LOGIC_VECTOR ((GET_BLOCK_SIZE(BS) - 1) DOWNTO 0));
END MixColumns;



-- ARCHITECTURE : DATAFLOW
----------------------------------------------------------------------------------
ARCHITECTURE Parallel of MixColumns is

	-- CONSTANT -------------------------------------------------------------------
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL C1_X2X0, C2_X2X0, C3_X2X0, C4_X2X0	: STD_LOGIC_VECTOR((W - 1) DOWNTO 0);
	SIGNAL C1_X2X1, C2_X2X1, C3_X2X1, C4_X2X1	: STD_LOGIC_VECTOR((W - 1) DOWNTO 0);

BEGIN

	-- X2 XOR X1 ------------------------------------------------------------------
	C1_X2X1 <= X((12 * W - 1) DOWNTO (11 * W)) XOR X(( 8 * W - 1) DOWNTO ( 7 * W));
	C2_X2X1 <= X((11 * W - 1) DOWNTO (10 * W)) XOR X(( 7 * W - 1) DOWNTO ( 6 * W));
	C3_X2X1 <= X((10 * W - 1) DOWNTO ( 9 * W)) XOR X(( 6 * W - 1) DOWNTO ( 5 * W));
	C4_X2X1 <= X(( 9 * W - 1) DOWNTO ( 8 * W)) XOR X(( 5 * W - 1) DOWNTO ( 4 * W));
	-------------------------------------------------------------------------------

	-- X2 XOR X0 ------------------------------------------------------------------
	C1_X2X0 <= X((16 * W - 1) DOWNTO (15 * W)) XOR X(( 8 * W - 1) DOWNTO ( 7 * W));
	C2_X2X0 <= X((15 * W - 1) DOWNTO (14 * W)) XOR X(( 7 * W - 1) DOWNTO ( 6 * W));
	C3_X2X0 <= X((14 * W - 1) DOWNTO (13 * W)) XOR X(( 6 * W - 1) DOWNTO ( 5 * W));
	C4_X2X0 <= X((13 * W - 1) DOWNTO (12 * W)) XOR X(( 5 * W - 1) DOWNTO ( 4 * W));
	-------------------------------------------------------------------------------

	-- COLUMN 1 -------------------------------------------------------------------
	Y((16 * W - 1) DOWNTO (15 * W)) <= C1_X2X0 XOR X(( 4 * W - 1) DOWNTO ( 3 * W));
	Y((12 * W - 1) DOWNTO (11 * W)) <= X((16 * W - 1) DOWNTO (15 * W));
	Y(( 8 * W - 1) DOWNTO ( 7 * W)) <= C1_X2X1;
	Y(( 4 * W - 1) DOWNTO ( 3 * W)) <= C1_X2X0;
	-------------------------------------------------------------------------------

	-- COLUMN 2 -------------------------------------------------------------------
	Y((15 * W - 1) DOWNTO (14 * W)) <= C2_X2X0 XOR X(( 3 * W - 1) DOWNTO ( 2 * W));
	Y((11 * W - 1) DOWNTO (10 * W)) <= X((15 * W - 1) DOWNTO (14 * W));
	Y(( 7 * W - 1) DOWNTO ( 6 * W)) <= C2_X2X1;
	Y(( 3 * W - 1) DOWNTO ( 2 * W)) <= C2_X2X0;
	-------------------------------------------------------------------------------

	-- COLUMN 3 -------------------------------------------------------------------
	Y((14 * W - 1) DOWNTO (13 * W)) <= C3_X2X0 XOR X(( 2 * W - 1) DOWNTO ( 1 * W));
	Y((10 * W - 1) DOWNTO ( 9 * W)) <= X((14 * W - 1) DOWNTO (13 * W));
	Y(( 6 * W - 1) DOWNTO ( 5 * W)) <= C3_X2X1;
	Y(( 2 * W - 1) DOWNTO ( 1 * W)) <= C3_X2X0;
	-------------------------------------------------------------------------------

	-- COLUMN 4 -------------------------------------------------------------------
	Y((13 * W - 1) DOWNTO (12 * W)) <= C4_X2X0 XOR X(( 1 * W - 1) DOWNTO ( 0 * W));
	Y(( 9 * W - 1) DOWNTO ( 8 * W)) <= X((13 * W - 1) DOWNTO (12 * W));
	Y(( 5 * W - 1) DOWNTO ( 4 * W)) <= C4_X2X1;
	Y(( 1 * W - 1) DOWNTO ( 0 * W)) <= C4_X2X0;
	-------------------------------------------------------------------------------

END Parallel;
