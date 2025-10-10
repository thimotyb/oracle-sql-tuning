--Connect as user sh in SQL Developer to run the statement


SELECT distinct week_ending_day week FROM times
WHERE week_ending_day BETWEEN TO_DATE('01-JUL-2001','dd-MON-yyyy') AND TO_DATE('16-JUL-2001','dd-MON-yyyy')
