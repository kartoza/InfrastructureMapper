export PATH=${postgresWithPostGIS}/bin:$PATH          
export PGDATA="$PWD/pgdata"                           
export PGHOST="$PGDATA"                               
export PGPORT=5432                                    
                                                                 
if [ ! -d "$PGDATA/base" ]; then                      
  echo "🛠️ Initializing PostgreSQL cluster in $PGDATA"
  initdb -D "$PGDATA" --locale=C                      
fi                                                    

echo "🚀 Starting PostgreSQL..."                      
pg_ctl -D "$PGDATA" -o "-k $PGDATA -p $PGPORT" -w start > /dev/null                                                   
                                                                 
if ! test -f "$PGDATA/.postgis_setup_done"; then      
  createdb gis                                        
  psql -d gis -c "CREATE EXTENSION IF NOT EXISTS postgis;" > /dev/null                                                
  touch "$PGDATA/.postgis_setup_done"                 
  echo "📦 PostGIS extension created in 'gis' database."                                                              
fi                                                                 

