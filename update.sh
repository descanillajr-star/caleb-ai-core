#!/bin/bash
cd /opt/caleb_ai_core
git pull
systemctl restart caleb-ai
crontab -e
0 3 * * * /opt/caleb_ai_core/update.sh
