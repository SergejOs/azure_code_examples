export SQLDBUSER='sqladminuser'
export SQLDBPASS='sqladminpassword'
export SQLSERVER='sqlservername'
export SQLDATABASE='master'
export ADUSERNAME='user.name@domain.onmicrosoft.com'

# -I Enable Quoted Identifiers

# -U -P : connect with username and password
sqlcmd -S ${SQLSERVER} -U ${SQLDBUSER} -P ${SQLDBPASS} -I 

# -d : specify database to connect to, if missing connect to user's default database
sqlcmd -S ${SQLSERVER} -d ${SQLDATABASE}-U ${SQLDBUSER} -P ${SQLDBPASS} -I 

# -G : use Azure Active Directory for authentication
sqlcmd -S ${SQLSERVER} -G -U ${ADUSERNAME} -I 

# -q "cmdline query"
# -Q "cmdline query" and exit
sqlcmd -S ${SQLSERVER} -G -U ${ADUSERNAME} -I  -Q "PRINT 'database='+ DB_NAME(); PRINT 'user=' + CURRENT_USER;"

