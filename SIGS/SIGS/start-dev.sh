#!/bin/bash

function_db_ready() {
ruby << END
require './config/environment.rb'
begin
  ActiveRecord::Base.establish_connection
  ActiveRecord::Base.connection
  exit 0 if ActiveRecord::Base.connected?
  exit -1 unless ActiveRecord::Base.connected?
rescue
  exit -1
end
END
}

until function_db_ready; do
  >&2 echo "DATABASE IS UNAVAILABLE, SLEEP"
  sleep 1
done

echo "DATABASE IS UP, CONTINUE"

bundle check || bundle install

bundle exec rake db:create
bundle exec rake db:migrate
bundle exec rake db:seed

pidfile='/SIGS-MES/tmp/pids/server.pid'

if [ -f $pidfile ]; then
	echo 'Server PID file already exists. Removing it...'
	rm $pidfile
fi

bundle exec rails s -p 3000 -b 0.0.0.0
