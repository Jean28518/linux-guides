# Postgresql server
We will install it on ubuntu server

```bash
sudo apt install postgresql 

# Change localhost to ip adress (needed, if docker containers want to connect)
# Also remove the '#' from #password_encryption = scram-sha-256
vim /etc/postgresql/14/main/postgresql.conf
listen_addresses = '192.168.178.84'
password_encryption = scram-sha-256

sudo systemctl restart postgresql
```

## Add user and database:
In this case we add a user called nocodb.
```bash
#sudo -u postgres createuser -P -d USERNAME
sudo -u postgres createuser -P -d nocodb

#sudo -u postgres createdb -O USERNAME DATABASE 
sudo -u postgres createdb -O nocodb nocodb 


# Set Authentication
vim /etc/postgresql/14/main/pg_hba.conf
# Change here the ip adress subnet from which connections are allowd
# To allow all change it to 0.0.0.0/0
host    nocodb          nocodb          192.168.178.0/24        scram-sha-256
# For access from docker:
# The best way is to add the specific ip adress of the docker container (docker inspect CONTAINER ID)
host    nocodb          nocodb          172.22.0.3/24           scram-sha-256 

sudo systemctl restart postgresql
```

## Connection issues?
- Check the port in the postgresql.conf and the connecting application. These can slightly differ!!! The standard port in ubuntu postgresql is 5433.
- Is SSL enabled? In this setup no ssl is used.