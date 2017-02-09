-- script changes multiple patterns in text field or text array field to a new single patterns, 
-- can be used to all schemas of server simultaneously, just fill list of schema-column pairs, new pattern, old patterns
DO
$do$
DECLARE
	-- list of pairs [schema.table, column]
	field varchar[];
	fields varchar[] := array[
	['schema1.users','user_url'],
	['schema1.users','image_url'], 
	['schema2.product','url'],
	['schema2.users','image_url'],
	['schema2.photo','url']
	];

	newItem text := '''https://newdomain.io/files/images/''';
	item text;
	searchItems text[] := array['''https://olddomain1.com/doc/''','''https://olddomain2.com/doc/'''];
	
	fullTableName varchar;
	columnName varchar;
	schemaName varchar;
	tableName varchar;
	splitTableName varchar[];
	
BEGIN
FOREACH field SLICE 1 IN ARRAY fields
LOOP
	
	FOREACH item IN ARRAY searchItems
	LOOP
	
	fullTableName := field [1];
	columnName := field [2];
	
	splitTableName := regexp_split_to_array(fullTableName, E'\\.');
	schemaName := splitTableName[1];
	tableName := splitTableName[2];
	
	IF EXISTS  (
		select * from information_schema.tables
		where table_schema = schemaName AND table_name = tableName)
	-- if array value
		THEN IF EXISTS (
			select * from information_schema.columns
			where table_schema = schemaName AND table_name = tableName AND column_name = columnName AND data_type = 'ARRAY')
		THEN 
		-- here we create temp table, split all matching arrays to simple rows, replace patterns, collect rows back to array, replace array.
			EXECUTE 'with temp1 as (select id, ' || columnName || ', B, replace(B,' || item || ',' || newItem || ') 
			as C FROM ' || fullTableName || ', unnest(' || columnName ||') 
			B WHERE array_to_string(' || columnName ||', '','',''*'') like ''%'' || ' || item || '|| ''%''),
			temp2 as (select id, array_agg(temp1.C) as newarray from temp1 group by id)
			update ' || fullTableName || ' myTable
			set ' || columnName || '= temp2.newarray
			FROM temp2
			where myTable.id = temp2.id';
			
			RAISE INFO 'Replaced as ARRAY % in table %,column: %',item,fullTableName,columnName ;
	-- if text value
		ELSE 
			EXECUTE 'UPDATE ' || fullTableName || ' SET ' || columnName || ' = replace(' 
			|| columnName || ',' || item || ',' || newItem || ')';
		
			RAISE INFO 'Replaced % in table %,column: %',item,fullTableName,columnName ;
		
		END IF;
		
	ELSE
		RAISE INFO 'Not fount table: %', fullTableName;
		
	END IF;
		
	END LOOP;
	
END LOOP;
	
END
$do$
