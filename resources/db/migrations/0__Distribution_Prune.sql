/* Ensure smoke test data is pruned for distribution release. */

DELETE FROM `topstack`.`account` where id > 1;



