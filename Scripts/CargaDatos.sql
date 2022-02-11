-- Inserts:
use proyectmovie;
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Director <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
INSERT INTO director(
SELECT distinct MD5(m.director) AS id_director, m.director AS Director
FROM movie_dataset_cleaned m LEFT JOIN crew c ON m.director = REPLACE(c.name, '"', ''));
-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Movie <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- Se inserta los datos de la tabla pelicula creada anteriormente
INSERT INTO movie
SELECT md.`index`,md.budget,md.genres,md.homepage,md.id_Movie,md.keywords,md.original_language,md.original_title,
       md.overview,md.popularity,md.release_date,md.revenue,md.runtime,md.status,md.tagline,md.title,
       md.vote_average,md.vote_count,md.cast,MD5(md.director)
	FROM movie_dataset_cleaned md;


-- Insert Production Companies
-- Una vez que tenemos los datos del JSON Production Companies Los entramos a la tabla production Companies Creada Anteriormente
INSERT INTO production_companies
SELECT DISTINCT t.name_production_company,t.id_production_company
FROM tmp_production_companies t;
-- WHERE m.id_Movie = t.id_movie ;

-- Una vez que tenemos la tabla movie y la tabla Production companies se crea la tercera tabla movies_companies que se genera debido a la
-- relacion de muchos a muchos por movie y production_companies
-- PK: id,  id_production_company
INSERT INTO movies_companies
SELECT  DISTINCT m.id_Movie,  pc.id_production_companies
FROM movie m, tmp_production_companies t, production_companies pc
WHERE m.id_Movie = t.id_movie AND t.id_production_company = pc.id_production_companies;



-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Production_Countries <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- Insert Production Companies
-- Una vez que tenemos los datos del JSON Production Companies Los entramos a la tabla production Countries Creada Anteriormente
INSERT INTO production_countries
SELECT DISTINCT tpc.iso_3166_1,tpc.country
FROM tmp_production_countries tpc;
-- WHERE m.id_Movie = t.id_movie ;

-- Una vez que tenemos la tabla movie y la tabla Production countries se crea la tercera tabla movies_countries que se genera debido a la
-- relacion de muchos a muchos por movie y production_countries
-- PK: id_Movie,  iso_3166_1
INSERT INTO movies_countries
SELECT  DISTINCT m.id_Movie,  pc.iso_3166_1
FROM movie m, tmp_production_countries tpc, production_countries pc
WHERE m.id_Movie = tpc.id_movie AND tpc.iso_3166_1 = pc.iso_3166_1;

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Spoken:Languages <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
-- Borrar si existe una versión anterior (re-crear el procedimiento)
-- Insert Production Companies

-- Una vez que tenemos los datos del JSON Production Companies Los entramos a la tabla production Countries Creada Anteriormente
INSERT INTO spoken_languages
SELECT DISTINCT sl.iso_639_1,sl.language
FROM tmp_spoken_languages sl;
-- WHERE m.id_Movie = t.id_movie ;

-- Una vez que tenemos la tabla movie y la tabla Production countries se crea la tercera tabla movies_countries que se genera debido a la
-- relacion de muchos a muchos por movie y production_countries
-- PK: id_Movie,  iso_3166_1
INSERT INTO movies_languages
SELECT  DISTINCT m.id_Movie,  sl.iso_639_1
FROM movie m, tmp_spoken_languages tsl, spoken_languages sl
WHERE m.id_Movie = tsl.id_movie AND tsl.iso_639_1 = sl.iso_639_1;

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Genero <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
use proyectmovie;
INSERT INTO genero
SELECT DISTINCT tmg.idGe,tmg.genre
FROM  tmp_genres tmg;

INSERT INTO genero_movie
SELECT m.id_Movie,  g.id_Genero
FROM movie m,tmp_genres tmg, genero g
WHERE m.id_Movie = tmg.id_movie AND tmg.idGe = g.id_Genero;

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> Crew <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
INSERT INTO crew(
SELECT DISTINCT tmc.id_crew, tmc.name,tmc.gender
FROM movie m,tmp_crew tmc
    WHERE m.id_Movie=tmc.id_movie);

INSERT INTO credit(
SELECT DISTINCT tmc.credit_id, tmc.job,tmc.department,tmc.id_crew
FROM movie m,tmp_crew tmc,crew c
WHERE m.id_Movie = tmc.id_movie AND tmc.id_crew = c.idCrew);

INSERT INTO movies_credit(
SELECT DISTINCT m.id_Movie,c.credit_id
FROM tmp_crew tmc,movie m, credit c
WHERE m.id_Movie = tmc.id_movie AND tmc.credit_id = c.credit_id);

-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> CAST <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
INSERT INTO `cast`(
SELECT DISTINCT tmc.idCast,tmc.cast
FROM  tmp_cast tmc
);

INSERT INTO cast_movie(
SELECT DISTINCT  tmc.id_movie,  tmc.idCast
FROM tmp_cast tmc );


-- >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> keywords <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
INSERT INTO keywords(
SELECT DISTINCT tmk.idKeywords,tmk.nameKeywords
FROM  tmp_keywords tmk
);

INSERT INTO keywords_movie(
SELECT DISTINCT  tmk.id_movie,  tmk.idKeywords
FROM tmp_keywords tmk );
