#!/bin/bash
########## Run cron job as: ##################
### Run at 2:30 am every month, every day, every week
# 30 2 * * * /home/ubuntu/logstash/curator_cron.sh &> /dev/null
##############################################
 
# Fast return
## Logstash
/usr/local/bin/curator -l /var/log/curator/curator.log delete --older-than 15
/usr/local/bin/curator -l /var/log/curator/curator.log close --older-than 14 
/usr/local/bin/curator -l /var/log/curator/curator.log bloom --older-than 1 
/usr/local/bin/curator -l /var/log/curator/curator.log snapshot --delete-older-than 15 --repository Repo-One
 

# Slow return
## Logstash
/usr/local/bin/curator -l /var/log/curator/curator.log optimize --older-than 1 --max_num_segments 1 
/usr/local/bin/curator -l /var/log/curator/curator.log snapshot --older-than 2 --repository Untergeek
