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

/*After reviewing the submitted tables (mindbody_reservations and clubready_reservations),
 I would propose to work with the partners to track and submit similar information among 
 them, which would improve consistency and comparability. For example, both tables are 
 storing similar information but use different field names. Is this the same information?
 I was able to deduct that check_in_at and signed_in_at fields were tracking the same 
 information however, for consistency I would suggest that every partners use the same 
 names for these fields:
 
	Checked_in_at vs. Signed_in_at
	Reserved_for vs. Class_time_at
	Canceled vs. Canceled_at

Also, although canceled and canceled_at fields are reporting similar information they are 
different type of attributes. Canceled is VARCHAR and canceled_at is DATETIME. I would 
suggest to request to track this variable as DATETIME to ensure that important information
is not lost. 

In addition, I found some inconsistencies in the datasets that would need to be addressed.

-	In the Mindbody table, ID 9,29,39,72 have a reserved_ at date > than class_time_at 
date. This can definitely skew the analysis and we should make sure that a member cannot 
reserve a class that was completed.

-	In the Clubready table, ID 8,35,47,58,85,97 had a “t” in the canceled field, but a 
signed_in_at date as well. The class should not be canceled and completed at the same 
time. I would propose to check if the reasoning behind the canceled field is correct.

Also, in the Mindbody table ID 28, 38, 46 are missing the studio_key information. To 
avoid missing data, I would suggest to force that all applicable fields are populated 
when the reservation is entered.

Lastly, I would propose that every partners track similar information and I would 
recommend to store the studio and class details in separated tables. 
	Studio Table
•	studio_address_street
•	studio_address_city
•	studio_address_state
•	studio_address_zip
	Class Table
•	instructor_full_name
•	level */

/*#9
What forecasting opportunities do you see with a dataset like this and why?*/

/*The mindbody table contains additional fields that are particularly relevant for forecasting. 
We can segment the reservation details by member_id, studio_key, address details, by date and time. 
We also have multiple date and time fields, such as the viewed date, reservation date, cancelation 
date, class date and checked date. These details give us a better understanding of each customer’s 
behavior and allow us to make better data-driven business decisions.

For example, the reservations are done on average 2.4 days before the class date and 0.7 days 
after viewing the information. 15% of all reservations (mostly Crossfit and Yoga) were cancelled 
on average within 2.1 days after they were reserved. In January and February, all cancelled classes 
were reserved during the evening (5-10pm) or morning (7-11pm) and were also scheduled during the 
evening and morning. Also, 17% of all reservations (mostly Crossfit and Yoga) were simply abandon. 
82% of all abandoned classes were reserved at night (10pm-6am). In brief, 68% of all reserved classes 
in January and February were checked in. The Pilate and Strength classes have the highest check-in 
rate with 83% and 82% respectively and Crossfit has the lowest with 45%. Also, classes reserved in 
RI have the highest check-in rate with 83% and NY has the lowest with 50%.

Overall, this information is very relevant for forecasting. For example, 2-3 days before 
classes, we can send automatic invites to customers that have not reserved knowing that 
most of our customers reserve 2.4 days before the class. We can also send different automatic 
reminders to our customers that reserved at night to increase the possibility they check in, 
knowing that 82% of our abandon were reserved at night. Also, knowing what the cancellation and 
abandon rates are allow us to forecast the completed reservations.*/

/*#10
What other data would you propose we gather to make reporting/forecasting more robust and why?*/

/*To improve reporting/forecasting, I would propose to gather additional customer information 
that would help us expand our understanding of our customers. I would suggest to track customer 
referrals. Are referrals good indicator of completed reservations? I would speculate that in the 
case that a customer was referred and reserved a class, there is a higher chance the customer will 
check in. Also, I would propose to track class review information. Knowing the review rate for each 
class would allow us to include this information in our model to forecast the completed reservations. 
Finally, it would be interesting to see what the complete reservation rate is by the duration of the 
class.
