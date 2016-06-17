CREATE TABLE sequence (
  name           VARCHAR(50) NOT NULL,
  initial_value  INT UNSIGNED NOT NULL DEFAULT 1,
  current_value    INT UNSIGNED NOT NULL DEFAULT 0,
  step_size      INT UNSIGNED NOT NULL DEFAULT 1,
  max_value      INT UNSIGNED NOT NULL DEFAULT 4294967295,
  cycle          TINYINT NOT NULL DEFAULT 0,
  PRIMARY KEY (name)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- call sequence_create_full('sequence_name', initial_value, current_value, step_size, max_value, cycle);
--

DROP PROCEDURE IF EXISTS sequence_create_full;
DELIMITER $
CREATE PROCEDURE sequence_create_full (IN seq_name VARCHAR(50), 
                                  IN sequence_initial_value INT UNSIGNED, 
                                  IN sequence_current_value INT UNSIGNED, 
                                  IN sequence_step_size INT UNSIGNED, 
                                  IN sequence_max_value INT UNSIGNED, 
                                  IN sequence_cycle TINYINT)
  DETERMINISTIC
  CONTAINS SQL
  BEGIN
    SET @sequence_initial_value := IFNULL(sequence_initial_value, 1);
    SET @sequence_current_value := IFNULL(sequence_current_value, 0);
    SET @sequence_step_size := IFNULL(sequence_step_size, 1);
    SET @sequence_max_value := IFNULL(sequence_max_value, 4294967295);
    SET @sequence_cycle := IF(ISNULL(sequence_cycle) OR sequence_cycle = 0, 0, 1);
    INSERT INTO sequence (name, initial_value, current_value, step_size, max_value, cycle) 
    VALUES (seq_name, @sequence_initial_value, @sequence_current_value, @sequence_step_size, @sequence_max_value, @sequence_cycle);
  END$
DELIMITER ;
  
--
-- call sequence_create('sequence_name'); 
--

DROP PROCEDURE IF EXISTS sequence_create;
DELIMITER $
CREATE PROCEDURE sequence_create (IN seq_name VARCHAR(50))
  DETERMINISTIC
  CONTAINS SQL
  BEGIN
    CALL sequence_create_full(seq_name, NULL, NULL, NULL, NULL, NULL);
  END$
DELIMITER ;

--
-- select sequence_getall('sequence_name');
--

DROP PROCEDURE IF EXISTS sequence_getall;
DELIMITER $
CREATE PROCEDURE sequence_getall (seq_name VARCHAR(50))
  DETERMINISTIC
  CONTAINS SQL
  BEGIN
    SELECT initial_value, current_value, step_size, max_value, cycle 
      INTO @sequence_initial_value, @sequence_current_value, @sequence_step_size, @sequence_max_value, @sequence_cycle
      FROM sequence WHERE name = seq_name;
  END$
DELIMITER ;

--
-- call sequence_drop('sequence_name');
--

DROP PROCEDURE IF EXISTS sequence_drop;
DELIMITER $
CREATE PROCEDURE sequence_drop (seq_name VARCHAR(50))
  DETERMINISTIC
  CONTAINS SQL
  BEGIN
    DELETE FROM sequence where name = seq_name;
    SET @sequence_initial_value := NULL;
    SET @sequence_current_value := NULL;
    SET @sequence_step_size := NULL;
    SET @sequence_max_value := NULL;
    SET @sequence_cycle := NULL;
  END$
DELIMITER ;
  
--
-- select sequence_setinc('sequence_name', new_step_size);
--

DROP FUNCTION IF EXISTS sequence_setinc;
DELIMITER $
CREATE FUNCTION sequence_setinc (seq_name VARCHAR(50), new_step_size INT UNSIGNED)
  RETURNS INT UNSIGNED
  DETERMINISTIC
  CONTAINS SQL
  BEGIN
    UPDATE sequence SET step_size = (@sequence_step_size := new_step_size) WHERE name = seq_name;
    RETURN @sequence_step_size;
  END$
DELIMITER ;

--
-- select sequence_getinc('sequence_name');
--

DROP FUNCTION IF EXISTS sequence_getinc;
DELIMITER $
CREATE FUNCTION sequence_getinc (seq_name VARCHAR(50))
  RETURNS INT UNSIGNED
  DETERMINISTIC
  CONTAINS SQL
  BEGIN
    SELECT step_size INTO @sequence_step_size FROM sequence WHERE name = seq_name;
    RETURN @sequence_step_size;
  END$
DELIMITER ;

--
-- select sequence_set_initial_value('sequence_name', new_initial_value);
--

DROP FUNCTION IF EXISTS sequence_set_initial_value;
DELIMITER $
CREATE FUNCTION sequence_set_initial_value (seq_name VARCHAR(50), new_initial_value INT UNSIGNED)
  RETURNS INT UNSIGNED
  DETERMINISTIC
  CONTAINS SQL
  BEGIN
    UPDATE sequence SET initial_value = (@sequence_initial_value := new_initial_value) WHERE name = seq_name;
    RETURN @sequence_initial_value;
  END$
DELIMITER ;

--
-- select sequence_get_initial_value('sequence_name');
--

DROP FUNCTION IF EXISTS sequence_get_initial_value;
DELIMITER $
CREATE FUNCTION sequence_get_initial_value (seq_name VARCHAR(50))
  RETURNS INT UNSIGNED
  DETERMINISTIC
  CONTAINS SQL
  BEGIN
    SELECT initial_value INTO @sequence_initial_value FROM sequence WHERE name = seq_name;
    RETURN @sequence_initial_value;
  END$
DELIMITER ;


--
-- select sequence_setmax('sequence_name', new_max_value);
--

DROP FUNCTION IF EXISTS sequence_setmax;
DELIMITER $
CREATE FUNCTION sequence_setmax (seq_name VARCHAR(50), new_max_value INT UNSIGNED)
  RETURNS INT UNSIGNED
  DETERMINISTIC
  CONTAINS SQL
  BEGIN
    UPDATE sequence SET max_value = (@sequence_max_value := new_max_value) WHERE name = seq_name;
    RETURN @sequence_max_value;
  END$
DELIMITER ;

--
-- select sequence_getmax('sequence_name');
--

DROP FUNCTION IF EXISTS sequence_getmax;
DELIMITER $
CREATE FUNCTION sequence_getmax (seq_name VARCHAR(50))
  RETURNS INT UNSIGNED
  DETERMINISTIC
  CONTAINS SQL
  BEGIN
    SELECT max_value INTO @sequence_max_value FROM sequence WHERE name = seq_name;
    RETURN @sequence_max_value;
  END$
DELIMITER ;

--
-- select sequence_setcycle('sequence_name', new_cycle_value);
--

DROP FUNCTION IF EXISTS sequence_setcycle;
DELIMITER $
CREATE FUNCTION sequence_setcycle (seq_name VARCHAR(50), new_cycle TINYINT UNSIGNED)
  RETURNS INT UNSIGNED
  DETERMINISTIC
  CONTAINS SQL
  BEGIN
    UPDATE sequence SET cycle = (@sequence_cycle := IF(ISNULL(new_cycle) OR new_cycle = 0, 0, 1) ) WHERE name = seq_name;
    RETURN @sequence_cycle;
  END$
DELIMITER ;

--
-- select sequence_getcycle('sequence_name');
--

DROP FUNCTION IF EXISTS sequence_getcycle;
DELIMITER $
CREATE FUNCTION sequence_getcycle (seq_name VARCHAR(50))
  RETURNS INT UNSIGNED
  DETERMINISTIC
  CONTAINS SQL
  BEGIN
    SELECT cycle INTO @sequence_cycle FROM sequence WHERE name = seq_name;
    RETURN @sequence_cycle;
  END$
DELIMITER ;

--
-- select sequence_setval('sequence_name', new_value);
--

DROP FUNCTION IF EXISTS sequence_setval;
DELIMITER $
CREATE FUNCTION sequence_setval (seq_name VARCHAR(50), new_value INT UNSIGNED)
  RETURNS INT UNSIGNED
  DETERMINISTIC
  CONTAINS SQL
  BEGIN
    UPDATE sequence SET current_value = (@sequence_current_value := IF(new_value > max_value, max_value, new_value)) WHERE name = seq_name;
    RETURN @sequence_current_value;
  END$
DELIMITER ;

--
-- select sequence_currval('sequence_name');
--

DROP FUNCTION IF EXISTS sequence_currval;
DELIMITER $
CREATE FUNCTION sequence_currval (seq_name VARCHAR(50))
  RETURNS INT UNSIGNED
  DETERMINISTIC
  CONTAINS SQL
  BEGIN
    SELECT current_value INTO @sequence_current_value FROM sequence WHERE name = seq_name;
    RETURN @sequence_current_value;
  END$
DELIMITER ;
  
--
-- select sequence_nextval('sequence_name');
--

DROP FUNCTION IF EXISTS sequence_nextval;
DELIMITER $
CREATE FUNCTION sequence_nextval (seq_name VARCHAR(50))
  RETURNS INT UNSIGNED
  DETERMINISTIC
  CONTAINS SQL
  BEGIN
    UPDATE sequence SET current_value = (@sequence_current_value := IF((current_value < initial_value OR (current_value+step_size) > max_value AND cycle = 1), initial_value, IF((current_value+step_size) > max_value, max_value, current_value+step_size)))  WHERE name = seq_name;
    RETURN @sequence_current_value;
  END$
DELIMITER ;
  
