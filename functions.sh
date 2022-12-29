#!/usr/local/bin/bash

function archive_files() {
   bound=$1
   destdir=$2
   # this ls flag is a GNU thing.
   ls -l --time-style +%s | awk '{print $6" "$7}' | while read age name; do
       if [[ $age -lt $bound ]]; then
           if [ ! -d $destdir ]; then
               mkdir $destdir
               if [ $? -ne 0 ]; then
                   echo "Problem creating $destdir."
                   return
               fi
           fi
           echo "moving $name to $destdir"
           mv -i $name $destdir/.
           if [ $? -ne 0 ]; then
              echo "problem moving '$name' to $destdir/."
           fi
       fi
   done
}

# This is BSD stat
function get_mtime() {
    if [[ $# == 1 ]]; then
        stat -s $1 | awk '{print $10}' | awk -F= '{print $2}'
    else
        echo "usage: get_mtime [filename]"
	return 1
    fi
}

# This is BSD stat
function get_ctime() {
    if [[ $# == 1 ]]; then
        stat -s $1 | awk '{print $11}' | awk -F= '{print $2}'
    else
        echo "usage: get_ctime [filename]"
	return 1
    fi
}

# Takes a doublequoted string, e.g. "Dec 27 12:43:18 2022"
function d2e() {
    if [[ ! -z $1 ]]; then
	case $(uname) in
            OpenBSD)
	        date -f "$*" +%s
	    ;;
	    *)
                date -j -f "%a %b %d %T %Z %Y" "$*" "+%s";
	    ;;
        esac
    fi
}

# https://www.gnu.org/software/diffutils/manual/html_node/ed-Scripts.html
function diff_apply() {
    (cat $1 && echo w) | ed - $2
}

function permcalc () {

    if [[ $# != 1 ]]; then
        echo "Usage: permcalc [9 character string] (eg, r-srwxr--)"
        return 1
    fi

    if [[ $( echo $1 | wc -c ) != 10 ]]; then
        echo "Error : $0 file permission input must be 9 characters"
        return 1
    fi

    a=0
    b=0
    c=0
    d=0

    for i in 1 2 3 4 5 6 7 8 9; do
        perms[$i]=$(echo $1 | cut -c$i)
    done

    if [[ ${perms[1]} = "r" ]]; then
	a=$(( $a + 4 ))
    fi

    if [[ ${perms[2]} = "w" ]]; then
	a=$(( $a + 2 ))
    fi

    if [[ ${perms[3]} = "x" ]]; then
	a=$(( $a + 1 ))
    fi

    if [[ ${perms[3]} = "S" ]]; then
	d=$(( $d + 4 ))
    fi

    if [[ ${perms[3]} = "s" ]]; then
	a=$(( $a + 1 ))
	d=$(( $d + 4 ))
    fi

    if [[ ${perms[4]} = "r" ]]; then
	b=$(( $b + 4 ))
    fi

    if [[ ${perms[5]} = "w" ]]; then
	b=$(( $b + 2 ))
    fi

    if [[ ${perms[6]} = "x" ]]; then
	b=$(( $b + 1 ))
    fi

    if [[ ${perms[6]} = "S" ]]; then
	d=$(( $d + 2 ))
    fi

    if [[ ${perms[6]} = "s" ]]; then
	b=$(( $b + 1 ))
	d=$(( $d + 2 ))
    fi

    if [[ ${perms[7]} = "r" ]]; then
        c=$(( $c + 4 ))
    fi

    if [[ ${perms[8]} = "w" ]]; then
	c=$(( $c + 2 ))
    fi

    if [[ ${perms[9]} = "x" ]]; then
	c=$(( $c + 1 ))
    fi

    if [[ ${perms[9]} = "t" ]]; then
	d=$(( $d + 1 ))
    fi

    if [[ $d = 0 ]]; then
        echo "$a$b$c"
    else
        echo "$d$a$b$c"
    fi
}
