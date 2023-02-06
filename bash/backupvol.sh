#!/bin/bash

volumes=("mongo_data" "es_data" "graylog_journal" "prometheus_data" "grafana_data" "license" "tsdb_data")

for vol in "${volumes[@]}"
do
  
  docker run -v $vol:/volume -v /tmp:/backup alpine tar -cjf /backup/$vol.tar.bz2 -C /volume ./


done

# restore
# docker run --rm -v some_volume:/volume -v /tmp:/backup alpine sh -c "rm -rf /volume/* /volume/..?* /volume/.[!.]* ; tar -C /volume/ -xjf /backup/some_archive.tar.bz2"
