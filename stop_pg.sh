PGDATA=$PWD/pgdata \
PGPORT=5432 \
pg_ctl -D "$PGDATA" -o "-k $PGDATA -p $PGPORT" stop -m fast

