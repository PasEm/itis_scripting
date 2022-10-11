declare -a numbers
declare -i current_step=1
declare -i total_missed=0
declare -i total_successful=0
isGameEnded=false
RED='\e[31m'
GREEN='\e[32m'
RESET='\e[0m'
while :
do
    my_number=$((RANDOM % 10))
    echo "Step ${current_step}"
    read -p "Please enter number from 0 to 9 (q - quit): " input
    case "${input}" in
        [0-9])
            if [[ "${input}" == "${my_number}" ]]
                then
                    echo "Hit! My number: ${my_number}"
                    total_successful+=1
                    number_string="${GREEN}${input}${RESET}"
                else
                    echo "Miss! My number: ${my_number}"
                    total_missed+=1
                    number_string="${RED}${input}${RESET}"
            fi
            numbers+=(${number_string})
            total=$(( total_successful + total_missed ))
            let hit_percent=total_successful*100/total
            let miss_percent=100-hit_percent
            echo "Hit: ${hit_percent}%" "Miss: ${miss_percent}%"
            if [[ ${#numbers[@]} -gt 10 ]]
                then
                    echo -e "Numbers: ${numbers[@]: -10}"
                else
                    echo -e "Numbers: ${numbers[@]}"
            fi
            current_step+=1
        ;;
        q)
            isGameEnded=true
        ;;
        *)
            echo "Not valid input. Repeat please"
        ;;
    esac
    if [[ "$isGameEnded" == true ]]
        then
            echo "The game ended"
            break
    fi
done