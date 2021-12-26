/*
 JavaScript Object Notation = JSON
  >> Text that is used to store and exchange data all over the web
  >> Written with JavaScript object notation
  >> JSON is often used when data is sent from a server to a web page
  
 There are two ways to store in PostgreSQL;
  >> json datatype - stores exact copy of input text. This type is faster to input since it is not processed 
  >> jsonb datatype - decomposed binary format that is parsed. This type is faster on functions and operators since it is already parsed.Also supports indexing.
     
*/

------------------------------------------STORING JSON----------------------------------------------------

CREATE TABLE books (
	id serial,
	bookinfo jsonb
)

INSERT INTO books (bookinfo)
VALUES
('{"title": "Deep Learning with Python","author": "Francois Chollet", "publisher":"Manning", "date": 2018}'),
('{"title": "Neural Networks - A Visual Intro for Beginners", "author": "Michael Taylor", "publisher":"self", "date": 2017}'),
('{"title": "Big Data In Practice","author": "Bernard Marr", "publisher":"Wiley", "date": 2016}');


 SELECT bookinfo->'author' FROM books; -- -> is used for selecting field

 
 
-----------------------------------------------CREATE JSON FROM TABLE-------------------------- 
 
SELECT jsonb_build_object(
	'id', air.id,
	'ident', air.ident,
	'name', air.name,
	'latitude_deg', air.latitude_deg,
	'elevation_ft', air.elevation_ft,
	'continent', air.continent,
	'iso_country', air.iso_country,
	'iso_region', air.iso_region,
	'airport_home_link', air.home_link,
	'airport_wikipedia_link', air.wikipedia_link,
	'municipality', air.municipality,
	'scheduled_service', air.scheduled_service,
	'gps_code', air.gps_code,
	'iata_code', air.iata_code,
	'airport_local_code', air.local_code,
	'airport_keywords', to_jsonb(string_to_array(air.keywords, ','))  ---- We add Array of Keywords
)
FROM airports AS air;

---------------------------------------------AGGREGATION-JSON--------------------------------------

SELECT to_jsonb(runway_json) FROM
( SELECT le_ident,
    he_ident,
	length_ft,
	width_ft,
	surface
  FROM runways
  WHERE airport_ident = 'JRA'
) as runway_json;

--Now we will use JSONB_AGG() function, to aggregate into array, one row

SELECT JSONB_AGG(to_jsonb(runway_json)) FROM
( SELECT le_ident,
    he_ident,
	length_ft,
	width_ft,
	surface
  FROM runways
  WHERE airport_ident = 'JRA'
) as runway_json;


-------------------------------------------------SELECTIONG INFORMATION OUT OF JSON FIELD---------------------------
SELECT airports->'runways'->0, airports->'country_name'
FROM airports_json;



-------------------------------------------------------SEARCHING DATA IN JSON-----------------------
--Finding all the airports in Brazil
SELECT * FROM airports_json
WHERE airports @> '{"iso_country": "BR"}';  ---by looking airport field that contains {"iso_country": "BR"}

--Count the airports in Brazil
SELECT COUNT(*) FROM airports_json
WHERE airports->>'iso_country' = 'BR';    --u can use like this as well, means equals to


/* 
 Select based on Nested  Attribute
 
 column -> 'field'-->'field2'="value"
                or
 column @> '{"field":{"field2":"value"}}'

*/

--Finding the number of airports with the first runway being 2000 feet long
SELECT COUNT(*) FROM airports_json
WHERE airports->'runways'-> 0 @> '{"length_ft": 2000}';


---------------------------------------------UPDATING OR DELETING JSON FIELD------------------------------

/*

|| operator add or replace existing value of field.

- operator delete value pairs
#- operator delete based on path

*/

-- Adding value

UPDATE airports_json
SET airports = airports || '{"nearby_lakes": ["Lake Chicot"]}'::jsonb
WHERE airports->>'iso_region' = 'US-AR'
		AND airports->>'municipality' = 'Lake Village';

--deleting by using - operator
UPDATE airports_json
SET airports = airports - 'nearby_lakes'
WHERE airports->>'iso_region' = 'US-AR'
		AND airports->>'municipality' = 'Lake Village';

--deleting by using #- operator
UPDATE airports_json
SET airports = airports #- '{"nearby_lakes", 1}'  -- we want to delete second element. Index goes on 0,1,2,3...
WHERE airports->>'iso_region' = 'US-AR'
		AND airports->>'municipality' = 'Lake Village';

































