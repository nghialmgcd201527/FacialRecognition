# #!/bin/sh

# DC_VERSION="latest"
# DC_PROJECT=`jq -r ".name" package.json`

# # Make sure we are using the latest version
# docker pull public.ecr.aws/govtechsg/cicd-images:dependency-check-latest

# docker run --rm \
#     -e user=$USER \
#     -u $(id -u ${USER}):$(id -g ${USER}) \
#     --volume $(pwd):/src:z \
#     --volume $(pwd)/odc-reports:/report:z \
#     public.ecr.aws/govtechsg/cicd-images:dependency-check-latest \
#     --scan /src \
#     --format JUNIT \
#     --format HTML \
#     --format JSON \
#     --nodeAuditSkipDevDependencies \
#     --nodePackageSkipDevDependencies \
#     --nvdValidForHours 24 \
#     --failOnCVSS 7 \
#     --junitFailOnCVSS 3 \
#     --project "$DC_PROJECT" \
#     --out /report
#     # Use suppression like this: (where /src == $pwd)
#     # --suppression "/src/security/dependency-check-suppression.xml"

#!/bin/sh

DC_VERSION="latest"
DC_DIRECTORY=$HOME/OWASP-Dependency-Check
DC_PROJECT="dependency-check scan: $(pwd)"
DATA_DIRECTORY="$DC_DIRECTORY/data"
CACHE_DIRECTORY="$DC_DIRECTORY/data/cache"

# Make sure we are using the latest version
docker pull owasp/dependency-check:$DC_VERSION

docker run --rm \
    -e user=$USER \
    -u $(id -u ${USER}):$(id -g ${USER}) \
    --nvdApiKey 66a986ca-b5fd-4aab-bb0b-c9e5f10edf7c \
    --volume $(pwd):/src:z \
    --volume "$DATA_DIRECTORY":/usr/share/dependency-check/data:z \
    --volume $(pwd)/odc-reports:/report:z \
    owasp/dependency-check:$DC_VERSION \
    --scan /src \
    --format "ALL" \
    --project "$DC_PROJECT" \
    --out /report
    # Use suppression like this: (where /src == $pwd)
    # --suppression "/src/security/dependency-check-suppression.xml"