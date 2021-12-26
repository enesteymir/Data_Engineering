/* 

--------------------SOME TERMINOLOGY ABOUT DATABASE---------------------------

Relational Databases : Data is stored in relations based on relational model developed by E.F Codd in 1970
OLTP (Online Transaction Processing) :  Used to handle current data that is being entered and changed
OLAP (Online Analytical Processing) : Primarily used for analysis of data that is not being changed or used real time
Tuples = Rows
Attribute = Field = Column ; In PostgreSQL, Fields are referred as columns
Views : Virtual tables that use fields from base tables
Domain = Field Specifications ; General ( name, description,parent table), 
								Physical (data type, length, display format),
								Logical ( required values, range of values, default values )								
Data Tables : Normal tables with records that change frequently
Validation Tables : also called lookup tables, static values
Linking Tables / Associative Tables : Used to create many-to-many relationships.Kind of key table between two main tables.
									  Especially when it is forbidden to make many to many relationships such as Tabular Model (SSAS)									  									  
Data Integrity : Used to refer to the validity (Geçerlilik), consistency (Tutarlilik), and accuracy (dogruluk) of data in a database
				 There are 4 levels of data integrity
				 1- Table (Entity) Level; no duplicated rows and a good primary key
				 2- Field (Domain) Level; structures of fields solid, values are accurate, same type field are defined the same
				 3- Relationship (Referential) Level; Relationships between tables are sound
				 4- Business Rules; requirements for business are enforced		
ER Diagram : Entity Relationship Diagram

------------------------TYPES OF FIELDS IN BAD DESIGN-----------------------

 	1- Multipart Field : such as Full Name
 	2- Multivalued Field : such as Company has more than one phone number
 	3- Clculated Field : such as Quantity*Unit Price


-------------------------DATABASE DESIGN PROCESSES------------------------

 	1- Define mission statement and objectives : Purpose of database, list of tasks people do using the database
 	2- Analyze current database and workflow   : Looking for information being used in company to run operations, paper forms, Talk employees and managers
 	3- Create the data structure			   : Define tables, fields, primary keys, field specifications
 	4- Create table relationships			   : Which tavles are related?, Establish foreign keys
 	5- Handle business rules				   : Find company rules about business works, Managers have visibilty into general rules, Employees into individual areas. Functions, Triggers, Constraints
 	6- Define views							   : Learn who should see what info or uses certain info consistently, Create views to support
 	7- Review data integrity				   : Do tables fields, relationships, business rules have integrity?
 	

------------------------- NORMALIZATION---------------------------------------

1- Eliminating duplicate/redundant data
2- Breaking large tables into smaller ones
3- Making sure that inserting / updating / deleting data doesn't  cause problems


							  
									  
									  
									  
									  
									  
									  
									  
									  
									  

*/

