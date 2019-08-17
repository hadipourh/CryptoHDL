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
ENTITY Skinny IS
	GENERIC ( BS : BLOCK_SIZE 		 := BLOCK_SIZE_64;
				 TS : TWEAK_SIZE 		 := TWEAK_SIZE_1N);
   PORT ( CLK        : IN  STD_LOGIC;
   		 -- CONTROL PORTS --------------------------------
          RESET      : IN  STD_LOGIC;
          DONE       : OUT STD_LOGIC;
   	    -- KEY PORT -------------------------------------
          KEY        : IN  STD_LOGIC_VECTOR (((GET_TWEAK_SIZE(BS, TS) / 4) - 1) DOWNTO 0);
   	    -- DATA PORTS -----------------------------------
          PLAINTEXT  : IN  STD_LOGIC_VECTOR (((GET_BLOCK_SIZE(BS) 	 / 4) - 1) DOWNTO 0);
          CIPHERTEXT : OUT STD_LOGIC_VECTOR (((GET_BLOCK_SIZE(BS) 	 / 4) - 1) DOWNTO 0));
END Skinny;



-- ARCHITECTURE : Structural
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF Skinny IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT N : INTEGER := GET_BLOCK_SIZE(BS);
	CONSTANT T : INTEGER := GET_TWEAK_SIZE(BS, TS);
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);

	-- SIGNALS --------------------------------------------------------------------
   SIGNAL ROUND_CTL : STD_LOGIC_VECTOR(0 DOWNTO 0);
   SIGNAL KEY_CTL   : STD_LOGIC_VECTOR(0 DOWNTO 0);

	SIGNAL ROUND_KEY : STD_LOGIC_VECTOR(((T / 4) - 1) DOWNTO 0);
	SIGNAL ROUND_CST : STD_LOGIC_VECTOR(((N / 4) - 1) DOWNTO 0);

BEGIN

	-- ROUND FUNCTION -------------------------------------------------------------
	RF : ENTITY work.RoundFunction GENERIC MAP (BS => BS, TS => TS) PORT MAP (CLK, RESET, ROUND_CTL, ROUND_CST, ROUND_KEY, PLAINTEXT, CIPHERTEXT);
	-------------------------------------------------------------------------------

   -- KEY EXPANSION --------------------------------------------------------------
   KE : ENTITY work.KeyExpansion  GENERIC MAP (BS => BS, TS => TS) PORT MAP (CLK, RESET, KEY_CTL, KEY, ROUND_KEY);
	-------------------------------------------------------------------------------

   -- CONTROL LOGIC --------------------------------------------------------------
   CL : ENTITY work.ControlLogic GENERIC MAP (BS => BS, TS => TS) PORT MAP (CLK, RESET, DONE, ROUND_CTL, KEY_CTL, ROUND_CST);
	-------------------------------------------------------------------------------

END Structural;
