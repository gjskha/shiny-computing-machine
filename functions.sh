function archive_files() {
   bound=$1
   destdir=$2
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

function d2e() {
    # d2e date
    if [ ! -z $1 ]; then
        date -j -f "%a %b %d %T %Z %Y" "`$*`" "+%s"
    fi
}
