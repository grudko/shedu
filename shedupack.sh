#!/bin/bash
remote_cmd="./run.sh"
shedu_dir=""

while getopts ":c:" opt; do
  case $opt in
  c)
    remote_cmd=$OPTARG
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

shedu_dir=$1
shedu_basename=`basename $shedu_dir`

if [ "x$shedu_dir" == "x" ]; then
  echo "Usage: $0 [-c cmdline] shedu_directory"
  echo "-c cmdline : command to run in bundle directory, default: ./run.sh"
  exit 1
fi

current_dir=`pwd`
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

cd $shedu_dir/bundle
tar czf $scriptbundle_tmp/shedu.tar.gz ./*
cd $scriptbundle_tmp
cat runner.sh shedu.tar.gz > $current_dir/$shedu_basename.sh && \
    chmod +x $current_dir/$shedu_basename.sh
cd $current_dir
rm -rf $scriptbundle_tmp

