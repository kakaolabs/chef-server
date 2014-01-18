pg_user "admin" do
  privileges superuser: true, createdb: true, login: true
  password "trilogy"
end

pg_user "kiennt" do
  privileges superuser: false, createdb: false, login: true
  password "HarryP0tter"
end

# create database for kakaolabs
pg_database "kakaolabs" do
  owner "kiennt"
  encoding "utf8"
  template "template0"
  locale "en_US.UTF8"
end

pg_database_extensions "kakaolabs" do
  extensions ["hstore"]
end

# create database for smscute
pg_database "smscute" do
  owner "kiennt"
  encoding "utf8"
  template "template0"
  locale "en_US.UTF8"
end

pg_database_extensions "smscute" do
  extensions ["hstore"]
end

