----------------------------------------------------------------------------------
-- Copyright 2016:
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



PACKAGE SKINNYPKG IS

	-- DEFINE BLOCKSIZE -----------------------------------------------------------
	TYPE BLOCK_SIZE IS (BLOCK_SIZE_64, BLOCK_SIZE_128);
	-------------------------------------------------------------------------------

	-- DEFINE TWEAKSIZE -----------------------------------------------------------
	TYPE TWEAK_SIZE IS (TWEAK_SIZE_1N, TWEAK_SIZE_2N, TWEAK_SIZE_3N);
	-------------------------------------------------------------------------------

	--DEFINE FUNCTIONS ------------------------------------------------------------
	FUNCTION GET_WORD_SIZE  (BS : BLOCK_SIZE) RETURN INTEGER;
	FUNCTION GET_BLOCK_SIZE (BS : BLOCK_SIZE) RETURN INTEGER;
	FUNCTION GET_TWEAK_FACT (TS : TWEAK_SIZE) RETURN INTEGER;
	FUNCTION GET_TWEAK_SIZE (BS : BLOCK_SIZE; TS : TWEAK_SIZE) RETURN INTEGER;
	FUNCTION GET_NUMBER_OF_ROUNDS (BS : BLOCK_SIZE; TS : TWEAK_SIZE) RETURN INTEGER;
	-------------------------------------------------------------------------------

END SKINNYPKG;

PACKAGE BODY SKINNYPKG IS

	-- FUNCTION: RETURN WORD SIZE -------------------------------------------------
	FUNCTION GET_WORD_SIZE (BS : BLOCK_SIZE) RETURN INTEGER IS
	BEGIN
			IF BS = BLOCK_SIZE_64 THEN
				RETURN 4;
			ELSE
				RETURN 8;
			END IF;
	END GET_WORD_SIZE;
	-------------------------------------------------------------------------------

	-- FUNCTION: RETURN BLOCK SIZE ------------------------------------------------
	FUNCTION GET_BLOCK_SIZE (BS : BLOCK_SIZE) RETURN INTEGER IS
	BEGIN
			IF BS = BLOCK_SIZE_64 THEN
				RETURN 64;
			ELSE
				RETURN 128;
			END IF;
	END GET_BLOCK_SIZE;
	-------------------------------------------------------------------------------

	-- FUNCTION: RETURN TWEAK FACTOR ----------------------------------------------
	FUNCTION GET_TWEAK_FACT (TS : TWEAK_SIZE) RETURN INTEGER IS
	BEGIN
			IF    TS = TWEAK_SIZE_1N THEN
				RETURN 1;
			ELSIF TS = TWEAK_SIZE_2N THEN
				RETURN 2;
			ELSE
				RETURN 3;
			END IF;
	END GET_TWEAK_FACT;
	-------------------------------------------------------------------------------

	-- FUNCTION: RETURN TWEAK SIZE ------------------------------------------------
	FUNCTION GET_TWEAK_SIZE (BS : BLOCK_SIZE; TS : TWEAK_SIZE) RETURN INTEGER IS
	BEGIN
			RETURN GET_BLOCK_SIZE(BS) * GET_TWEAK_FACT(TS);
	END GET_TWEAK_SIZE;
	-------------------------------------------------------------------------------

	-- FUNCTION: RETURN NUMBER OF ROUNDS ------------------------------------------
	FUNCTION GET_NUMBER_OF_ROUNDS (BS : BLOCK_SIZE; TS : TWEAK_SIZE) RETURN INTEGER IS
	BEGIN
			RETURN (28 + (GET_BLOCK_SIZE(BS) / 16) * GET_TWEAK_FACT(TS)) + 4 * (GET_BLOCK_SIZE(BS) / 128);
	END GET_NUMBER_OF_ROUNDS;
	-------------------------------------------------------------------------------

END SKINNYPKG;
