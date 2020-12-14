#!/bin/bash


cat .env.k8 | grep = | sort | sed -e 's|REACT_APP_\([a-zA-Z_]*\)=\(.*\)|REACT_APP_\1=NGINX_REPLACE_\1|' > .env.local
npm run build > build.log
cat build.log  | grep -E 'error|Error|fail|failed|Failed' && { echo \"Build failed\"; exit 2; } || { echo \"Build passed\"; }
export NGINX_SUB_FILTER="$(cat .env.k8 | grep '=' | sort | sed -e 's/REACT_APP_\([a-zA-Z_]*\)=\(.*\)/sub_filter\ \"NGINX_REPLACE_\1\" \"$\{\1\}\";/')"
# export NGINX_SUB_FILTER="$(cat .env.k8 | grep '=' | sort | sed -e 's/REACT_APP_\([a-zA-Z_]*\)=\(.*\)/sub_filter\ \"NGINX_REPLACE_\1\" \"\$\$\{\1\}\";/')"
echo $NGINX_SUB_FILTER
cat nginx.sample.conf | sed -e "s|LOCATION_SUB_FILTER|$(echo $NGINX_SUB_FILTER)|" | sed 's|}";\n |}";\n\t\t|g' > nginx.conf
echo "Successfully created Build!"
