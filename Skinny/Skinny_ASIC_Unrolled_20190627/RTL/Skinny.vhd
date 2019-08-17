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
   	    -- KEY PORT -------------------------------------
          KEY        : IN  STD_LOGIC_VECTOR ((GET_TWEAK_SIZE(BS, TS) - 1) DOWNTO 0);
   	    -- DATA PORTS -----------------------------------
          PLAINTEXT  : IN  STD_LOGIC_VECTOR ((GET_BLOCK_SIZE(BS) 	   - 1) DOWNTO 0);
          CIPHERTEXT : OUT STD_LOGIC_VECTOR ((GET_BLOCK_SIZE(BS) 	   - 1) DOWNTO 0));
END Skinny;



-- ARCHITECTURE : UNROLLED
----------------------------------------------------------------------------------
ARCHITECTURE Structural OF Skinny IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT N : INTEGER := GET_BLOCK_SIZE(BS);
	CONSTANT T : INTEGER := GET_TWEAK_SIZE(BS, TS);
	CONSTANT R : INTEGER := GET_NUMBER_OF_ROUNDS(BS, TS);

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL ROUND_TMP : STD_LOGIC_VECTOR(((R + 1) * N) - 1 DOWNTO 0);
	SIGNAL ROUND_KEY : STD_LOGIC_VECTOR(((R + 1) * T) - 1 DOWNTO 0);
	SIGNAL ROUND_CST : STD_LOGIC_VECTOR(              371 DOWNTO 0);

BEGIN

   -- INPUT ASSIGNMENT -----------------------------------------------------------
   ROUND_TMP((N - 1) DOWNTO 0) <= PLAINTEXT;
   ROUND_KEY((T - 1) DOWNTO 0) <= KEY;
   -------------------------------------------------------------------------------

	-- GENERATE -------------------------------------------------------------------
	GEN : FOR I IN 0 TO (R - 1) GENERATE

	   -- ROUND FUNCTION ----------------------------------------------------------
      RF : ENTITY work.RoundFunction GENERIC MAP (BS => BS, TS => TS) PORT MAP (
         CLK			=> CLK,
         ROUND_CST	=> ROUND_CST(((I + 1) * 6) - 1 DOWNTO ((I + 0) * 6)),
         ROUND_KEY	=> ROUND_KEY(((I + 1) * T) - 1 DOWNTO ((I + 0) * T)),
         ROUND_IN		=> ROUND_TMP(((I + 1) * N) - 1 DOWNTO ((I + 0) * N)),
         ROUND_OUT	=> ROUND_TMP(((I + 2) * N) - 1 DOWNTO ((I + 1) * N))
      );
	   ----------------------------------------------------------------------------

      -- KEY EXPANSION -----------------------------------------------------------
      KE : ENTITY work.KeyExpansion  GENERIC MAP (BS => BS, TS => TS) PORT MAP (
			CLK			=> CLK,
			KEY			=> ROUND_KEY(((I + 1) * T) - 1 DOWNTO ((I + 0) * T)),
			ROUND_KEY	=> ROUND_KEY(((I + 2) * T) - 1 DOWNTO ((I + 1) * T))
      );
	   ----------------------------------------------------------------------------

   END GENERATE;
	-------------------------------------------------------------------------------

   -- CONTROL LOGIC --------------------------------------------------------------
   CL : ENTITY work.ControlLogic PORT MAP (CLK, ROUND_CST);
	-------------------------------------------------------------------------------

   -- OUTPUT ASSIGNMENT ----------------------------------------------------------
   CIPHERTEXT <= ROUND_TMP(((R + 1) * N) - 1 DOWNTO (R * N));
   -------------------------------------------------------------------------------

END Structural;
