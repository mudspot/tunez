TIMESTAMP := $(shell date +"%Y%m%d%H%M%S")

stop:
	docker-compose down --remove-orphans

devdb: stop
	STAGE=dev docker-compose up --build -d

dbconnect:
	docker-compose exec db psql -h localhost -U postgres tunez_dev

dev:
	STAGE=dev iex -S mix phx.server

prod:
	MIX_ENV=prod iex -S mix phx.server

migrate:
	mix ash.migrate

rollback:
	mix ash.rollback

migration-reset: snapshot-reset
	git ls-files --others priv/repo/migrations | xargs rm

snapshot-reset:
	git ls-files --others priv/resource_snapshots | xargs rm
