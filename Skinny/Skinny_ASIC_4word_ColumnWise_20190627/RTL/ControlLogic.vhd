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
			 ROUND_CTL	: OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
			 KEY_CTL 	: OUT STD_LOGIC_VECTOR(0 DOWNTO 0);
			 -- CONST PORT -----------------------------------
          ROUND_CST  : OUT STD_LOGIC_VECTOR(((GET_BLOCK_SIZE(BS) 	   / 4) - 1) DOWNTO 0));
END ControlLogic;



-- ARCHITECTURE : ROUND
----------------------------------------------------------------------------------
ARCHITECTURE Round OF ControlLogic IS

	-- SIGNALS --------------------------------------------------------------------
	SIGNAL STATE, UPDATE : STD_LOGIC_VECTOR(5 DOWNTO 0);
	SIGNAL CONTROL			: STD_LOGIC_VECTOR(4 DOWNTO 0);

BEGIN

	-- CONTROL LOGIC --------------------------------------------------------------
	PROCESS(CLK) BEGIN
		IF RISING_EDGE(CLK) THEN
			IF (RESET = '1') THEN
				CONTROL <= "00001";
			ELSE
				CONTROL <= CONTROL(3 DOWNTO 0) & CONTROL(4);
			END IF;
		END IF;
	END PROCESS;

	KEY_CTL(0) 	 <= CONTROL(0) AND NOT(RESET);
	ROUND_CTL(0) <= CONTROL(0) AND NOT(RESET);

	-- CONST: STATE ---------------------------------------------------------------
	REG : PROCESS(CLK) BEGIN
		IF RISING_EDGE(CLK) THEN
			IF (RESET = '1') THEN
				STATE <= (OTHERS => '0');
			ELSIF (CONTROL(4) = '1') THEN
				STATE <= UPDATE;
			END IF;
		END IF;
	END PROCESS;

	-- UPDATE FUNCTION ------------------------------------------------------------
	UPDATE <= STATE(4 DOWNTO 0) & (STATE(5) XNOR STATE(4));

	-- CONSTANT -------------------------------------------------------------------
	N64 : IF BS = BLOCK_SIZE_64 GENERATE
		ROUND_CST <= UPDATE(3 DOWNTO 0) & X"000" WHEN (CONTROL = "00010") ELSE X"0" & "00" & UPDATE(5 DOWNTO 4) & X"00"  WHEN (CONTROL = "00100") ELSE X"0020"  WHEN (CONTROL = "01000") ELSE (OTHERS => '0');
	END GENERATE;

	N128 : IF BS = BLOCK_SIZE_128 GENERATE
		ROUND_CST <= X"0" & UPDATE(3 DOWNTO 0) & X"000000" WHEN (CONTROL = "00010") ELSE X"000" & "00" & UPDATE(5 DOWNTO 4) & X"0000"  WHEN (CONTROL = "00100") ELSE X"00000200"  WHEN (CONTROL = "01000") ELSE (OTHERS => '0');
	END GENERATE;

	-- DONE SIGNAL ----------------------------------------------------------------
	CHK_64_1N  : IF BS = BLOCK_SIZE_64  AND TS = TWEAK_SIZE_1N GENERATE DONE <= '1' WHEN (UPDATE = "111000" AND CONTROL(0) = '0') ELSE '0'; END GENERATE;
	CHK_64_2N  : IF BS = BLOCK_SIZE_64  AND TS = TWEAK_SIZE_2N GENERATE DONE <= '1' WHEN (UPDATE = "001101" AND CONTROL(0) = '0') ELSE '0'; END GENERATE;
	CHK_64_3N  : IF BS = BLOCK_SIZE_64  AND TS = TWEAK_SIZE_3N GENERATE DONE <= '1' WHEN (UPDATE = "011010" AND CONTROL(0) = '0') ELSE '0'; END GENERATE;
	CHK_128_1N : IF BS = BLOCK_SIZE_128 AND TS = TWEAK_SIZE_1N GENERATE DONE <= '1' WHEN (UPDATE = "011010" AND CONTROL(0) = '0') ELSE '0'; END GENERATE;
	CHK_128_2N : IF BS = BLOCK_SIZE_128 AND TS = TWEAK_SIZE_2N GENERATE DONE <= '1' WHEN (UPDATE = "000100" AND CONTROL(0) = '0') ELSE '0'; END GENERATE;
	CHK_128_3N : IF BS = BLOCK_SIZE_128 AND TS = TWEAK_SIZE_3N GENERATE DONE <= '1' WHEN (UPDATE = "001010" AND CONTROL(0) = '0') ELSE '0'; END GENERATE;

END Round;
