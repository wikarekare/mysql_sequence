# mysql_sequence

Add stored procedures and functions to mysql mimic sequences.

##Table Definition
```
CREATE TABLE sequence (
    name           VARCHAR(50) NOT NULL,
    initial_value   INT UNSIGNED NOT NULL DEFAULT 1,
    current_value     INT UNSIGNED NOT NULL,
    step_size      INT UNSIGNED NOT NULL DEFAULT 1,
    max_value      INT UNSIGNED NOT NULL DEFAULT 4294967295,
    cycle          TINYINT NOT NULL DEFAULT 0,
    PRIMARY KEY (name)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;
```
###Table fields
* name is the name of the sequence, and key for sequence function calls.
* current_value is the last value we issued, or 0 if no values have been issued
* step size is the amount we increment the current_value in sequence_nextval()
* max_value, if not null, is the point we wrap and issue 1 as the next value.
* cycle, start at 1 if current_value = max_value otherwise it is an error

##Usage

###call sequence_create(sequence_name);
* Adds a named sequence to the sequence table, using default sequence values.

####sets session variables
* @sequence_initial_value is set to initial_value
* @sequence_current_value is set to current_value
* @sequence_step_size is set to step_size
* @sequence_max_value is set to max_value (Null means MAX_UNSIGNED_INT)
* @sequence_cycle is set to 0 or 1 (Null means 0, i.e. don't cycle)

###call sequence_create_full(sequence_name, initial_value, current_value, step_size, max_value, cycle);
*Adds a named sequence to the sequence table, specifying initial_value, current_value, step_size and max_value.

   if cycle is true, then when sequence_nextval() increments past max_value, it cycles back to initial_value.

####sets session variables
* @sequence_initial_value is set to initial_value
* @sequence_current_value is set to current_value
* @sequence_step_size is set to step_size
* @sequence_max_value is set to max_value (Null means MAX_UNSIGNED_INT)
* @sequence_cycle is set to 0 or 1 (Null means 0, i.e. don't cycle)


###call select sequence_getall(sequence_name);

####sets session variables
* @sequence_initial_value is set to sequence.initial_value
* @sequence_current_value is set to sequence.current_value
* @sequence_step_size is set to sequence.step_size
* @sequence_max_value is set to sequence.max_value
* @sequence_cycle is set to sequence.cycle

###call sequence_drop(sequence_name);
* Removes a named sequence from the sequence table

####sets session variables
* @sequence_initial_value is set to NULL
* @sequence_current_value is set to NULL 
* @sequence_step_size is set to NULL
* @sequence_max_value is set to NULL
* @sequence_cycle is set to NULL


###select sequence_setinc(sequence_name, new_step_size);
* Updates the sequence.step_size field to the new_step_size.
* sets session variable @sequence_step_size to new_step_size.
* Returns the step size

###select sequence_getinc(sequence_name);
* sets session variable @sequence_step_size to step_size.
* Returns sequence.step_size

###select sequence_setmax(sequence_name, new_max_value);
* Updates the sequence.max_value field to the new_max_value.
* sets session variable @sequence_max_value to new_max_value.
* Returns the new_max_value

###select sequence_getmax(sequence_name);
* sets session variable @sequence_max_value to max_value.
* Returns sequence.max_value

###select sequence_set_initial_value('sequence_name', new_initial_value);
* Updates the sequence.initial_value field to the new_initial_value.
* sets session variable @sequence_initial_value to new_initial_value.
* Returns the new_initial_value

###select sequence_get_initial_value('sequence_name');
* sets session variable @sequence_initial_value to initial_value.
* Returns sequence.initial_value

###select sequence_setcycle('sequence_name', new_cycle_value);
* Updates the sequence.cycle field to the new_cycle_value.  

   if new_cycle_value is null then new_cycle_value changed to 0  
   if new_cycle_value > 1 then new_cycle_value changed to 1
* sets session variable @sequence_cycle to new_cycle_value.
* Returns the new_cycle_value

###select sequence_getcycle('sequence_name');
* sets session variable @sequence_cycle to cycle.
* Returns sequence.cycle

###select sequence_setval(sequence_name, new_value);
* Updates the sequence.current_value to the new_value.
   Setting a value above max_value will cause the value to be set to max_value.  
   Setting a value below the initial value mean the nextval will be the initial value.
* sets session variable @sequence_current_value to new_value
* Returns the new_ sequence_value

###select sequence_currval(sequence_name);
* sets session variable @sequence_current_value to current_value
* Returns sequence.current_value value

###select sequence_nextval(sequence_name);
* Updates the sequence table, incrementing current_value by the step_size.

   if the current_value < initial_value then sets current_value to the initial_value.  
   if cycle is true and the incremented current_value is > max_value, current_value is set to initial_value.  
   if cycle is false and the incremented current_value is > max_value, current_value is set to max_value.
* sets session variable @sequence_current_value to the new current_value
* Returns the new sequence.current_value having set


