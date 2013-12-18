#!/bin/bash
# plg.sh - Propus Letterhead Generator
#
# Gera um documento ODT com o formato padrão do Papel Timbrado da Propus

VERSION="0.1"
PLG_GENERATOR="Propus Letterhead Generator v$VERSION"
PLG_DATE=`date +%Y-%m-%dT%H:%M:%S`
PLG_INITIALCREATOR="Propus Informática Ltda"
templatefile="template.odt"
tmpdir=`mktemp -d --tmpdir=/tmp plg.XXXXXXXX`
MYPWD=$PWD

# Propus Tag
tag_DATA=`date --utc +%Y:%j:%H:%M`
tag_YEAR=`echo $tag_DATA|cut -f1 -d:`
tag_DAY_OF_YEAR=`echo $tag_DATA|cut -f2 -d:`
tag_HOUR=`echo $tag_DATA|cut -f3 -d:`
tag_MINUTE=`echo $tag_DATA|cut -f4 -d:`
tag_MINUTES_OF_DAY=$(((tag_HOUR * 60) + tag_MINUTE))
PLG_TAGNUM=`printf '%4d-%03X-%03X' $tag_YEAR $tag_DAY_OF_YEAR $tag_MINUTES_OF_DAY`

show_help() {
    echo "plg.sh version $VERSION"
    echo "Generates a new Letterhead ODT document"
    echo "Usage: plg.sh [OPTION]"
    echo "       -h/-?          This help"
    echo "       -p             Add private message to the footer"
    echo "                      [Default: no private message]"
    echo "       -d             Add draft message to the footer"
    echo "                      [Default: no draft message]"
    echo "       -c CREATOR     Sets the Creator Tag to CREATOR value"
    echo "                      [Default: \"$PLG_INITIALCREATOR\"]"
    echo "       -t TITLE       Sets the title of the document to TITLE value"
    echo "                      [Default: \"$PLG_TITLE1\"]"
    echo "       -s SUBTITLE    Same, but with SUBTITLE"
    echo "                      [Default: \"$PLG_TITLE2\"]"
    echo "       -g TAGNUM      Sets the Propus Tag"
    echo "                      [If ommitted, generates a new one]"
}

# getopts
OPTIND=1
PLG_CREATOR=$PLG_INITIALCREATOR
PLG_TITLE1="Papel Timbrado Propus"
PLG_TITLE2=""
private=0 # Pública = 0; Privada = 1
private_msg="- - - Documento restrito à Diretoria. Não deve ser publicado ou compartilhado - - -"
PLG_PRIVATEMSG=""
draft=0 # Minuta = 1; Quente = 0
draft_msg="- - - ATENÇÃO: Este documento é uma MINUTA - - -"
PLG_DRAFTMSG=""
tablerow="<table:table-row><table:table-cell table:style-name=\"Table1.A1\" table:number-columns-spanned=\"2\" office:value-type=\"string\"><text:p text:style-name=\"MP5\">%s<\/text:p><\/table:table-cell><table:covered-table-cell\/><\/table:table-row>"

while getopts "h?pdc:t:s:g:" opt; do
    case "$opt" in
    h|\?)
        show_help
        exit 0
        ;;
    p)  private=1
        PLG_PRIVATEMSG=`printf "$tablerow" "$private_msg"`
        #PLG_PRIVATEMSG=$private_msg
        ;;
    d)  draft=1
        PLG_DRAFTMSG=`printf "$tablerow" "$draft_msg"`
        #PLG_DRAFTMSG=$draft_msg
        ;;
    c)  PLG_CREATOR=`printf '%.50s' $OPTARG`
        ;;
    t)  PLG_TITLE1=`printf '%.30s' $OPTARG`
        ;;
    s)  PLG_TITLE2=`printf '%.30s' $OPTARG`
        ;;
    g)  PLG_TAGNUM=`printf '%.12s' $OPTARG`
        ;;
    esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

# sets outputfile
outputfile=${PLG_TAGNUM}_-_novo_documento.odt

# Unzip the template
cp $templatefile $tmpdir
cd $tmpdir
unzip $templatefile
rm -f $templatefile

# Replace all the tags
sed -e "s/PLG_CREATOR/$PLG_CREATOR/" \
    -e "s/PLG_TITLE1/$PLG_TITLE1/" \
    -e "s/PLG_INITIALCREATOR/$PLG_INITIALCREATOR/" \
    -e "s/PLG_DATE/$PLG_DATE/" \
    -e "s/PLG_CREATIONDATE/$PLG_DATE/" \
    -e "s/PLG_GENERATOR/$PLG_GENERATOR/" meta.xml > meta.xml.1

sed -e "s/PLG_TITLE1/$PLG_TITLE1/" \
    -e "s/PLG_TITLE2/$PLG_TITLE2/" \
    -e "s/PLG_TAGNUM/$PLG_TAGNUM/" \
    -e "s/PLG_PRIVATEMSG/$PLG_PRIVATEMSG/" \
    -e "s/PLG_DRAFTMSG/$PLG_DRAFTMSG/" styles.xml > styles.xml.1

# Rename modified files
mv meta.xml.1 meta.xml
mv styles.xml.1 styles.xml

# Zip the files back
zip -r $MYPWD/$outputfile *

# Cleanup
cd $MYPWD
rm -rf $tmpdir

# vim:fileencoding=utf8:encoding=utf8
