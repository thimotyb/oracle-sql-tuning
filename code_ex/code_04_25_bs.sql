--Use the hr schema to execute the given SQL statement 

SELECT v.last_name, v.first_name, l.state_province  
FROM locations l, emp_dept v 
WHERE l.state_province = 'California'  
AND   v.location_id = l.location_id (+);
