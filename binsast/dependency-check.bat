@echo off

set DC_VERSION="latest"
SET DC_PROJECT="dependency-check scan: %CD%"

rem Make sure we are using the latest version
docker pull public.ecr.aws/govtechsg/cicd-images:dependency-check-latest

docker run --rm ^
    --volume %CD%:/src ^
    --volume %CD%/odc-reports:/report ^
    public.ecr.aws/govtechsg/cicd-images:dependency-check-latest ^
    --scan /src ^
    --format JUNIT ^
    --format HTML ^
    --nodeAuditSkipDevDependencies ^
    --nodePackageSkipDevDependencies ^
    --nvdValidForHours 24 ^
    --failOnCVSS 7 ^
    --junitFailOnCVSS 3 ^
    --project "$DC_PROJECT" ^
    --out /report
    rem Use suppression like this: (where /src == %CD%)
    rem --suppression "/src/security/dependency-check-suppression.xml"