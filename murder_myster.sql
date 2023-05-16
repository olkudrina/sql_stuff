-- Game and data is provided by https://mystery.knightlab.com/
-- Let's extract the crime scene report

Select * FROM crime_scene_report WHERE date = 20180115
AND type = 'murder' AND city = 'SQL City'

-- as a result we can see that there are two witnesses: 
-- The first witness lives at the last house on "Northwestern Dr". 
-- The second witness, named Annabel, lives somewhere on "Franklin Ave".

-- Let's have a look at the 1st witness testimony

WITH temp AS (Select * FROM person WHERE address_street_name = 'Northwestern Dr' 
			  AND address_number = (SELECT MAX(address_number) FROM person 
									WHERE address_street_name = 'Northwestern Dr'))

Select * FROM interview WHERE person_id = (Select id FROM temp)

-- I heard a gunshot and then saw a man run out. He had a "Get Fit Now Gym" bag. 
-- The membership number on the bag started with "48Z". Only gold members have those bags. 
-- The man got into a car with a plate that included "H42W".

-- Let's have a look at the 2nd witness testimony

WITH temp AS (Select * FROM person WHERE address_street_name = 'Franklin Ave' 
			  AND name LIKE 'Annabel%')
Select * FROM interview WHERE person_id = (Select id FROM temp)

-- I saw the murder happen, and I recognized the killer from my gym when I was working out last week on January the 9th.

-- As both witnesses mentioned the gym, let's have a look at gym records
-- Let's have a look at the check-ins of the January the 9th with the gold membership number that starts with "48Z"

Select * FROM get_fit_now_check_in 
LEFT JOIN get_fit_now_member ON membership_id = id
WHERE check_in_date = 20180109
AND membership_id LIKE '48Z%' AND membership_status = 'gold'

-- we have now two suspects: Joe Germuska and Jeremy Bowers
-- Since we know a car plate number, we can have a look into the driver licenses

SELECT * FROM person WHERE license_id = (SELECT id FROM drivers_license WHERE plate_number LIKE 'H42W%')

-- As we can see the vehicle is owned by Maxine Whitely, who lives on Fisk Rd, 110
-- Let's have a look at testimonies

SELECT interview.*, name FROM interview
INNER JOIN (Select * FROM person WHERE name IN ('Joe Germuska', 'Jeremy Bowers')) as temp ON person_id = id

-- And we have our killer, who was hired to kill by someone. But who is the real mstermind behind the case? 
-- According to testimony: I was hired by a woman with a lot of money. I don't know her name but I know she's around 5'5" (65") or 5'7" (67"). 
--                         She has red hair and she drives a Tesla Model S. 
--                         I know that she attended the SQL Symphony Concert 3 times in December 2017.	

WITH id_from_event AS (Select person_id FROM facebook_event_checkin 
					   WHERE CAST(date AS varchar) LIKE '201712%'
					   AND event_name LIKE 'SQL Symphony Concert'
					   GROUP BY person_id
					   HAVING COUNT(DISTINCT date) = 3)
Select name FROM person 
LEFT JOIN drivers_license ON license_id = drivers_license.id
WHERE person.id IN (Select person_id FROM id_from_event)
AND gender = 'female' AND hair_color = 'red' AND car_make = 'Tesla'
AND car_model = 'Model S' AND height BETWEEN 65 AND 67

