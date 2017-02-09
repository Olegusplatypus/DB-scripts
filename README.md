# DB-scripts
Here I am going to share some not trivial DB scripts that can help other developers

script for pattern change.sql - what it is about?

Recently on my job I faced necessity to change a big amount of URLs in Postgres DB, that was related with changing storage addresses of some pictures.
I am Java developer, and as usual I write only simple CRUD scripts in DB, so I tried to monitor all web resources, and found nothing to help me solve my problen directly, so I decided to improve my PSQL and made it by my self.
So, I had different schemas in DB, different tables and columns, the real pictures  stored in 5 different URLs, and needed to be moved in single URL. The data type in columns were of few types: text, varchar and text arrays.
By the way, the largest problem for me was in changing parts of matching array elements.
That was realy hot.
So if you have similar task, just take this script, enter info about schema,tables,columns as in example, also patterns that needs to be changed and new pattern. 
Also you can rework it to your purposes, since Im am not PSQL PRO level specialist.
