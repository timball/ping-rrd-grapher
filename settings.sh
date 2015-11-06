### EDIT THIS TO SUIT YOUR NEEDS. 

export PING_HOST=YOUR_HOST_HERE_IN_settings.sh
# this is to deal w/ the fact that 'g' prefixes OSX things

case $(uname -s) in
    Darwin)
        export gdate=/usr/local/bin/gdate
        export gawk=/usr/local/bin/gawk
        export rrdtool=/usr/local/bin/rrdtool
        ;;
    Linux)
        export gdate=date
        export gawk=gawk
        export rrdtool=rrdtool
        ;;
    *)
        echo "no soup for you"
        ;;
esac
