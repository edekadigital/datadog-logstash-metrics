#!/bin/bash

set -eo pipefail

# this is a workaround from https://github.com/DataDog/datadog-agent/issues/2288#issuecomment-424290606 to attach host tags to metrics
# there is a feature request for the agent: https://github.com/DataDog/datadog-agent/issues/3159
if [[ -n "${ECS_FARGATE}" ]]; then
  taskid=$(curl -sf 169.254.170.2/v2/metadata | sed -r 's/^.*"TaskARN":".*:task\/([A-z0-9\-]+?)".*$/\1/')
  export DD_HOSTNAME="${taskid}"
fi

exec /init "${@}"