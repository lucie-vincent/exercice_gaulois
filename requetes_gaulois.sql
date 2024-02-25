-- QUESTION 1 --
SELECT nom_lieu FROM lieu WHERE lieu.nom_lieu LIKE "%um";

-- QUESTION 2 --
SELECT 	lieu.nom_lieu,
			COUNT(personnage.id_personnage) AS nombre_personnages
FROM personnage
	INNER JOIN lieu ON personnage.id_lieu = lieu.id_lieu
-- important de faire les GROUP BY sur id_qqch et PAS sur nom_qqch : car si plsrs noms similaires : regroupés
GROUP BY personnage.id_lieu
ORDER BY nombre_personnages DESC;

-- QUESTION 3 --
SELECT 	personnage.nom_personnage,
			specialite.nom_specialite,
			ifnull(personnage.adresse_personnage,'[aucune adresse]') AS 'Adresse',
			lieu.nom_lieu
FROM personnage 
INNER JOIN specialite ON personnage.id_specialite = specialite.id_specialite
INNER JOIN lieu ON personnage.id_lieu =  lieu.id_lieu
ORDER BY lieu.nom_lieu, personnage.nom_personnage;

 -- QUESTION 4 --
 SELECT 	specialite.nom_specialite,
 			COUNT(personnage.id_specialite) AS nombre_personnages
 FROM specialite
 	NNER JOIN personnage ON specialite.id_specialite = personnage.id_specialite
 -- idem, même commentaire sur GROUP BY : id_qqch et pas nom_qqch
 GROUP BY specialite.id_specialite
 ORDER BY nombre_personnages DESC;
 
 -- QUESTION 5 --
 SELECT bataille.nom_bataille, lieu.nom_lieu,
 DATE_FORMAT(bataille.date_bataille, '%d/%m/%Y') AS 'Date'
 FROM bataille
 	INNER JOIN lieu ON bataille.id_lieu = lieu.id_lieu
 ORDER BY bataille.date_bataille;
 
 -- QUESTION 6 --
 SELECT 	potion.nom_potion,
 			SUM(ingredient.cout_ingredient * composer.qte) AS prix_potion
 FROM potion
 	INNER JOIN composer ON potion.id_potion = composer.id_potion
 	INNER JOIN ingredient ON composer.id_ingredient = ingredient.id_ingredient
 GROUP BY potion.id_potion
 ORDER BY prix_potion DESC;
 
 -- QUESTION 7 --
SELECT ingredient.nom_ingredient, ingredient.cout_ingredient, composer.qte
FROM ingredient
	INNER JOIN composer ON ingredient.id_ingredient = composer.id_ingredient
	INNER JOIN potion ON composer.id_potion = potion.id_potion
WHERE potion.id_potion = 3; /* Potion de Santé */

-- QUESTION 8 --
SELECT p.nom_personnage
FROM personnage p
	INNER JOIN prendre_casque pc1 ON pc1.id_personnage = p.id_personnage
WHERE pc1.id_bataille = 1 /*bataille du village gaulois*/
GROUP BY p.id_personnage
HAVING SUM(pc1.qte) >= ALL(
								SELECT SUM(pc2.qte)
								FROM prendre_casque pc2
								WHERE pc2.id_bataille = 1 /*bataille du village gaulois*/
								GROUP BY pc2.id_personnage);
 -- version de travail --
SELECT p1.nom_personnage
FROM personnage p1
	INNER JOIN prendre_casque pc1 ON p1.id_personnage = pc1.id_personnage
WHERE pc1.id_bataille = 1
GROUP BY p1.id_personnage
HAVING sum(pc1.qte) >= ALL(
	SELECT SUM(pc2.qte)
	FROM personnage p2
		INNER JOIN prendre_casque pc2 ON p2.id_personnage = pc2.id_personnage
		INNER JOIN bataille b2 ON pc2.id_bataille = b2.id_bataille
	WHERE b2.id_bataille = 1
	GROUP BY p2.id_personnage
);

-- QUESTION 9 -- 
SELECT 	personnage.nom_personnage,
			SUM(boire.dose_boire) AS quantite_potion_bue
FROM personnage
	INNER JOIN boire ON personnage.id_personnage = boire.id_personnage
GROUP BY personnage.id_personnage
ORDER BY quantite_potion_bue DESC;

 -- QUESTION 10 --
SELECT b1.nom_bataille
FROM bataille b1
	INNER JOIN prendre_casque pc1 ON b1.id_bataille = pc1.id_bataille
GROUP BY b1.id_bataille 
HAVING SUM(pc1.qte) >= ALL (
	SELECT SUM(pc2.qte) AS nombre_casques_pris
	FROM bataille b2
		INNER JOIN prendre_casque pc2 ON b2.id_bataille = pc2.id_bataille
	GROUP BY pc2.id_bataille
);

-- QUESTION 11 --
SELECT	type_casque.nom_type_casque AS 'Nationalité/Type',
			COUNT(casque.id_type_casque) AS 'Nb Forme de casque',
			SUM(casque.cout_casque) AS 'Cout total'
FROM type_casque
	INNER JOIN casque ON type_casque.id_type_casque = casque.id_type_casque
GROUP BY type_casque.id_type_casque;

-- QUESTION 12 --
SELECT potion.nom_potion
FROM potion
	INNER JOIN composer ON composer.id_potion = potion.id_potion
	INNER JOIN ingredient ON composer.id_ingredient = ingredient.id_ingredient
WHERE ingredient.nom_ingredient = 'Poisson frais';

-- QUESTION 13 --
SELECT lieu.nom_lieu
FROM lieu
	INNER JOIN personnage ON lieu.id_lieu = personnage.id_lieu
WHERE lieu.nom_lieu <> 'Village gaulois'
GROUP BY personnage.id_lieu
HAVING COUNT(personnage.id_lieu) >= ALL (
	SELECT COUNT(personnage.id_lieu) AS nombre_habitants
	FROM lieu
	INNER JOIN personnage ON lieu.id_lieu = personnage.id_lieu
	WHERE lieu.nom_lieu <> 'Village gaulois'
	GROUP BY personnage.id_lieu
);
 
  -- QUESTION 14 --
SELECT personnage.nom_personnage
FROM personnage
WHERE personnage.id_personnage NOT IN (
	SELECT personnage.id_personnage 
	FROM personnage
		INNER JOIN boire ON personnage.id_personnage = boire.id_personnage
	);

-- QUESTION 15 --
SELECT personnage.nom_personnage
FROM personnage
WHERE personnage.id_personnage NOT IN (
	SELECT personnage.id_personnage
	FROM personnage
		INNER JOIN autoriser_boire ON personnage.id_personnage = autoriser_boire.id_personnage
	WHERE id_potion = 1
	);

-- QUESTION A --
INSERT INTO personnage (nom_personnage, id_specialite, adresse_personnage, id_lieu)
VALUES ("Champdeblix", 12, "Ferme Hantassion", 6);

-- QUESTION B --
INSERT INTO autoriser_boire (id_potion, id_personnage)
VALUES (1, 12);
-- version sans connaitre les ID--
INSERT INTO autoriser_boire (id_potion, id_personnage)
VALUES (	SELECT id_potion FROM potion WHERE nom_potion = 'Magique' ,
			SELECT id_personnage FROM personnage WHERE nom_personnage = 'Bonemine');

-- QUESTION C --
/*DELETE 
FROM casque 
WHERE id_type_casque = 2 AND id_casque NOT IN (
	SELECT DISTINCT casque.id_casque
	FROM casque
		INNER JOIN prendre_casque ON prendre_casque.id_casque = casque.id_casque
	WHERE id_type_casque = 2
); 
*/

-- QUESTION D --
UPDATE personnage
SET adresse_personnage = 'Prison',
	id_lieu = 9
WHERE id_personnage = 23;

-- QUESTION E --
DELETE FROM composer
WHERE id_potion = 9 AND id_ingredient = 19;

-- QUESTION F --
UPDATE prendre_casque
SET id_casque = 10,
	qte = 42
WHERE id_bataille = 9;
