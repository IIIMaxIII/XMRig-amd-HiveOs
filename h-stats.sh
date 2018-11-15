#!/usr/bin/env bash

#######################
# MAIN script body
#######################

[ -t 1 ] && . colors

. /hive/custom/xmrig-amd/h-manifest.conf

stats_raw=`curl --connect-timeout 2 --max-time $API_TIMEOUT --silent --noproxy '*' http://127.0.0.1:$WEB_PORT/api.json`
#echo $stats_raw | jq .
if [[ $? -ne 0 || -z $stats_raw ]]; then
	echo -e "${YELLOW}Failed to read $miner from localhost:${WEB_PORT}${NOCOLOR}"
else
	[[ -z $CUSTOM_ALGO ]] && CUSTOM_ALGO="cryptonight"

	khs=`echo $stats_raw | jq -r '.hashrate.total[0]' | awk '{print $1/1000}'`
	local hs_units="hs"
	local temp=$(jq '.temp' <<< $gpu_stats)
	local fan=$(jq '.fan' <<< $gpu_stats)
	local ac=$(jq '.results.shares_good' <<< "$stats_raw")
	local rj=$(( $(jq '.results.shares_total' <<< "$stats_raw") - $ac ))
	stats=$(jq --argjson temp "$temp" --argjson fan "$fan" --arg ac "$ac" --arg rj "$rj" --arg algo "$CUSTOM_ALGO" --arg hs_units "$hs_units"\
		'{hs: [.hashrate.threads[][0]], $algo, $temp, $fan, $hs_units, uptime: .connection.uptime, ar: [$ac, $rj]}' <<< "$stats_raw")
fi