# Solution part 1
cat /c/Users/Fabien/Documents/rise-again/advent-of-code-2024/advent-3-input.txt \
    | grep -o -E 'mul\([0-9]{1,3},[0-9]{1,3}\)' \
    | sed 's/mul(//g' | sed 's/)//g' | awk -F , '{print $1 * $2}' \
    | awk '{x+=$0} END {print x}'

# Solution part 2
cat /c/Users/Fabien/Documents/rise-again/advent-of-code-2024/advent-3-input.txt \
    | tr -d '\n' | perl -pe "s/don't\(\).*?do\(\)//g" \
    | grep -o -E 'mul\([0-9]{1,3},[0-9]{1,3}\)' \
    | sed 's/mul(//g' | sed 's/)//g' | awk -F , '{print $1 * $2}' \
    | awk '{x+=$0} END {print x}'
