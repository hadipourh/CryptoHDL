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
ENTITY TB_Skinny IS
	GENERIC (BS : BLOCK_SIZE := BLOCK_SIZE_64;
				TS : TWEAK_SIZE := TWEAK_SIZE_1N);
END TB_Skinny;



-- ARCHITECTURE : BEHAVIORAL
----------------------------------------------------------------------------------
ARCHITECTURE Behavioral OF TB_Skinny IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT N : INTEGER := GET_BLOCK_SIZE(BS);
	CONSTANT T : INTEGER := GET_TWEAK_SIZE(BS, TS);
	CONSTANT F : INTEGER := GET_TWEAK_FACT(TS);
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);
	-------------------------------------------------------------------------------

	-- TEST VECTORS ---------------------------------------------------------------
	SIGNAL TV_PT 	: STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
	SIGNAL TV_CT 	: STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
	SIGNAL TV_KT 	: STD_LOGIC_VECTOR((T - 1) DOWNTO 0);
	-------------------------------------------------------------------------------

	-- INPUTS ---------------------------------------------------------------------
   SIGNAL CLK 			: STD_LOGIC := '0';
   SIGNAL RESET 		: STD_LOGIC := '0';
   SIGNAL KEY 			: STD_LOGIC_VECTOR((T / 8) - 1 DOWNTO 0);
   SIGNAL PLAINTEXT 	: STD_LOGIC_VECTOR((N / 8) - 1 DOWNTO 0);
	-------------------------------------------------------------------------------

	-- OUTPUTS --------------------------------------------------------------------
   SIGNAL CT	      : STD_LOGIC_VECTOR((N - 1) DOWNTO 0);
	SIGNAL DONE			: STD_LOGIC;
   SIGNAL CIPHERTEXT : STD_LOGIC_VECTOR((N / 8) - 1 DOWNTO 0);
	-------------------------------------------------------------------------------

   -- CLOCK PERIOD DEFINITIONS ---------------------------------------------------
   CONSTANT CLK_PERIOD : TIME := 10 NS;
	-------------------------------------------------------------------------------

BEGIN

	-- INSTANTIATE UNIT UNDER TEST (UUT) ------------------------------------------
   UUT : ENTITY work.Skinny
	GENERIC MAP (BS => BS, TS => TS)
	PORT MAP (
		CLK 			=> CLK,
		RESET 		=> RESET,
		DONE			=> DONE,
		KEY 			=> KEY,
		PLAINTEXT 	=> PLAINTEXT,
		CIPHERTEXT	=> CIPHERTEXT
	);
	-------------------------------------------------------------------------------

   -- CLOCK PROCESS --------------------------------------------------------------
   CLK_PROCESS : PROCESS
	BEGIN
		CLK <= '0'; WAIT FOR CLK_PERIOD/2;
		CLK <= '1'; WAIT FOR CLK_PERIOD/2;
   END PROCESS;
	-------------------------------------------------------------------------------

   -- STIMULUS PROCESS -----------------------------------------------------------
   STIM_PROCESS : PROCESS
   BEGIN

		----------------------------------------------------------------------------
		IF BS = BLOCK_SIZE_64 THEN
			IF 	TS = TWEAK_SIZE_1N THEN
				TV_PT <= X"DC6A4944FF7DE341";
				TV_CT <= X"6DE8CEA4CAF93063";
				TV_KT	<= X"E8619935055EE7BF";
			ELSIF TS = TWEAK_SIZE_2N THEN
				TV_PT <= X"046BE0BAECC1F283";
				TV_CT <= X"90EA84689DB6E2C8";
				TV_KT	<= X"D57AAFD67AF4483428D61A94C501D2FE";
			ELSE
				TV_PT <= X"417FC42CBF51A9A7";
				TV_CT <= X"245BBAB49997B3E3";
				TV_KT	<= X"08890F904144EC10BC1EBCC379A526C6ED0EDC120327C308";
			END IF;
		ELSE
			IF 	TS = TWEAK_SIZE_1N THEN
				TV_PT <= X"7F9511997A1A64342BBE8DBAD5506E97";
				TV_CT <= X"E77E5D9A1FFF3C7F9D8752EBA9882F24";
				TV_KT	<= X"01BD8C480B87B76EE172EE2108817D86";
			ELSIF TS = TWEAK_SIZE_2N THEN
				TV_PT <= X"25B580E1E413D1E918D89F691B85B410";
				TV_CT <= X"149F87CB921884E0F5B53D928091458F";
				TV_KT	<= X"B25BA13C92CB6011232F37C983B7DF4ACEA6E6FE9DBE52DFCCF887D181796B35";
			ELSE
				TV_PT <= X"A42757D2ACE7CE858BA9B1A3215A899D";
				TV_CT <= X"48CB7AEC1888C54A94426EDDB7AFF97B";
				TV_KT	<= X"EA135685849431216BEE303E087F8A46EA23FB1553A96A09F684CA58FFC33EA7544480D81A2483237C795768A7444EC3";
			END IF;
		END IF;
		----------------------------------------------------------------------------

		WAIT FOR CLK_PERIOD;

		----------------------------------------------------------------------------
		RESET <= '1';
			FOR I IN 0 TO 7 LOOP
				PLAINTEXT((1 * W - 1) DOWNTO (0 * W)) <= TV_PT((N - (I + 8) * W - 1) DOWNTO (N - (I + 9) * W));
				PLAINTEXT((2 * W - 1) DOWNTO (1 * W)) <= TV_PT((N - (I + 0) * W - 1) DOWNTO (N - (I + 1) * W));

				FOR J IN 0 TO (F - 1) LOOP
					KEY(((2 * J + 1) * W - 1) DOWNTO ((2 * J + 0) * W)) <= TV_KT((T - J * N - (I + 8) * W - 1) DOWNTO (T - J * N - (I + 9) * W));
					KEY(((2 * J + 2) * W - 1) DOWNTO ((2 * J + 1) * W)) <= TV_KT((T - J * N - (I + 0) * W - 1) DOWNTO (T - J * N - (I + 1) * W));
				END LOOP;

				WAIT FOR CLK_PERIOD;
			END LOOP;
		RESET <= '0';
		---------------------------------------------------------------------------

     	WAIT UNTIL DONE = '1';

		---------------------------------------------------------------------------
	   WAIT FOR CLK_PERIOD/2;

      FOR I IN 0 TO 7 LOOP
          CT((N - (I + 8) * W - 1) DOWNTO (N - (I + 9) * W)) <= CIPHERTEXT((1 * W - 1) DOWNTO (0 * W));
          CT((N - (I + 0) * W - 1) DOWNTO (N - (I + 1) * W)) <= CIPHERTEXT((2 * W - 1) DOWNTO (1 * W));
          WAIT FOR CLK_PERIOD;
     	END LOOP;

		WAIT FOR CLK_PERIOD/2;
		---------------------------------------------------------------------------

  	 	---------------------------------------------------------------------------
     	IF (CT = TV_CT) THEN
   		ASSERT FALSE REPORT "---------- PASSED ----------" SEVERITY FAILURE;
     	ELSE
         ASSERT FALSE REPORT "---------- FAILED ----------" SEVERITY FAILURE;
    	END IF;
		---------------------------------------------------------------------------

   END PROCESS;
	-------------------------------------------------------------------------------
END;
