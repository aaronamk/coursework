#!/bin/sh
# script to find vulnerabilities in Android APKs


## ENFORCE COMMAND STRUCTURE
print_help() { printf "Usage: $0 -i <target_apk> -o <out_file>\n"; exit 1; }

# parse options
while getopts ':i:o:' OPTION; do
  case $OPTION in
    "i") target_apk="$OPTARG";;
    "o") out_file="$OPTARG";;
    :) printf "$0: Missing argument for option: $OPTARG\n"; print_help;;
    ?) printf "$0: Invalid option: $OPTARG\n"; print_help;;
  esac
done

# check that both variables are set
if [ -z "$target_apk" ] || [ -z "$out_file" ]; then
  printf "$0: Missing option\n"; print_help
fi


## SETUP
> "$out_file"
manifest="$target_apk/AndroidManifest.xml"

# find the .smali files (here's a little lesson in trickery)
package=$(sed -n 's/.*package=\"\(.*\)/\1/p' $manifest | cut -d "\"" -f 1)
smali_dir="$target_apk/smali/$(echo $package | tr '.' '/')"
smali_files=$(find "$smali_dir" | grep '\.smali' | grep -v '\$' | tr '\n' ' ')


## RUN TESTS
printf "HTTP vulnerabilities:\n" >> $out_file
grep -nr "http:\/\/" $smali_files >> $out_file

printf "\nAllow all hosts vulnerabilities:\n" >> $out_file
grep -nr "AllowAllHostnameVerifier" $smali_files >> $out_file
grep -nr "FakeHostnameVerifier" $smali_files >> $out_file

printf "\nOverride SSL error vulnerabilities:\n" >> $out_file
grep -nr "onReceivedSslError" $smali_files >> $out_file

printf "\nTrust all certificates vulnerabilities:\n" >> $out_file
grep -nr "checkClientTrusted" $smali_files >> $out_file
grep -nr "checkServerTrusted" $smali_files >> $out_file

printf "File written\n"

# cleanup
rm -rf $target_apk
