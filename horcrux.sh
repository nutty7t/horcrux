#!/usr/bin/env nix-shell
#!nix-shell -i bash -p ssss steghide --pure

set -eE

cat <<- "EOF"
                   .

                    .
          /^\     .
     /\   "V"
    /__\   I      O  o
   //..\\  I     .
   \].`[/  I                     █
   /l\/j\  (]    .  O            █
  /. ~~ ,\/I          .          ███  ███  ███  ███  ███  █ █  █ █
  \\L__j^\/I       o             █ █  █ █  █    █    █    █ █   █
   \/--v}  I     o   .           █ █  ███  █    ███  █    ███  █ █
   |    |  I   _________
   |    |  I c(`       ')o     ────────────────────────────────────╴
   |    l  I   \.     ,/                ダークアートの秘密
 _/j  L l\_!  _//^---^\\_      ────────────────────────────────────╴

EOF

split_soul () {
	echo "splitting the soul (∩｀-´)⊃━☆ﾟ.*・｡ﾟ"
	echo -n "reciting the magical incantation..."
	read -s password
	echo

	cp -r fragments horcrux
	mapfile -t containers < <(find horcrux -type f)
	mapfile -t fragments < <(ssss-split -t 3 -n ${#containers[@]} <soul | grep '^[0-9]*-.*$')

	for i in $(seq 0 $((${#containers[@]} - 1))); do
		echo "${fragments[i]}" > fragment
		steghide embed -cf ${containers[i]} -ef fragment -p "${password}"
		rm fragment
	done

	echo "done"
}

reconstruct_soul () {
	echo "reconstructing the soul ଘ(੭*ˊᵕˋ)੭*"
	echo -n "reciting the magical incantation..."
	read -s password
	export password
	echo

	rm -f fragment
	rm -f fragments.tmp && touch fragments.tmp
	find horcrux -type f | xargs -I{} sh -c 'steghide extract -sf {} -p "${password}"; cat fragment >>fragments.tmp; rm fragment'
	ssss-combine -t 3 <fragments.tmp 2>&1 >/dev/null | grep 'secret' | sed 's/Resulting secret: \(.*\)/\1/' >soul
	rm fragments.tmp

	echo "done"
}

cleanup () {
	rm -f fragments.tmp
	rm -f fragment
}

trap cleanup SIGINT SIGTERM ERR

if [ ! -d "horcrux" ]; then
	if [ ! -d "fragments" ]; then
		echo "error: unable to find the fragments"
		exit 1
	else
		if [ ! -f "soul" ]; then
			echo "error: unable to find the soul"
			exit 1
		else
			split_soul
			exit 0
		fi
	fi
else
	if [ ! -f "soul" ]; then
		reconstruct_soul
		exit 0
	fi
	echo "nothing to do"
fi
