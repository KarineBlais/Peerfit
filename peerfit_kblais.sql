/*#1
Across all reservation partners for January & February, 
how many completed reservation occured?*/
SELECT Partners, Months, SUM(Completed_Reservations) AS Completed_Reservations
FROM (
SELECT 'Mindbody' AS Partners, month(checked_in_at) AS Months, COUNT(checked_in_at) AS Completed_Reservations
FROM mindbody_reservations
WHERE month(checked_in_at) = 1 OR month(checked_in_at) = 2
GROUP by Months
UNION
SELECT 'Clubready' AS Partners, month(signed_in_at) AS Months, COUNT(signed_in_at) AS Completed_Reservations
FROM clubready_reservations
WHERE month(signed_in_at) = 1 OR month(signed_in_at) = 2
GROUP BY Months) AS TABLE1
GROUP BY Partners, Months with ROLLUP;

/*#1 - Answer
135 reservations were completed in January and February. 
There were 97 reservations in January and 38 in February. 
Clubready had 68 and Mindbody 67 reservations in January and February.*/

/*#2
Which studio has the highest rate of reservation abandonment  
(did not cancel but did not check-in)?*/
SELECT studio_key AS Studio, (SELECT COUNT(checked_in_at) ) AS Completed, COUNT(*) AS Reserved, 
ROUND(100*(COUNT(*)-COUNT(Checked_in_at))/COUNT(*),2) AS Rate
FROM mindbody_reservations
GROUP BY studio_key
UNION 
SELECT studio_key AS Studio, (SELECT COUNT(signed_in_at) ) AS Completed, COUNT(*) AS Reserved, 
ROUND(100*(COUNT(*)-COUNT(signed_in_at))/COUNT(*),2) AS Rate
FROM clubready_reservations
GROUP BY studio_key
ORDER BY Rate DESC, Studio;

/*#2 - Answer
Using all combined 200 instances, flusing-crossfit had the highest rate of 
reservation abandonment with 60.00%.*/

/*#3
Which fitness area (i.e., tag) has the highest number of completed 
reservations for February*/
SELECT Fitness_Area, SUM(Completed) AS Completed
FROM(
SELECT class_tag AS Fitness_Area, COUNT(checked_in_at) AS Completed
FROM mindbody_reservations
WHERE month(checked_in_at) = 2
GROUP BY Fitness_Area
UNION 
SELECT class_tag AS Fitness_Area, COUNT(signed_in_at) AS Completed_
FROM clubready_reservations
WHERE month(signed_in_at) = 2
GROUP BY Fitness_Area
ORDER BY Completed DESC) AS Table2
GROUP BY Fitness_Area;

/*#3 - Answer
The fitness area with the highest number of completed reservations 
in February is yoga with 12.*/

/*#4
How many members completed at least 1 reservation and no more than 
1 cancelled reservation in January*/
SELECT COUNT(members) AS Total_Members
FROM(
SELECT member_id AS members, COUNT(month(checked_in_at)=1) AS Completed_Reservations 
FROM mindbody_reservations
GROUP BY member_id
HAVING COUNT(month(canceled_at)=1)<=1 AND COUNT(month(checked_in_at)=1)>=1
UNION
SELECT member_id AS members, COUNT(month(signed_in_at)=1) AS Completed_Reservations 
FROM clubready_reservations
GROUP BY member_id
HAVING COUNT(canceled)='t'<=1 AND COUNT(month(signed_in_at)=1)>=1
ORDER BY members) AS Table3;

/*#4 - Answer
36 members completed at least 1 reservation and no more than 1 cancelled 
reservation in January*/

/*#5
At what time of day do most users book classes? Attend classes?
(Morning =7-11 AM, Afternoon = 12-4 PM, Evening = 5-10 PM)*/

SELECT count(*) as Total,
SUM(case when hour(reserved_at)>= 7 and hour(reserved_at)<=11 then 1 else 0 end) Morning,
SUM(case when hour(reserved_at)>= 12 and hour(reserved_at)<=16 then 1 else 0 end) Afternoon,
SUM(case when hour(reserved_at)>= 17 and hour(reserved_at)<=22 then 1 else 0 end) Evening
FROM mindbody_reservations;

/*#5A - Answer 
Please note that the clubready_reservations table does not include a reserved_at field.
Most users from Mindbody booked classes during the evening. Using all 100 instances, 
Mindbody had a total of 53 in evening*/

SELECT SUM(Morning) AS Morning, SUM(Afternoon) AS Afternoon, SUM(Evening) AS Evening
FROM(
SELECT 
SUM(case when hour(checked_in_at)>= 7 and hour(checked_in_at)<=11 then 1 else 0 end) AS Morning,
SUM(case when hour(checked_in_at)>= 12 and hour(checked_in_at)<=16 then 1 else 0 end) AS Afternoon,
SUM(case when hour(checked_in_at)>= 17 and hour(checked_in_at)<=22 then 1 else 0 end) AS Evening
FROM mindbody_reservations
UNION
SELECT 
SUM(case when hour(signed_in_at)>= 7 and hour(signed_in_at)<=11 then 1 else 0 end) AS Morning,
SUM(case when hour(signed_in_at)>= 12 and hour(signed_in_at)<=16 then 1 else 0 end) AS Afternoon,
SUM(case when hour(signed_in_at)>= 17 and hour(signed_in_at)<=22 then 1 else 0 end) AS Evening
FROM clubready_reservations) AS Table4;

/*#5B - Answer 
Using all 200 instanes, most users attend classes during morning for a total of 122 classes.*/

/*#6
How many confirmed completed reservations did the member (ID) with 
the most reserved classes in February have*/

SELECT member_id AS members,
COUNT(checked_in_at) AS Completed_Reservations
FROM mindbody_reservations
WHERE month(reserved_at) = 2
GROUP BY member_id
ORDER BY Completed_Reservations DESC;

/*#6 - Answer 
The member with the most confirmed completed reservations in February 
is ID #6 (Mindbody) with 5 reservations.*/

/*#7
Write a query that unions the 'mindbody reservations' table
and clubready-reservations' table*/

SELECT 'Mindbody' AS partner, member_id, studio_key, studio_address_street, studio_address_city, 
studio_address_state, studio_address_zip, class_tag, NULL AS level, viewed_at, reserved_at, class_time_at,
canceled_at, NULL AS canceled, checked_in_at
FROM mindbody_reservations
UNION ALL
SELECT 'Clubready' AS partner, member_id, studio_key, NULL, NULL, NULL, NULL, class_tag, level, 
NULL, NULL, reserved_for, NULL, canceled, signed_in_at
FROM clubready_reservations

/*#7 - Notes
All the fields were combined in the new table*/

/*#8
What opportunities do you see to improve data storage and 
standardization for these datasets?*/

/*#9
What forecasting opportunities do you see with a dataset like this and why?*/

/*#10
What other data would you propose we gather to make reporting/forecasting more robust and why?*/
