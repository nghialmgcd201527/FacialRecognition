#!/bin/sh

DC_VERSION="latest"
DC_PROJECT=`jq -r ".name" package.json`

# Make sure we are using the latest version
docker pull public.ecr.aws/govtechsg/cicd-images:dependency-check-latest

docker run --rm \
    -e user=$USER \
    -u $(id -u ${USER}):$(id -g ${USER}) \
    --volume $(pwd):/src:z \
    --volume $(pwd)/odc-reports:/report:z \
    public.ecr.aws/govtechsg/cicd-images:dependency-check-latest \
    --scan /src \
    --format JUNIT \
    --format HTML \
    --format JSON \
    --nodeAuditSkipDevDependencies \
    --nodePackageSkipDevDependencies \
    --nvdValidForHours 24 \
    --failOnCVSS 7 \
    --junitFailOnCVSS 3 \
    --project "$DC_PROJECT" \
    --out /report
    # Use suppression like this: (where /src == $pwd)
    # --suppression "/src/security/dependency-check-suppression.xml"