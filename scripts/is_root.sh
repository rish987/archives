roots=("src/rl_theory")
roots+=(`find src -type d \( -name "proof" -o -name "note" \) | xargs -i find "{}" -maxdepth 1 -mindepth 1 -type d`)

roots=(`realpath ${roots[@]}`)

if [[ " ${roots[@]} " =~ " $1 " ]]; then
    exit 0
fi
exit 1
