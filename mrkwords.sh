#!/bin/sh

# choose the first argument as the model file or try to open '.mrkdb'
file="${1:-~/.mrkdb}"

# $n is the maximum number of remaining words (iterations)
# it is the 2nd argument of this program
n="${2:-1}"

# if present, use $key (3rd argument) to find pairs starting
# with it in the model, you may use this to force a
# word as the first word of the message
key="$3"

# if $key is set print it
[ -n "$key" ] && echo "$key"

# the max remaining number of words cannot be equal or less to 0
[ "$n" -le 0 ] && exit

# if key is not set, set the chosen word to the first element
# of a random pair in the model
if [ -z "$key" ]; then
  word=$(shuf -n 1 < "$file" | cut -d' ' -f1)

# otherwise (key is set)
else
    # step 1, filter the model to find lines containing $key
    # step 2, use awk to get only the lines in the model
    # beginning with $key (the first element of the pairs)
    # step 3, after filtering out the model, pick the second element of
    # a random pair and set it as the value of the variable $word
  word=$(grep -Fw -- "$key" < "$file" |
    awk -v key="$key" '$1 == key { print $2 }' |
    shuf -n 1) || exit

    # if $word is empty then exit this iteration
    # this may also mean that the randomized step picked
    # a line in the model containing only the first element
    # (signaling the end of the process)
  [ -z "$word" ] && exit
fi

# the real magic happens here. this last step is similar
# to a recursive function call in most programming languages
# it runs this program again, with $n decremented by 1
# and with the chosen $word as the next iteration's $key
exec "$0" "$file" "$(( n - 1 ))" "$word"

