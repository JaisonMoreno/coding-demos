/* Challenge - Animal vaccinations report
Write a query to report animals and their vacciantions. 
Include animas that have not been vaccinated.
The report should show the aninal's name, species, breed, and primary color, vaccination time and the vaccine name, the staff member's first name, last name, and role. 
Use the minimal number of tables required. 
Use the correct logical join types and force join orders as needed. */


SELECT	A.Name,
		A.Species,
		A.Breed,
		A.Primary_Color, 
		V.Vaccination_Time, 
		V.Vaccine, 
		P.First_Name, 
		P.Last_Name, 
		SA.Role
FROM	Animals AS A
		LEFT OUTER JOIN
		(	Vaccinations as V
			INNER JOIN
			Staff_Assignments as SA
			ON V.Email=SA.Email
			INNER JOIN
			Persons as P
			ON P.Email = V.Email
		)
		ON A.Name = V.Name and A.Species = V.Species
ORDER BY A.Name, A.Species, A.Breed, V.Vaccination_Time


/* Challenge - Animal vaccination report
Wrete a query  to report the number of vaccinations each animal has recieved. Include animals that were never vaccinated. Exclude rabbits, rabies, vaccines, and animals that were last vaccinated on or after October first,2019.
The repor should show the animals name, specied, primary color, breed, and the number of vaccinations. Use the corret logical join types and force order if needed. 
Use the correct logical group by expressions. */

SELECT A.Name,
	   a.Species,
	   MAX(a.Primary_Color) AS Primary_Coloer,
	   max(a.Breed) AS Breed, COUNT(v.vaccine)
FROM ANIMALS AS A
	LEFT OUTER JOIN 
	Vaccinations AS V 
	ON a.Name=v.Name and a.Species=v.Species
WHERE a.Species != 'Rabbit' AND  (v.Vaccine != 'Rabies' or v.Vaccine IS NULL) 
GROUP BY a.Species, a.Name
HAVING MAX(v.Vaccination_Time) <'20191001' OR MAX(v.Vaccination_Time) IS NULL
ORDER BY a.Species, a.Name


/* Self join example */
SELECT	A1.Adopter_Email, A1.Adoption_Date, 
		A1.Name AS Name1, A1.Species AS Species1, 
		A2.Name AS NAme2, A2.Species AS Species2
FROM	Adoptions AS A1
		INNER JOIN
		Adoptions AS A2
		ON A1.Adopter_Email = A2.Adopter_Email
		AND
		A1.Adoption_Date = A2.Adoption_Date
		AND	(	(A1.Name=A2.Name AND A1.Species > A2.Species)
				OR
				(A1.Name > A2.Name AND A1.Species = A2.Species)
				OR
				(A1.Name > A2.Name AND A1.Species <> A2.Species))
ORDER BY A1.Adopter_Email, A1.Adoption_Date

-- Grouping Sets
SELECT YEAR(Adoption_Date) AS Year, 
	MONTH(Adoption_Date) AS Month,
	COUNT (*) AS Monthly_Adoptions
FROM Adoptions
GROUP BY GROUPING SETS
	((YEAR(Adoption_Date),
	  MONTH(Adoption_Date)
	  ))