
$version = (cat .\info.json | convertfrom-json ).version
$filename = "Miner_Planner_$version"
git archive --format zip --prefix "MinerPlanner_$version\" --output "$filename.zip" master -0

#somehow this zip is not compatible with factorio mod portal, so we unzip it here so it can be zipped by hand
expand-archive "$filename.zip" -destinationpath .\

rm "$filename.zip"


#this does not work either
#compress-archive -path "MinerPlanner_$version"  -destinationpath  "$filename.zip"

#rm -r "MinerPlanner_$version"