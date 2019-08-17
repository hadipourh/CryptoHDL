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
ENTITY ControlLogic IS
	GENERIC ( BS : BLOCK_SIZE 		 := BLOCK_SIZE_64;
				 TS : TWEAK_SIZE 		 := TWEAK_SIZE_1N);
	PORT ( CLK		: IN	STD_LOGIC;
			 -- CONTROL PORTS --------------------------------
		  	 RESET		: IN  STD_LOGIC;
		    DONE			: OUT STD_LOGIC;
			 ROUND_CTL	: OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
			 KEY_CTL 	: OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
			 -- CONST PORT -----------------------------------
          ROUND_CST  : OUT STD_LOGIC);
END ControlLogic;



-- ARCHITECTURE : ROUND
----------------------------------------------------------------------------------
ARCHITECTURE Round OF ControlLogic IS

	-- CONSTANTS ------------------------------------------------------------------
	CONSTANT W : INTEGER := GET_WORD_SIZE(BS);

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL STATE, UPDATE : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL FINAL			: STD_LOGIC;
	SIGNAL COUNT_WD	: INTEGER RANGE 0 TO (W + 2);
	SIGNAL COUNT_OP	: INTEGER RANGE 0 TO 20;

BEGIN

	-- CONTROL LOGIC --------------------------------------------------------------
	PROCESS(CLK) BEGIN
		IF RISING_EDGE(CLK) THEN
			IF (RESET = '1' OR COUNT_WD = (W + 2) OR (COUNT_WD = (W - 1) AND COUNT_OP > 15)) THEN
				COUNT_WD <= 0;
			ELSE
				COUNT_WD <= COUNT_WD + 1;
			END IF;
		END IF;
	END PROCESS;

	PROCESS(CLK) BEGIN
		IF RISING_EDGE(CLK) THEN
			IF (RESET = '1' OR (COUNT_OP = 20 AND COUNT_WD = (W - 1))) THEN
				COUNT_OP <= 0;
			ELSIF ((COUNT_WD = (W + 2)) OR (COUNT_OP > 15 AND COUNT_WD = (W - 1))) THEN
				COUNT_OP <= COUNT_OP + 1;
			END IF;
		END IF;
	END PROCESS;

	ROUND_CTL(0) <= '1' WHEN (COUNT_OP < 16 AND COUNT_WD < 4 AND RESET = '0' AND FINAL = '0') ELSE '0';
	ROUND_CTL(1) <= '1' WHEN ((COUNT_OP < 16 AND COUNT_WD > 2) OR (COUNT_OP > 15) OR RESET = '1' OR FINAL = '1') ELSE '0';
	ROUND_CTL(2) <= '1' WHEN (COUNT_OP = 16 AND RESET = '0') ELSE '0';
	ROUND_CTL(3) <= '1' WHEN (COUNT_OP > 16) ELSE '0';

	KEY_CTL(0) <= '1' WHEN (COUNT_OP < 8 AND COUNT_WD = (W + 2) AND RESET = '0' AND FINAL = '0') ELSE '0';
	KEY_CTL(1) <= '1' WHEN (COUNT_OP = 8 AND COUNT_WD > 2) ELSE '0';
	KEY_CTL(2) <= '1' WHEN (COUNT_OP < 8 AND COUNT_WD > 2) ELSE '0';

	-- CONST: STATE ---------------------------------------------------------------
	REG : PROCESS(CLK) BEGIN
		IF RISING_EDGE(CLK) THEN
			IF (RESET = '1') THEN
				STATE <= (OTHERS => '0');
			ELSIF (COUNT_OP = 20 AND COUNT_WD = (W - 1)) THEN
				STATE <= UPDATE;
			END IF;
		END IF;
	END PROCESS;

	-- UPDATE FUNCTION ------------------------------------------------------------
	UPDATE <= STATE(4 DOWNTO 0) & (STATE(5) XNOR STATE(4));

	-- CONSTANT -------------------------------------------------------------------
	N64 : IF BS = BLOCK_SIZE_64 GENERATE
		ROUND_CST <= UPDATE(3) WHEN (COUNT_WD = 3 AND COUNT_OP = 0) ELSE
						 UPDATE(2) WHEN (COUNT_WD = 4 AND COUNT_OP = 0) ELSE
						 UPDATE(1) WHEN (COUNT_WD = 5 AND COUNT_OP = 0) ELSE
						 UPDATE(0) WHEN (COUNT_WD = 6 AND COUNT_OP = 0) ELSE
						 UPDATE(5) WHEN (COUNT_WD = 5 AND COUNT_OP = 4) ELSE
						 UPDATE(4) WHEN (COUNT_WD = 6 AND COUNT_OP = 4) ELSE
						 '1' 		  WHEN (COUNT_WD = 5 AND COUNT_OP = 8) ELSE '0';
	END GENERATE;

	N128 : IF BS = BLOCK_SIZE_128 GENERATE
		ROUND_CST <= UPDATE(3) WHEN (COUNT_WD =  7 AND COUNT_OP = 0) ELSE
						 UPDATE(2) WHEN (COUNT_WD =  8 AND COUNT_OP = 0) ELSE
						 UPDATE(1) WHEN (COUNT_WD =  9 AND COUNT_OP = 0) ELSE
						 UPDATE(0) WHEN (COUNT_WD = 10 AND COUNT_OP = 0) ELSE
						 UPDATE(5) WHEN (COUNT_WD =  9 AND COUNT_OP = 4) ELSE
						 UPDATE(4) WHEN (COUNT_WD = 10 AND COUNT_OP = 4) ELSE
						 '1' 		  WHEN (COUNT_WD =  9 AND COUNT_OP = 8) ELSE '0';
	END GENERATE;

	-- DONE SIGNAL ----------------------------------------------------------------
	CHK_64_1N  : IF BS = BLOCK_SIZE_64  AND TS = TWEAK_SIZE_1N GENERATE FINAL <= '1' WHEN (UPDATE = "110001" AND COUNT_OP < 16) ELSE '0'; END GENERATE;
	CHK_64_2N  : IF BS = BLOCK_SIZE_64  AND TS = TWEAK_SIZE_2N GENERATE FINAL <= '1' WHEN (UPDATE = "011011" AND COUNT_OP < 16) ELSE '0'; END GENERATE;
	CHK_64_3N  : IF BS = BLOCK_SIZE_64  AND TS = TWEAK_SIZE_3N GENERATE FINAL <= '1' WHEN (UPDATE = "110100" AND COUNT_OP < 16) ELSE '0'; END GENERATE;
	CHK_128_1N : IF BS = BLOCK_SIZE_128 AND TS = TWEAK_SIZE_1N GENERATE FINAL <= '1' WHEN (UPDATE = "110100" AND COUNT_OP < 16) ELSE '0'; END GENERATE;
	CHK_128_2N : IF BS = BLOCK_SIZE_128 AND TS = TWEAK_SIZE_2N GENERATE FINAL <= '1' WHEN (UPDATE = "001001" AND COUNT_OP < 16) ELSE '0'; END GENERATE;
	CHK_128_3N : IF BS = BLOCK_SIZE_128 AND TS = TWEAK_SIZE_3N GENERATE FINAL <= '1' WHEN (UPDATE = "010101" AND COUNT_OP < 16) ELSE '0'; END GENERATE;
	DONE <= FINAL;

END Round;
