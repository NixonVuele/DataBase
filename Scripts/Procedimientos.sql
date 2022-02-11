-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Procedimientos <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Produccion companies JSON <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- Crear la tabla temporal de la relacion movies con production companies y se extrae los datos que se encuentran en
-- El JSON production_companies
DROP PROCEDURE IF EXISTS Json2Relational_production_companies ;
DELIMITER //
CREATE PROCEDURE Json2Relational_production_companies()
BEGIN
	DECLARE a INT Default 0 ;
	DROP TABLE IF EXISTS tmp_production_companies ;
	CREATE TABlE tmp_production_companies (id_movie INTEGER, id_production_company INT, name_production_company VARCHAR (100) );
  simple_loop: LOOP
		INSERT INTO tmp_production_companies (id_movie, name_production_company,id_production_company)
		SELECT m.id_Movie,
		    JSON_EXTRACT(m.production_companies , CONCAT('$[',a,'].name')),
			JSON_EXTRACT(m.production_companies, CONCAT('$[',a,'].id'))
		FROM movie_dataset_cleaned m ;
			SET a=a+1;
     	IF a=10 THEN
            LEAVE simple_loop;
      END IF;
   END LOOP simple_loop;
   DELETE FROM tmp_production_companies WHERE id_production_company IS NULL ;
END //
DELIMITER ;
Call Json2Relational_production_companies();


-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Produccion countries JSON <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

DROP PROCEDURE IF EXISTS Json2Relational_production_countries ;
DELIMITER //
CREATE PROCEDURE Json2Relational_production_countries()
BEGIN
	DECLARE a INT Default 0 ;
	DROP TABLE IF EXISTS tmp_production_countries ;
	CREATE TABlE tmp_production_countries (id_movie INT, iso_3166_1 VARCHAR (7), country VARCHAR (100) );
  simple_loop: LOOP
		INSERT INTO tmp_production_countries (id_movie, iso_3166_1, country)
		SELECT id_Movie,
			JSON_EXTRACT(production_countries, CONCAT('$[',a,'].iso_3166_1')) AS iso_3166_1,
			JSON_EXTRACT(production_countries , CONCAT('$[',a,'].name')) AS country
		FROM movie_dataset_cleaned m ;
			SET a=a+1;
     	IF a=10 THEN
            LEAVE simple_loop;
      END IF;
   END LOOP simple_loop;
   DELETE FROM tmp_production_countries WHERE iso_3166_1 IS NULL ;
END //
DELIMITER ;

CALL Json2Relational_production_countries();

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Produccion SpokenLanguage JSON <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
DROP PROCEDURE IF EXISTS Json2Relational_spoken_languages ;
DELIMITER //
CREATE PROCEDURE Json2Relational_spoken_languages()
BEGIN
	DECLARE a INT Default 0 ;
	DROP TABLE IF EXISTS tmp_spoken_languages ;
	CREATE TABlE tmp_spoken_languages (id_movie INT, iso_639_1 VARCHAR (5), `language` VARCHAR (100) );
  simple_loop: LOOP
		INSERT INTO tmp_spoken_languages (id_movie, iso_639_1, `language`)
		SELECT id_Movie,
			JSON_EXTRACT(spoken_languages , CONCAT('$[',a,'].iso_639_1')) AS iso_639_1,
			JSON_EXTRACT(spoken_languages , CONCAT('$[',a,'].name')) AS language
		FROM movie_dataset_cleaned m ;
			SET a=a+1;
     	IF a=10 THEN
            LEAVE simple_loop;
      END IF;
   END LOOP simple_loop;
   DELETE FROM tmp_spoken_languages WHERE iso_639_1 IS NULL ;
END //
DELIMITER ;

CALL Json2Relational_spoken_languages();

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> CREW JSON <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
DROP PROCEDURE IF EXISTS Json2Relational_crew ;
DELIMITER //
CREATE PROCEDURE Json2Relational_crew()
BEGIN
	DECLARE a INT Default 0 ;
	DROP TABLE IF EXISTS tmp_crew;
	CREATE TABlE tmp_crew
	  (id_movie INT, id_crew INT, job VARCHAR (200), name VARCHAR (400), gender INT, credit_id VARCHAR (50), department VARCHAR (50) );
simple_loop: LOOP
		INSERT INTO tmp_crew (id_movie, id_crew, job, name, gender, credit_id, department)
		SELECT id_Movie,
			JSON_EXTRACT(CONVERT(crew using utf8mb4), CONCAT("$[",a,"].id")) AS id_crew,
			JSON_EXTRACT(CONVERT(crew using utf8mb4), CONCAT("$[",a,"].job")) AS job,
			JSON_EXTRACT(CONVERT(crew using utf8mb4), CONCAT("$[",a,"].name")) AS name,
			JSON_EXTRACT(CONVERT(crew using utf8mb4), CONCAT("$[",a,"].gender")) AS gender,
			JSON_EXTRACT(CONVERT(crew using utf8mb4), CONCAT("$[",a,"].credit_id")) AS credit_id,
			JSON_EXTRACT(CONVERT(crew using utf8mb4), CONCAT("$[",a,"].department")) AS department
		FROM movie_dataset_cleaned m
		WHERE id_Movie IN (SELECT id_Movie FROM movie_dataset_cleaned WHERE a <= JSON_LENGTH (crew) );
SET a=a+1;
     	IF a=436 THEN
            LEAVE simple_loop;
      END IF;
   END LOOP simple_loop;
   DELETE FROM tmp_crew WHERE id_crew IS NULL ;
END //
DELIMITER ;
Call Json2Relational_crew();
Alter table tmp_crew add primary key (id_movie,credit_id);
UPDATE tmp_crew
SET gender = 2
WHERE id_crew = 30711 ;

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Genres <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
DROP PROCEDURE IF EXISTS Json2Relational_genres ;
DELIMITER //
CREATE PROCEDURE Json2Relational_genres()
BEGIN
	DECLARE a INT Default 0 ;
	DROP TABLE IF EXISTS tmp_genres ;
	CREATE TABlE tmp_genres (id_movie INT not null, idGe VARCHAR(100),genre VARCHAR (100) );
	simple_loop: LOOP
		INSERT INTO tmp_genres (id_movie,idGe,genre)
        SELECT * FROM (
			SELECT id_Movie as id_Movie,MD5(REPLACE(JSON_EXTRACT(CONCAT('["', REPLACE(REPLACE (genres, ' ', '","'),
				    'Science","Fiction', 'Science Fiction'), '"]'), CONCAT("$[",a,"]")), """","")),
				REPLACE(JSON_EXTRACT(CONCAT('["', REPLACE(REPLACE (genres, ' ', '","'),
				    'Science","Fiction', 'Science Fiction'), '"]'), CONCAT("$[",a,"]")), """","") AS genre
			FROM movie_dataset_cleaned ) t
        WHERE genre != "";
			SET a=a+1;
     	IF a=6 THEN
            LEAVE simple_loop;
		END IF;
	END LOOP simple_loop;
	DELETE FROM tmp_genres
	WHERE genre IS NULL;
END //
DELIMITER ;
Call Json2Relational_genres();

-- Procedimiento de Cast
use proyectmovie;
CREATE TABLE JSONCat (id_movie INT not null,castJson VARCHAR (300));
INSERT INTO JSONCat (id_movie,castJson)
SELECT  id_Movie,
       REPLACE(REPLACE(
       CONCAT('["',
                IF(SpacesNumber >= 13, CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ' ', -14), ' ', 2), '","'), '') ,
	   			IF(SpacesNumber >= 11, CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ' ', -12), ' ', 2), '","'), '') ,
	   			IF(SpacesNumber >= 9, CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ' ', -10), ' ', 2), '","'), '') ,
	   			IF(SpacesNumber >= 7, CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ' ', -8), ' ', 2), '","'), '') ,
	   			IF(SpacesNumber >= 5, CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ' ', -6), ' ', 2), '","'), '') ,
	   			IF(SpacesNumber >=3, CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(cast, ' ', -4), ' ', 2), '","'), '') ,'"]'),
       "-", " "),"Delete", " ") AS CastJson
FROM(
    SELECT id_Movie, cast, LENGTH(cast) - LENGTH(REPLACE(cast, ' ', '')) AS SpacesNumber
FROM(
    SELECT id_Movie,
           CONVERT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
               REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
                   REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
            Cast, ' Jr.', '-Jr.'), ' Jr ', '-Jr '),'=Jr ', '-Jr '),"'Jules'",'Jules'),
            '. ', '.-'),' The ', ' The-'), ' the ',' the-'), ' de ','-de'), ' Le ','-Le'),'-Jr.-Ice ','-Jr. Ice '),
                '--Jr.-Jon ','-Jr. Jon '), 'Lisa Ann Walter', 'Lisa Ann-Walter'),'Gian Maria Volonté', 'Gian Maria-Volonté'),
                'Gordon Liu Chia-Hui', 'Gordon Liu-Chia-Hui'),'Kristin Scott Thomas', 'Kristin Scott-Thomas'),
                'Gordon Liu Chia-Hui', 'Gordon Liu-Chia-Hui'),'Tommy Lee Jones', 'Tommy Lee-Jones'),'Lee Van Cleef', 'Lee Van-Cleef'),
                'Nicole de Boer', 'Nicole de-Boer'),'Dick Van Dyke', 'Dick Van Dyke'),'Catalina Sandino Moreno', 'Catalina Sandino-Moreno'),
                'Michael Clarke Duncan', 'Michael Clarke-Duncan'),'Sarah Jessica Parker', 'Sarah Jessica-Parker'),'Helena Bonham Carter',
                'Helena Bonham-Carter'),'Bryce Dallas Howard', 'Bryce Dallas-Howard'),'=Ice Cube Morris', ' Ice Cube-Morris'),
                ' Lucille La Verne', ' Lucille La-Verne'),'Charles Martin Smith', 'Charles Martin-Smith'),
                'Tim Blake Nelson', 'Tim Blake-Nelson'),'Anthony Michael Hall', 'Anthony Michael-Hall'),'Robert Sean Leonard',
                'Robert Sean-Leonard'),'Max von Sydow', 'Max von-Sydow'),'Brendan Sexton III', 'Brendan Sexton-III'),"'",''),
               'Al" Yankovic','Al Yankovic'),'"Doogie" Milewski','Doogie Milewski'),'"Gunner" Lail','Gunner Lail')
            using utf8mb4) AS cast
FROM movie_dataset_cleaned
WHERE cast<> '')t1)t2;

DROP PROCEDURE IF EXISTS Json2Relational_cast ;
DELIMITER //
CREATE PROCEDURE Json2Relational_cast()
BEGIN
	DECLARE a INT Default 0 ;
	DROP TABLE IF EXISTS tmp_cast ;
	CREATE TABlE tmp_cast (id_movie INTEGER not null, idCast VARCHAR(300),cast VARCHAR (300) );
	simple_loop: LOOP
		INSERT INTO tmp_cast (id_movie,idCast,cast)
        SELECT * FROM (
			SELECT distinct id_Movie as id_Movie,MD5(REPLACE(JSON_EXTRACT(CONVERT(JSONCat.castJson using utf8mb4), CONCAT("$[",a,"]")),"""","")) as id_cast,
			       REPLACE(JSON_EXTRACT(CONVERT(JSONCat.castJson using utf8mb4), CONCAT("$[",a,"]")),"""","") AS Cast
			FROM JSONCat ) t
        WHERE cast != "";
			SET a=a+1;
     	IF a=6 THEN
            LEAVE simple_loop;
		END IF;
	END LOOP simple_loop;
	DELETE FROM tmp_cast
	WHERE cast IS NULL;
END //
DELIMITER ;
Call Json2Relational_cast();

Select id_movie,JSON_VALID(JSONCat.castJson)
from jsoncat;

-- Procedimiento de Keywords
CREATE TABLE JSONKeywords (id_movie INT not null,Keywords VARCHAR (300));
INSERT INTO JSONKeywords (id_movie,Keywords)
SELECT  id_Movie,
       REPLACE(REPLACE(
       CONCAT('["',
                IF(SpacesNumber >= 11, CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(keywords, ' ', -14), ' ', 1), '","'), '') ,
	   			IF(SpacesNumber >= 9, CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(keywords, ' ', -12), ' ', 1), '","'), '') ,
	   			IF(SpacesNumber >= 7, CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(keywords, ' ', -10), ' ', 1), '","'), '') ,
	   			IF(SpacesNumber >= 5, CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(keywords, ' ', -8), ' ', 1), '","'), '') ,
	   			IF(SpacesNumber >= 3, CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(keywords, ' ', -6), ' ', 1), '","'), '') ,
	   			IF(SpacesNumber >=1, CONCAT(SUBSTRING_INDEX(SUBSTRING_INDEX(keywords, ' ', -4), ' ', 1), '","'), '') ,'"]'),
       "-", " "),"Delete", " ") AS KeywordsJson
FROM(
    SELECT id_Movie,keywords , LENGTH(keywords) - LENGTH(REPLACE(keywords, ' ', '')) AS SpacesNumber
FROM(
    SELECT id_Movie,
           CONVERT(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
            keywords,'. ', '.-'),' The ', ' The-'), ' the ',' the-'), ' the ',' the-'), ' on ','on-'),' a ',' a-'),
               'jackson"','jackson')
            using utf8mb4) AS keywords
FROM movie_dataset_cleaned
WHERE cast<> '')t1)2t;
Select id_movie,JSON_VALID(JSONKeywords.Keywords)
from jsonkeywords;

DROP PROCEDURE IF EXISTS Json2Relational_Keywords ;
DELIMITER //
CREATE PROCEDURE Json2Relational_Keywords()
BEGIN
	DECLARE a INT Default 0 ;
	DROP TABLE IF EXISTS tmp_keywords ;
	CREATE TABlE tmp_keywords (id_movie INTEGER not null, idKeywords VARCHAR(300),nameKeywords VARCHAR (300) );
	simple_loop: LOOP
		INSERT INTO tmp_keywords (id_movie,idKeywords,nameKeywords)
        SELECT * FROM (
			SELECT distinct id_Movie as id_Movie,MD5(REPLACE(JSON_EXTRACT(CONVERT(jsonkeywords.Keywords using utf8mb4), CONCAT("$[",a,"]")),"""","")) as id_keywords,
			       REPLACE(JSON_EXTRACT(CONVERT(jsonkeywords.Keywords using utf8mb4), CONCAT("$[",a,"]")),"""","") AS keywords
			FROM jsonkeywords ) t
        WHERE keywords  != "";
			SET a=a+1;
     	IF a=6 THEN
            LEAVE simple_loop;
		END IF;
	END LOOP simple_loop;
	DELETE FROM tmp_keywords
	WHERE tmp_keywords.nameKeywords IS NULL;
END //
DELIMITER ;
Call Json2Relational_Keywords();
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> drops de tables temporales <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
DROP TABLE IF EXISTS tmp_production_companies ;
DROP TABLE IF EXISTS tmp_production_countries ;
DROP TABLE IF EXISTS tmp_spoken_languages ;
DROP TABLE IF EXISTS tmp_crew ;
DROP TABLE IF EXISTS tmp_genres;
DROP TABLE IF EXISTS tmp_cast;
DROP TABLE IF EXISTS tmp_keywords;
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> drops de Json <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
DROP TABLE IF EXISTS jsonkeywords;
DROP TABLE IF EXISTS jsoncat;
