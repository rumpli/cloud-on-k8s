#!/bin/bash -eu

ROOT="$(cd "$(dirname "$0")"; pwd)/../.."

GH_TOKEN=$(vault kv get --field=github-token-snyk.io secret/ci/elastic-cloud-on-k8s/service-account-eckmachine)
git remote add upstream "https://eckmachine:$GH_TOKEN@github.com/elastic/cloud-on-k8s.git"
git config user.name  eckmachine
git config user.email eckmachine@elastic.co

sync() {
    local task="$@"
    echo -- "$task"
    $task
    git add -u && git commit -m "$cmd" || true 
}

# cd $ROOT
# sync echo make generate

# cd $ROOT/hack/helm/release
# sync go mod tidy

git switch -c $BUILDKITE_BRANCH

date > date.txt
git add date.txt && git commit -m "test"

git push upstream
