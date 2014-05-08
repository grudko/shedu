#!/bin/bash
remote_cmd="./run.sh"
bundle_dir=""
out_file=""

while getopts ":c:f:" opt; do
  case $opt in
  c)
    remote_cmd=$OPTARG
    ;;
  f)
    out_file=$OPTARG
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
  echo "Usage: $0 [-c cmdline] -f outfile bundle_directory"
  echo "-c cmdline : command to run in bundle directory, default: ./run.sh"
  echo "-f outfile : package filename"
  exit 1
fi

current_dir=`pwd`
out_file=`readlink -f $out_file`
scriptbundle_tmp=`mktemp -d /tmp/scriptbundle.XXXXXX`

cat >$scriptbundle_tmp/runner.sh << EOF
#!/bin/bash
export TMPDIR=\`mktemp -d /tmp/selfextract.XXXXXX\`
ARCHIVE=\`awk '/^__ARCHIVE_BELOW__/ {print NR + 1; exit 0; }' \$0\`
tail -n+\$ARCHIVE \$0 | tar xzv -C \$TMPDIR
CDIR=\`pwd\`
cd \$TMPDIR
$remote_cmd
cd \$CDIR
exit 0
__ARCHIVE_BELOW__
EOF

cd $bundle_dir
tar czf $scriptbundle_tmp/shedu.tar.gz ./*
cd $scriptbundle_tmp
cat runner.sh shedu.tar.gz > $out_file && \
    chmod +x $out_file
cd $current_dir
rm -rf $scriptbundle_tmp
