--Use the hr schema to execute the SQL statement in SQL Developer

variable low_sal number;
variable high_sal number;
SELECT count(*) FROM hr.employees where salary between :low_sal and :high_sal;
