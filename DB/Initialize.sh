echo "Executing data: initialize.sql"
psql -a  -U${POSTGRES_USER} -f scripts/initialize.sql

echo "Executing file: schema.sql"
psql -d scheduler -a  -U${POSTGRES_USER} -f scripts/schema.sql

for f in scripts/Data/*.sql
do
echo "Executing data file: $f"
psql -d scheduler -b -U${POSTGRES_USER} -f "$f"
done