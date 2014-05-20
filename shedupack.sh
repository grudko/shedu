#!/bin/bash
remote_cmd="./run.sh"
out_file=""
unpack_dir=""
bundle_dir=""

while getopts ":c:f:d:" opt; do
  case $opt in
  c)
    remote_cmd=$OPTARG
    ;;
  f)
    out_file=$OPTARG
    ;;
  d)
    unpack_dir=$OPTARG
    ;;
  \?)
    echo "Invalid option: -$OPTARG" >&2
    exit 1
    ;;
  :)
    echo "Option -$OPTARG requires an argument" >&2
    exit 1
    ;;
  esac
done
shift $(($OPTIND - 1))

bundle_dir=$1

if [ "x$bundle_dir" == "x" ] || [ "x$out_file" == "x" ]; then
  echo "Usage: $0 [-c cmdline] [-d unpack_dir] -f outfile bundle_directory"
  echo "-c cmdline    : command to run in bundle directory, default: ./run.sh"
  echo "-u unpack_dir : directory to extract bundle, default: /tmp/selfextract.XXXXXX"
  echo "-f outfile    : package filename"
  exit 1
fi

current_dir=`pwd`
out_file=`readlink -f $out_file`
scriptbundle_tmp=`mktemp -d /tmp/scriptbundle.XXXXXX`

echo "#!/bin/bash" >$scriptbundle_tmp/header.sh

if [ "x$unpack_dir" == "x" ]; then
  echo "export EXTRACTDIR=\`mktemp -d /tmp/selfextract.XXXXXX\`" >>$scriptbundle_tmp/header.sh
else
  echo "export EXTRACTDIR=$unpack_dir; mkdir -p \$EXTRACTDIR;" >>$scriptbundle_tmp/header.sh
fi

echo "base64 -d <<ENDOFPACKAGE|tar zx -C \$EXTRACTDIR && cd \$EXTRACTDIR && $remote_cmd" >>$scriptbundle_tmp/header.sh
echo "ENDOFPACKAGE" >>$scriptbundle_tmp/footer.sh

cd $bundle_dir
tar czf -  ./* |base64 > $scriptbundle_tmp/payload.base64
cd $scriptbundle_tmp
cat header.sh payload.base64 footer.sh > $out_file && \
    chmod +x $out_file
cd $current_dir
rm -rf $scriptbundle_tmp
