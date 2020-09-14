#!/usr/bin/env bash
set -euo pipefail

: "${CR_TOKEN:?Environment variable CR_TOKEN must be set}"
: "${CR_OWNER:?Environment variable CR_OWNER must be set}"
: "${CR_GIT_REPO:?Environment variable CR_GIT_REPO must be set}"
: "${CR_PACKAGE_PATH:?Environment variable CR_PACKAGE_PATH must be set}"
: "${CHARTS_REPO:?Environment variable CHARTS_REPO must be set}"

HELM_DOCS=jnorwood/helm-docs:latest
CHART_RELEASER=quay.io/helmpack/chart-releaser:latest

BUMP_TYPE=$1

bump() {
  local chart=$1
  local type=$BUMP_TYPE
  local version=$(yq read charts/$chart/Chart.yaml version)
  local base_list=(`echo $version | tr '.' ' '`)
  local major=${base_list[0]}
  local minor=${base_list[1]}
  local patch=${base_list[2]}
  case $type in
    "patch")
      patch=$((patch + 1))
      ;;
    "minor")
      minor=$((minor + 1))
      patch=0
      ;;
    "major")
      major=$((major + 1))
      minor=0
      patch=0
      ;;
    *)
      echo "Only 'major | minor | patch' supported"
      exit
      ;;
  esac
  yq write -i charts/$chart/Chart.yaml version "$major.$minor.$patch"
}

releaser() {
  docker run \
    --rm \
    -v "$(pwd):/workspace" \
    -w /workspace \
    -u $(id -u) \
    -e CR_TOKEN=$CR_TOKEN \
    -e CR_OWNER=$CR_OWNER \
    -e CR_GIT_REPO=$CR_GIT_REPO \
    -e CR_PACKAGE_PATH=$CR_PACKAGE_PATH \
    -e CHARTS_REPO=$CHARTS_REPO \
    $CHART_RELEASER sh -c "cr $1"
}

find_latest_tag() {
  if ! git describe --tags --abbrev=0 2> /dev/null; then
    git rev-list --max-parents=0 --first-parent HEAD
  fi
}

package_chart() {
  local chart="$1"
  helm dependency build "$chart"
  helm package "$chart" --destination $CR_PACKAGE_PATH
}

commit() {
  echo "Committing changes"
  git add --all
  git commit -m "repository updates"
  git push origin $1
}

echo "Updating chart docs"
docker run --rm -v "$(pwd):/helm-docs" -u $(id -u) $HELM_DOCS

if ! git diff --quiet; then
  commit "master"
else
  echo "No code changes. Nothing to commit"
  # exit
fi

latest_tag=$(find_latest_tag)
latest_tag_rev=$(git rev-parse --verify "$latest_tag")
echo "$latest_tag_rev $latest_tag (latest tag)"

head_rev=$(git rev-parse --verify HEAD)
echo "$head_rev HEAD"

if [[ "$latest_tag_rev" == "$head_rev" ]]; then
  echo "No code changes. Nothing to release."
  exit
fi

rm -rf $CR_PACKAGE_PATH
mkdir -p $CR_PACKAGE_PATH

echo "Identifying changed charts since tag '$latest_tag'..."

changed_charts=()
readarray -t changed_charts <<< "$(git diff --find-renames --name-only "$latest_tag_rev" -- charts | cut -d '/' -f 2 | uniq)"
if [[ -n "${changed_charts[*]}" ]]; then
  for chart in "${changed_charts[@]}"; do
    echo "Packaging chart '$chart'..."
    bump $chart
    package_chart "charts/$chart"
  done
fi

commit "master"
releaser "upload"

releaser "index -i $CR_PACKAGE_PATH/index.yaml -c $CHARTS_REPO"

for file in charts/*/*.md; do
  if [[ -e $file ]]; then
    mkdir -p "$CR_PACKAGE_PATH/docs/$(dirname "$file")"
    cp --force "$file" "$CR_PACKAGE_PATH/docs/$(dirname "$file")"
  fi
done

git checkout gh-pages

cp --force $CR_PACKAGE_PATH/index.yaml index.yaml

if [[ -e "$CR_PACKAGE_PATH/docs/charts" ]]; then
  mkdir -p docs
  cp --force --recursive $CR_PACKAGE_PATH/docs/charts/* docs/
fi

commit "gh-pages"
git checkout master